locals {
  aws_account_id         = "017000801446"
  recordings_bucket_name = var.create_buckets && var.recordings_bucket_name == null ? "${var.project}-recordings-${random_id.suffix.hex}" : var.recordings_bucket_name
  outputs_bucket_name    = var.create_buckets && var.outputs_bucket_name == null ? "${var.project}-outputs-${random_id.suffix.hex}" : var.outputs_bucket_name
}
