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
  default = "us.anthropic.claude-haiku-4-5-20251001-v1:0"
}

variable "polly_voice" {
  type    = string
  default = "Lucia"
}
