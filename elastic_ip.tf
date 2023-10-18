module "eip_lambda" {
  count = local.use_floating_ip ? 1 : 0

  source = "./eip_lambda"

  name                        = "${local.module_resource_name}-eiplambda"
  module_resource_name_prefix = local.module_resource_name_prefix
  eip_id                      = length(aws_eip.this) > 0 ? aws_eip.this[0].id : data.aws_eip.own_eip[0].id
  autoscalinggroup_name       = aws_autoscaling_group.this.name
  autoscalinggroup_arn        = aws_autoscaling_group.this.arn
  sqs_dlq_arn                 = var.sqs_dlq_arn
  lifecycle_hook_name         = local.elastic_ip_lifecyclehook
  kms_key_arn = var.kms_key_arn
}

resource "aws_eip" "this" {
  count = var.use_floating_ip && var.own_eip_for_floaing_ip == null ? 1 : 0

  vpc = true

  tags = {
    "Name" = local.module_resource_name
  }
}

data "aws_eip" "own_eip" {
  count = var.use_floating_ip && var.own_eip_for_floaing_ip != null ? 1 : 0

  id = var.own_eip_for_floaing_ip
}

resource "aws_ssm_parameter" "public-ip" {
  count = local.use_floating_ip ? 1 : 0

  name  = "/ec2_asg/${var.name}/public-ip"
  type  = "String"
  value = length(aws_eip.this) > 0 ? aws_eip.this[0].public_ip : data.aws_eip.own_eip[0].public_ip
}
