terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "799b8ac2-95c2-49ae-bf18-9a3bf3936b19"

}
resource "azurerm_resource_group" "Milan_rg1" {
  name     = "Milan_rg1"
  location = "Central India"

}
resource "azurerm_virtual_network" "vnet_Milan" {
  name                = "MilanVnet"
  address_space       = ["10.16.0.0/27"]
  location            = azurerm_resource_group.Milan_rg1.location
  resource_group_name = azurerm_resource_group.Milan_rg1.name
}

resource "azurerm_subnet" "subnet_frontend" {
  name                 = "frontend_Milan"
  resource_group_name  = azurerm_resource_group.Milan_rg1.name
  virtual_network_name = azurerm_virtual_network.vnet_Milan.name
  address_prefixes     = ["10.16.0.0/28"]
  depends_on           = [azurerm_virtual_network.vnet_Milan]
}
resource "azurerm_subnet" "subnet_backend" {
  name                 = "backend_Milan"
  resource_group_name  = azurerm_resource_group.Milan_rg1.name
  virtual_network_name = azurerm_virtual_network.vnet_Milan.name
  address_prefixes     = ["10.16.0.16/28"]
  depends_on           = [azurerm_virtual_network.vnet_Milan]
}



#########################
# Public IPs
#########################
resource "azurerm_public_ip" "frontend_ip" {
  name                = "frontend-public-ip"
  location            = azurerm_resource_group.Milan_rg1.location
  resource_group_name = azurerm_resource_group.Milan_rg1.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_public_ip" "backend_ip" {
  name                = "backend-public-ip"
  location            = azurerm_resource_group.Milan_rg1.location
  resource_group_name = azurerm_resource_group.Milan_rg1.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

#########################
# Network Interfaces
#########################
resource "azurerm_network_interface" "nic_frontend" {
  name                = "nic-frontend-Milan"
  location            = azurerm_resource_group.Milan_rg1.location
  resource_group_name = azurerm_resource_group.Milan_rg1.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_frontend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend_ip.id
  }
}

resource "azurerm_network_interface" "nic_backend" {
  name                = "nic-backend-Milan"
  location            = azurerm_resource_group.Milan_rg1.location
  resource_group_name = azurerm_resource_group.Milan_rg1.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.backend_ip.id
  }
}

#########################
# Linux Virtual Machines
#########################
variable "admin_username" {
  default = "Milanc1985"
}

variable "admin_password" {
  default = "Oneday@1231985"
}

resource "azurerm_linux_virtual_machine" "frontend_vm" {
  name                            = "frontend-vm-Milan"
  location                        = azurerm_resource_group.Milan_rg1.location
  resource_group_name             = azurerm_resource_group.Milan_rg1.name
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic_frontend.id,
  ]

  os_disk {
    name                 = "frontend-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    role = "frontend"
  }
}

resource "azurerm_linux_virtual_machine" "backend_vm" {
  name                            = "backend-vm-Milan"
  location                        = azurerm_resource_group.Milan_rg1.location
  resource_group_name             = azurerm_resource_group.Milan_rg1.name
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic_backend.id,
  ]

  os_disk {
    name                 = "backend-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = {
    role = "backend"
  }
}
