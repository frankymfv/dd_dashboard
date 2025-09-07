output "dashboard_jsons" {
  description = "The dashboard JSON configurations after merging with prefix"
  value = {
    for k, v in datadog_dashboard_json.dashboards : k => jsondecode(v.dashboard)
  }
}

output "dashboard_titles" {
  description = "The dashboard titles after applying prefix"
  value = {
    for k, v in datadog_dashboard_json.dashboards : k => jsondecode(v.dashboard).title
  }
}

output "dashboard_json" {
  description = "The dashboard JSON configurations after merging with prefix"
  value = local.dashboards
}
