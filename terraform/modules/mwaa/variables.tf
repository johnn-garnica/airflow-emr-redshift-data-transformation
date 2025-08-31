variable "vpc_region" {
  description = "AWS region for the intances"
  type        = string
  default     = "us-east-1"
}

variable "airflow_private_a_subnet_id" {
  description = "First subnet ID where the environment will be launched"
  type        = string
}

variable "airflow_private_b_subnet_id" {
  description = "Second subnet ID where the environment will be launched"
  type        = string
}

variable mwaa_data_bucket_arn {
  description = "ARN of the S3 bucket for MWAA data"
  type        = string
}

variable "ssh_security_group_id" {
  description = "Security group ID for SSH access to the environment"
  type        = string
}

variable "https_security_group_id" {
  description = "Security group ID for HTTPS access to the environment"
  type        = string
}

variable "airflow_security_group_id" {
  description = "Security group ID for the MWAA environment"
  type        = string
}

variable "mwaa_environment_name" {
  description = "Name of the MWAA environment"
  type        = string
}

variable "airflow_environment_class" {
  description = "MWAA environment class"
  type        = string
  default     = "mw1.micro"
}

variable "airflow_version" {
  description = "Version of Airflow to use in MWAA"
  type        = string
  default     = "2.10.3"
}

variable "airflow_access_mode" {
  description = "Access mode for MWAA"
  type        = string
  default     = "PUBLIC_ONLY"
}

variable "mwaa_role_arn" {
  description = "ARN of the IAM role for MWAA"
  type        = string
}

variable "ses_email_origin" {
  description = "Email address origin in SES"
  type        = string
}

variable "smtp_user" {
  description = "SMTP user for sending emails"
  type        = string
}

variable "smtp_password" {
  description = "SMTP password for sending emails"
  type        = string
}