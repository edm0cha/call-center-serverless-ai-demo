variable "project" { type = string }
variable "region"  { type = string }

# Prefijos (por si usas Connect o cargas manualmente audios)
variable "recordings_prefix" { 
  type = string 
  default = "audio/" 
}
variable "outputs_prefix"    { 
  type = string
  default = "outputs/" 
}

# Modelo de Bedrock (ajusta según región/permisos habilitados)
variable "bedrock_model_id" {
  type        = string
  description = "e.g. anthropic.claude-3-haiku-20240307-v1:0"
}

# Código de idioma para Transcribe (ajústalo según tus audios)
variable "transcribe_language_code" {
  type        = string
  default     = "es-MX"
  description = "Ej: es-MX, es-ES, en-US, etc."
}

# Voz de Polly (ej: 'Lucia' para español)
variable "polly_voice_id" {
  type    = string
  default = "Lucia"
}

# ¿Deseas crear buckets S3 dentro del módulo?
variable "create_buckets" {
  type    = bool
  default = true
}

# Si no los creas aquí, puedes inyectar nombres de buckets existentes
variable "recordings_bucket_name" { 
  type = string 
  default = null 
}
variable "outputs_bucket_name"    { 
  type = string
  default = null 
}
