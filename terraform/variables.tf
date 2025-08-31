variable "vpc_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block's prefix for the VPC"
  type        = string
  default     = "10.0"
}

variable "availability_zone" {
  description = "Availability zone for the VPC"
  type        = string
  default     = "us-east-1a"
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
}

variable "redshift_cluster_name" {
  description = "Redshift cluster identifier"
  type        = string
}

variable "redshift_db_name" {
  description = "Redshift database name"
  type        = string
}

variable "redshift_db_user" {
  description = "Redshift database user"
  type        = string
}

variable "redshift_db_password" {
  description = "Redshift database password"
  type        = string
  sensitive   = true
}

variable "ses_email_origin" {
  description = "Email address origin in SES"
  type        = string
}

variable "ses_email_destination" {
  description = "Email address destination in SES"
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

variable "bastion_instance_type" {
  description = "EC2 instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "redshift_node_type" {
  description = "Node type for the Redshift cluster"
  type        = string
  default     = "ra3.large"
}

variable "redshift_cluster_type" {
  description = "Type of Redshift cluster"
  type        = string
  default     = "single-node"
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

variable "key_pair_identifier" {
  description = "Key pair to use for EC2 instances"
  type        = string
}