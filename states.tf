resource "aws_sfn_state_machine" "runtask_states" {
  name     = "${var.name_prefix}-runtask-statemachine"
  role_arn = aws_iam_role.runtask_states.arn
  definition = templatefile("${path.module}/states/runtask_states.asl.json", {
    resource_runtask_request     = aws_lambda_function.runtask_request.arn
    resource_runtask_fulfillment = aws_lambda_function.runtask_fulfillment.arn
    resource_runtask_callback    = aws_lambda_function.runtask_callback.arn
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.runtask_states.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }

  tracing_configuration {
    enabled = true
  }
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "runtask_states" {
  name              = "/aws/state/${var.name_prefix}-runtask-statemachine"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.runtask_key.arn
  tags              = var.tags
}