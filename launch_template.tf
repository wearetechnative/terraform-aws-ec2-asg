resource "aws_launch_template" "this" {
  name_prefix = "${local.module_resource_name}-"

  disable_api_termination = false # for manual invervention

  ebs_optimized = true

  block_device_mappings {
    device_name = data.aws_ami.this.root_device_name

    ebs {
      delete_on_termination = true
      encrypted             = var.kms_key_arn != null ? true : false
      kms_key_id            = var.kms_key_arn
      volume_size           = var.ec2_root_initial_size
      volume_type           = "gp3"
    }
  }

  network_interfaces {
    associate_public_ip_address = var.use_public_ip
    security_groups             = var.security_group_ids
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  image_id = data.aws_ami.this.image_id

  instance_initiated_shutdown_behavior = "terminate" # required for Spot instance support

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint = "enabled"
    # causes issues with tags containing space (e.g. Patch Group) or EKS tags (e.g. kubernetes/io/)
    instance_metadata_tags = "disabled"
    # https://aws.amazon.com/blogs/security/defense-in-depth-open-firewalls-reverse-proxies-ssrf-vulnerabilities-ec2-instance-metadata-service/
    http_tokens = "required"
  }

  key_name = var.key_name

  update_default_version = true
  user_data = base64encode(join("", [var.user_data_completion_hook ? join("", [coalesce(var.user_data, "## none"), <<EOT

imdsv2_token=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
instance_id=$(curl -H "X-aws-ec2-metadata-token: $${imdsv2_token}" -s http://169.254.169.254/latest/meta-data/instance-id)

aws autoscaling complete-lifecycle-action \
--lifecycle-hook-name userdata \
--auto-scaling-group-name "${local.module_resource_name}" \
--lifecycle-action-result CONTINUE \
--instance-id $instance_id \
--region "${data.aws_region.current.name}"
EOT
    ]) : var.user_data, <<EOT

# reboot to make sure stuff is persistent
reboot
EOT
    ]
  ))
}
