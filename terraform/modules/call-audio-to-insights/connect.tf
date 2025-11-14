# Crea instancia (básica). Requiere aceptar/activar servicio en la cuenta.
resource "aws_connect_instance" "this" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  outbound_calls_enabled   = false
  instance_alias           = var.project
}

# Enlaza S3 para CALL_RECORDINGS (graba en recordings/audio/)
resource "aws_connect_instance_storage_config" "call_recordings" {
    instance_id = aws_connect_instance.this.id
    resource_type = "CALL_RECORDINGS"

    storage_config {
    storage_type = "S3"
    s3_config {
        bucket_name   = local.recordings_bucket_name
        bucket_prefix = "audio/"
        encryption_config {
        encryption_type = "KMS"
        key_id          = aws_kms_key.s3.arn
        }
    }
    }
}