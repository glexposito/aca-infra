variable "location" {
  description = "Azure region for the resource group."
  type        = string
}

variable "environment" {
  description = "Deployment environment name, for example dev or prod."
  type        = string
}

variable "name" {
  description = "Base name for the workload or shared platform."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
