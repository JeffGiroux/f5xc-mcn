############################ Locals ############################

locals {
  f5xcCommonLabels = merge(var.labels, {
    demo     = "mcn-demo"
    owner    = var.resourceOwner
    prefix   = var.projectPrefix
    suffix   = var.buildSuffix
    platform = "azure"
  })
  f5xcResourceGroup = format("%s-f5xc192-%s", var.projectPrefix, var.buildSuffix)
}

############################ F5 XC Azure Vnet Sites ############################

resource "volterra_azure_vnet_site" "xc" {
  name                    = format("%s-azure192-%s", var.projectPrefix, var.buildSuffix)
  namespace               = "system"
  azure_region            = azurerm_resource_group.rg.location
  resource_group          = local.f5xcResourceGroup
  machine_type            = "Standard_D3_v2"
  logs_streaming_disabled = true
  no_worker_nodes         = true

  azure_cred {
    name      = var.f5xcCloudCredAzure
    namespace = "system"
    tenant    = var.f5xcTenant
  }

  ingress_egress_gw {
    azure_certified_hw       = "azure-byol-multi-nic-voltmesh"
    no_forward_proxy         = true
    no_global_network        = true
    no_network_policy        = true
    no_outside_static_routes = true
    no_inside_static_routes  = true

    az_nodes {
      azure_az  = "1"
      disk_size = 80

      inside_subnet {
        subnet {
          subnet_name         = "sli"
          vnet_resource_group = true
        }
      }
      outside_subnet {
        subnet {
          subnet_name         = "public"
          vnet_resource_group = true
        }
      }
    }

    # inside_static_routes {
    #   static_route_list {
    #     custom_static_route {
    #       subnets {
    #         ipv4 {
    #           prefix = "10.1.0.0"
    #           plen   = "16"
    #         }
    #       }
    #       nexthop {
    #         type = "NEXT_HOP_USE_CONFIGURED"
    #         nexthop_address {
    #           ipv4 {
    #             addr = "10.1.52.1"
    #           }
    #         }
    #       }
    #       attrs = [
    #         "ROUTE_ATTR_INSTALL_FORWARDING",
    #         "ROUTE_ATTR_INSTALL_HOST"
    #       ]
    #     }
    #   }
    # }
  }

  vnet {
    existing_vnet {
      resource_group = azurerm_resource_group.rg.name
      vnet_name      = module.network.vnet_name
    }
  }

  lifecycle {
    ignore_changes = [labels]
  }
}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_azure_vnet_site.xc.name
  site_type        = "azure_vnet_site"
  labels           = local.f5xcCommonLabels
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "apply" {
  site_name        = volterra_azure_vnet_site.xc.name
  site_kind        = "azure_vnet_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false

  depends_on = [volterra_azure_vnet_site.xc]
}

############################ NIC Info ############################

# Collect data for F5 XC node "site local inside" NIC
data "azurerm_network_interface" "sli" {
  name                = "master-0-sli"
  resource_group_name = local.f5xcResourceGroup
  depends_on          = [volterra_tf_params_action.apply]
}

############################ Routes ############################

resource "azurerm_route_table" "webserver" {
  name                          = format("%s-rt-webserver-%s", var.projectPrefix, var.buildSuffix)
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = local.f5xcResourceGroup
  disable_bgp_route_propagation = false

  route {
    name                   = "route1"
    address_prefix         = var.remoteCidr
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.azurerm_network_interface.sli.private_ip_address
  }

  tags = {
    owner = var.resourceOwner
  }
  depends_on = [volterra_tf_params_action.apply]
}

resource "azurerm_subnet_route_table_association" "webserver" {
  subnet_id      = module.network.vnet_subnets[2]
  route_table_id = azurerm_route_table.webserver.id
}
