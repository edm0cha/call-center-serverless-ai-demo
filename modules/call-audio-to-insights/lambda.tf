resource "aws_lambda_function" "transcribe" {
  function_name    = "${var.project}-transcribe-${random_id.suffix.hex}"
  role             = aws_iam_role.lambda_transcribe.arn
  handler          = "handler_transcribe.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.transcribe_zip.output_path
  source_code_hash = data.archive_file.transcribe_zip.output_base64sha256
  layers           = ["arn:aws:lambda:${var.region}:${local.aws_account_id}:layer:AWSLambdaPowertoolsPythonV2:78"]
  timeout          = 120
  environment {
    variables = {
      PROJECT_NAME        = "${var.project}-${random_id.suffix.hex}"
      OUTPUTS_BUCKET      = local.outputs_bucket_name
      DYNAMO_DB_TABLE = aws_dynamodb_table.this.name
    }
  }
}

resource "aws_lambda_function" "sentiment" {
  function_name    = "${var.project}-sentiment-${random_id.suffix.hex}"
  role             = aws_iam_role.lambda_sentiment.arn
  handler          = "handler_sentiment.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.sentiment_zip.output_path
  source_code_hash = data.archive_file.sentiment_zip.output_base64sha256
  layers           = ["arn:aws:lambda:${var.region}:${local.aws_account_id}:layer:AWSLambdaPowertoolsPythonV2:78"]
  timeout          = 180
  environment {
    variables = {
      PROJECT_NAME    = "${var.project}-${random_id.suffix.hex}"
      OUTPUTS_BUCKET  = local.outputs_bucket_name
      DYNAMO_DB_TABLE = aws_dynamodb_table.this.name
    }
  }
}

resource "aws_lambda_function" "bedrock" {
  function_name    = "${var.project}-bedrock-${random_id.suffix.hex}"
  role             = aws_iam_role.lambda_bedrock.arn
  handler          = "handler_bedrock.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.bedrock_zip.output_path
  source_code_hash = data.archive_file.bedrock_zip.output_base64sha256
  layers           = ["arn:aws:lambda:${var.region}:${local.aws_account_id}:layer:AWSLambdaPowertoolsPythonV2:78"]
  timeout          = 180
  environment {
    variables = {
      PROJECT_NAME    = "${var.project}-${random_id.suffix.hex}"
      OUTPUTS_BUCKET  = local.outputs_bucket_name
      BEDROCK_MODELID = var.bedrock_model_id
      DYNAMO_DB_TABLE = aws_dynamodb_table.this.name
    }
  }
}

resource "aws_lambda_function" "polly" {
  function_name    = "${var.project}-polly-${random_id.suffix.hex}"
  role             = aws_iam_role.lambda_polly.arn
  handler          = "handler_polly.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.polly_zip.output_path
  source_code_hash = data.archive_file.polly_zip.output_base64sha256
  layers           = ["arn:aws:lambda:${var.region}:${local.aws_account_id}:layer:AWSLambdaPowertoolsPythonV2:78"]
  timeout          = 180
  environment {
    variables = {
      PROJECT_NAME    = "${var.project}-${random_id.suffix.hex}"
      OUTPUTS_BUCKET  = local.outputs_bucket_name
      POLLY_VOICE_ID  = var.polly_voice_id
      DYNAMO_DB_TABLE = aws_dynamodb_table.this.name
    }
  }
}

data "archive_file" "transcribe_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/handler_transcribe.py"
  output_path = "${path.module}/build/transcribe.zip"
}

data "archive_file" "sentiment_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/handler_sentiment.py"
  output_path = "${path.module}/build/sentiment.zip"
}

data "archive_file" "bedrock_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/handler_bedrock.py"
  output_path = "${path.module}/build/bedrock.zip"
}

data "archive_file" "polly_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/handler_polly.py"
  output_path = "${path.module}/build/polly.zip"
}
