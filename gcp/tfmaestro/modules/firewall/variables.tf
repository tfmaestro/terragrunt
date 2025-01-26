variable "project" {
  description = "The ID of the project to deploy resources in."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network to which the firewall rules will be applied."
  type        = string
}

variable "allow_firewall_rules" {
  description = "Map of firewall rules to allow."
  type = map(object({
    description      = string
    priority         = number
    protocol         = string
    ports            = optional(list(string))
    source_ip_ranges = optional(list(string))
    tags             = optional(list(string))
  }))
}
