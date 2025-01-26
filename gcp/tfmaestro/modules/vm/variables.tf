variable "compute_engines" {
  description = "Map of compute engine instances to create, keyed by instance name."
  type = map(object({
    machine_type        = string
    machine_description = optional(string)
    machine_location    = string
    network_tags        = optional(list(string))
    ip_host             = number
  }))
}

variable "ip_forward" {
  description = "Whether the instance can send and receive packets with non-matching destination or source IPs."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the instance."
  type        = bool
  default     = false
}

variable "machine_labels" {
  description = "A map of labels to assign to the instances."
  type        = map(string)
  default     = {}
}

variable "boot_image" {
  description = "The boot image to use for the instances."
  type        = string
  default     = "debian-cloud/debian-11-bullseye-v20240910"
}

variable "subnetwork_ip_cidr_range" {
  description = "The CIDR range for the subnetwork."
  type        = string
}

variable "region" {
  description = "The region in which to create the internal addresses."
  type        = string
}

variable "project" {
  description = "The ID of the project to deploy resources in."
  type        = string
}