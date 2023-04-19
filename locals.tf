locals {
  lambda_managed_policies     = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn]
  lambda_reserved_concurrency = var.lambda_reserved_concurrency
  lambda_default_timeout      = var.lambda_default_timeout
  lambda_python_runtime       = "python3.9"

  cloudwatch_log_group_name = var.cloudwatch_log_group_name

  waf_deployment = var.deploy_waf ? 1 : 0
  waf_rate_limit = var.waf_rate_limit

  cloudfront_sig_name = "x-cf-sig"
  cloudfront_custom_header = {
    name  = local.cloudfront_sig_name
    value = var.deploy_waf ? aws_secretsmanager_secret_version.runtask_cloudfront[0].secret_string : null
  }
}