## NOTES: run after setup
# attach and validate that the runtasks logic runs properly
terraform {
  cloud {
    organization = "wellsiau-org"
    workspaces {
      name = "aws-ia2-Demo-Workspace"
    }
  }

  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.73.0, < 5.0.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.38.0"
    }
  }
}

data "tfe_organization" "org" {
  name = var.tfc_org
}

data "tfe_workspace" "workspace" {
  name         = var.demo_workspace_name
  organization = data.tfe_organization.org.name
}

data "aws_region" "current_region" {}

data "aws_caller_identity" "current_account" {}

data "aws_partition" "current_partition" {}


# ==========================================================================
# ATTACH RUN TASKS
# ==========================================================================

resource "tfe_workspace_run_task" "aws-iam-analyzer-attach" {
  count             = var.flag_attach_runtask ? 1 : 0
  workspace_id      = data.tfe_workspace.workspace.id
  task_id           = var.runtask_id
  enforcement_level = var.runtask_enforcement_level
  stage             = var.runtask_stage
}

# ==========================================================================
# SIMPLE IAM POLICY WITH INVALID PERMISSION
# ==========================================================================

resource "aws_iam_policy" "policy_with_eof" {
  # the sample policy below contains invalid iam permissions (syntax-wise)
  count  = var.flag_deploy_invalid_resource ? 1 : 0
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DuplicateSid",
      "Action": [
        "logs:CreateLogGroups"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Sid": "DuplicateSid",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}