locals {
  solution_prefix = "${var.name_prefix}-${random_string.solution_prefix.result}"

  lambda_managed_policies     = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn]
  lambda_reserved_concurrency = var.lambda_reserved_concurrency
  lambda_default_timeout      = var.lambda_default_timeout
  lambda_python_runtime       = "python3.11"
  lambda_architecture         = [var.lambda_architecture]

  cloudwatch_log_group_name = var.cloudwatch_log_group_name

  waf_deployment = var.deploy_waf ? 1 : 0
  waf_rate_limit = var.waf_rate_limit

  cloudfront_sig_name = "x-cf-sig"
  cloudfront_custom_header = {
    name  = local.cloudfront_sig_name
    value = var.deploy_waf ? aws_secretsmanager_secret_version.runtask_cloudfront[0].secret_string : null
  }

  combined_tags = merge(
    var.tags,
    {
      Solution = local.solution_prefix
    }
  )

}

resource "random_string" "solution_prefix" {
  length  = 4
  special = false
  upper   = false
}
