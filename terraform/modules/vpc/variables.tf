variable "vpc_cidr" {
  description = "CIDR block's prefix for the VPC"
  type        = string
  default     = "10.0"
}

variable "vpc_region" {
  description = "AWS region for the VPC"
  type        = string
  default     = "us-east-1"
}