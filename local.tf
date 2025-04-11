locals {
  module_resource_name_prefix = "ec2-asg"
  module_resource_name        = var.used_fixed_name == true ? "${var.name}" : "${local.module_resource_name_prefix}-${var.name}"

  elastic_ip_lifecyclehook = "elastic-ip-lambda"

  use_floating_ip = length(aws_eip.this) > 0 || length(data.aws_eip.own_eip) > 0
}
