unit "myapp-1" {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/units/aca-app"
  path   = "app"

  values = {
    name                           = "myapp-1"
    resource_group_name            = "rg-platform-nc-dev-sea"
    container_app_environment_name = "cae-platform-nc-dev-sea"
    container_image                = "nginx:stable"
    min_replicas                   = 0
    max_replicas                   = 1
    ingress = {
      external_enabled = true
      target_port      = 80
    }
    liveness_probes = [
      {
        transport        = "HTTP"
        port             = 80
        path             = "/"
        initial_delay    = 10
        interval_seconds = 30
      }
    ]
    readiness_probes = [
      {
        transport        = "HTTP"
        port             = 80
        path             = "/"
        initial_delay    = 5
        interval_seconds = 15
      }
    ]
  }
}
