############################ AMI ############################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = [var.webapp_ami_search_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################ Locals ############################

# Onboard files
locals {
  user_data = templatefile("${path.module}/templates/cloud-config.yml", {
    index_html      = replace(file("${path.module}/../files/backend/index.html"), "/[\\n\\r]/", "")
    f5_logo_rgb_svg = base64gzip(file("${path.module}/../files/backend/f5-logo-rgb.svg"))
    styles_css      = base64gzip(file("${path.module}/../files/backend/styles.css"))
  })
}

############################ Compute ############################

module "webapp" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "4.3.0"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.sshKey.id
  private_ip                  = cidrhost(var.privateSubnets[0], 200)
  vpc_security_group_ids      = [aws_security_group.webserver.id]
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = true
  tags = {
    Name  = format("%s-webapp-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  }
}
