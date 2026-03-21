locals {
  root_dir = dirname(find_in_parent_folders("root.hcl"))
}

unit "rg" {
  source = "${local.root_dir}/live/units/rg"
  path   = "rg"

  values = {
    environment = "dev"
    name        = "platform-noncritical"
  }
}

unit "storage-account" {
  source = "${local.root_dir}/live/units/storage-account"
  path   = "storage-account"

  values = {
    environment          = "dev"
    resource_group_path  = "../rg"
    name                 = "platform-noncritical"
    storage_account_name = "stplatformnoncdevweu"
    containers           = ["tfstate"]
  }
}

unit "aca-env" {
  source = "${local.root_dir}/live/units/aca-env"
  path   = "aca-env"

  values = {
    environment                     = "dev"
    resource_group_path             = "../rg"
    name                            = "platform-noncritical"
    log_analytics_retention_in_days = 30
  }
}

unit "myapp-1" {
  source = "${local.root_dir}/live/units/aca-app"
  path   = "myapp-1"

  values = {
    environment     = "dev"
    platform_path   = "../aca-env"
    name            = "myapp-1"
    container_image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    min_replicas    = 1
    max_replicas    = 1
    secret_environment_variables = {
      TEST_SECRET = {
        secret_name  = "test-secret"
        secret_value = trimspace(get_env("ARM_TENANT_ID", ""))
      }
    }
  }
}

unit "myapp-3" {
  source = "${local.root_dir}/live/units/aca-app"
  path   = "myapp-3"

  values = {
    environment     = "dev"
    platform_path   = "../aca-env"
    name            = "myapp-3"
    container_image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    min_replicas    = 1
    max_replicas    = 1
  }
}
