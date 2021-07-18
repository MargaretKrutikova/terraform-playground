# variables
variable "azure_subscription_id" {}

variable "region" {
  default = "Norway East" 
}
variable "failover_location" {
  default = "North Europe"
}
variable "cosmosdb_account_name" {}
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

resource "azurerm_resource_group" "cosmos" {
  name = "cosmos-db-mongo-rg"
  location = var.region
}

# cosmos db

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmosdb_account_name
  location            = azurerm_resource_group.cosmos.location
  resource_group_name = azurerm_resource_group.cosmos.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  
  enable_free_tier = true
  enable_automatic_failover = true

  consistency_policy {
    consistency_level = "Session"
  }
  capabilities {
    name = "mongoEnableDocLevelTTL"
  }
  capabilities {
    name = "EnableMongo"
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }
  geo_location {
    location          = azurerm_resource_group.cosmos.location
    failover_priority = 0
  }
}

output "cosmosdb_account_endpoint" {
  value = azurerm_cosmosdb_account.cosmos.endpoint
}

output "cosmosdb_account_name" {
  value = azurerm_cosmosdb_account.cosmos.name
}
