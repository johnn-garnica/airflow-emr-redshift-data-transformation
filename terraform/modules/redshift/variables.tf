variable "vpc_region" {
  description = "AWS region for the intances"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability zone for the bastion-host"
  type        = string
  default     = "us-east-1a"
}

variable "ssh_security_group_id" {
  description = "Security group ID for SSH access to the cluster"
  type        = string
}

variable "redshift_security_group_id" {
  description = "Security group ID for REDSHIFT access to the cluster"
  type        = string
}

variable "redshift_private_a_subnet_id" {
  description = "First subnet ID where the cluster will be launched"
  type        = string
}

variable "redshift_private_b_subnet_id" {
  description = "Second subnet ID where the cluster will be launched"
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

variable "redshift_role_s3" {
  description = "ARN of the IAM role that Redshift will use to access S3"
  type        = string
}

variable "redshift_node_type" {
  description = "Redshift node type"
  type        = string
  default     = "ra3.large"
}

variable "redshift_cluster_type" {
  description = "Redshift cluster type"
  type        = string
  default     = "single-node"
}