########################### Providers ##########################

terraform {
  required_version = "~> 1.0"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.18"
    }
    azurerm = "~> 3.41"
  }
}

provider "azurerm" {
  features {}
}

provider "volterra" {
  timeout = "90s"
}

############################ Zones ############################

resource "random_shuffle" "zones" {
  input = var.azureZones
  keepers = {
    azureLocation = var.azureLocation
  }
}

############################ Resource Groups ############################

# Create Resource Groups
resource "azurerm_resource_group" "rg" {
  name     = format("%s-rg192-%s", var.projectPrefix, var.buildSuffix)
  location = var.azureLocation

  tags = {
    Owner = var.resourceOwner
  }
}

############################ VNets ############################

# Create VNets
module "network" {
  source              = "Azure/vnet/azurerm"
  version             = "4.0.0"
  use_for_each        = false
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = format("%s-vnet-%s", var.projectPrefix, var.buildSuffix)
  vnet_location       = var.azureLocation
  address_space       = [var.vnetCidr]
  subnet_prefixes     = var.subnetPrefixes
  subnet_names        = var.subnetNames

  tags = {
    Name  = format("%s-vnet-%s", var.resourceOwner, var.buildSuffix)
    Owner = var.resourceOwner
  }

  depends_on = [azurerm_resource_group.rg]
}

############################ Security Groups - Web Servers ############################

# Webserver Security Group
resource "azurerm_network_security_group" "webserver" {
  name                = format("%s-nsg-webservers-%s", var.projectPrefix, var.buildSuffix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_8080"
    description                = "Allow HTTP access"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Owner = var.resourceOwner
  }
}
