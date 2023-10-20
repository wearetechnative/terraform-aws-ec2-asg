module "iam_role" {
  source = "git@github.com:wearetechnative/terraform-aws-iam-role"

  role_name = var.name
  role_path = "/${var.module_resource_name_prefix}/"

  customer_managed_policies = {
    "eip" : jsondecode(data.aws_iam_policy_document.eipreassign.json)
    "sqs_dlq" : jsondecode(data.aws_iam_policy_document.sqs_dlq.json)
  }

  trust_relationship = {
    "ec2" : { "identifier" : "lambda.amazonaws.com", "identifier_type" : "Service", "enforce_mfa" : false, "enforce_userprincipal" : false, "external_id" : null, "prevent_account_confuseddeputy" : false }
  }
}

data "aws_iam_policy_document" "sqs_dlq" {
  statement {
    sid = "AllowDLQAccess"

    actions = ["sqs:SendMessage"]

    resources = [var.sqs_dlq_arn]
  }
}

data "aws_iam_policy_document" "eipreassign" {
  statement {
    sid = "AllowLifeCycleActionForEIPLambda1"

    actions = ["ec2:AssociateAddress"]

    resources = [join(":", ["arn", data.aws_partition.current.id
      , "ec2", data.aws_region.current.name
    , data.aws_caller_identity.current.account_id, "elastic-ip/${var.eip_id}"])]
  }

  statement {
    sid = "AllowLifeCycleActionForEIPLambda2"

    actions = ["ec2:AssociateAddress"]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/aws:autoscaling:groupName"
      values   = [var.autoscalinggroup_name]
    }
  }

  statement {
    sid = "AllowLifeCycleActionForEIPLambda3"

    actions = ["autoscaling:CompleteLifecycleAction"]

    resources = [var.autoscalinggroup_arn]
  }
}
