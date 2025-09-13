output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = try(module.eks_blueprints_addons.argocd.namespace, "argocd")
}

output "argocd_helm_release" {
  description = "Helm release name for ArgoCD"
  value       = try(module.eks_blueprints_addons.argocd.helm_release_name, "argocd")
}
