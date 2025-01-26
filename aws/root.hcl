terraform {
  source = "${path_relative_to_include()}/../modules/${basename(path_relative_to_include())}"
}

locals {
  has_region_hcl = fileexists(find_in_parent_folders("region.hcl", true))

  region_vars = (
    local.has_region_hcl ? 
    try({ inputs = merge({ region = "us-east-1", zones = [] }, read_terragrunt_config(find_in_parent_folders("region.hcl")).inputs) }, { inputs = { region = "us-east-1", zones = [] } }) : 
    { inputs = { region = "us-east-1", zones = [] } }
  )

  region = local.region_vars.inputs.region
  zones  = local.region_vars.inputs.zones
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "5.64.0"
      }
    }
  }

  provider "aws" {
    region = "${local.region}"
  }
  EOF
}

inputs = {
  region = local.region
}
