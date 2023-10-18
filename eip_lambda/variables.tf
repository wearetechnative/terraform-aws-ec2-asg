variable "name" {
  description = "Unique name for EC2 with ASG setup."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for encrypting CloudWatch Logs. More uses might be added later."
  type = string
}

variable "module_resource_name_prefix" {
  description = "Prefix used for role creation."
  type        = string
}

variable "eip_id" {
  description = "ID for EIP to be transferred."
  type        = string
}

variable "autoscalinggroup_name" {
  description = "ASG name for policy."
  type        = string
}

variable "autoscalinggroup_arn" {
  description = "ASG ARN for policy."
  type        = string
}

variable "sqs_dlq_arn" {
  description = "Required normal SQS queue to be used as DLQ for EventBridge."
  type        = string
}

variable "lifecycle_hook_name" {
  description = "Hook name for the Lambda to trigger on."
  type        = string
}
