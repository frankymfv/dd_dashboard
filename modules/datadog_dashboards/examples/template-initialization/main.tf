# Template Initialization Example
# This example shows how to use the datadog_dashboards module to get a dashboard template.
# After deployment, remove the module and manage dashboards via Datadog UI.

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.0.0"
    }
  }
}

# Configure the Datadog Provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

# Get the dashboard template
module "datadog_dashboard_templates" {
  source = "../../"

  # Basic configuration - customize as needed
  dashboard_title     = "[PROD] System Dashboard Template"
  dashboard_image_url = "https://your-company.com/dashboard-image.png"
  slack_team          = "your-team"

  # SLO IDs - update with your actual SLO IDs
  slo_ids = {
    request_latency = "your-request-latency-slo-id"
    availability_api = "your-availability-api-slo-id"
  }

  # Template variables - customize for your environment
  template_variables = {
    env = {
      available_values = ["prod", "stg"]
      default         = "prod"
    }
    team = {
      available_values = []
      default         = "asset-accounting"
    }
    namespace = {
      available_values = []
      default         = "prod-asset-accounting"
    }
    service = {
      available_values = []
      default = "asset-accounting-backend"
    }
  }

  # Widget configuration - enable/disable as needed
  enabled_widgets = {
    access_location = true
    alb_information = true
    cpu_mem_kubernetes = true
    application_performance = true
    services_group = true
    rds_group = true
    cache_group = true
    s3_group = true
  }

  # IMPORTANT: This module includes lifecycle ignore_changes to prevent conflicts with UI modifications
  # You can safely modify dashboards in the Datadog UI after initial deployment
  # The module will ignore changes made in the UI to prevent Terraform conflicts
}

# Output dashboard information for post-deployment reference
output "dashboard_titles" {
  description = "Dashboard titles created by the template"
  value       = module.datadog_dashboard_templates.dashboard_titles
}

output "dashboard_ids" {
  description = "Dashboard IDs for post-deployment management"
  value       = module.datadog_dashboard_templates.dashboard_ids
}

output "dashboard_urls" {
  description = "Direct URLs to access the created dashboards"
  value       = module.datadog_dashboard_templates.dashboard_urls
}

output "widget_counts" {
  description = "Number of widgets in each dashboard"
  value       = module.datadog_dashboard_templates.widget_counts
}

output "enabled_widgets_status" {
  description = "Shows which widgets are enabled in the current configuration"
  value       = module.datadog_dashboard_templates.enabled_widgets_status
}

output "template_variables" {
  description = "Template variables configuration used for dashboard filtering"
  value       = module.datadog_dashboard_templates.template_variables
}

output "post_deployment_instructions" {
  description = "Instructions for post-deployment management"
  value = <<-EOT
    Template initialization complete! Next steps:
    
    1. ✅ SAFE: You can now modify dashboards in the Datadog UI without conflicts
    2. ✅ The module includes lifecycle ignore_changes to prevent Terraform from reverting UI modifications
    3. Optional: Keep this module in Terraform for reference or remove it after initial setup
    4. Optional: Import dashboards to state if you need Terraform management:
       terraform import datadog_dashboard_json.dashboards["dashboard_name"] <dashboard_id>
    5. Document your dashboard management process
    
    Dashboard Summary:
    ${join("\n", [for k, v in module.datadog_dashboard_templates.dashboard_ids : "${k}: ID=${v}, URL=${module.datadog_dashboard_templates.dashboard_urls[k]}, Widgets=${module.datadog_dashboard_templates.widget_counts[k]}"])}
    
    Enabled Widgets:
    ${join("\n", [for widget, enabled in module.datadog_dashboard_templates.enabled_widgets_status : "${widget}: ${enabled}"])}
    
    ✅ CONFLICT-FREE: The module automatically ignores changes made in the Datadog UI.
    You can customize dashboards freely without Terraform interference.
  EOT
}
