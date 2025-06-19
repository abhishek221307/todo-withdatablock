module "resource_group_name" {
  source = "./rg"

  rg_name  = "polaris_rg"
  location = "Japan East"
}

module "vnet" {
  depends_on = [module.resource_group_name]
  source     = "./vnet"

  virtual_network_name = "polaris_vnet"
  address_space        = ["192.168.0.0/16"]
  location             = "Japan East"
  rg_name              = "polaris_rg"
}

module "subnet_frontend" {
  depends_on = [module.vnet]
  source     = "./subnet"

  name                 = "polaris_subnet_frontend"
  rg_name              = "polaris_rg"
  virtual_network_name = "polaris_vnet"
  address_prefixes     = ["192.168.1.0/24"]
}



module "subnet_backend" {
  depends_on = [module.vnet]
  source     = "./subnet"

  name                 = "polaris_subnet_backend"
  rg_name              = "polaris_rg"
  virtual_network_name = "polaris_vnet"
  address_prefixes     = ["192.168.2.0/24"]
}

module "public_ip" {
  source     = "./public-ip"
  depends_on = [module.resource_group_name]
  name       = "polaris_pip"
  location   = "Japan East"
  rg_name    = "polaris_rg"
}

module "public_ip_backend" {
  source     = "./public-ip"
  depends_on = [module.resource_group_name]
  name       = "polaris_pip_backend"
  location   = "Japan East"
  rg_name    = "polaris_rg"
}
module "nic-frontend" {
  source               = "./nic"
  depends_on           = [module.subnet_frontend]
  name                 = "nic-frontend"
  location             = "Japan East"
  rg_name              = "polaris_rg"
  subnet               = "polaris_subnet_frontend"
  public_ip            = "polaris_pip"
  virtual_network_name = "polaris_vnet"



}
module "nic-backend" {
  source               = "./nic"
  depends_on           = [module.subnet_backend]
  name                 = "nic-backend"
  location             = "Japan East"
  rg_name              = "polaris_rg"
  subnet               = "polaris_subnet_backend"
  public_ip            = "polaris_pip_backend"
  virtual_network_name = "polaris_vnet"



}

module "virtual_machine_frontend" {
  depends_on = [module.subnet_frontend]

  source = "./vm"

  name                   = "polaris_frontendvm"
  rg_name                = "polaris_rg"
  network_interface_name = "nic-frontend"
  key_vault_name = "polaris-kv"
  admin_username         = "frontendadmin"
  admin_password         = "frontendpass"
  location               = "Japan East"
  publisher              = "Canonical"
  offer                  = "0001-com-ubuntu-server-focal"
  sku                    = "22_04-lts"

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
  )

}

module "virtual_machine_backend" {
  depends_on = [module.subnet_backend]

  source = "./vm"

  name                   = "polaris_backendvm"
  rg_name                = "polaris_rg"
  network_interface_name = "nic-backend"
  key_vault_name = "polaris-kv"
  admin_username         = "backendadmin"
  admin_password         = "backendpass"
  location               = "Japan East"
  publisher              = "Canonical"
  offer                  = "0001-com-ubuntu-server-focal"
  sku                    = "20_04-lts"

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y python3 python3-pip
              EOF
  )
}

module "server" {
  depends_on = [module.resource_group_name]
  source     = "./sql-server"

  sql_server_name = "polaris-server"
  rg_name         = "polaris_rg"
  location        = "Japan East"

    key_vault_name = "polaris-kv"
  admin_username         = "dbadmin"
  admin_password         = "dbpass"
}

module "database" {
  depends_on        = [module.server]
  source            = "./sql-database"
  sql_database_name = "polaris-database"
  rg_name           = "polaris_rg"
}