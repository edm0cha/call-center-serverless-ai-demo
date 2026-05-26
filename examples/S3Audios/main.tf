module "call_audio_to_insights" {
  source           = "../../modules/call-audio-to-insights"
  project          = var.project
  region           = var.region
  bedrock_model_id = "anthropic.claude-3-haiku-20240307-v1:0"
  polly_voice_id   = "Lucia"

  # Set create_buckets = false and provide existing bucket names to reuse them:
  create_buckets = true
  # recordings_bucket_name = "${var.project}-demo-ai-bucket-recordings"
  # outputs_bucket_name    = "${var.project}-demo-ai-bucket-outputs"
}
