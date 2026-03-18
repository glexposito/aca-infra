# Southeast Asia - Platform Only
include "master" {
  path = "${get_repo_root()}/live/_catalog/stacks/master.stack.hcl"
}

# We "choose" only the platform by disabling the app unit
unit "myapp" {
  enabled = false
}
