############################ DNS Resolver Endpoint ############################

resource "aws_route53_resolver_endpoint" "dns" {
  name               = format("%s-resolver-%s", var.projectPrefix, var.buildSuffix)
  direction          = "OUTBOUND"
  security_group_ids = [module.vpc.default_security_group_id]

  ip_address {
    subnet_id = module.vpc.public_subnets[0]
  }
  ip_address {
    subnet_id = module.vpc.public_subnets[1]
  }

  tags = {
    Name  = format("%s-resolver-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  }
}

############################ DNS Resolver Rule (aka delegation) ############################

resource "aws_route53_resolver_rule" "dns" {
  name                 = format("%s-route53rule-%s", var.projectPrefix, var.buildSuffix)
  domain_name          = var.domain_name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.dns.id

  target_ip {
    ip = data.aws_network_interface.xc_sli.private_ip
  }

  tags = {
    Name  = format("%s-route53rule-%s", var.projectPrefix, var.buildSuffix)
    Owner = var.resourceOwner
  }
}

############################ DNS Rule Association ############################

resource "aws_route53_resolver_rule_association" "dns" {
  resolver_rule_id = aws_route53_resolver_rule.dns.id
  vpc_id           = module.vpc.vpc_id
}
