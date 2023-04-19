resource "tfe_organization_run_task" "aws_iam_analyzer" {
  organization = var.tfc_org
  url          = var.deploy_waf ? "https://${module.runtask_cloudfront[0].cloudfront_distribution_domain_name}" : trim(aws_lambda_function_url.runtask_eventbridge.function_url, "/")
  name         = "${var.name_prefix}-runtask"
  enabled      = true
  hmac_key     = aws_secretsmanager_secret_version.runtask_hmac.secret_string
  description  = "Run Task integration with AWS IAM Access Analyzer"
  depends_on   = [aws_lambda_function.runtask_eventbridge] # explicit dependency for URL verification
}
