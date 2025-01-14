variable "name" {
  description = "Unique name for EC2 with ASG setup."
  type        = string
}

variable "initial_amount_of_pods" {
  description = "Initial amount of pods to set when the ASG is (re)created."
  type = number
  default = 0
}

variable "desired_capacity_type" {
  description = "The unit of measurement for the value specified for desired_capacity. Supported for attribute-based instance type selection only."
  type = string
  default = "units"
}

variable "ec2_ami_name_filter_list" {
  description = "Optional regex value to filter the AMI image. Most recently is used. Only AMIs with root device EBS and virtualization type HVM are currently allowed. Default is Ubuntu."
  type        = list(string)
  default     = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
}

variable "ec2_ami_owner_list" {
  description = "Optional list of owners as an additional filter. This is a safeguard to prevent AMI names from being reused by malicious third parties. Default is Canonical."
  type        = list(string)
  default     = ["099720109477"] # Canonical, for default value of ec2_ami_name_filter_list
}

variable "instance_role_name" {
  description = "Optional instance role name. If not specified a default role with some policies like AmazonSSMManagedInstanceCore will be attached."
  type        = string
  default     = null
}

variable "user_data" {
  description = <<EOT
Optional userdata in cleartext.
- Especially if var.user_data_completion_hook is set as well then keep the 16Kb limit in mind for these scripts.
- The script always initiates a server reboot at the end.
EOT
  type        = string
  default     = ""
}

variable "user_data_lifecyclehook_timeout" {
  description = "Max timeout on userdata lifecycle hook in seconds. Default to 1800 seconds."
  type        = number
  default     = 1800
}

variable "security_group_ids" {
  description = "Optional security groups to be associated with EC2 instances. Make sure that SSM endpoints or WAN access is allowed if you want SSM to work."
  type        = list(string)
  default     = []
}

variable "ec2_root_initial_size" {
  description = "Optional initial size of the EC2 root instance disk. Must be sufficient for the AMI that is used. Defaults to 8Gb."
  type        = number
  default     = 8 # default for ec2_ami_name_filter_list
}

variable "ec2_instance_type" {
  description = "Optional instance type for EC2. Defaults to t3a.small."
  type        = string
  default     = "t3a.small"
}

variable "subnet_ids" {
  description = "Required list of subnets to launch instances in."
  type        = list(string)
}

variable "use_public_ip" {
  description = "Associate public IPs to EC2 instance."
  type        = bool
  default     = false
}

variable "use_floating_ip" {
  description = "Use an Elastic IP for standard endpoint entry."
  type = bool
  default = true
}

variable "own_eip_for_floating_ip" {
  description = "Optionally own EIP if floating IP is set to true."
  type = string
  default = null
}

variable "user_data_completion_hook" {
  description = "Append completion hook to userdata. Make sure you install awscli and jq in the userdata script. This assumes the userdata script is a bash shell script!"
  type        = bool
  default     = false
}

variable "sqs_dlq_arn" {
  description = "Optionally specify a normal SQS queue to be used as DLQ for EventBridge and Lambda."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key to use for encrypting EBS volumes."
  type        = string
}

variable "additional_tags" {
  description = "Additional tags on the ASG that will be propagated to the hosts. Useful for EKS & Systems Manager state management. Always propagated to EC2 instances."
  type        = map(string)
  default     = {}
}

variable "target_group_arns" {
  description = "Target groups to add the managed EC2 instances to."
  type = list(string)
  default = []
}

variable "lifecycle_hooks" {
  description = "Additional lifecycle hooks for this ASG. They are implemented as initial lifecycle hooks so they will apply to all created EC2 instances. The map key is the name."
  type = map(object({
    timeout_in_seconds = number
    launch_lifecycle = bool
    notification_metadata = string
  }))
  default = {}
}
