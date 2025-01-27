variable "name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}
variable "location" {
  description = "Location for the resources"
  type        = string
  default     = "westus"
}
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}
variable "private_subnets" {
  description = "Map of private subnets configuration"
  type        = map(object({
    address_prefix = string
  }))
}
variable "public_subnets" {
  description = "Map of public subnets configuration"
  type        = map(object({
    address_prefix = string
  }))
}
variable "public_database_subnets" {
  description = "Map of public subnets configuration"
  type        = map(object({
    address_prefix = string
  }))
}
