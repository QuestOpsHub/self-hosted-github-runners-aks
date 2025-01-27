#--------------------
# Required Providers
#--------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.16.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.33.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.0"
    }
  }
  required_version = ">=0.13"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}