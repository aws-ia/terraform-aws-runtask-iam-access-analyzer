terraform {
  cloud {
    organization = "wellsiau-org"
    workspaces {
      name = "aws-ia2-Test-Workspace"
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

# Create S3 bucket with bucket prefix prod
