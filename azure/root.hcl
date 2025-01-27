terraform {
  source = "${path_relative_to_include()}/../modules/${basename(path_relative_to_include())}"
}

locals {
  has_region_hcl = fileexists(find_in_parent_folders("region.hcl", true))

  region_vars = (
    local.has_region_hcl ? 
    try({ inputs = read_terragrunt_config(find_in_parent_folders("region.hcl")).inputs }, { inputs = { region = "westus", zones = [] } }) : 
    { inputs = { region = "westus", zones = [] } }
  )

  region = local.region_vars.inputs.region
  zones  = local.region_vars.inputs.zones != null ? local.region_vars.inputs.zones : []
}


inputs = {
  region = local.region
  zones  = local.zones
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  terraform {
    required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        version = "4.1.0"
      }
    }
  }

  provider "azurerm" {
    features {}
  }
  EOF
}
