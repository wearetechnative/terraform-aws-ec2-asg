# ec2_asg

Use ec2_asg if:
- You need to provide a fail-over setup with one EC2 (i.e. the initial use of ec2_asg).
  - Generally used with `use_floating_ip = true` to host applications that are not Dockerized. An EIP will be used and floats to another EC2 instance if the current instance fails.
  - Also used for setting up reliable Bastion hosts.
- You need to provide compute resources for ECS clusters.

Do not use ec2_asg if:
- If you need to provision EC2 instances for EKS, we have `eks_custom_nodegroup` for this. (Altough we should/could refactor the `ec2_asg` module for use with EKS as well...) or at least use it in `eks_custom_nodegroup`.

Todo: Implement spot instance functionality in launch_template.

Known issues:
- Sometimes you receive:
╷
│ Error: creating Auto Scaling Group (ec2-asg-website_stack_dev-eu-central-1b): ValidationError: ARN specified for Service-Linked Role does not exist.
│       status code: 400, request id: 3dcf1ff4-d46f-4724-9586-f1e4957b5dd4
│ 
│   with module.network_compute.module.network.module.nat_instances["eu-central-1b"].module.ec2_asg.aws_autoscaling_group.this,
│   on ../../modules/ec2_asg/autoscaling_group.tf line 16, in resource "aws_autoscaling_group" "this":
│   16: resource "aws_autoscaling_group" "this" {
│ 
╵

Try again. This is because of a race condition in AWS.

- Initial lifecycle hooks are not updated in ASG when changed.

Currently no known solution other than deleting and recreating the ASG.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.8.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eip_lambda"></a> [eip\_lambda](#module\_eip\_lambda) | ./eip_lambda | n/a |
| <a name="module_iam_role"></a> [iam\_role](#module\_iam\_role) | ../identity_and_access_management/iam_role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.userdata-lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.userdata-lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_service_linked_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_kms_grant.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ssm_parameter.public-ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eip.own_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eip) | data source |
| [aws_iam_policy_document.userdata-lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags on the ASG that will be propagated to the hosts. Useful for EKS & Systems Manager state management. Always propagated to EC2 instances. | `map(string)` | `{}` | no |
| <a name="input_ec2_ami_name_filter_list"></a> [ec2\_ami\_name\_filter\_list](#input\_ec2\_ami\_name\_filter\_list) | Optional regex value to filter the AMI image. Most recently is used. Only AMIs with root device EBS and virtualization type HVM are currently allowed. Default is Ubuntu. | `list(string)` | <pre>[<br>  "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"<br>]</pre> | no |
| <a name="input_ec2_ami_owner_list"></a> [ec2\_ami\_owner\_list](#input\_ec2\_ami\_owner\_list) | Optional list of owners as an additional filter. This is a safeguard to prevent AMI names from being reused by malicious third parties. Default is Canonical. | `list(string)` | <pre>[<br>  "099720109477"<br>]</pre> | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | Optional instance type for EC2. Defaults to t3a.small. | `string` | `"t3a.small"` | no |
| <a name="input_ec2_root_initial_size"></a> [ec2\_root\_initial\_size](#input\_ec2\_root\_initial\_size) | Optional initial size of the EC2 root instance disk. Must be sufficient for the AMI that is used. Defaults to 8Gb. | `number` | `8` | no |
| <a name="input_initial_amount_of_pods"></a> [initial\_amount\_of\_pods](#input\_initial\_amount\_of\_pods) | Initial amount of pods to set when the ASG is (re)created. | `number` | `0` | no |
| <a name="input_instance_role_name"></a> [instance\_role\_name](#input\_instance\_role\_name) | Optional instance role name. If not specified a default role with some policies like AmazonSSMManagedInstanceCore will be attached. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key to use for encrypting EBS volumes. | `string` | n/a | yes |
| <a name="input_lifecycle_hooks"></a> [lifecycle\_hooks](#input\_lifecycle\_hooks) | Additional lifecycle hooks for this ASG. They are implemented as initial lifecycle hooks so they will apply to all created EC2 instances. The map key is the name. | <pre>map(object({<br>    timeout_in_seconds = number<br>    launch_lifecycle = bool<br>    notification_metadata = string<br>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name for EC2 with ASG setup. | `string` | n/a | yes |
| <a name="input_own_eip_for_floaing_ip"></a> [own\_eip\_for\_floaing\_ip](#input\_own\_eip\_for\_floaing\_ip) | Optionally own EIP if floating IP is set to true. | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Optional security groups to be associated with EC2 instances. Make sure that SSM endpoints or WAN access is allowed if you want SSM to work. | `list(string)` | `[]` | no |
| <a name="input_sqs_dlq_arn"></a> [sqs\_dlq\_arn](#input\_sqs\_dlq\_arn) | Optionally specify a normal SQS queue to be used as DLQ for EventBridge and Lambda. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Required list of subnets to launch instances in. | `list(string)` | n/a | yes |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | Target groups to add the managed EC2 instances to. | `list(string)` | `[]` | no |
| <a name="input_use_floating_ip"></a> [use\_floating\_ip](#input\_use\_floating\_ip) | Use floating IP for standard endpoint entry. | `bool` | `true` | no |
| <a name="input_use_public_ip"></a> [use\_public\_ip](#input\_use\_public\_ip) | Associate public IPs to EC2 instance. | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Optional userdata in cleartext.<br>- Especially if var.user\_data\_completion\_hook is set as well then keep the 16Kb limit in mind for these scripts.<br>- The script always initiates a server reboot at the end. | `string` | `""` | no |
| <a name="input_user_data_completion_hook"></a> [user\_data\_completion\_hook](#input\_user\_data\_completion\_hook) | Append completion hook to userdata. Make sure you install awscli and jq in the userdata script. This assumes the userdata script is a bash shell script! | `bool` | `false` | no |
| <a name="input_user_data_lifecyclehook_timeout"></a> [user\_data\_lifecyclehook\_timeout](#input\_user\_data\_lifecyclehook\_timeout) | Max timeout on userdata lifecycle hook in seconds. Default to 1800 seconds. | `number` | `1800` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | n/a |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | n/a |
| <a name="output_elasticip_parameter_arn"></a> [elasticip\_parameter\_arn](#output\_elasticip\_parameter\_arn) | n/a |
<!-- END_TF_DOCS -->