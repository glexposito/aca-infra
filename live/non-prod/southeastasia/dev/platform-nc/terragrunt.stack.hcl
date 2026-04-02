unit "rg" {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/units/rg"
  path   = "rg"

  values = {
    name = "platform-nc"
  }
}

unit "aca-env" {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/units/aca-env"
  path   = "aca-env"

  values = {
    resource_group_path             = "../rg"
    name                            = "platform-nc"
    log_analytics_retention_in_days = 30
  }
}
