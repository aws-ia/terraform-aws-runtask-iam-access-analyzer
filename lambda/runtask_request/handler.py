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
from time import sleep

if "TFC_ORG" in os.environ:
    TFC_ORG = os.environ["TFC_ORG"]
else:
    TFC_ORG = False

if "WORKSPACE_PREFIX" in os.environ:
    WORKSPACE_PREFIX = os.environ["WORKSPACE_PREFIX"]
else:
    WORKSPACE_PREFIX = False

if "RUNTASK_STAGES" in os.environ:
    RUNTASK_STAGES = os.environ["RUNTASK_STAGES"]
else:
    RUNTASK_STAGES = False

logger = logging.getLogger()
if 'log_level' in os.environ:
    logger.setLevel(os.environ['log_level'])
    logger.info("Log level set to %s" % logger.getEffectiveLevel())
else:
    logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.debug(json.dumps(event))
    try:
        VERIFY = True
        if event["payload"]["detail-type"] == "hashicorp-tfc-runtask":
            if TFC_ORG and event["payload"]["detail"]["organization_name"] != TFC_ORG:
                logger.error("TFC Org verification failed : {}".format(event["payload"]["detail"]["organization_name"]))
                VERIFY = False
            if WORKSPACE_PREFIX and not (str(event["payload"]["detail"]["workspace_name"]).startswith(WORKSPACE_PREFIX)):
                logger.error("TFC workspace prefix verification failed : {}".format(event["payload"]["detail"]["workspace_name"]))
                VERIFY = False
            if RUNTASK_STAGES and not (event["payload"]["detail"]["stage"] in RUNTASK_STAGES):
                logger.error("TFC Runtask stage verification failed: {}".format(event["payload"]["detail"]["stage"]))
                VERIFY = False

        if VERIFY:
            return "verified"
        else:
            return "unverified"
        
    except Exception as e:
        logger.exception("Run Task Request error: {}".format(e))
        raise
