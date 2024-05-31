terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.43.0"

    }

  }
}
provider "azurerm" {
  features {

  }
  skip_provider_registration = true

}
resource "azurerm_resource_group" "rg" {
  name     = "809-eae8125f-deploy-to-azure-using-the-terraform-c"
  location = "West US"
}

resource "azurerm_storage_account" "strgaccnt" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.rg.location
  name                     = "strgaccnt128941"
  resource_group_name      = azurerm_resource_group.rg.name

}
