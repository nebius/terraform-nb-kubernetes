terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "> 0.8"
    }

    random = {
      source  = "hashicorp/random"
      version = "> 3.3"
    }
  }
}


data "yandex_client_config" "client" {}

data "yandex_kubernetes_cluster" "kubernetes" {
  name = yandex_kubernetes_cluster.kube_cluster.name
}
