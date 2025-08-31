variable "ses_email_origin" {
  description = "Email address origin in SES"
  type        = string
}

variable "ses_email_destination" {
  description = "Email address destination in SES"
  type        = string
}

variable "vpc_region" {
  description = "AWS region for the buckets"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID for the buckets"
  type        = string
}