data "aws_region" "current_region" {}

data "aws_region" "cloudfront_region" {
  provider = aws.cloudfront_waf
}

data "aws_caller_identity" "current_account" {}

data "aws_partition" "current_partition" {}

data "aws_iam_policy" "aws_lambda_basic_execution_role" {
  name = "AWSLambdaBasicExecutionRole"
}

data "archive_file" "runtask_eventbridge" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/runtask_eventbridge/site-packages/"
  output_path = "${path.module}/lambda/runtask_eventbridge.zip"
}

data "archive_file" "runtask_request" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/runtask_request/site-packages/"
  output_path = "${path.module}/lambda/runtask_request.zip"
}

data "archive_file" "runtask_fulfillment" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/runtask_fulfillment/site-packages/"
  output_path = "${path.module}/lambda/runtask_fulfillment.zip"
}

data "archive_file" "runtask_callback" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/runtask_callback/site-packages"
  output_path = "${path.module}/lambda/runtask_callback.zip"
}

data "archive_file" "runtask_edge" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/runtask_edge/site-packages"
  output_path = "${path.module}/lambda/runtask_edge.zip"
}


data "aws_iam_policy_document" "runtask_key" {
  #checkov:skip=CKV_AWS_109:Skip
  #checkov:skip=CKV_AWS_111:Skip
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current_partition.id}:iam::${data.aws_caller_identity.current_account.account_id}:root"
      ]
    }
  }
  statement {
    sid    = "Allow Service CloudWatchLogGroup"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:Describe",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current_region.name}.amazonaws.com"
      ]
    }
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:/aws/lambda/${var.name_prefix}*",
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:/aws/state/${var.name_prefix}*",
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:/aws/vendedlogs/states/${var.name_prefix}*",
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:${var.cloudwatch_log_group_name}*"
      ]
    }
  }
  statement {
    sid    = "Allow Service Secrets Manager"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:Describe"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.runtask_eventbridge.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.${data.aws_region.current_region.name}.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = [
        data.aws_caller_identity.current_account.account_id
      ]
    }
  }
}

data "aws_iam_policy_document" "runtask_waf" {
  #checkov:skip=CKV_AWS_109:Skip
  #checkov:skip=CKV_AWS_111:Skip
  count    = local.waf_deployment
  provider = aws.cloudfront_waf
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current_partition.id}:iam::${data.aws_caller_identity.current_account.account_id}:root"
      ]
    }
  }
  statement {
    sid    = "Allow Service CloudWatchLogGroup"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:Describe",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.cloudfront_region.name}.amazonaws.com"
      ]
    }
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.cloudfront_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:aws-waf-logs-${var.name_prefix}-runtask_waf_acl*"
      ]
    }
  }
}