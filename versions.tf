terraform {
  required_version = ">= 1.0.0"

  required_providers {
    nebius = {
      source = "terraform-registry.storage.ai.nebius.cloud/nebius/nebius"
      version = ">= 0.8.3"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "> 3.3"
    }
  }
}

data "nebius_client_config" "client" {}

data "nebius_kubernetes_cluster" "kubernetes" {
  name = nebius_kubernetes_cluster.kube_cluster.name
}
