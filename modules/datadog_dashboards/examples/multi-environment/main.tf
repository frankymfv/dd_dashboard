# Multi-Environment Dashboard Example
# This example shows how to create dashboards for multiple environments

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

# Production Dashboard
module "prod_dashboard" {
  source = "../../"
  
  dashboard_title     = "[PROD] Production System Dashboard"
  dashboard_image_url = "https://example.com/prod-dashboard-image.png"
  slack_team          = "production-team"
  
  slo_ids = {
    request_latency = var.prod_slo_ids.request_latency
    availability_api = var.prod_slo_ids.availability_api
  }
  
  template_variables = {
    env = {
      available_values = ["prod", "production"]
      default         = "prod"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    namespace = {
      available_values = ["prod-platform", "prod-data", "prod-frontend"]
      default         = "prod-platform"
    }
    service = {
      available_values = [
        "prod-api-service",
        "prod-web-service",
        "prod-worker-service",
        "prod-data-pipeline"
      ]
      default = "prod-api-service"
    }
  }
  
  # Production-specific widget configuration
  enabled_widgets = {
    dashboard_header = true
    overview_group = true
    access_location = true
    alb_information = true
    cpu_mem_kubernetes = true
    application_performance = true
    services_group = true
    rds_group = true
    cache_group = true
    s3_group = true
  }
}

# Staging Dashboard
module "staging_dashboard" {
  source = "../../"
  
  dashboard_title     = "[STG] Staging System Dashboard"
  dashboard_image_url = "https://example.com/staging-dashboard-image.png"
  slack_team          = "staging-team"
  
  slo_ids = {
    request_latency = var.staging_slo_ids.request_latency
    availability_api = var.staging_slo_ids.availability_api
  }
  
  template_variables = {
    env = {
      available_values = ["stg", "staging"]
      default         = "stg"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    namespace = {
      available_values = ["stg-platform", "stg-data", "stg-frontend"]
      default         = "stg-platform"
    }
    service = {
      available_values = [
        "stg-api-service",
        "stg-web-service",
        "stg-worker-service"
      ]
      default = "stg-api-service"
    }
  }
  
  # Staging-specific widget configuration (simplified)
  enabled_widgets = {
    dashboard_header = true
    overview_group = true
    access_location = false
    alb_information = true
    cpu_mem_kubernetes = true
    application_performance = true
    services_group = true
    rds_group = false
    cache_group = true
    s3_group = false
  }
}

# Development Dashboard
module "dev_dashboard" {
  source = "../../"
  
  dashboard_title     = "[DEV] Development System Dashboard"
  dashboard_image_url = "https://example.com/dev-dashboard-image.png"
  slack_team          = "dev-team"
  
  slo_ids = {
    request_latency = var.dev_slo_ids.request_latency
    availability_api = var.dev_slo_ids.availability_api
  }
  
  template_variables = {
    env = {
      available_values = ["dev", "development"]
      default         = "dev"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    namespace = {
      available_values = ["dev-platform", "dev-data", "dev-frontend"]
      default         = "dev-platform"
    }
    service = {
      available_values = [
        "dev-api-service",
        "dev-web-service"
      ]
      default = "dev-api-service"
    }
  }
  
  # Development-specific widget configuration (minimal)
  enabled_widgets = {
    dashboard_header = true
    overview_group = true
    access_location = false
    alb_information = false
    cpu_mem_kubernetes = true
    application_performance = true
    services_group = true
    rds_group = false
    cache_group = false
    s3_group = false
  }
}

# Outputs
output "prod_dashboard_titles" {
  description = "Production dashboard titles"
  value       = module.prod_dashboard.dashboard_titles
}

output "staging_dashboard_titles" {
  description = "Staging dashboard titles"
  value       = module.staging_dashboard.dashboard_titles
}

output "dev_dashboard_titles" {
  description = "Development dashboard titles"
  value       = module.dev_dashboard.dashboard_titles
}

output "all_dashboard_count" {
  description = "Total number of dashboards created across all environments"
  value = length(module.prod_dashboard.dashboard_titles) + 
          length(module.staging_dashboard.dashboard_titles) + 
          length(module.dev_dashboard.dashboard_titles)
}
