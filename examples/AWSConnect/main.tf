module "call_audio_to_insights" {
  source         = "../../modules/call-audio-to-insights"
  project        = var.project
  region         = var.region
  bedrock_model_id = var.bedrock_model
  polly_voice_id = var.polly_voice
  create_buckets = true
}
