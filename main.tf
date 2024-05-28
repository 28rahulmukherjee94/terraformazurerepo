terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  subscription_id            = "2213e8b1-dbc7-4d54-8aff-b5e315df5e5b"
  client_id                  = "b8b69685-6371-4547-90c9-f43bbacdfbb4"
  client_secret              = ""
  tenant_id                  = "84f1e4ea-8554-43e1-8709-f0b8589ea118"
  features {

  }

}

locals {
  resource_group_name = "1-25c3f82d-playground-sandbox"
  location            = "westus"

}


resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  resource_group_name = local.resource_group_name
  location            = "westus"
  address_space       = ["10.0.0.0/16"]
}

variable "storage_account_name" {
  type        = string
  default     = "stracc28novaccount"

}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = "westus"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob"
  depends_on            = [azurerm_storage_account.example]
}

resource "azurerm_storage_blob" "iac" {
  name                   = "iac"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "C:/Users/rahul.g.mukherjee/Documents/IAC/main.tf"
  depends_on             = [azurerm_storage_container.data]
}




resource "azurerm_virtual_network" "app-vnet" {
  name                = "app-vnet"
  location            = "westus"
  resource_group_name = local.resource_group_name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

}

data "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.app-vnet.name
}



resource "azurerm_network_interface" "app-interface" {
  name                = "app-interface"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [azurerm_virtual_network.vnet1]
}

resource "azurerm_windows_virtual_machine" "appvm" {
  name                = "appvm"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.app-interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  depends_on = [azurerm_network_interface.app-interface]
}
