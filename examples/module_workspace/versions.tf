terraform {
  cloud {
    # TODO: Change this to your Terraform Cloud org name.
    organization = "wellsiau-org"
    workspaces {
      name = "runtasks"
    }
  }

  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = " 5.0.0"
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
  }
}

