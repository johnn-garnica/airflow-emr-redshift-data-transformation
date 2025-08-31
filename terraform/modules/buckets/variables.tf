variable "vpc_region" {
  description = "AWS region for the buckets"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID for the buckets"
  type        = string
}

variable "dag_local_path" {
  description = "Local path for dag"
  type        = string
}

variable "mwaa_requirements_local_path" {
  description = "Local path for requirements.txt"
  type        = string
}

variable "etl_file_local_path" {
  description = "Local path for etl file"
  type        = string
}

variable "input_csv_local_path" {
  description = "Local path for input csv file"
  type        = string
}