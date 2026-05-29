variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Used as a prefix for resource names"
  type        = string
  default     = "tf-demo"
}

variable "repository_name" {
  description = "GitHub repository name (without the org prefix)"
  type        = string
}

variable "repository_organization" {
  description = "GitHub organization or username that owns the repository"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be one of: dev, prod"
  }
}

variable "bucket_force_destroy" {
  description = "Force to Destroy S3 Bucket"
  type        = bool
  default     = false
}

