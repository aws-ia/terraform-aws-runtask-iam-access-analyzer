terraform {

  cloud {
    # TODO: Change this to your HCP Terraform org name.
    organization = "wellsiau-org"

    # OPTIONAL: Change the workspace name
    workspaces {
      name = "AWS-Runtask-IAM-Access-Analyzer-Demo"
    }
  }

  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.72.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.38.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
