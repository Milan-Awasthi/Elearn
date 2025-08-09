terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "799b8ac2-95c2-49ae-bf18-9a3bf3936b19"

}
resource "azurerm_resource_group" "akhi_rg1" {
  name     = "akhi_rg1"
  location = "Central India"
}


