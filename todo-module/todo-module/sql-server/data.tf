data "azurerm_key_vault" "polaris" {
  name                = var.key_vault_name
  resource_group_name = var.rg_name
}
data "azurerm_key_vault_secret" "db-username" {
  name         = var.admin_username
  key_vault_id = data.azurerm_key_vault.polaris.id
}
data "azurerm_key_vault_secret" "db-password" {
  name         = var.admin_password
  key_vault_id = data.azurerm_key_vault.polaris.id
}