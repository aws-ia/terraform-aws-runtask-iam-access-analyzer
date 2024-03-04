## NOTES: run after we try to validate Run Task result
# this will inspect the workspace to find total runs and errors
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
