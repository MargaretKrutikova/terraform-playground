# variables

# path to public key on the local machine
variable "public_key_path" {}
variable "azure_subscription_id" {}
variable "region" {
  default = "Norway East" 
}
variable "admin_username" {
  default = "adminuser"
}
variable "network_address_space" {
  default = "10.0.0.0/16"
}
variable "subnet_address_space" {
  default = "10.0.2.0/24"
}

# providers

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

resource "azurerm_resource_group" "local" {
  name = "terraform-resources"
  location = var.region

  tags = {
    "environment" = "demo"
  }
}

# Network

resource "azurerm_virtual_network" "local" {
  name = "terraform-network"
  resource_group_name = azurerm_resource_group.local.name
  location = azurerm_resource_group.local.location
  address_space = [ var.network_address_space ]
  tags = {
    "environment" = "demo"
  }
}

resource "azurerm_subnet" "local" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.local.name
  virtual_network_name = azurerm_virtual_network.local.name
  address_prefixes     = [var.subnet_address_space]
}

resource "azurerm_public_ip" "local" {
  name = "terraform-ip"
  allocation_method = "Static"
  domain_name_label = "terraform-demo"

  resource_group_name = azurerm_resource_group.local.name
  location = azurerm_resource_group.local.location
  tags = {
    "environment" = "demo"
  }
}

resource "azurerm_network_interface" "local" {
  name = "terraform-machine"
  resource_group_name = azurerm_resource_group.local.name
  location = azurerm_resource_group.local.location
  
  ip_configuration {
    name = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.local.id
    public_ip_address_id = azurerm_public_ip.local.id
  }
}

# Security rules

resource "azurerm_network_security_group" "local" {
  name = "terraform-security-group"
  resource_group_name = azurerm_resource_group.local.name
  location = azurerm_resource_group.local.location
}

resource "azurerm_network_security_rule" "https" {
  name = "https"
  priority = 300
  direction = "Inbound"
  access = "Allow"
  protocol = "tcp"
  destination_port_range = "443"
  source_address_prefix = "*"
  source_port_range = "*"
  resource_group_name = azurerm_resource_group.local.name
  network_security_group_name = azurerm_network_security_group.local.name
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "ssh" {
  name = "ssh"
  access = "Allow"
  destination_port_range = "22"
  direction = "Inbound"
  priority = 290
  protocol = "tcp"
  source_address_prefix = "*"
  source_port_range = "*"
  resource_group_name = azurerm_resource_group.local.name
  network_security_group_name = azurerm_network_security_group.local.name
  destination_address_prefix = "*"
}

resource "azurerm_network_interface_security_group_association" "name" {
  network_interface_id = azurerm_network_interface.local.id
  network_security_group_id = azurerm_network_security_group.local.id
}

# VM
resource "azurerm_linux_virtual_machine" "local" {
  name = "terraform-vm"
  
  resource_group_name = azurerm_resource_group.local.name
  location = azurerm_resource_group.local.location

  size = "Standard_A1_v2"
  network_interface_ids = [ azurerm_network_interface.local.id ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  computer_name = "terraform-vm-demo"
  admin_username = var.admin_username
  disable_password_authentication = true
  
  admin_ssh_key {
    username = var.admin_username
    public_key = file(var.public_key_path)
  }

  # connection {
  #   type = "ssh"
  #   host = azurerm_public_ip.local.ip_address
  #   user = "testuser"
  #   private_key = file(var.private_key_path)
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo yum install nginx -y",
  #     "sudo service nginx start"
  #   ]
  # }
  
  tags = {
    "environment" = "demo"
  }
}

# output
output "vm_public_ip_address" {
  value = azurerm_linux_virtual_machine.local.public_ip_address
}
