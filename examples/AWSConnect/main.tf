module "call_audio_to_insights" {
  source                   = "../../terraform/modules/call-audio-to-insights"
  project                  = var.project
  region                   = var.region
  bedrock_model_id         = var.bedrock_model
  polly_voice_id           = var.polly_voice
  transcribe_language_code = var.transcribe_language_code
  create_buckets           = true
}
