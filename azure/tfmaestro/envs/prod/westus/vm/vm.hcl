locals {
  use_local_source = true
  env_vars         = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment      = local.env_vars.inputs.environment
  location         = local.region_vars.inputs.region
  zones            = local.region_vars.inputs.zones
  network_name     = "${local.environment}-vnet"
  vm_config = {
    "${local.environment}-tfmaestro-web-app-01" = {
      private_ip          = "10.0.11.5"
      public_ip_name      = "${local.environment}-tfmaestro-web-app-01 public IP"
      machine_type        = "Standard_DS1_v2"
      machine_description = "Internal ${local.environment} web application instance"
    }
    "${local.environment}-tfmaestro-web-app-02" = {
      private_ip          = "10.0.11.4"
      public_ip_name      = "${local.environment}-tfmaestro-web-app-02 public IP"
      machine_type        = "Standard_DS1_v2"
      machine_description = "Internal ${local.environment} web application instance"
    }
  }

  firewall_rules = {
    "allow-http" = {
      protocol              = "Tcp"
      ports                 = ["80"]
      priority              = 1000
      description           = "Allow http communication."
      source_address_prefix = ["0.0.0.0/0"]
    }
    "allow-https" = {
      protocol              = "Tcp"
      ports                 = ["443"]
      priority              = 1001
      description           = "Allow https communication."
      source_address_prefix = ["0.0.0.0/0"]
    }
    "allow-ssh-vpn" = {
      protocol              = "Tcp"
      ports                 = ["22"]
      priority              = 101
      description           = "Allow ssh communication via VPN."
      source_address_prefix = ["<TWÓJ_IP>/0"]
    }
    "allow-icmp" = {
      protocol              = "Icmp"
      ports                 = []
      priority              = 2000
      description           = "Allow ICMP."
      source_address_prefix = ["0.0.0.0/0"]
    }
  }
}

terraform {
  source = local.use_local_source ? "../../../../modules/vm" : "git::ssh://git@github.com/tfmaestro/azure.git//modules/vm?ref=${local.git_ref}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  location                = local.location
  environment             = local.environment
  network_name            = local.network_name
  vm_config               = local.vm_config
  firewall_rules          = local.firewall_rules
  resource_group_name     = "${local.environment}-rg"
  resource_group_location = local.location
}





















