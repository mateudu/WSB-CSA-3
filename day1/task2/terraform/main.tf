terraform {
  required_version = "~>1.3.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.26.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "studentId" {
  default = "xxxxx"
}

variable "location" {
  default = "westeurope"
}

variable "adminUsername" {
  default = "LocalAdminUser"
}

variable "adminPassword" {
  default   = "Passw00rd!Passw00rd!"
  sensitive = true
}

variable "resourceGroupName" {
  default = "lab12"
}

locals {
  nicName         = "${local.vmName}-nic-01"
  nicPublicIpName = "${local.vmName}-nic-01-pip"
  vmName          = "vm${var.studentId}tf"
  vmOsDiskName    = "${local.vmName}-disk-os"
  vnetName        = "lab12-vnet-tf"
  vnetSubnetName  = "subnet01"
}

resource "azurerm_public_ip" "pip" {
  name                = local.nicPublicIpName
  resource_group_name = var.resourceGroupName
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnetName
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sub01" {
  name                 = local.vnetSubnetName
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = local.nicName
  location            = var.location
  resource_group_name = var.resourceGroupName

  ip_configuration {
    name                          = "ipconfig1"
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.sub01.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = local.vmName
  resource_group_name   = var.resourceGroupName
  location              = var.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B2ms"
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    create_option = "FromImage"
    disk_size_gb  = 256
    name          = local.vmOsDiskName
  }
  os_profile {
    computer_name  = local.vmName
    admin_username = var.adminUsername
    admin_password = var.adminPassword
  }
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }
}
