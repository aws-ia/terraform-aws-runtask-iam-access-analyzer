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
