'''
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'''
import json
import logging
import os
import boto3
import time
import yaml
import re
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from enum import Enum
from collections import Counter

session = boto3.Session()
ia2_client = session.client('accessanalyzer')
cwl_client = session.client('logs')
logger = logging.getLogger()

iamConfigMap = {} # map of terraform plan attribute and IAM access analyzer resource type, loaded from default.yaml

if "log_level" in os.environ:
    logger.setLevel(os.environ["log_level"])
    logger.info("Log level set to %s" % logger.getEffectiveLevel())
else:
    logger.setLevel(logging.INFO)

if "SUPPORTED_POLICY_DOCUMENT" in os.environ:
    SUPPORTED_POLICY_DOCUMENT = os.environ["SUPPORTED_POLICY_DOCUMENT"]
else:
    SUPPORTED_POLICY_DOCUMENT = False # default to False and then load it from config file default.yaml

if "TFC_HOST_NAME" in os.environ:
    TFC_HOST_NAME = os.environ["TFC_HOST_NAME"]
else:
    TFC_HOST_NAME = "app.terraform.io"

IAM_ACCESS_ANALYZER_COUNTER = {
    "ERROR" : 0,
    "SECURITY_WARNING" : 0,
    "SUGGESTION" : 0,
    "WARNING" : 0
}

if "CW_LOG_GROUP_NAME" in os.environ:
    LOG_GROUP_NAME = os.environ["CW_LOG_GROUP_NAME"]
    LOG_STREAM_NAME = ""
    SEQUENCE_TOKEN = "" # nosec B105
else: # disable logging if environment variable is not set
    LOG_GROUP_NAME = False

def lambda_handler(event, context):
    logger.debug(json.dumps(event))
    try:
        if not iamConfigMap: load_config("default.yaml") # load the config file

        # Get plan output from Terraform Cloud
        endpoint = event["payload"]["detail"]["plan_json_api_url"]
        access_token = event["payload"]["detail"]["access_token"]
        headers = __build_standard_headers(access_token)
        response, response_raw = __get(endpoint, headers)
        json_response = json.loads(response.decode("utf-8"))
        logger.debug("Headers : {}".format(response_raw.headers))
        logger.debug("JSON Response : {}".format(json.dumps(json_response)))

        # Get workspace and run task metadata
        run_id = event["payload"]["detail"]["run_id"]
        workspace_id = event["payload"]["detail"]["workspace_id"]
        
        # Initialize log
        global LOG_STREAM_NAME
        LOG_STREAM_NAME = workspace_id + "_" + run_id
        log_helper(LOG_GROUP_NAME, LOG_STREAM_NAME, 
            "Start IAM Access Analyzer analysis for workspace: {} - run: {}".format(workspace_id, run_id)
        )
        
        if get_plan_changes(json_response): # Check if there are any changes in plan output
            logger.info("Resource changes detected")
            total_ia2_violation_count = ia2_handler(json_response["resource_changes"]) # analyze and calculate number of violations
            fulfillment_response = fulfillment_response_helper(total_ia2_violation_count, skip_log = False) # generate response
        else:
            logger.info("No resource changes detected")
            fulfillment_response = fulfillment_response_helper(total_ia2_violation_count = {}, skip_log = True, override_message = "No resource changes detected", overrise_status = "passed") # override response
        
        return fulfillment_response
  
    except Exception as e: # run-task must return response despite of exception
        logger.exception("Run Task Fulfillment error: {}".format(e))
        fulfillment_response = fulfillment_response_helper(total_ia2_violation_count = {}, skip_log = True, override_message = "Run Task IAM Access Analyzer failed to complete successfully", override_status = "failed") # override response
        return fulfillment_response

def get_plan_changes(plan_payload):
    if "resource_changes" in plan_payload:
        return True
    else:
        return False

# IAM Access Analyzer handler:
# Search for resource changes in Terraform plan that match the supported resource
# Map the right Terraform plan attribute according to resource type to find the policy value
# Analyze the policy using IAM Access Analyzer
# Calculate the number of findings per policy, per resource and total all resources
def ia2_handler(plan_resource_changes):
    total_ia2_violation_count = IAM_ACCESS_ANALYZER_COUNTER

    for resource in plan_resource_changes: # look for resource changes and match the supported policy document
        if resource["type"] in SUPPORTED_POLICY_DOCUMENT:
            logger.info("Resource : {}".format(json.dumps(resource)))
            ia2_violation_count = analyze_resource_policy_changes(resource) # get the policy difference per resource
            if ia2_violation_count: # calculate total violation count 
                total_ia2_violation_count = iam_policy_violation_counter_helper(total_ia2_violation_count, ia2_violation_count)
        else:
            logger.info("Resource type : {} is not supported".format(resource["type"]))
    
    return total_ia2_violation_count

def analyze_resource_policy_changes(resource): # parse terraform plan to find the policy changes and validate it with IAM Access analyzer
    if "create" in resource["change"]["actions"]: # skip any deleted resources
        resource_violation_counter = IAM_ACCESS_ANALYZER_COUNTER
        resource_config_map = get_resource_type_and_attribute(resource) # look up from config map to find the right attribute and resource type

        for item in resource_config_map: # certain resource type have two attributes (i.e. iam role assume policy and in-line policy)
            # check for nested attribute , i.e. for aws_iam_role : inline_policy.policy
            if "." in item["attribute"]: 
                item_attribute, item_sub_attribute = item["attribute"].split(".")
            else:
                item_attribute = item["attribute"]
                item_sub_attribute = False
            item_type = item["type"]
            logger.info("Policy type : {}".format(item_type))

            if item_attribute in resource["change"]["after"]: # ensure that the policy is available in plan output
                resource_policies = get_resource_policy(item_attribute, item_sub_attribute, resource)
                per_item_violation_counter = IAM_ACCESS_ANALYZER_COUNTER

                for policy in resource_policies: # resource like iam_role can include multiple in-line policies     
                    iam_policy = json.loads(policy) # take the new changed policy document
                    logger.info("Policy : {}".format(json.dumps(iam_policy)))

                    ia2_response = validate_policy(json.dumps(iam_policy), item_type) # run IAM Access analyzer validation
                    logger.info("Response : {}".format(ia2_response["findings"]))

                    per_policy_violation_counter = get_iam_policy_violation_count(resource, ia2_response) # calculate any IA2 violations
                    per_item_violation_counter = iam_policy_violation_counter_helper(per_item_violation_counter, per_policy_violation_counter) # sum all findings per resource item
                
                resource_violation_counter = iam_policy_violation_counter_helper(resource_violation_counter, per_item_violation_counter) # sum all findings per resource

            elif item_attribute in resource["change"]["after_unknown"] and resource["change"]["after_unknown"][item_attribute] == True: # missing computed values is not supported
                logger.info("Unsupported resource due to missing computed values")
                log_helper(LOG_GROUP_NAME, LOG_STREAM_NAME, "resource: {} - unsupported resource due to missing computed values" .format(resource["address"]))

        return resource_violation_counter

    elif "delete" in resource["change"]["actions"]:
        logger.info("New policy is null / deleted")
        log_helper(LOG_GROUP_NAME, LOG_STREAM_NAME, "resource: {} - policy is null / deleted" .format(resource["address"]))
    
    else:
        logger.error("Unknown / unsupported action")
        raise

def get_resource_type_and_attribute(resource): # look up resource type and terraform plan attribute name from config file    
    if isinstance(iamConfigMap[resource["type"]], list):
        return iamConfigMap[resource["type"]]
    else:
        return [iamConfigMap[resource["type"]]] # return it as list

def get_resource_policy(attribute, sub_attribute, resource): # extract the resource policy, including nested policies
    resource_policies = []

    if not sub_attribute: # standard non-nested attribute
        resource_policies.append(resource["change"]["after"][attribute])

    else: # nested attribute
        # convert all nested attribute into list for easy comparison
        if isinstance (resource["change"]["after"][attribute], list): 
            sub_attribute_policies = resource["change"]["after"][attribute]
        else:
            sub_attribute_policies = [resource["change"]["after"][attribute]]
        
        for item in sub_attribute_policies: # resource like iam_role can include multiple in-line policies
            if sub_attribute in item.keys():
                resource_policies.append(item[sub_attribute])

    return resource_policies

def get_iam_policy_violation_count(resource, ia2_response): # count the policy violation and return a dictionary
    ia2_violation_count = {
        "ERROR" : 0,
        "SECURITY_WARNING" : 0,
        "SUGGESTION" : 0,
        "WARNING" : 0
    }

    if len(ia2_response["findings"]) > 0: # calculate violation if there's any findings
        for finding in ia2_response["findings"]:
            ia2_violation_count[finding["findingType"]] += 1 
            log_helper(LOG_GROUP_NAME, LOG_STREAM_NAME, "resource: {} ".format(resource["address"]) + json.dumps(finding))
    else:
        log_helper(LOG_GROUP_NAME, LOG_STREAM_NAME, "resource: {} - no new findings".format(resource["address"]) )
    
    logger.info("Findings : {}".format(ia2_violation_count))
    return ia2_violation_count

def iam_policy_violation_counter_helper(total_ia2_violation_count, ia2_violation_count): # add new violation to existing counter
    total_counter = Counter(total_ia2_violation_count)
    total_counter.update(Counter(ia2_violation_count))
    total_ia2_violation_count = dict(total_counter)
    return total_ia2_violation_count

def validate_policy(policy_document, policy_type): # call IAM access analyzer to validate policy
    response = ia2_client.validate_policy(
        policyDocument=policy_document,
        policyType=policy_type
    )
    return response

def log_helper(log_group_name, log_stream_name, log_message): # helper function to write RunTask results to dedicated cloudwatch log group
    if log_group_name: # true if CW log group name is specified
        global SEQUENCE_TOKEN
        try:
            SEQUENCE_TOKEN = log_writer(log_group_name, log_stream_name, log_message, SEQUENCE_TOKEN)["nextSequenceToken"]
        except:
            cwl_client.create_log_stream(logGroupName = log_group_name,logStreamName = log_stream_name)
            SEQUENCE_TOKEN = log_writer(log_group_name, log_stream_name, log_message)["nextSequenceToken"]

def log_writer(log_group_name, log_stream_name, log_message, sequence_token = False): # writer to CloudWatch log stream based on sequence token
    if sequence_token: # if token exist, append to the previous token stream
        response = cwl_client.put_log_events(
            logGroupName = log_group_name,
            logStreamName = log_stream_name,
            logEvents = [{
                'timestamp' : int(round(time.time() * 1000)),
                'message' : time.strftime('%Y-%m-%d %H:%M:%S') + ": " + log_message
            }],
            sequenceToken = sequence_token
        )
    else: # new log stream, no token exist
        response = cwl_client.put_log_events(
            logGroupName = log_group_name,
            logStreamName = log_stream_name,
            logEvents = [{
                'timestamp' : int(round(time.time() * 1000)),
                'message' : time.strftime('%Y-%m-%d %H:%M:%S') + ": " + log_message
            }]
        )
    return response

def fulfillment_response_helper(total_ia2_violation_count, skip_log = False, override_message = False, override_status = False): # helper function to send response to callback step function
    runtask_response = {} # run tasks call back includes three attribute: status, message and url

    # Return message
    if not override_message:
        fulfillment_output = "{} ERROR, {} SECURITY_WARNING, {} SUGGESTION, {} WARNING".format(
            total_ia2_violation_count["ERROR"], total_ia2_violation_count["SECURITY_WARNING"], total_ia2_violation_count["SUGGESTION"], total_ia2_violation_count["WARNING"])
    else:
        fulfillment_output = override_message
    logger.info("Summary : " + fulfillment_output)
    runtask_response["message"] = fulfillment_output

    # Hyperlink to CloudWatch log
    if not skip_log:
        if LOG_GROUP_NAME:
            fulfillment_logs_link = "https://console.aws.amazon.com/cloudwatch/home?region={}#logEventViewer:group={};stream={}".format(os.environ["AWS_REGION"], LOG_GROUP_NAME, LOG_STREAM_NAME)
        else:
            fulfillment_logs_link = "https://console.aws.amazon.com"
        logger.info("Logs : " + fulfillment_logs_link)
    else:
        fulfillment_logs_link = False
    runtask_response["url"] = fulfillment_logs_link

    # Run Tasks status
    if not override_status:
        if total_ia2_violation_count["ERROR"] + total_ia2_violation_count["SECURITY_WARNING"] > 0:
            fulfillment_status = "failed"
        else:
            fulfillment_status = "passed"
    else:
        fulfillment_status = override_status
    logger.info("Status : " + fulfillment_status)
    runtask_response["status"] = fulfillment_status
    
    return runtask_response

def __build_standard_headers(api_token): # TFC API header
    return {
        "Authorization": "Bearer {}".format(api_token),
        "Content-type": "application/vnd.api+json",
    }
    
def __get(endpoint, headers): # HTTP request helper function
    request = Request(endpoint, headers=headers or {}, method = "GET")
    try:
        if validate_endpoint(endpoint):
            with urlopen(request, timeout=10) as response: #nosec URL validation 
                return response.read(), response
        else:
            raise URLError("Invalid endpoint URL, expected host is: {}".format(TFC_HOST_NAME))
    except HTTPError as error:
        logger.error(error.status, error.reason)
    except URLError as error:
        logger.error(error.reason)
    except TimeoutError:
        logger.error("Request timed out")

def validate_endpoint(endpoint): # validate that the endpoint hostname is valid
    pattern = "^https:\/\/" + str(TFC_HOST_NAME).replace(".", "\.") + "\/"+ ".*"    
    result = re.match(pattern, endpoint)
    return result

def load_config(file_name): # load the config file
    global iamConfigMap
    global SUPPORTED_POLICY_DOCUMENT
    
    with open(file_name, "r") as config_stream:
        config_dict = yaml.safe_load(config_stream)

    iamConfigMap = config_dict.get("iamConfigMap") # load the config map
    logger.debug("Config map loaded: {}".format(json.dumps(iamConfigMap)))

    if not SUPPORTED_POLICY_DOCUMENT: # load the supported resource if there's no override from environment variables
        SUPPORTED_POLICY_DOCUMENT = list(iamConfigMap.keys()) 