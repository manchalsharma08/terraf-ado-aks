# ----------------------------------------------------
# Provider Configuration
# ----------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.47.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "tera-rg"
    storage_account_name = "terastorage3567987"
    container_name = "teracon"
    key = "ram.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "a029ac91-4ead-438a-b2ee-394333e687e0"  # Your Subscription ID
}

# ----------------------------------------------------
# Resource Group
# ----------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "Abhi-rg"
  location = "westus"
}

# ----------------------------------------------------
# AKS Cluster with Calico Network Policy
# ----------------------------------------------------
resource "azurerm_kubernetes_cluster" "example" {
  name                = "abhi-aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "abhipool"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  # ✅ Networking Configuration (Calico)
  network_profile {
    network_plugin = "azure"    # Azure CNI plugin
    network_policy = "calico"   # Enables Calico for network security policies
  }

  
}


