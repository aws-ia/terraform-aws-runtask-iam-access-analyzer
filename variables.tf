variable "name_prefix" {
  description = "Name to be used on all the resources as identifier."
  type        = string
  default     = "aws-ia2"
}

variable "event_bus_name" {
  description = "EventBridge event bus name"
  type        = string
  default     = "default"
}

variable "cloudwatch_log_group_name" {
  description = "RunTask CloudWatch log group name"
  type        = string
  default     = "/hashicorp/terraform/runtask/iam-access-analyzer/"
}

variable "cloudwatch_log_group_retention" {
  description = "Lambda CloudWatch log group retention period"
  type        = string
  default     = "365"
  validation {
    condition     = contains(["1", "3", "5", "7", "14", "30", "60", "90", "120", "150", "180", "365", "400", "545", "731", "1827", "3653", "0"], var.cloudwatch_log_group_retention)
    error_message = "Valid values for var: cloudwatch_log_group_retention are (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0)."
  }
}

variable "event_source" {
  description = "EventBridge source name"
  type        = string
  default     = "app.terraform.io"
}

variable "runtask_stages" {
  description = "List of all supported RunTask stages"
  type        = list(string)
  default     = ["pre_plan", "post_plan", "pre_apply"]
}

variable "tfc_org" {
  description = "Terraform Organization name"
  type        = string
}

variable "workspace_prefix" {
  description = "TFC workspace name prefix that allowed to run this runtask"
  type        = string
  default     = ""
}

variable "supported_policy_document" {
  description = "(Optional) allow list of the supported IAM policy document"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "The region from which this module will be executed."
  type        = string
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d", var.aws_region))
    error_message = "Variable var: region is not valid."
  }
}

variable "recovery_window" {
  description = "Numbers of day Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 0
  validation {
    condition     = (var.recovery_window >= 0 && var.recovery_window <= 30)
    error_message = "Variable var: recovery_window must be between 0 and 30"
  }
}

variable "lambda_reserved_concurrency" {
  description = "Maximum Lambda reserved concurrency, make sure your AWS quota is sufficient"
  type        = number
  default     = 100
}

variable "lambda_default_timeout" {
  description = "Lambda default timeout in seconds"
  type        = number
  default     = 30
}

variable "deploy_waf" {
  description = "Set to true to deploy CloudFront and WAF in front of the Lambda function URL"
  type        = string
  default     = false
  validation {
    condition     = contains(["true", "false"], var.deploy_waf)
    error_message = "Valid values for var: deploy_waf are true, false"
  }
}

variable "waf_rate_limit" {
  description = "Rate limit for request coming to WAF"
  type        = number
  default     = 100
}

variable "waf_managed_rule_set" {
  description = "List of AWS Managed rules to use inside the WAF ACL"
  type        = list(map(string))
  default = [
    {
      name          = "AWSManagedRulesCommonRuleSet"
      priority      = 10
      vendor_name   = "AWS"
      metric_suffix = "common"
    },
    {
      name          = "AWSManagedRulesKnownBadInputsRuleSet"
      priority      = 20
      vendor_name   = "AWS"
      metric_suffix = "bad_input"
    }
  ]
}

variable "tags" {
  description = "Map of tags to apply to resources deployed by this solution."
  type        = map(any)
  default     = null
}

variable "lambda_architecture" {
  description = "Lambda architecture (arm64 or x86_64)"
  type        = string
  default     = "x86_64"
  validation {
    condition     = contains(["arm64", "x86_64"], var.lambda_architecture)
    error_message = "Valid values for var: lambda_architecture are arm64 or x86_64"
  }
}