resource "aws_ses_email_identity" "ses_email_origin" {
  email = var.ses_email_origin
}

resource "aws_ses_email_identity" "ses_email_destination" {
  email = var.ses_email_destination
}