# Basic Dashboard Example
# This example shows the minimal configuration needed to create a Datadog dashboard

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

module "basic_dashboard" {
  source = "../../"
  
  # Basic dashboard configuration
  dashboard_title     = "[PROD] Basic System Dashboard"
  dashboard_image_url = "https://example.com/dashboard-image.png"
  slack_team          = "platform-team"
  
  # SLO IDs - replace with your actual SLO IDs
  slo_ids = {
    request_latency = "your-request-latency-slo-id"
    availability_api = "your-availability-slo-id"
  }
  
  # Template variables for filtering
  template_variables = {
    env = {
      available_values = ["prod", "stg", "dev"]
      default         = "prod"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    namespace = {
      available_values = ["prod-platform", "stg-platform"]
      default         = "prod-platform"
    }
    service = {
      available_values = ["api-service", "web-service", "worker-service"]
      default = "api-service"
    }
  }
}

# Outputs
output "dashboard_titles" {
  description = "Created dashboard titles"
  value       = module.basic_dashboard.dashboard_titles
}

output "dashboard_count" {
  description = "Number of dashboards created"
  value       = length(module.basic_dashboard.dashboard_titles)
}
