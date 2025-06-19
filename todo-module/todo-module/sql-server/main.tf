

resource "azurerm_mssql_server" "polaris-dbserver" {
  name                         = var.sql_server_name
  resource_group_name          = var.rg_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.db-username.value
  administrator_login_password = data.azurerm_key_vault_secret.db-password.value
  minimum_tls_version          = "1.2"
}
