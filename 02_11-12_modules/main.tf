# //////////////////////////////
# VARIABLES
# //////////////////////////////
variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "region" {
  default = "us-east-2"
}


# //////////////////////////////
# PROVIDERS
# //////////////////////////////
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# //////////////////////////////
# SECURITY GROUP
# //////////////////////////////
resource "aws_security_group" "sg_frontend" {
  name   = "sg_frontend"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# //////////////////////////////
# MODULES
# //////////////////////////////
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "frontend-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = var.priv_subnet_list
  public_subnets  = var.pub_subnet_list

  enable_nat_gateway = true
  single_nat_gateway = true
  # one_nat_gateway_per_az = true
}


# //////////////////////////////
# DATA
# //////////////////////////////
data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
