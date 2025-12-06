module "call_audio_to_insights" {
  source                = "../modules/call-audio-to-insights"
  project               = var.project
  region                = var.region
  bedrock_model_id      = "anthropic.claude-3-haiku-20240307-v1:0"
  transcribe_language_code = "es-MX"
  polly_voice_id        = "Lucia"

  # Si ya tienes buckets existentes, usa:
  create_buckets         = true
  # recordings_bucket_name = "${var.project}-demo-ai-bucket-recordings"
  # outputs_bucket_name    = "${var.project}-demo-ai-bucket-outputs"
}
