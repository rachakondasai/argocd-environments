terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
    }
  }
}

provider "aws" {
  region = var.region
}

# Discover existing EKS cluster details
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

# OIDC provider for IRSA used by some addons
data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Wire Kubernetes and Helm providers to the EKS cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# Install ArgoCD via AWS EKS Blueprints Addons
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = ">= 1.0.0"

  cluster_name      = var.cluster_name
  cluster_endpoint  = data.aws_eks_cluster.this.endpoint
  cluster_version   = data.aws_eks_cluster.this.version
  oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn

  enable_argocd = true

  # Uncomment to expose ArgoCD via LoadBalancer
  # argocd = {
  #   values = [
  #     yamlencode({
  #       server = {
  #         service = {
  #           type = "LoadBalancer"
  #         }
  #       }
  #     })
  #   ]
  # }
}