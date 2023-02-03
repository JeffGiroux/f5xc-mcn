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
    f5demo_app      = "website"
    f5demo_nodename = "Q2 Learning Week (AWS)"
    f5demo_color    = "ed7b0c"
  })
}

############################ Public IP (EIP) ############################

resource "aws_eip" "webserver" {
  instance = aws_instance.webserver.id
  vpc      = true

  tags = {
    Name  = format("%s-eip-webserver-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  }
}

############################ Compute ############################

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.large"
  subnet_id              = aws_subnet.private.id
  private_ip             = cidrhost(var.privateSubnets[0], 200)
  vpc_security_group_ids = [aws_security_group.webserver.id]
  key_name               = aws_key_pair.sshKey.id
  user_data              = local.user_data

  tags = {
    Name  = format("%s-webserver-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  }
}
