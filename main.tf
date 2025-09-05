provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  
  # api_url = "https://api.us5.datadoghq.com/" # For EU site, or use the correct one for your region
  api_url = "https://app.datadoghq.com/"

}


module "datadog_dashboards" {
  source     = "./modules/datadog_dashboards"
  add_prefix = "[PROD] "
  
  # Dashboard customization
  dashboard_image_url = "https://dlaudio.fineshare.net/cover/song-ai/covers/mackenzie-border-collie.webp"
  slack_team          = "franky_channel_test"
  
  # SLO IDs configuration
  slo_ids = {
    request_latency = "55851b7bf8d15e6597a0b55aa15ceadc"
    availability_api = "b8c13e6ff68e500eb487c3aac7eaaa8a"
  }
  
  # Customize template variable values using object structure
  template_variables = {
    env = {
      available_values = ["prod", "stg", "production", "staging"]
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
        "aa-n8n",
        "asset_accounting_mfid",
        "asset-accounting",
        "asset-accounting-core",
        "asset_accounting_mysql",
        "asset-accounting-backend",
        "asset_accounting_accplus",
        "asset_accounting_googleoauth2",
        "asset-accounting-admin-web",
        "asset-accounting-datapatch"
      ]
      default = "asset-accounting-backend"
    }
  }
  
  # Enable/disable specific widget groups based on your needs
  enabled_widgets = {
    application_performance = true   # Keep application metrics
    services_group = true            # Keep service health monitoring
    rds_group = true                 # Keep database monitoring
    cache_group = true               # Keep cache monitoring
    s3_group = true                  # Keep storage monitoring
  }
}

# Outputs to display module results
output "dashboard_titles" {
  description = "Created dashboard titles"
  value       = module.datadog_dashboards.dashboard_titles
}

output "dashboard_configs" {
  description = "Dashboard configurations (JSON format)"
  value       = module.datadog_dashboards.dashboard_jsons
}

output "dashboard_count" {
  description = "Number of dashboards created"
  value       = length(module.datadog_dashboards.dashboard_titles)
}

output "dashboard_names" {
  description = "List of dashboard names"
  value       = keys(module.datadog_dashboards.dashboard_titles)
}

# output "dashboard_json_output_result" {
#   description = "Dashboard JSON configurations"
#   value       = module.datadog_dashboards.dashboard_json
# }
