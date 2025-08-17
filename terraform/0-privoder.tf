terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.17"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = "../clusters/kubeconfig.yaml"
  }
}

provider "kubernetes" {
  config_path = "../clusters/kubeconfig.yaml"
}
