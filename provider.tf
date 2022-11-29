terraform {
  required_providers{
    source  = "hashicorp/azurerm"
    version = "3.0.0"
  }
}

provider "azurerm"{
    features {}
}