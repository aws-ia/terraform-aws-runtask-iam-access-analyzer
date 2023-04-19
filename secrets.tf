resource "random_uuid" "runtask_hmac" {}

resource "aws_secretsmanager_secret" "runtask_hmac" {
  name                    = "${var.name_prefix}-runtask-hmac"
  recovery_window_in_days = var.recovery_window
  kms_key_id              = aws_kms_key.runtask_key.arn
}

resource "aws_secretsmanager_secret_version" "runtask_hmac" {
  secret_id     = aws_secretsmanager_secret.runtask_hmac.id
  secret_string = random_uuid.runtask_hmac.result
}

resource "random_uuid" "runtask_cloudfront" {
  count = local.waf_deployment
}

resource "aws_secretsmanager_secret" "runtask_cloudfront" {
  count                   = local.waf_deployment
  name                    = "${var.name_prefix}-runtask_cloudfront"
  recovery_window_in_days = var.recovery_window
  kms_key_id              = aws_kms_key.runtask_key.arn
}

resource "aws_secretsmanager_secret_version" "runtask_cloudfront" {
  count         = local.waf_deployment
  secret_id     = aws_secretsmanager_secret.runtask_cloudfront[count.index].id
  secret_string = random_uuid.runtask_cloudfront[count.index].result
}