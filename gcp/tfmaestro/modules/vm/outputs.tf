output "instance_ips" {
  description = "The internal IP addresses of the created instances"
  value       = { for name, instance in google_compute_instance.main : name => instance.network_interface[0].network_ip }
}

output "instance_external_ips" {
  description = "The external IP addresses of the created instances"
  value       = { for name, instance in google_compute_instance.main : name => instance.network_interface[0].access_config[0].nat_ip }
}

output "instance_names" {
  description = "The names of the created instances"
  value       = { for name, instance in google_compute_instance.main : name => instance.name }
}