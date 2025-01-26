locals {
  use_local_source = true
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment = local.env_vars.inputs.environment
  region      = local.region_vars.inputs.region
  name_prefix = "tfmaestro"
  subnet_cidr = "10.0.10.0/24"
  network_name = "${local.environment}-vpc"

  ec2_instances = {
    "${local.environment}-${local.name_prefix}-web-app-01" = {
      instance_type        = "t2.micro"
      availability_zone    = "${local.region}a"
      instance_description = "${local.environment} Web application"
      ip_host              = 4
    }
    "${local.environment}-${local.name_prefix}-web-app-02" = {
      instance_type        = "t2.micro"
      availability_zone    = "${local.region}a"
      instance_description = "${local.environment} Web application"
      ip_host              = 5
    }
  }

  allow_firewall_rules = {
    "allow-http" = {
      protocol         = "tcp"
      ports            = ["80"]
      priority         = 1000
      description      = "Allow http communication."
      source_ip_ranges = ["0.0.0.0/0"]
    }
    "allow-https" = {
      protocol         = "tcp"
      ports            = ["443"]
      priority         = 1001
      description      = "Allow https communication."
      source_ip_ranges = ["0.0.0.0/0"]
    }
    "allow-ssh-vpn" = {
      protocol         = "tcp"
      ports            = ["22"]
      priority         = 1002
      description      = "Allow ssh communication via VPN."
      source_ip_ranges = ["<YOUR_IP>/32"]
    }
    "allow-icmp" = {
      protocol         = "icmp"
      priority         = 2000
      description      = "Allow ICMP."
      source_ip_ranges = ["0.0.0.0/0"]
    }
  }
}

terraform {
  source = local.use_local_source ? "../../../../modules/ec2_firewall" : "git::ssh://git@github.com:tfmaestro/aws.git//modules/ec2_firewall?ref=${local.git_ref}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment         = local.environment
  region              = local.region
  name_prefix         = local.name_prefix
  network_name        = local.network_name
  subnet_cidr         = local.subnet_cidr
  ec2_instances       = local.ec2_instances
  ami_id              = "ami-07593001243a00d0a"
  allow_firewall_rules = local.allow_firewall_rules
}

