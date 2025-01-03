output "runtask_hmac" {
  value       = aws_secretsmanager_secret_version.runtask_hmac.secret_string
  description = "HMAC key value, keep this sensitive data safe"
  sensitive   = true
}

output "runtask_url" {
  value       = var.deploy_waf ? "https://${module.runtask_cloudfront[0].cloudfront_distribution_domain_name}" : trim(aws_lambda_function_url.runtask_eventbridge.function_url, "/")
  description = "The Run Tasks URL endpoint, you can use this to configure the Run Task setup in HCP Terraform"
}

output "runtask_id" {
  value       = tfe_organization_run_task.aws_iam_analyzer.id
  description = "The Run Tasks id configured in HCP Terraform"
}