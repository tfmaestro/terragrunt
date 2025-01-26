locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  use_local_source = true
  public_subnets = {
    "${local.env_vars.inputs.environment}-public-subnet-01" = {
      cidr                    = "10.0.10.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
    },
    "${local.env_vars.inputs.environment}-public-subnet-02" = {
      cidr                    = "10.0.11.0/24"
      availability_zone       = "us-east-1b"
      map_public_ip_on_launch = true
    }
  }
  private_subnets = {
    "${local.env_vars.inputs.environment}-private-subnet-01" = {
      cidr                    = "10.0.12.0/24"
      availability_zone       = "us-east-1c"
      map_public_ip_on_launch = false
    },
    "${local.env_vars.inputs.environment}-private-subnet-02" = {
      cidr                    = "10.0.13.0/24"
      availability_zone       = "us-east-1d"
      map_public_ip_on_launch = false
    }
  }
}

terraform {
  source = local.use_local_source ? "../../../../modules/vpc" : "git::ssh://git@github.com/tfmaestro/aws.git//modules/vpc?ref=${local.git_ref}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment      = local.env_vars.inputs.environment
  description      = "Production environment VPC"
  cidr_block       = "10.0.0.0/16"
  name             = local.env_vars.inputs.environment
  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
}
