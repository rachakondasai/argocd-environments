# argocd-setup/kubernetes/argocd/terragrunt.hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "./."
}