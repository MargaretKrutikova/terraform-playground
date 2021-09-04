# variables
variable "azure_subscription_id" {}
variable "region" {
  default = "Norway East" 
}

variable "app_name" {
  default = "antura-web-app"
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
  name = "antura-app-rg"
  location = var.region
}

# app service

resource "azurerm_app_service_plan" "local" {
  name = "antura-app-service-plan"
  location = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  kind = "Windows"
  reserved = false
    
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "local" {
  name = var.app_name
  location = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  app_service_plan_id = azurerm_app_service_plan.local.id
  
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "12-lts"
  }
}

output "webapp_link" {
  value = "https://${azurerm_app_service.local.default_site_hostname}"
}