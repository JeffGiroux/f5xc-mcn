terraform {
  required_version = ">= 1.2"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.18"
    }
  }
}

# Used to generate a random build suffix
resource "random_id" "buildSuffix" {
  byte_length = 2
}

locals {
  # Allow user to specify a build suffix, but fallback to random as needed.
  buildSuffix = coalesce(var.buildSuffix, random_id.buildSuffix.hex)
  commonLabels = {
    demo   = "mcn-f5xc"
    owner  = var.resourceOwner
    prefix = var.projectPrefix
    suffix = local.buildSuffix
  }
}

# Create a virtual site that will identify services deployed in AWS, Azure, and GCP.
resource "volterra_virtual_site" "site" {
  name        = format("%s-vsite-%s", var.projectPrefix, local.buildSuffix)
  namespace   = var.namespace
  description = format("Virtual site for %s-%s", var.projectPrefix, local.buildSuffix)
  labels      = local.commonLabels
  site_type   = "CUSTOMER_EDGE"
  site_selector {
    expressions = [
      join(",", [for k, v in local.commonLabels : format("%s = %s", k, v)])
    ]
  }
}
