env_name = "dev"
region = "us-east-1"

vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
availability_zone  = "us-east-1a"

ami_id  = "ami-04df9ee4d3dfde202"
vhd_size = "50"
instance_type = "t2.medium"
allowed_ips= ["128.77.15.12/32"]