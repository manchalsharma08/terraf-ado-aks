# ----------------------------------------------------
# Terraform Configuration
# ----------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.47.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "azurerm" {
    resource_group_name  = "backenb-rg"
    storage_account_name = "backenb8786757579837"
    container_name       = "backenbcon"
    key                  = "dev.terraform.tfstate"
  }
}

# ----------------------------------------------------
# Provider Configuration
# ----------------------------------------------------
provider "azurerm" {
  features {}
  subscription_id = "a029ac91-4ead-438a-b2ee-394333e687e0"
  tenant_id       = "9fd46876-3d8e-430b-bbf2-d44cc4d29b1f"
}

# ----------------------------------------------------
# Random String for Unique ACR Name
# ----------------------------------------------------
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

# ----------------------------------------------------
# Resource Group
# ----------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "Abhi-rg"
  location = "westus"
}

# ----------------------------------------------------
# ACR
# ----------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = "abhiacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  depends_on          = [azurerm_resource_group.rg]
}

# ----------------------------------------------------
# AKS Cluster with Calico Network Policy
# ----------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
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

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }
}

# ----------------------------------------------------
# Azure-ACR-Role
# ----------------------------------------------------
resource "azurerm_role_assignment" "acrrole" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  depends_on                       = [azurerm_kubernetes_cluster.aks]
}

# ----------------------------------------------------
# Outputs
# ----------------------------------------------------
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_resource_group" {
  value = azurerm_resource_group.rg.name
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}
