############################ Private DNS Zones ############################

resource "azurerm_private_dns_zone" "sharedAcme" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Owner = var.resourceOwner
  }
}

############################ Zone Records ############################

resource "azurerm_private_dns_a_record" "inside" {
  name                = "inside"
  zone_name           = azurerm_private_dns_zone.sharedAcme.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [data.azurerm_network_interface.sli.private_ip_address]
}

resource "azurerm_private_dns_cname_record" "sharedAcme" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.sharedAcme.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record              = format("inside.%s", var.domain_name)
}

############################ DNS Virtual Network Link ############################

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "sharedDNS"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sharedAcme.name
  virtual_network_id    = module.network.vnet_id
}
