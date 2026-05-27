# 🎧 Call Center Serverless AI Demo

Transform call audio into **transcriptions**, **sentiment analysis**, **AI-generated insights**, **spoken summaries**, and **email notifications** using a fully serverless AWS pipeline.

This project provides a reusable Terraform module and two ready-to-deploy examples for demos, PoCs, and production-ready call analysis systems.

## Notes

This project was authored by the maintainer. AI-assisted coding tools were used to accelerate development, with all logic reviewed and validated manually.

---

## 📚 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Module Variables](#module-variables)
- [Module Outputs](#module-outputs)
- [Examples](#examples)
- [Sample DynamoDB Output](#sample-dynamodb-output)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Limitations](#limitations)

---

## 🧠 Overview

When an audio file is uploaded to S3, an event-driven pipeline automatically:

1. **Transcribes** the call using AWS Transcribe (auto language detection: Spanish + English)
2. **Analyzes sentiment** using Amazon Comprehend
3. **Extracts insights** using Amazon Bedrock (Claude) — summary, suggested action, call type
4. **Synthesizes a spoken summary** using Amazon Polly
5. **Sends an email report** via Amazon SES (optional)

All results are persisted to DynamoDB. Metrics are emitted to CloudWatch at every step via AWS Lambda Powertools.

---

## 🏗️ Architecture

```
Audio file uploaded to S3 (audio/ prefix)
        │
        ▼
EventBridge (S3 ObjectCreated)
        │
        ▼
Step Functions State Machine
        │
        ├─ 1. TranscribeAudio   → AWS Transcribe  → S3 (transcript JSON)
        │
        ├─ 2. DetectSentiment   → Amazon Comprehend
        │
        ├─ 3. AnalyzeBedrock    → Amazon Bedrock (Claude)
        │
        ├─ 4. SummaryPolly      → Amazon Polly    → S3 (audio MP3)
        │
        └─ 5. SendEmail         → Amazon SES (optional)
                │
                ▼
           DynamoDB (all results)
           CloudWatch (metrics + dashboard)
```

Each step is a dedicated Lambda function (Python 3.12) that reads from and writes to DynamoDB, passing only the `TranscriptionJobName` between states.

---

## 📁 Repository Structure

```
.
├── modules/
│   └── call-audio-to-insights/     # Reusable Terraform module
│       ├── lambda.tf                # Five Lambda functions
│       ├── step_function.tf         # State machine + EventBridge trigger
│       ├── s3.tf                    # Recordings + outputs buckets
│       ├── dynamodb.tf              # Insights table
│       ├── connect.tf               # AWS Connect instance + storage config
│       ├── ses.tf                   # SES email identity (conditional)
│       ├── iam.tf                   # Roles and policies per Lambda + SFN
│       ├── kms.tf                   # KMS key for S3 encryption
│       ├── dashboard.tf             # CloudWatch dashboard
│       ├── variables.tf
│       ├── outputs.tf
│       └── lambdas/
│           ├── handler_transcribe.py
│           ├── handler_sentiment.py
│           ├── handler_bedrock.py
│           ├── handler_polly.py
│           └── handler_ses.py
│
└── examples/
    ├── AWSConnect/                  # Pipeline triggered by AWS Connect call recordings
    └── S3Audios/                    # Pipeline triggered by manual S3 uploads
        └── calls/
            ├── test-positive-1.mp3
            └── test-negative-1.mp3
```

---

## ⚙️ Module Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `project` | string | *(required)* | Prefix for all resource names |
| `region` | string | *(required)* | AWS region to deploy into |
| `bedrock_model_id` | string | *(required)* | Bedrock model or inference profile ID (e.g. `us.anthropic.claude-haiku-4-5-20251001-v1:0`) |
| `recordings_prefix` | string | `"audio/"` | S3 key prefix that triggers the pipeline |
| `polly_voice_id` | string | `"Lucia"` | Amazon Polly voice ID for audio summaries |
| `response_language` | string | `"Spanish"` | Language for Bedrock's summary, suggested action, and call type output |
| `create_buckets` | bool | `true` | Whether to create S3 buckets inside the module |
| `recordings_bucket_name` | string | `null` | Existing recordings bucket name (used when `create_buckets = false`) |
| `outputs_bucket_name` | string | `null` | Existing outputs bucket name (used when `create_buckets = false`) |
| `verified_email` | string | `""` | SES verified email address. If empty, SES identity and email sending are skipped |

---

## 📤 Module Outputs

| Output | Description |
|---|---|
| `recordings_bucket_name` | Name of the recordings S3 bucket |
| `recordings_bucket_arn` | ARN of the recordings S3 bucket |
| `outputs_bucket_name` | Name of the outputs S3 bucket |
| `outputs_bucket_arn` | ARN of the outputs S3 bucket |
| `kms_key_arn` | ARN of the KMS key used for S3 encryption |
| `dynamodb_table_name` | Name of the DynamoDB insights table |
| `dynamodb_table_arn` | ARN of the DynamoDB insights table |
| `lambda_transcribe_arn` | ARN of the Transcribe Lambda |
| `lambda_sentiment_arn` | ARN of the Sentiment Lambda |
| `lambda_bedrock_arn` | ARN of the Bedrock Lambda |
| `lambda_polly_arn` | ARN of the Polly Lambda |
| `lambda_ses_arn` | ARN of the SES Lambda |
| `step_function_arn` | ARN of the Step Functions state machine |
| `step_function_name` | Name of the Step Functions state machine |
| `connect_instance_id` | ID of the AWS Connect instance |
| `connect_instance_arn` | ARN of the AWS Connect instance |
| `dashboard_name` | Name of the CloudWatch dashboard |
| `ses_email_identity_arn` | ARN of the SES verified email identity (null if not configured) |
| `ses_verified_email` | The verified email address (null if not configured) |

---

## 🚀 Examples

### S3Audios — Manual upload trigger

Use this example to test the pipeline by uploading audio files directly to S3. Sample audio files are included under `examples/S3Audios/calls/`.

```hcl
module "call_audio_to_insights" {
  source           = "../../modules/call-audio-to-insights"
  project          = "my-demo"
  region           = "us-east-1"
  bedrock_model_id = "us.anthropic.claude-haiku-4-5-20251001-v1:0"
  polly_voice_id   = "Lucia"
  create_buckets   = true
  verified_email   = "you@example.com"   # optional — omit to skip email
}
```

### AWSConnect — AWS Connect call recording trigger

Use this example when audio comes from an AWS Connect instance. The module provisions the Connect instance and wires its call recordings storage to the recordings S3 bucket automatically.

```hcl
module "call_audio_to_insights" {
  source           = "../../modules/call-audio-to-insights"
  project          = "my-connect-demo"
  region           = "us-east-1"
  bedrock_model_id = var.bedrock_model
  polly_voice_id   = var.polly_voice
  create_buckets   = true
}
```

---

## 🗄️ Sample DynamoDB Output

After a call is processed, the DynamoDB record looks like this:

```json
{
  "transcription_job": "job-6d928409-ad4e-4c1c-8bfb-07133c704c7b",
  "sentiment": "POSITIVE",
  "summary": "Customer thanked the delivery team for leaving the package safely at their home and maintaining constant communication throughout the delivery.",
  "suggested_action": "Recognize and reward the delivery team through an internal incentive program and use this as a success story in customer service training.",
  "call_type": "business",
  "is_personal_call": false,
  "transcript_s3": "s3://my-demo-outputs-7004ebc8/job-6d928409-ad4e-4c1c-8bfb-07133c704c7b.json",
  "audio_s3": "s3://my-demo-outputs-7004ebc8/outputs/audio/job-6d928409-ad4e-4c1c-8bfb-07133c704c7b.mp3"
}
```

---

## ✅ Prerequisites

- Terraform >= 1.8.0
- AWS credentials configured with sufficient permissions
- Amazon Bedrock model access enabled in your account for the chosen model ID
- (Optional) A verified SES email identity if you want email notifications

---

## 🛠️ Usage

```bash
cd examples/S3Audios   # or examples/AWSConnect

terraform init
terraform plan
terraform apply
```

Once deployed, upload an audio file to the recordings bucket under the `audio/` prefix:

```bash
aws s3 cp examples/S3Audios/calls/test-positive-1.mp3 \
  s3://<recordings_bucket_name>/audio/test-positive-1.mp3
```

The pipeline will trigger automatically. Monitor progress in the Step Functions console or the CloudWatch dashboard.

---

## ⚠️ Limitations

- S3 buckets are created with `force_destroy = true` — suitable for demos, review before production use
- DynamoDB table has `deletion_protection_enabled = false` — same caveat
- SES email sending uses the same address as both source and destination — extend `handler_ses.py` if you need to send to a different recipient
- Transcribe jobs are polled synchronously inside the Lambda with exponential backoff; very long calls (> ~10 min) may hit the 120-second Lambda timeout
