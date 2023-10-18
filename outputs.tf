output "elasticip_parameter_arn" {
  value = length(aws_ssm_parameter.public-ip) > 0 ? aws_ssm_parameter.public-ip[0].arn : null
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.this.name
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.this.arn
}
