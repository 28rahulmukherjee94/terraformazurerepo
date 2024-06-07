################################
# VARIABLES
################################
variable "resource_group_name" {
  type        = string
  description = "Enter Resource group name"

}

variable "location" {
  type    = string
  default = "eastus"

}

variable "vnet_cidr_range" {
  type    = list(string)
  default = ["10.0.0.0/16"]

}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]

}

variable "subnet_name" {
  type    = list(string)
  default = ["web", "database"]

}

###############################
# PROVIDERS
###############################

# terraform {
#   required_providers {
#     azurerm = {
#         source = "hashicorp/azurerm"
#         version = "3.106.1"
#     }
#   }
# }

provider "azurerm" {
  features {

  }
  skip_provider_registration = true

}

#################################
# RESOURCES
#################################

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"
  # insert the 3 required variables here
  resource_group_name = var.resource_group_name
  vnet_location       = var.location
  vnet_name           = var.resource_group_name
  address_space       = var.vnet_cidr_range
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_name
  nsg_ids             = {}
  use_for_each        = false

  tags = {
    environment = "dev"
    costcenter  = "it"
  }

}

output "vnet_id" {
  value = module.vnet.vnet_id

}
