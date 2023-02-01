############################ Locals ############################

# Onboard files
locals {
  user_data = templatefile("${path.module}/templates/cloud-config.yml", {
    index_html      = replace(file("${path.module}/../files/backend/index.html"), "/[\\n\\r]/", "")
    f5_logo_rgb_svg = base64gzip(file("${path.module}/../files/backend/f5-logo-rgb.svg"))
    styles_css      = base64gzip(file("${path.module}/../files/backend/styles.css"))
  })
  zone = random_shuffle.zones.result[0]
}

############################ Public IP ############################

resource "azurerm_public_ip" "webserver" {
  count               = var.public_address ? 1 : 0
  name                = format("%s-pip-webserver-%s", var.projectPrefix, var.buildSuffix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = [local.zone]
  tags = {
    Owner = var.resourceOwner
  }
}

############################ Network Interfaces (NIC) ############################

resource "azurerm_network_interface" "webserver" {
  name                = format("%s-nic-webserver-%s", var.projectPrefix, var.buildSuffix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "primary"
    subnet_id                     = module.network.vnet_subnets[2]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.subnetPrefixes[2], 200)
    public_ip_address_id          = var.public_address ? azurerm_public_ip.webserver[0].id : null
  }
  tags = {
    Owner = var.resourceOwner
  }
}

# Associate security groups with NIC
resource "azurerm_network_interface_security_group_association" "webserver" {
  network_interface_id      = azurerm_network_interface.webserver.id
  network_security_group_id = azurerm_network_security_group.webserver.id
}

############################ Compute ############################

# Create VM
resource "azurerm_linux_virtual_machine" "webserver" {
  name                  = format("%s-webserver-%s", var.projectPrefix, var.buildSuffix)
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.webserver.id]
  size                  = var.instanceType
  admin_username        = var.adminAccountName
  custom_data           = base64encode(local.user_data)
  zone                  = local.zone
  admin_ssh_key {
    username   = var.adminAccountName
    public_key = var.ssh_key
  }
  os_disk {
    name                 = format("%s-disk-webserver-%s", var.projectPrefix, var.buildSuffix)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  tags = {
    Owner = var.resourceOwner
  }
}
