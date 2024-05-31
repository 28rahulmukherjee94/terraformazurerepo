terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.43.0"
    }

  }
  cloud {
    organization = "terraformcloudguru"

    workspaces {
      name = "remotestate"
    }
  }
}

provider "azurerm" {
  features {

  }
  skip_provider_registration = true
}

resource "azurerm_resource_group" "rg" {
  name     = "1-b6986a1b-playground-sandbox"
  location = "South Central US"

}
