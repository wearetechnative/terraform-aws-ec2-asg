# stolen from https://github.com/hashicorp/terraform/issues/8344

module "lambda" {
  source = "github.com/wearetechnative/terraform-aws-lambda?ref=5ba61dffd4fd93e7ec4d4883f75acab7d56847bd"

  name = var.name
  role_arn = module.iam_role.role_arn
  role_arn_provided = true

  handler = "lambda_function.lambda_handler"
  source_type = "local"
  source_directory_location = "${path.module}/source"
  source_file_name = null

  sqs_dlq_arn = var.sqs_dlq_arn
  kms_key_arn = var.kms_key_arn
  memory_size = 128
  timeout = 10
  runtime = "python3.9"
}

resource "aws_lambda_function_event_invoke_config" "dlq" {
  function_name = var.name

  # NOTE This is disabled as this caused continuous configuration drift (60>0>null) in aws-proviver 5.26
  # maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 2

  destination_config {
    on_failure {
      destination = var.sqs_dlq_arn
    }
  }

  depends_on = [
    module.lambda
  ]
}
