provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  
  # api_url = "https://api.us5.datadoghq.com/" # For EU site, or use the correct one for your region
  api_url = "https://app.datadoghq.com/"

}



# provider "datadog" {
#   api_key = var.datadog_api_key
#   app_key = var.datadog_app_key
# }

module "datadog_dashboards" {
  source     = "./modules/datadog_dashboards"
  add_prefix = "[PROD] "
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
