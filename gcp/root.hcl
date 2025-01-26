locals {
  git_ref = "main"
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  project   = local.project_vars.inputs.project
}

terraform {
  source = "${path_relative_to_include()}/../modules/${basename(path_relative_to_include())}"
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  terraform {
    required_providers {
      google = {
        source  = "hashicorp/google"
        version = "5.38.0"
      }
    }
  }
  provider "google" {
    project = "${local.project}"
  }
  EOF
}
inputs = {
  project_id = local.project
}
