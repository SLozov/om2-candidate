module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v5.9.0"  
  name                 = "om2tech-${var.env_name}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = [var.availability_zone]
  public_subnets       = [var.public_subnet_cidr]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = var.env_name
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = aws_key_pair.auth.key_name
  
  root_block_device {
    volume_size = var.vhd_size
  }
  tags = {
    Name = "om2tech-${var.env_name}-server"
    Terraform   = "true"
    Environment = var.env_name
  }
  associate_public_ip_address = true
}

resource "aws_key_pair" "auth" {
  key_name   = "default-key"
  public_key = "" 
}

import {
  to = aws_key_pair.auth
  id = "default-key"
}

resource "aws_security_group_rule" "allow_rdp" {
  for_each = toset(var.allowed_ips)

  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = module.vpc.default_security_group_id
}