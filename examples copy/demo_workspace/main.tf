# ==========================================================================
# ATTACH RUN TASKS
# ==========================================================================

resource "tfe_workspace_run_task" "aws-iam-analyzer-attach" {
  count             = var.flag_attach_runtask ? 1 : 0
  workspace_id      = data.tfe_workspace.workspace.id
  task_id           = var.runtask_id
  enforcement_level = var.runtask_enforcement_level
  stage             = var.runtask_stage
}

# ==========================================================================
# SIMPLE IAM POLICY WITH INVALID PERMISSION
# ==========================================================================

resource "aws_iam_policy" "policy_with_eof" {
  # the sample policy below contains invalid iam permissions (syntax-wise)
  count  = var.flag_deploy_invalid_resource ? 1 : 0
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DuplicateSid",
      "Action": [
        "logs:CreateLogGroups"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Sid": "DuplicateSid",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# ==========================================================================
# USING IAM POLICY DOCUMENT DATA SOURCE WITH WRONG PERMISSION
# ==========================================================================

data "aws_iam_policy_document" "policy_with_data_source" {
  count = var.flag_deploy_invalid_resource ? 1 : 0

  statement {
    sid = "InvalidGetBucketLocation"
    actions = [
      "s3:GetMyBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_policy" "policy_with_data_source" {
  count  = var.flag_deploy_invalid_resource ? 1 : 0
  policy = data.aws_iam_policy_document.policy_with_data_source[count.index].json
}

# ==========================================================================
# IAM ROLE WITH POLICY TEMPLATE FILE
# ==========================================================================

resource "aws_iam_role" "invalid_assume_role" {
  count              = var.flag_deploy_invalid_resource ? 1 : 0
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/invalid-trust.tpl", { none = "none" })
  inline_policy {
    name = "inline_policy_with_invalid_version"

    policy = jsonencode({
      Version = "2022-10-17"
      Statement = [
        {
          Action   = ["ec2:Describe*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name = "inline_policy_with_invalid_effect"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ec2:Describe*"]
          Effect   = "Permit"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role_policy" "invalid_iam_role_policy" {
  count = var.flag_deploy_invalid_resource ? 1 : 0
  role  = aws_iam_role.invalid_assume_role[count.index].id
  policy = templatefile("${path.module}/iam/role-policies/invalid-iam-role-policy.tpl", {
    aws_region     = "us-east-0" # trigger invalid ARN region
    aws_account_id = "123456789012"
    aws_partition  = "aws-gov-cloud" # trigger invalid partition
    aws_service    = "events"
    name_prefix    = "test"
  })
}

# ==========================================================================
# KMS WITH INVALID POLICY
# ==========================================================================

data "aws_iam_policy_document" "invalid_kms_key_policy" {
  count = var.flag_deploy_invalid_resource ? 1 : 0

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*"
    ]
    resources = ["*"]

    principals {
      type = "AWSAccount"
      identifiers = [
        "arn:${data.aws_partition.current_partition.id}:iam::${data.aws_caller_identity.current_account.account_id}:root"
      ]
    }
  }
}

resource "aws_kms_key" "invalid_kms_key_policy" {
  count  = var.flag_deploy_invalid_resource ? 1 : 0
  policy = data.aws_iam_policy_document.invalid_kms_key_policy[count.index].json
}

# ==========================================================================
# SCP WITH INVALID POLICY
# ==========================================================================

resource "aws_organizations_policy" "invalid_scp_policy" {
  count = var.flag_deploy_invalid_resource ? 1 : 0

  name    = "test_invalid_scp_policy"
  content = <<CONTENT
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "iam:*role",
    "Resource": "*"
  }
}
CONTENT
}

# ==========================================================================
# SIMPLE IAM POLICY WITH INVALID PERMISSION AND COMPUTED VALUES
# ==========================================================================

resource "aws_cloudwatch_log_group" "sample_log" {
  count = var.flag_deploy_invalid_resource ? 1 : 0
}

resource "aws_iam_policy" "policy_with_computed_values" {
  # the sample policy below contains invalid iam permissions (syntax-wise)
  count  = var.flag_deploy_invalid_resource ? 1 : 0
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DuplicateSid",
      "Action": [
        "logs:CreateLogGroups"
      ],
      "Resource": "${aws_cloudwatch_log_group.sample_log[count.index].arn}",
      "Effect": "Allow"
    },
    {
      "Sid": "DuplicateSid",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": "${aws_cloudwatch_log_group.sample_log[count.index].arn}:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# ==========================================================================
# CODEARTIFACT WITH INVALID POLICY VERSION
# ==========================================================================

# resource "aws_codeartifact_domain" "example" {
#   count  = var.flag_deploy_invalid_resource ? 1 : 0

#   domain         = "example"
# }

# resource "aws_codeartifact_repository" "example" {
#   count  = var.flag_deploy_invalid_resource ? 1 : 0

#   repository = "example"
#   domain     = aws_codeartifact_domain.example[count.index].domain
# }

# resource "aws_codeartifact_repository_permissions_policy" "example" {
#   count  = var.flag_deploy_invalid_resource ? 1 : 0

#   repository      = aws_codeartifact_repository.example[count.index].repository
#   domain          = aws_codeartifact_domain.example[count.index].domain
#   policy_document = <<EOF
# {
#     "Version": "2022-10-17",
#     "Statement": [
#         {
#             "Action": "codeartifact:CreateRepository",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }