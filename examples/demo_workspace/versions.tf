terraform {

  cloud {
    # TODO: Change this to your HCP Terraform org name.
    organization = "my-sample-org"
    workspaces {
      tags = ["app:aws-access-analyzer-demo"]
    }
  }

  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = ">= 3.73.0, < 5.0.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.38.0"
    }
  }
}
