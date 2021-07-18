# variables
variable "azure_subscription_id" {}

variable "region" {
  default = "Norway East" 
}
variable "cosmosdb_account_name" {}
variable "cosmosdb_rg" {}

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

resource "azurerm_resource_group" "wordsdb" {
  name = "words-db-resource-group"
  location = var.region
  tags = {
    "environment" = "production"
  }
}
resource "azurerm_resource_group" "wordsapp" {
  name = "words-app-resource-group"
  location = var.region
  tags = {
    "environment" = "production"
  }
}

# database

resource "azurerm_cosmosdb_mongo_database" "wordsdb" {
  name = "words-db-production"
  account_name = var.cosmosdb_account_name
  resource_group_name = var.cosmosdb_rg
}

# app service

resource "azurerm_app_service_plan" "wordsapp" {
  name = "words-appserviceplan"
  location = azurerm_resource_group.wordsapp.location
  resource_group_name = azurerm_resource_group.wordsapp.name

  sku {
    tier = "Free"
    size = "S1"
  }
}

resource "azurerm_app_service" "wordsapp" {
  name = "words-appservice"
  location = azurerm_resource_group.wordsapp.location
  resource_group_name = azurerm_resource_group.wordsapp.name
  app_service_plan_id = azurerm_app_service_plan.wordsapp.id

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "12-lts"
  }
}
