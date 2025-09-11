# root.hcl (recommended root config for Terragrunt)
remote_state {
  backend = "local"
  config = {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var-file=${find_in_parent_folders("common.tfvars", "ignore")}"
    ]
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
