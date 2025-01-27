module "vpc" {
  source       = "../../modules/vpc"
  name         = "dev"
  description  = "Development environment VPC"
  routing_mode = "GLOBAL"

  subnets = {
    "dev-subnet-01" = {
      cidr                     = "10.1.1.0/24"
      region                   = "europe-central2"
      private_ip_google_access = true
    },
    "dev-subnet-02" = {
      cidr                     = "10.1.2.0/24"
      region                   = "us-central1"
      private_ip_google_access = true
    }
  }
}
