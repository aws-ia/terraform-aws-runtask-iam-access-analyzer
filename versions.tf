terraform {
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

    time = {
      source  = "hashicorp/time"
      version = ">=0.12.0"
    }
  }
}