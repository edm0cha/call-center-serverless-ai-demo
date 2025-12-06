variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "ia-demo-connect"
}

variable "bedrock_model" {
  type    = string
  default = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "polly_voice" {
  type    = string
  default = "Lucia"
}

variable "transcribe_language_code" {
  type    = string
  default = "es-MX"
}
