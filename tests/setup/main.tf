## NOTES: run first to deploy the module
# outputs the runtasks id to be used on the next run
terraform {
  cloud {
    organization = "wellsiau-org"
    workspaces {
      name = "aws-ia2-Module-Workspace"
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

    random = {
      source  = "hashicorp/random"
      version = ">=3.4.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~>2.2.0"
    }

    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

data "aws_region" "current" {
}

data "http" "runtask_url" {
  url    = module.runtask_iam_access_analyzer.runtask_url
  method = "HEAD"
}

module "runtask_iam_access_analyzer" {
  source           = "../../" # set your Terraform Cloud workspace with Local execution mode to allow module reference like this
  tfc_org          = var.tfc_org
  aws_region       = data.aws_region.current.name
  workspace_prefix = var.workspace_prefix
  deploy_waf       = false
}

output "runtask_id" {
  value = module.runtask_iam_access_analyzer.runtask_id
}
