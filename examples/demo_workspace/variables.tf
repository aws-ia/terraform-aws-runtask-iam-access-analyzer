variable "flag_attach_runtask" {
  description = "Switch this flag to true to attach the run task to the workspace"
  type        = bool
  default     = false
}

variable "flag_deploy_invalid_resource" {
  description = "Switch this flag to true to deploy sample invalid IAM policy and validate it with Run Task"
  type        = bool
  default     = false
}

variable "runtask_enforcement_level" {
  type        = string
  description = "The description give to the attached run task (optional)"
  default     = "mandatory"
}

variable "runtask_stage" {
  type        = string
  description = "The description give to the attached run task (optional)"
  default     = "post_plan"
}

variable "runtask_id" {
  type        = string
  description = "The run task id of the IAM Access Analyzer run task"
}

variable "tfc_org" {
  description = "Terraform Organization name"
  type        = string
}

variable "aws_region" {
  description = "The region from which this module will be executed."
  type        = string
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d", var.aws_region))
    error_message = "Variable var: region is not valid."
  }
}

variable "demo_workspace_name" {
  type        = string
  description = "The workspace name"
}
