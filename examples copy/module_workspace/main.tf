data "aws_region" "current" {
}

module "runtask_iam_access_analyzer" {
  source           = "../../" # set your Terraform Cloud workspace with Local execution mode to allow module reference like this
  tfc_org          = var.tfc_org
  aws_region       = data.aws_region.current.name
  workspace_prefix = var.workspace_prefix
  deploy_waf       = true
}
