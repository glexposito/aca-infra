locals {
  app_vars    = read_terragrunt_config("${dirname(find_in_parent_folders("root.hcl"))}/live/_shared/app.hcl")
  region_vars = read_terragrunt_config("${get_original_terragrunt_dir()}/../../region.hcl")
  env_vars    = read_terragrunt_config("${get_original_terragrunt_dir()}/../env.hcl")

  env        = local.env_vars.locals.environment
  app_name   = local.app_vars.locals.app_name
  stack_name = local.app_name
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/aca-environment"
}

inputs = {
  location                        = local.region_vars.locals.location
  environment                     = local.env
  name                            = local.stack_name
  resource_group_name             = "rg-${local.stack_name}-${local.env}-${local.region_vars.locals.location_short}"
  container_app_environment_name  = "cae-${local.stack_name}-${local.env}-${local.region_vars.locals.location_short}"
  log_analytics_workspace_name    = "law-${local.stack_name}-${local.env}-${local.region_vars.locals.location_short}"
  log_analytics_retention_in_days = 30
}
