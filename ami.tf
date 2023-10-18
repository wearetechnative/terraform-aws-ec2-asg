data "aws_ami" "this" {
  most_recent = true
  owners      = var.ec2_ami_owner_list

  filter {
    name   = "name"
    values = var.ec2_ami_name_filter_list
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
