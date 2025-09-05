# Custom Widget Configuration Example
# This example shows how to enable/disable specific widget groups

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.0.0"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://app.datadoghq.com/"
}

module "custom_dashboard" {
  source = "../../"
  
  # Dashboard configuration
  dashboard_title     = "[PROD] Custom System Dashboard"
  dashboard_image_url = "https://example.com/custom-dashboard-image.png"
  slack_team          = "production-team"
  
  # SLO IDs configuration
  slo_ids = {
    request_latency = "55851b7bf8d15e6597a0b55aa15ceadc"
    availability_api = "b8c13e6ff68e500eb487c3aac7eaaa8a"
  }
  
  # Template variables
  template_variables = {
    env = {
      available_values = ["prod", "stg"]
      default         = "prod"
    }
    team = {
      available_values = ["asset-accounting", "platform", "data-team"]
      default         = "asset-accounting"
    }
    namespace = {
      available_values = ["prod-asset-accounting", "stg-asset-accounting"]
      default         = "prod-asset-accounting"
    }
    service = {
      available_values = [
        "asset-accounting-backend",
        "asset-accounting-core",
        "asset-accounting-admin-web",
        "asset-accounting-datapatch"
      ]
      default = "asset-accounting-backend"
    }
  }
  
  # Custom widget configuration - only enable specific widgets
  enabled_widgets = {
    dashboard_header = true      # Keep header with team info
    overview_group = true        # Keep system overview
    access_location = false      # Disable geographic access patterns
    alb_information = true       # Keep load balancer metrics
    cpu_mem_kubernetes = true    # Keep Kubernetes metrics
    application_performance = true # Keep application performance
    services_group = true        # Keep service health monitoring
    rds_group = false           # Disable database metrics (no RDS in this environment)
    cache_group = true          # Keep cache metrics
    s3_group = true             # Keep storage metrics
  }
}

# Outputs
output "dashboard_titles" {
  description = "Created dashboard titles"
  value       = module.custom_dashboard.dashboard_titles
}

output "dashboard_configs" {
  description = "Dashboard configurations (JSON format)"
  value       = module.custom_dashboard.dashboard_jsons
}

output "enabled_widgets_summary" {
  description = "Summary of enabled widgets"
  value = {
    total_widgets = length(module.custom_dashboard.enabled_widgets)
    enabled_widgets = [
      for widget, enabled in module.custom_dashboard.enabled_widgets : widget
      if enabled
    ]
  }
}
