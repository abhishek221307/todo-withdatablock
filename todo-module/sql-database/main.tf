data "azurerm_mssql_server" "polaris-db" {
  name                = var.sql_database_name
  resource_group_name = var.rg_name
}
resource "azurerm_mssql_database" "polaris-db" {
  name         = var.sql_database_name
  server_id    = data.azurerm_mssql_server.polaris-db.id
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

}
