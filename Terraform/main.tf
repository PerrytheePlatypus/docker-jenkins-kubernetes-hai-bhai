
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  required_version = ">=1.0.0"
}

provider "azurerm" {
  subscription_id = "bf9c4a23-fb6a-43a2-a6c4-9e224b69b5ac"
  tenant_id       = "ccb92876-d4ba-4bc7-b967-c9177170db6d"
  client_id       = "a2512cbf-86c8-4423-bf4c-e995761d7450"
  client_secret   = "7wx8Q~hHRP3eCBWIOPgyPwDg5FJu14usW-xYMcYl"
  features {}
}

# Variables
variable "location" {
  default = "East US 2"
}

variable "resource_group_name" {
  default = "rg-aks-acr"
}

variable "acr_name" {
  default = "kubernetesacr04082003" 
}

variable "aks_cluster_name" {
  default = "mycluster04082003"
}

variable "dns_prefix" {
  default = "myakscluster"
}

variable "node_count" {
  default = 2
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "Development"
  }
}

# Role assignment to allow AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id

 
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}


