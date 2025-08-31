variable "vpc_region" {
  description = "AWS region for the intances"
  type        = string
  default     = "us-east-1"
}

variable "public_a_subnet_id" {
  description = "Subnet ID where the bastion-host will be launched"
  type        = string
}

variable "ssh_security_group_id" {
  description = "Security group ID for SSH access to the bastion-host"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the bastion-host"
  type        = string
  default     = "us-east-1a"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion-host"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_identifier" {
  description = "Key pair to use for EC2 instances"
  type        = string
}