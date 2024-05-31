terraform {
#   required_version = "~>1.3.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "3.43.0"
    }
    
  }
  cloud {
    organization = "terraformcloudguru"

    workspaces {
      name = "terraformcloudremotestate2"
    }
  }
}

provider "azurerm" {
    features {
      
    }
    skip_provider_registration = true
  
}
resource "azurerm_resource_group" "rg" {
    name = "1-36a643dc-playground-sandbox"
    location = "South Central US"
  
}
