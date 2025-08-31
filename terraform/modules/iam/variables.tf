variable "vpc_region" {
  description = "AWS region for the intances"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "environment_name" {
  description = "Name of the MWAA environment"
  type        = string
}

variable "redshift_cluster_name" {
  description = "Redshift cluster identifier"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for MWAA data"
  type        = string
}

variable "redshift_s3_bucket_name" {
  description = "Name of the S3 bucket where Redshift reads data from and writes data to"
  type        = string
}