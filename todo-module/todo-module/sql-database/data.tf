data "azurerm_mssql_server" "polaris-db" {
  name                = var.sql_database_name
  resource_group_name = var.rg_name
}