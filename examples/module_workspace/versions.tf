terraform {
  cloud {
    # TODO: Change this to your HCP Terraform org name.
    organization = "wellsiau-org"
    workspaces {
      name = "TestExamplesLaunchModule"
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

    random = {
      source  = "hashicorp/random"
      version = ">=3.4.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~>2.2.0"
    }
  }
}