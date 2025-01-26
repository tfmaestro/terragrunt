locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  use_local_source = true

  subnets = {
    "${local.env_vars.inputs.environment}-tg-subnet-01" = {
      cidr                     = "10.0.3.0/24"
      region                   = "europe-central2"
      private_ip_google_access = true
    },
    "${local.env_vars.inputs.environment}-tg-subnet-02" = {
      cidr                     = "10.0.4.0/24"
      region                   = "us-central1"
      private_ip_google_access = true
    }
  }
}

terraform {
  source = local.use_local_source ? "../../../../modules/vpc" : "git::ssh://git@github.com/tfmaestro/gcp.git//modules/vpc?ref=${local.git_ref}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  project       = local.project_vars.inputs.project
  region        = local.project_vars.inputs.region
  environment   = local.env_vars.inputs.environment
  description   = "Production environment VPC"
  routing_mode  = "GLOBAL"
  subnets       = local.subnets
  name          = local.env_vars.inputs.environment 
}
