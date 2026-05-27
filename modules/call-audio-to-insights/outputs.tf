# ── S3 ────────────────────────────────────────────────────────────────────────
output "recordings_bucket_name" {
  description = "Name of the S3 bucket where call recordings are stored"
  value       = local.recordings_bucket_name
}

output "recordings_bucket_arn" {
  description = "ARN of the S3 bucket where call recordings are stored"
  value       = var.create_buckets && var.recordings_bucket_name == null ? aws_s3_bucket.recordings[0].arn : null
}

output "outputs_bucket_name" {
  description = "Name of the S3 bucket where transcripts, Bedrock JSON, and Polly audio are stored"
  value       = local.outputs_bucket_name
}

output "outputs_bucket_arn" {
  description = "ARN of the S3 bucket where transcripts, Bedrock JSON, and Polly audio are stored"
  value       = var.create_buckets && var.outputs_bucket_name == null ? aws_s3_bucket.outputs[0].arn : null
}

# ── KMS ───────────────────────────────────────────────────────────────────────
output "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt S3 buckets"
  value       = aws_kms_key.s3.arn
}

# ── DynamoDB ──────────────────────────────────────────────────────────────────
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table storing call insights"
  value       = aws_dynamodb_table.this.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table storing call insights"
  value       = aws_dynamodb_table.this.arn
}

# ── Lambda ────────────────────────────────────────────────────────────────────
output "lambda_transcribe_arn" {
  description = "ARN of the Transcribe Lambda function"
  value       = aws_lambda_function.transcribe.arn
}

output "lambda_sentiment_arn" {
  description = "ARN of the Sentiment Lambda function"
  value       = aws_lambda_function.sentiment.arn
}

output "lambda_bedrock_arn" {
  description = "ARN of the Bedrock Lambda function"
  value       = aws_lambda_function.bedrock.arn
}

output "lambda_polly_arn" {
  description = "ARN of the Polly Lambda function"
  value       = aws_lambda_function.polly.arn
}

output "lambda_ses_arn" {
  description = "ARN of the SES Lambda function"
  value       = aws_lambda_function.ses.arn
}

# ── Step Function ─────────────────────────────────────────────────────────────
output "step_function_arn" {
  description = "ARN of the Step Functions state machine orchestrating the pipeline"
  value       = aws_sfn_state_machine.this.arn
}

output "step_function_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.name
}

# ── AWS Connect ───────────────────────────────────────────────────────────────
output "connect_instance_id" {
  description = "ID of the AWS Connect instance"
  value       = aws_connect_instance.this.id
}

output "connect_instance_arn" {
  description = "ARN of the AWS Connect instance"
  value       = aws_connect_instance.this.arn
}

# ── CloudWatch ────────────────────────────────────────────────────────────────
output "dashboard_name" {
  description = "Name of the CloudWatch dashboard for call insights monitoring"
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}

# ── SES ───────────────────────────────────────────────────────────────────────
output "ses_email_identity_arn" {
  description = "ARN of the SES verified email identity (null if verified_email was not provided)"
  value       = var.verified_email != "" ? aws_ses_email_identity.email[0].arn : null
}

output "ses_verified_email" {
  description = "Email address registered as an SES identity (null if verified_email was not provided)"
  value       = var.verified_email != "" ? aws_ses_email_identity.email[0].email : null
}
