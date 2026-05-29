resource "aws_dynamodb_table" "this" {
  name                        = "${var.project}-output-${random_id.suffix.hex}"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false

  hash_key = "transcription_job"

  attribute {
    name = "transcription_job"
    type = "S"
  }
}
