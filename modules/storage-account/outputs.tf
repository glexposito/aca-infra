output "storage_account_name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "storage_account_id" {
  description = "Storage account ID."
  value       = azurerm_storage_account.this.id
}

output "container_names" {
  description = "Blob container names."
  value       = [for container in azurerm_storage_container.this : container.name]
}
