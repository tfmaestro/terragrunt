locals {
  use_local_source = true
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars         = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment      = local.env_vars.inputs.environment
  region           = local.region_vars.inputs.region
}

terraform {
  source = local.use_local_source ? "../../../../modules/vm" : "git::ssh://git@github.com/tfmaestro/gcp.git//modules/vm?ref=${local.git_ref}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  project                  = local.project_vars.inputs.project
  region                   = local.region
  environment              = local.environment
  subnetwork_ip_cidr_range = "10.0.1.0/24"
  compute_engines = {
    "${local.env_vars.inputs.environment}-tfmaestro-web-app-tg-01" = {
      machine_type        = "f1-micro"
      machine_location    = "${local.region}-a"
      network_tags        = ["app", "http-server", "https-server"]
      external_ip         = true
      machine_description = "Web ${local.env_vars.inputs.environment} application instance 01"
      ip_host             = 2
    }
    "${local.env_vars.inputs.environment}-tfmaestro-web-app-tg-02" = {
      machine_type        = "f1-micro"
      machine_location    = "${local.region}-b"
      network_tags        = ["app", "http-server", "https-server"]
      external_ip         = true
      machine_description = "Web ${local.env_vars.inputs.environment} application instance 02"
      ip_host             = 3
    }
  }
}

