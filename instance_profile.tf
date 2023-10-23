resource "aws_iam_instance_profile" "this" {
  name = local.module_resource_name
  role = length(module.iam_role) > 0 ? module.iam_role[0].role_name : var.instance_role_name
}

module "iam_role" {
  count = var.instance_role_name == null ? 1 : 0

  source = "git@github.com:wearetechnative/terraform-aws-iam-role?ref=0fe916c27097706237692122e09f323f55e8237e"

  role_name = local.module_resource_name
  role_path = "/${local.module_resource_name_prefix}/"

  aws_managed_policies = ["AmazonSSMManagedInstanceCore"]

  trust_relationship = {
    "ec2" : { "identifier" : "ec2.amazonaws.com", "identifier_type" : "Service", "enforce_mfa" : false, "enforce_userprincipal" : false, "external_id" : null, "prevent_account_confuseddeputy" : false }
  }
}

resource "aws_iam_role_policy_attachment" "userdata-lifecycle" {
  count      = length(aws_iam_policy.userdata-lifecycle)
  role       = length(module.iam_role) > 0 ? module.iam_role[0].role_name : var.instance_role_name
  policy_arn = aws_iam_policy.userdata-lifecycle[0].arn
}

resource "aws_iam_policy" "userdata-lifecycle" {
  count = var.user_data_completion_hook ? 1 : 0

  name = "${local.module_resource_name}-userdatalifecycle"
  path = "/"

  policy = data.aws_iam_policy_document.userdata-lifecycle.json
}

data "aws_iam_policy_document" "userdata-lifecycle" {
  statement {
    sid = "AllowLifeCycleActionForUserDataScript"

    actions = [
      "autoscaling:CompleteLifecycleAction"
    ]

    resources = [
      aws_autoscaling_group.this.arn
    ]
  }
}
