resource "aws_ses_email_identity" "email" {
  count = var.verified_email != "" ? 1 : 0
  email = var.verified_email
}