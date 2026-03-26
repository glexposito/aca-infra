output "container_group_id" {
  description = "Azure Container Group ID."
  value       = azurerm_container_group.this.id
}

output "container_group_name" {
  description = "Azure Container Group name."
  value       = azurerm_container_group.this.name
}

output "container_group_ip_address" {
  description = "Assigned IP address when available."
  value       = try(azurerm_container_group.this.ip_address, null)
}

output "container_group_fqdn" {
  description = "Assigned FQDN when available."
  value       = try(azurerm_container_group.this.fqdn, null)
}
