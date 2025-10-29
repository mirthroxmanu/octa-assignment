terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.60.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }    
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }    
  }

}

provider "kubernetes" {
  config_path = "./octabyte-kubeconfig.yaml"
  alias       = "kube"
}


provider "kubectl" {
  config_path = "./octabyte-kubeconfig.yaml"
  alias       = "kubectl"
  load_config_file       = true
}

provider "helm" {
  kubernetes = {
    config_path = "./octabyte-kubeconfig.yaml"
  }
  alias = "helm"
}



provider "aws" {
  region = "ap-south-1"
}

