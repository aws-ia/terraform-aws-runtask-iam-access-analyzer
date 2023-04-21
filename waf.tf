resource "aws_wafv2_web_acl" "runtask_waf" {
  count    = local.waf_deployment
  provider = aws.cloudfront_waf

  name        = "${var.name_prefix}-runtask_waf_acl"
  description = "Run Task WAF with simple rate base rules"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-base-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = local.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-runtask_request_rate"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.waf_managed_rule_set
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor_name
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name_prefix}-runtask_request_${rule.value.metric_suffix}"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-runtask_waf_acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudwatch_log_group" "runtask_waf" {
  count             = local.waf_deployment
  provider          = aws.cloudfront_waf
  name              = "aws-waf-logs-${var.name_prefix}-runtask_waf_acl"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.runtask_waf[count.index].arn
}

resource "aws_wafv2_web_acl_logging_configuration" "runtask_waf" {
  count                   = local.waf_deployment
  provider                = aws.cloudfront_waf
  log_destination_configs = [aws_cloudwatch_log_group.runtask_waf[count.index].arn]
  resource_arn            = aws_wafv2_web_acl.runtask_waf[count.index].arn
  redacted_fields {
    single_header {
      name = "x-tfc-task-signature"
    }
  }
}