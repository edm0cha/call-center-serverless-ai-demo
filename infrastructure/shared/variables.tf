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
