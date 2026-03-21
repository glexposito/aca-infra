include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  region_vars = read_terragrunt_config("${get_terragrunt_dir()}/../../../region.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/resource-group-reference"
}

inputs = {
  resource_group_name     = values.resource_group_name
  resource_group_location = try(values.resource_group_location, local.region_vars.locals.location)
}
