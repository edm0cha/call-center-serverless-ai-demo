resource "aws_lambda_function" "ingest" {
  function_name = "${var.project}-ingest"
  role          = aws_iam_role.lambda_ingest.arn
  handler       = "handler_ingest.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.ingest_zip.output_path
  source_code_hash = data.archive_file.ingest_zip.output_base64sha256
  timeout       = 60
  environment {
    variables = {
      RECORDINGS_BUCKET   = local.recordings_bucket_name
      OUTPUTS_BUCKET      = local.outputs_bucket_name
      REGION              = var.region
      TRANSCRIBE_LANGCODE = var.transcribe_language_code
    }
  }
}

resource "aws_lambda_function" "post" {
  function_name = "${var.project}-post"
  role          = aws_iam_role.lambda_post.arn
  handler       = "handler_post.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.post_zip.output_path
  source_code_hash = data.archive_file.post_zip.output_base64sha256
  timeout       = 180
  environment {
    variables = {
      OUTPUTS_BUCKET  = local.outputs_bucket_name
      BEDROCK_MODELID = var.bedrock_model_id
      REGION          = var.region
      POLLY_VOICE_ID  = var.polly_voice_id
    }
  }
}

# Permitir a S3 invocar Lambda #1
resource "aws_lambda_permission" "allow_s3_to_lambda" {
  statement_id  = "AllowS3InvokeIngest"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${local.recordings_bucket_name}"
}

# Notificación S3 -> Lambda #1 (cuando subas audio a recordings_prefix)
resource "aws_s3_bucket_notification" "recordings" {
  bucket = local.recordings_bucket_name
  lambda_function {
    lambda_function_arn = aws_lambda_function.ingest.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.recordings_prefix
  }
  depends_on = [aws_lambda_permission.allow_s3_to_lambda]
}

# EventBridge: Transcribe Job COMPLETED -> Lambda #2
resource "aws_cloudwatch_event_rule" "transcribe_complete" {
  name = "${var.project}-transcribe-complete"
  event_pattern = jsonencode({
    "source": ["aws.transcribe"],
    "detail-type": ["Transcribe Job State Change"],
    "detail": { "TranscriptionJobStatus": ["COMPLETED"] }
  })
}

resource "aws_cloudwatch_event_target" "transcribe_complete" {
  rule      = aws_cloudwatch_event_rule.transcribe_complete.name
  target_id = "lambda-post"
  arn       = aws_lambda_function.post.arn
}

resource "aws_lambda_permission" "allow_eventbridge_to_post" {
  statement_id  = "AllowEventBridgeInvokePost"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.transcribe_complete.arn
}

# Empaquetado del código
data "archive_file" "ingest_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/handler_ingest.py"
  output_path = "${path.module}/build/ingest.zip"
}

data "archive_file" "post_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/handler_post.py"
  output_path = "${path.module}/build/post.zip"
}
