resource "aws_kms_grant" "this" {
  name              = local.module_resource_name
  key_id            = var.kms_key_arn
  grantee_principal = aws_iam_service_linked_role.this.arn
  operations        = ["Decrypt", "GenerateDataKeyWithoutPlaintext", "CreateGrant" ]
  # , "Encrypt", "ReEncryptFrom", "ReEncryptTo", "GenerateDataKey"
  # , "GenerateDataKeyPair", "GenerateDataKeyPairWithoutPlaintext", "DescribeKey"]
}
