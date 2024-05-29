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
  client_id                  = "514f8e9b-6220-463f-898b-16050acf012d"
  client_secret              = ""
  tenant_id                  = "84f1e4ea-8554-43e1-8709-f0b8589ea118"
  features {

  }

}

locals {
  resource_group_name = "1-e35e2bb4-playground-sandbox"
  location            = "eastus"

}


resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  resource_group_name = local.resource_group_name
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]
}

variable "storage_account_name" {
  type        = string
  default     = "stracc2288novaccount"

}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = "eastus"
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
  location            = "eastus"
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
    public_ip_address_id = azurerm_public_ip.app_public_ip.id
  }
  depends_on = [azurerm_virtual_network.vnet1,
  azurerm_public_ip.app_public_ip]
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

resource "azurerm_public_ip" "app_public_ip" {
  name                = "app_public_ip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_managed_disk" "source" {
  name                 = "app_disk"
  location             = local.location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "16"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "app_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.source.id
  virtual_machine_id = azurerm_windows_virtual_machine.appvm.id
  lun                = "10"
  caching            = "ReadWrite"
  depends_on = [ azurerm_windows_virtual_machine.appvm,
  azurerm_managed_disk.source ]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "ALLOWHTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  subnet_id                 = data.azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [ azurerm_network_security_group.nsg ]
}
