########################### Providers ##########################

terraform {
  required_version = "~> 1.0"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.18"
    }
    aws = "~> 4.0"
  }
}

provider "aws" {
  region = var.awsRegion
}

provider "volterra" {
  timeout = "90s"
}

############################ Locals ############################

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  awsAz1 = var.awsAz1 != null ? var.awsAz1 : data.aws_availability_zones.available.names[0]
  awsAz2 = var.awsAz2 != null ? var.awsAz1 : data.aws_availability_zones.available.names[1]
  awsAz3 = var.awsAz3 != null ? var.awsAz1 : data.aws_availability_zones.available.names[2]

  awsCommonLabels = merge(var.awsLabels, {})
  f5xcCommonLabels = merge(var.labels, {
    demo     = "mcn-demo"
    owner    = var.resourceOwner
    prefix   = var.projectPrefix
    suffix   = var.buildSuffix
    platform = "aws"
  })
}

############################ VPCs ############################

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "3.19.0"
  name                 = format("%s-vpc-%s", var.projectPrefix, var.buildSuffix)
  cidr                 = var.vpcCidr
  azs                  = [local.awsAz1, local.awsAz2]
  public_subnets       = var.publicSubnets
  private_subnets      = var.privateSubnets
  enable_dns_hostnames = true
  #enable_nat_gateway   = true
  #single_nat_gateway   = true
  tags = merge(local.volterraCommonLabels, {
    Name  = format("%s-vpc-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  })
}

############################ Workload Subnet ############################

# @JeffGiroux workaround route table association conflict
# - AWS VPC module creates subnets with RT associations
# - Volterra tries to create causes RT conflicts and fails site
# - Create additional subnets for sli and workload without RT for Volterra's use

# resource "aws_subnet" "sli" {
#   vpc_id            = module.vpc.vpc_id
#   availability_zone = local.awsAz1
#   cidr_block        = "10.1.20.0/24"

#   tags = {
#     Name  = format("%s-site-local-inside-%s", var.resourceOwner, var.buildSuffix)
#     Owner = var.resourceOwner
#   }
# }

resource "aws_subnet" "workload" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz1
  cidr_block        = var.workloadSubnets[0]

  tags = {
    Name  = format("%s-workload-%s", var.resourceOwner, var.buildSuffix)
    Owner = var.resourceOwner
  }
}

############################ SSH Key ############################

# SSH key
resource "aws_key_pair" "sshKey" {
  key_name   = format("%s-sshKey-%s", var.projectPrefix, var.buildSuffix)
  public_key = var.ssh_key
}

############################ Security Groups - Web Servers ############################

# Webserver Security Group
resource "aws_security_group" "webserver" {
  name        = format("%s-sg-webservers-%s", var.projectPrefix, var.buildSuffix)
  description = "Webservers security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = format("%s-sg-webservers-%s", var.resourceOwner, var.buildSuffix)
    Owner = var.resourceOwner
  }
}
