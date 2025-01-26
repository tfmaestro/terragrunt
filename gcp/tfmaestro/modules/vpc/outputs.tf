output "vpc_id" {
  description = "The ID of the created VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the created VPC network"
  value       = google_compute_network.vpc.name
}

output "subnets" {
  description = "Details of the created subnets"
  value = {
    for k, subnet in google_compute_subnetwork.subnet :
    k => {
      id                       = subnet.id
      name                     = subnet.name
      ip_cidr_range            = subnet.ip_cidr_range
      region                   = subnet.region
      private_ip_google_access = subnet.private_ip_google_access
    }
  }
}