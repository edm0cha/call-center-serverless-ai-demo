resource "aws_kms_key" "s3" {
  description             = "KMS for ${var.project} buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project}-s3"
  target_key_id = aws_kms_key.s3.id
}