output "elasticip_parameter_arn" {
  value = length(aws_ssm_parameter.public-ip) > 0 ? aws_ssm_parameter.public-ip[0].arn : null
}

output "elasticip_parameter_name" {
  value = length(aws_ssm_parameter.public-ip) > 0 ? aws_ssm_parameter.public-ip[0].name : null
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.this.name
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.this.arn
}

output "autoscaling_group_service_role_arn" {
  value = aws_iam_service_linked_role.this.arn
}

output "autoscaling_group_service_role_id" {
  value = aws_iam_service_linked_role.this.id
}

output "autoscaling_group_iam_role_id" {
  value = length(module.iam_role.role_arn) > 0 ? module.iam_role[0].role_arn : ""
}
