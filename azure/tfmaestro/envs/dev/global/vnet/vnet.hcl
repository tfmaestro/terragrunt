locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  use_local_source = true
  region           = "westus"
  address_space    = ["10.0.0.0/16"]

  private_subnets = {
    "${local.env_vars.inputs.environment}-private-subnet-01" = {
      address_prefix = "10.0.14.0/24"
    }
    "${local.env_vars.inputs.environment}-private-subnet-02" = {
      address_prefix = "10.0.15.0/24"
    }
  }

  public_subnets = {
    "${local.env_vars.inputs.environment}-public-subnet-01" = {
      address_prefix = "10.0.16.0/24"
    }
    "${local.env_vars.inputs.environment}-public-subnet-02" = {
      address_prefix = "10.0.17.0/24"
    }
  }

  public_database_subnets = {
    "${local.env_vars.inputs.environment}-database-public-subnet-01" = {
      address_prefix = "10.0.18.0/24"
    }
  }
}

terraform {
  source = local.use_local_source ? "../../../../modules/vnet" : "git::ssh://git@github.com:tfmaestro/azure.git//modules/vnet?ref=${local.git_ref}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  name                    = local.env_vars.inputs.environment
  location                = local.region
  environment             = local.env_vars.inputs.environment
  resource_group_name     = "${local.env_vars.inputs.environment}-rg"
  address_space           = local.address_space
  private_subnets         = local.private_subnets
  public_subnets          = local.public_subnets
  public_database_subnets = local.public_database_subnets
}
