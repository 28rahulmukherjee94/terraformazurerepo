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
  subscription_id            = 
  client_id                  = 
  client_secret              = 
  tenant_id                  =  
  features {

  }

}

locals {
  resource_group_name = "1-25c3f82d-playground-sandbox"

}


resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  resource_group_name = local.resource_group_name
  location            = "westus"
  address_space       = ["10.0.0.0/16"]
}

variable "storage_account_name" {
  type = string
  description = "Please enter teh storage account name"
  
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
  depends_on = [ azurerm_storage_account.example ]
}

resource "azurerm_storage_blob" "iac" {
  name                   = "iac"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "C:/Users/rahul.g.mukherjee/Documents/IAC/main.tf"
  depends_on = [ azurerm_storage_container.data ]
}
