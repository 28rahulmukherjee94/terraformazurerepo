terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
    
  }
  skip_provider_registration = true
}
# resource "azurerm_resource_group" "mlstoragrg" {      # Resource block
#     name = "rg-mlstorage-dev"
#     location = "Australia East"

# }

resource "azurerm_storage_account" "storage" {
  resource_group_name      = "1-91754a9a-playground-sandbox"
  name                     = "strg101"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"


}