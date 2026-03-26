locals {
  default_tags = {
    app         = var.name
    environment = var.environment
    managed_by  = "terraform"
  }
  tags = merge(var.tags, local.default_tags)
}

resource "azurerm_container_group" "this" {
  name                = var.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  restart_policy      = var.restart_policy
  ip_address_type     = var.ip_address_type
  dns_name_label      = var.dns_name_label
  subnet_ids          = var.subnet_ids
  tags                = local.tags

  dynamic "container" {
    for_each = var.containers
    content {
      name   = container.value.name
      image  = container.value.image
      cpu    = container.value.cpu
      memory = container.value.memory

      environment_variables        = try(container.value.environment_variables, {})
      secure_environment_variables = try(container.value.secure_environment_variables, {})
      commands                     = try(container.value.commands, [])

      dynamic "ports" {
        for_each = try(container.value.ports, [])
        content {
          port     = ports.value.port
          protocol = try(ports.value.protocol, "TCP")
        }
      }

      dynamic "readiness_probe" {
        for_each = try(container.value.readiness_probe, null) == null ? [] : [container.value.readiness_probe]
        content {
          exec                  = try(readiness_probe.value.exec, null)
          initial_delay_seconds = try(readiness_probe.value.initial_delay_seconds, null)
          period_seconds        = try(readiness_probe.value.period_seconds, null)
          failure_threshold     = try(readiness_probe.value.failure_threshold, null)
          success_threshold     = try(readiness_probe.value.success_threshold, null)
          timeout_seconds       = try(readiness_probe.value.timeout_seconds, null)

          dynamic "http_get" {
            for_each = try(readiness_probe.value.http_get, null) == null ? [] : [readiness_probe.value.http_get]
            content {
              path         = try(http_get.value.path, null)
              port         = try(http_get.value.port, null)
              scheme       = try(http_get.value.scheme, null)
              http_headers = try(http_get.value.http_headers, {})
            }
          }
        }
      }

      dynamic "liveness_probe" {
        for_each = try(container.value.liveness_probe, null) == null ? [] : [container.value.liveness_probe]
        content {
          exec                  = try(liveness_probe.value.exec, null)
          initial_delay_seconds = try(liveness_probe.value.initial_delay_seconds, null)
          period_seconds        = try(liveness_probe.value.period_seconds, null)
          failure_threshold     = try(liveness_probe.value.failure_threshold, null)
          success_threshold     = try(liveness_probe.value.success_threshold, null)
          timeout_seconds       = try(liveness_probe.value.timeout_seconds, null)

          dynamic "http_get" {
            for_each = try(liveness_probe.value.http_get, null) == null ? [] : [liveness_probe.value.http_get]
            content {
              path         = try(http_get.value.path, null)
              port         = try(http_get.value.port, null)
              scheme       = try(http_get.value.scheme, null)
              http_headers = try(http_get.value.http_headers, {})
            }
          }
        }
      }
    }
  }

  dynamic "image_registry_credential" {
    for_each = var.image_registry_credential == null ? [] : [var.image_registry_credential]
    content {
      server   = image_registry_credential.value.server
      username = image_registry_credential.value.username
      password = image_registry_credential.value.password
    }
  }
}
