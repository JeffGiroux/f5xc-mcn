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

############################ Zones ############################

# Retrieve availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

############################ Client IP ############################

# Retrieve client public IP
data "http" "ipinfo" {
  url = "https://ifconfig.me/ip"
}

############################ Locals ############################

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

  clientIp = format("%s/32", data.http.ipinfo.response_body)
}

############################ VPCs ############################

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "3.19.0"
  name                 = format("%s-vpc-%s", var.projectPrefix, var.buildSuffix)
  cidr                 = var.vpcCidr
  azs                  = [local.awsAz1, local.awsAz2]
  public_subnets       = var.publicSubnets
  enable_dns_hostnames = true
  tags = merge(local.f5xcCommonLabels, {
    Name  = format("%s-vpc-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  })
}

############################ Web Server Subnets ############################

# @JeffGiroux workaround VPC module
# - Need private subnet to reach internet to download onboarding files.
# - Will associate public route table with private subnet for demo purposes.
# - Note: Best practice is to use NAT gateway and bastion host.
resource "aws_subnet" "private" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz1
  cidr_block        = var.privateSubnets[0]

  tags = {
    Name  = format("%s-private-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  }
}

resource "aws_route_table_association" "private_routes" {
  subnet_id      = aws_subnet.private.id
  route_table_id = module.vpc.public_route_table_ids[0]
}

############################ F5 XC Subnets ############################

# @JeffGiroux workaround route table association conflict
# - AWS VPC module creates subnets with RT associations, and
# - F5 XC tries to create which causes conflicts and fails.
# - Create additional subnets for SLI and Workload without route tables.

resource "aws_subnet" "sli" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz1
  cidr_block        = var.sliSubnets[0]

  tags = {
    Name  = format("%s-site-local-inside-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "workload" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz1
  cidr_block        = var.workloadSubnets[0]

  tags = {
    Name  = format("%s-workload-%s", var.projectPrefix, var.buildSuffix)
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
    cidr_blocks = [local.clientIp]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpcCidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = format("%s-sg-webservers-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  }
}
