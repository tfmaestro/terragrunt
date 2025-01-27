dependency "vpc" {
  config_path = "../vpc/vpc.hcl"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment  = local.env_vars.inputs.environment
  project      = local.project_vars.inputs.project
  use_local_source = true


  allow_firewall_rules = {
    "allow-http" = {
      protocol         = "tcp"
      ports            = ["80"]
      priority         = 1000
      tags             = ["https-server"]
      description      = "Allow https communication."
      source_ip_ranges = ["0.0.0.0/0"]
    }
    "allow-https" = {
      protocol         = "tcp"
      ports            = ["443"]
      priority         = 1001
      tags             = ["https-server"]
      description      = "Allow https communication."
      source_ip_ranges = ["0.0.0.0/0"]
    }
    "allow-ssh-vpn" = {
      protocol         = "tcp"
      ports            = ["22"]
      priority         = 1002
      description      = "Allow ssh communication via VPN."
      source_ip_ranges = ["<TWOJE_IP>/32"]
    }
    "allow-icmp" = {
      protocol         = "icmp"
      priority         = 1999
      description      = "Allow ICMP."
      source_ip_ranges = ["0.0.0.0/0"]
    }
  }
}

terraform {
  source = local.use_local_source ? "../../../../modules/firewall" : "git::ssh://git@github.com/tfmaestro/gcp.git//modules/firewall?ref=${local.git_ref}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  project             = local.project
  environment         = local.environment
  network_name        = dependency.vpc.outputs.vpc_name
  allow_firewall_rules = local.allow_firewall_rules
}
