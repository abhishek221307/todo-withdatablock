data "azurerm_public_ip" "pip" {
  name                = var.public_ip
  resource_group_name = var.rg_name
}
data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.rg_name
}


resource "azurerm_network_interface" "polaris" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.pip.id
  }
}
output "nic_id"  {
  value = azurerm_network_interface.polaris.id
}