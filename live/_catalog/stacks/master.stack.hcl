# Master Blueprint - One file containing all infrastructure units.
# Units are enabled by default. To disable a unit in a specific environment,
# redefine the unit block in the leaf stack with 'enabled = false'.

locals {
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars          = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  location       = local.region_vars.locals.location
  location_short = local.region_vars.locals.location_short
  environment    = local.env_vars.locals.environment

  stack_name = "core"
  app_name   = "myapp"

  statuspage_api_key = trimspace(get_env("STATUSPAGE_API_KEY", ""))
}

unit "app_env" {
  source = "../../units/app-env"
  path   = "app-env"
  no_dot_terragrunt_stack = true

  values = {
    location                        = local.location
    environment                     = local.environment
    name                            = local.stack_name
    resource_group_name             = "rg-${local.stack_name}-${local.environment}-${local.location_short}"
    container_app_environment_name  = "cae-${local.stack_name}-${local.environment}-${local.location_short}"
    log_analytics_workspace_name    = "law-${local.stack_name}-${local.environment}-${local.location_short}"
    log_analytics_retention_in_days = 30
  }
}

unit "myapp" {
  source = "../../units/myapp"
  path   = "myapp"
  no_dot_terragrunt_stack = true

  values = {
    # Direct references. No indexing, no complex logic.
    container_app_environment_id = unit.app_env.outputs.container_app_environment_id
    resource_group_name          = unit.app_env.outputs.resource_group_name
    
    location           = local.location
    environment        = local.environment
    name               = local.app_name
    container_app_name = "ca-${local.app_name}-${local.environment}-${local.location_short}"
    container_name     = local.app_name
    container_image    = coalesce(get_env("MYAPP_IMAGE", ""), "ghcr.io/example/myapp:${local.environment}")
    registry_server    = trimspace(get_env("MYAPP_REGISTRY_SERVER", "")) == "" ? null : trimspace(get_env("MYAPP_REGISTRY_SERVER", ""))
    acr_id             = trimspace(get_env("MYAPP_ACR_ID", "")) == "" ? null : trimspace(get_env("MYAPP_ACR_ID", ""))
    min_replicas       = 1
    max_replicas       = 1

    environment_variables = {
      APP_ENV = local.environment
    }

    secret_environment_variables = local.statuspage_api_key == "" ? {} : {
      STATUSPAGE_API_KEY = {
        secret_name  = "statuspage-api-key"
        secret_value = local.statuspage_api_key
      }
    }
  }
}
