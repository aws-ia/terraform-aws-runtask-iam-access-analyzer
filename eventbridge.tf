resource "aws_cloudwatch_event_rule" "runtask_rule" {
  name           = "${var.name_prefix}-runtask-rule"
  description    = "Rule to capture HashiCorp Terraform Cloud RunTask events"
  event_bus_name = var.event_bus_name
  event_pattern = templatefile("${path.module}/event/runtask_rule.tpl", {
    var_event_source   = var.event_source
    var_runtask_stages = jsonencode(var.runtask_stages)
  })

}

resource "aws_cloudwatch_event_target" "runtask_target" {
  rule           = aws_cloudwatch_event_rule.runtask_rule.id
  event_bus_name = var.event_bus_name
  arn            = aws_sfn_state_machine.runtask_states.arn
  role_arn       = aws_iam_role.runtask_rule.arn
}