# ── S3 ────────────────────────────────────────────────────────────────────────
output "recordings_bucket_name" {
  value = module.call_audio_to_insights.recordings_bucket_name
}

output "recordings_bucket_arn" {
  value = module.call_audio_to_insights.recordings_bucket_arn
}

output "outputs_bucket_name" {
  value = module.call_audio_to_insights.outputs_bucket_name
}

output "outputs_bucket_arn" {
  value = module.call_audio_to_insights.outputs_bucket_arn
}

# ── KMS ───────────────────────────────────────────────────────────────────────
output "kms_key_arn" {
  value = module.call_audio_to_insights.kms_key_arn
}

# ── DynamoDB ──────────────────────────────────────────────────────────────────
output "dynamodb_table_name" {
  value = module.call_audio_to_insights.dynamodb_table_name
}

output "dynamodb_table_arn" {
  value = module.call_audio_to_insights.dynamodb_table_arn
}

# ── Lambda ────────────────────────────────────────────────────────────────────
output "lambda_transcribe_arn" {
  value = module.call_audio_to_insights.lambda_transcribe_arn
}

output "lambda_sentiment_arn" {
  value = module.call_audio_to_insights.lambda_sentiment_arn
}

output "lambda_bedrock_arn" {
  value = module.call_audio_to_insights.lambda_bedrock_arn
}

output "lambda_polly_arn" {
  value = module.call_audio_to_insights.lambda_polly_arn
}

output "lambda_ses_arn" {
  value = module.call_audio_to_insights.lambda_ses_arn
}

# ── Step Function ─────────────────────────────────────────────────────────────
output "step_function_arn" {
  value = module.call_audio_to_insights.step_function_arn
}

output "step_function_name" {
  value = module.call_audio_to_insights.step_function_name
}

# ── AWS Connect ───────────────────────────────────────────────────────────────
output "connect_instance_id" {
  value = module.call_audio_to_insights.connect_instance_id
}

output "connect_instance_arn" {
  value = module.call_audio_to_insights.connect_instance_arn
}

# ── CloudWatch ────────────────────────────────────────────────────────────────
output "dashboard_name" {
  value = module.call_audio_to_insights.dashboard_name
}

# ── SES ───────────────────────────────────────────────────────────────────────
output "ses_email_identity_arn" {
  value = module.call_audio_to_insights.ses_email_identity_arn
}

output "ses_verified_email" {
  value = module.call_audio_to_insights.ses_verified_email
}
