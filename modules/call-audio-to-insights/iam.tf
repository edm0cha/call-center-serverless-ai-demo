# Lambda Roles and policies
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_transcribe" {
  name               = "${var.project}-lambda-transcribe"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role" "lambda_sentiment" {
  name               = "${var.project}-lambda-sentiment"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role" "lambda_bedrock" {
  name               = "${var.project}-lambda-bedrock"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role" "lambda_polly" {
  name               = "${var.project}-lambda-polly"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role" "lambda_ses" {
  name               = "${var.project}-lambda-ses"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "common" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
  statement {
    actions   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
    resources = [aws_kms_key.s3.arn]
  }
  statement {
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${local.recordings_bucket_name}",
      "arn:aws:s3:::${local.recordings_bucket_name}/*",
      "arn:aws:s3:::${local.outputs_bucket_name}",
      "arn:aws:s3:::${local.outputs_bucket_name}/*"
    ]
  }
  statement {
    actions   = ["dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:GetItem"]
    resources = [aws_dynamodb_table.this.arn]
  }
}

resource "aws_iam_policy" "common" {
  name   = "${var.project}-lambda-common"
  policy = data.aws_iam_policy_document.common.json
}

resource "aws_iam_role_policy_attachment" "transcribe_common" {
  role       = aws_iam_role.lambda_transcribe.name
  policy_arn = aws_iam_policy.common.arn
}
resource "aws_iam_role_policy_attachment" "sentiment_common" {
  role       = aws_iam_role.lambda_sentiment.name
  policy_arn = aws_iam_policy.common.arn
}

resource "aws_iam_role_policy_attachment" "bedrock_common" {
  role       = aws_iam_role.lambda_bedrock.name
  policy_arn = aws_iam_policy.common.arn
}

resource "aws_iam_role_policy_attachment" "polly_common" {
  role       = aws_iam_role.lambda_polly.name
  policy_arn = aws_iam_policy.common.arn
}

resource "aws_iam_role_policy_attachment" "ses_common" {
  role       = aws_iam_role.lambda_ses.name
  policy_arn = aws_iam_policy.common.arn
}

# Transcribe
data "aws_iam_policy_document" "transcribe" {
  statement {
    actions   = ["transcribe:StartTranscriptionJob", "transcribe:GetTranscriptionJob", "transcribe:ListTranscriptionJobs"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "transcribe" {
  name   = "${var.project}-transcribe-policy"
  policy = data.aws_iam_policy_document.transcribe.json
}

resource "aws_iam_role_policy_attachment" "transcribe" {
  role       = aws_iam_role.lambda_transcribe.name
  policy_arn = aws_iam_policy.transcribe.arn
}

# Sentiment
data "aws_iam_policy_document" "sentiment" {
  statement {
    actions   = ["comprehend:DetectSentiment", "comprehend:DetectEntities", "comprehend:DetectKeyPhrases"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sentiment" {
  name   = "${var.project}-sentiment-policy"
  policy = data.aws_iam_policy_document.sentiment.json
}

resource "aws_iam_role_policy_attachment" "sentiment" {
  role       = aws_iam_role.lambda_sentiment.name
  policy_arn = aws_iam_policy.sentiment.arn
}

# Bedrock

data "aws_iam_policy_document" "bedrock" {
  statement {
    actions   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
    resources = ["*"]
  }

  statement {
    actions   = ["aws-marketplace:ViewSubscriptions", "aws-marketplace:Subscribe"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "bedrock" {
  name   = "${var.project}-bedrock-policy"
  policy = data.aws_iam_policy_document.bedrock.json
}

resource "aws_iam_role_policy_attachment" "bedrock" {
  role       = aws_iam_role.lambda_bedrock.name
  policy_arn = aws_iam_policy.bedrock.arn
}

# Polly
data "aws_iam_policy_document" "polly" {
  statement {
    actions   = ["polly:SynthesizeSpeech"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "polly" {
  name   = "${var.project}-polly-policy"
  policy = data.aws_iam_policy_document.polly.json
}

resource "aws_iam_role_policy_attachment" "polly" {
  role       = aws_iam_role.lambda_polly.name
  policy_arn = aws_iam_policy.polly.arn
}

# SES
data "aws_iam_policy_document" "ses" {
  count = var.verified_email != "" ? 1 : 0
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = [aws_ses_email_identity.email[0].arn]
  }
}

resource "aws_iam_policy" "ses" {
  count  = var.verified_email != "" ? 1 : 0
  name   = "${var.project}-ses-policy"
  policy = data.aws_iam_policy_document.ses[0].json
}

resource "aws_iam_role_policy_attachment" "ses" {
  count      = var.verified_email != "" ? 1 : 0
  role       = aws_iam_role.lambda_ses.name
  policy_arn = aws_iam_policy.ses[0].arn
}

# Step Function IAM Role and Policy
data "aws_iam_policy_document" "step_function_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "step_function_role" {
  name               = "${var.project}-step-function-role"
  assume_role_policy = data.aws_iam_policy_document.step_function_assume_role.json
}

data "aws_iam_policy_document" "step_function_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync"
    ]
    resources = [
      aws_lambda_function.transcribe.arn,
      aws_lambda_function.sentiment.arn,
      aws_lambda_function.bedrock.arn,
      aws_lambda_function.polly.arn,
      aws_lambda_function.ses.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${local.recordings_bucket_name}/*"
    ]
  }
  # Required for Step Functions to write execution logs to the log group
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
  # Allow writing log events to the specific log group
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.call_audio_insights_sfn.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "step_function_role_policy" {
  name   = "${var.project}-step-function-policy"
  role   = aws_iam_role.step_function_role.id
  policy = data.aws_iam_policy_document.step_function_policy.json
}
