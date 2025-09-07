output "dashboard_titles" {
  description = "The dashboard titles after applying prefix"
  value = {
    for k, v in datadog_dashboard_json.dashboards : k => jsondecode(v.dashboard).title
  }
}

# output "dashboard_json" {
#   description = "The dashboard JSON configurations after merging with prefix"
#   value = local.dashboards
# }

output "dashboard_ids" {
  description = "The Datadog dashboard IDs for each created dashboard"
  value = {
    for k, v in datadog_dashboard_json.dashboards : k => v.id
  }
}

output "dashboard_urls" {
  description = "The Datadog dashboard URLs for each created dashboard"
  value = {
    for k, v in datadog_dashboard_json.dashboards : k => v.url
  }
}

output "widget_counts" {
  description = "The number of widgets in each dashboard"
  value = {
    for k, v in local.dashboards : k => length(v.widgets)
  }
}

output "enabled_widgets_status" {
  description = "Shows which widgets are enabled/disabled in the current configuration"
  value = local.widget_enabled_map
}

output "template_variables" {
  description = "The template variables configuration used for dashboard filtering"
  value = var.template_variables
}
