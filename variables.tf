variable "env_name" {
  type        = string
  description = "Environment name"
}

variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
}

variable "availability_zone" {
  description = "The availability zone for the public subnet"
  default     = "us-east-1a"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  description = "The type of instance to create"
}

variable "vhd_size" {
  description = "The size of the root volume"
}

variable "allowed_ips" {
  description = "List of IP addresses to allow RDP access"
  type        = list(string)
}
