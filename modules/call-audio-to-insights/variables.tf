variable "project" { type = string }
variable "region" { type = string }

# S3 key prefix for audio recordings (used by Connect and manual uploads)
variable "recordings_prefix" {
  type    = string
  default = "audio/"
}

# Bedrock model ID or Inference profile ID to use for call analysis
variable "bedrock_model_id" {
  type        = string
  description = "e.g. us.anthropic.claude-haiku-4-5-20251001-v1:0"
}

# Polly voice ID for speech synthesis (e.g. 'Lucia' for Spanish)
variable "polly_voice_id" {
  type    = string
  default = "Lucia"
}

# Whether to create S3 buckets inside this module
variable "create_buckets" {
  type    = bool
  default = true
}

# Existing bucket names to use when create_buckets is false
variable "recordings_bucket_name" {
  type    = string
  default = null
}
variable "outputs_bucket_name" {
  type    = string
  default = null
}
