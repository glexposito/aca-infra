# Full Stack environment
include "master" {
  path = "${get_repo_root()}/live/_catalog/stacks/master.stack.hcl"
}

unit "myapp" {
  enabled = false
}
