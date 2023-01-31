############################ F5 XC AWS VPC Sites ############################

resource "volterra_aws_vpc_site" "xc" {
  name                    = format("%s-aws-%s", var.projectPrefix, var.buildSuffix)
  namespace               = "system"
  aws_region              = var.awsRegion
  instance_type           = "t3.xlarge"
  disk_size               = "80"
  ssh_key                 = var.ssh_key
  logs_streaming_disabled = true
  no_worker_nodes         = true

  aws_cred {
    name      = var.f5xcCloudCredAWS
    namespace = "system"
    tenant    = var.f5xcTenant
  }

  ingress_egress_gw {
    aws_certified_hw         = "aws-byol-multi-nic-voltmesh"
    forward_proxy_allow_all  = true
    no_global_network        = true
    no_network_policy        = true
    no_outside_static_routes = true
    no_inside_static_routes  = true

    az_nodes {
      aws_az_name            = local.awsAz1
      reserved_inside_subnet = false
      disk_size              = 100

      inside_subnet {
        existing_subnet_id = module.vpc.private_subnets[0]
      }
      outside_subnet {
        existing_subnet_id = module.vpc.public_subnets[0]
      }
      workload_subnet {
        existing_subnet_id = aws_subnet.workload.id
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
    #             addr = "10.1.20.1"
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

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  lifecycle {
    ignore_changes = [labels]
  }
}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_aws_vpc_site.xc.name
  site_type        = "aws_vpc_site"
  labels           = local.f5xcCommonLabels
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "apply" {
  site_name        = volterra_aws_vpc_site.xc.name
  site_kind        = "aws_vpc_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false

  depends_on = [volterra_aws_vpc_site.xc]
}

############################ Collect XC Node Info ############################

# Instance info
data "aws_instances" "xc" {
  instance_state_names = ["running"]
  instance_tags = {
    "ves-io-site-name" = volterra_aws_vpc_site.xc.name
  }

  depends_on = [volterra_tf_params_action.apply]
}

# NIC info
data "aws_network_interface" "xc_sli" {
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instances.xc.ids[0]]
  }
  filter {
    name   = "tag:ves.io/interface-type"
    values = ["site-local-inside"]
  }
}
