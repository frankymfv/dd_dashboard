locals {
  dashboard_layout_path = "${path.module}/dashboard_layout"
  widgets_path   = "${path.module}/dashboard_widgets"
  
  # Load dashboard outline files
  dashboard_files = fileset(local.dashboard_layout_path, "*.yaml")
  
  # Load all widget files
  widget_files = fileset(local.widgets_path, "*.yaml")
  
  # Parse dashboard outlines with template substitution
  dashboard_outlines = {
    for f in local.dashboard_files :
    replace(basename(f), ".yaml", "") => yamldecode(
      templatefile("${local.dashboard_layout_path}/${f}", {
        dashboard_title   = var.dashboard_title
        env_values        = var.template_variables.env.available_values
        default_env       = var.template_variables.env.default
        team_values       = var.template_variables.team.available_values
        default_team      = var.template_variables.team.default
        namespace_values  = var.template_variables.namespace.available_values
        default_namespace = var.template_variables.namespace.default
        service_values    = var.template_variables.service.available_values
        default_service   = var.template_variables.service.default
      })
    )
  }
  
  # Filter widgets based on enabled_widgets configuration
  filtered_dashboard_outlines = {
    for dashboard_name, dashboard_outline in local.dashboard_outlines :
    dashboard_name => merge(
      dashboard_outline,
      {
        widgets = [
          for widget_ref in dashboard_outline.widgets :
          widget_ref
          if can(local.widget_enabled_map[replace(basename(widget_ref.widget_file), ".yaml", "")]) && 
             local.widget_enabled_map[replace(basename(widget_ref.widget_file), ".yaml", "")]
        ]
      }
    )
  }
  
  # Widget enable/disable mapping
  widget_enabled_map = {
    "dashboard_header_note" = true
    "overview_group" = true
    "access_location_widget" = var.enabled_widgets.access_location
    "alb_information_widget" = var.enabled_widgets.alb_information
    "cpu_mem_kubernetes_widget" = var.enabled_widgets.cpu_mem_kubernetes
    "application_performance_group" = var.enabled_widgets.application_performance
    "services_group" = var.enabled_widgets.services_group
    "rds_group" = var.enabled_widgets.rds_group
    "cache_group" = var.enabled_widgets.cache_group
    "s3_group" = var.enabled_widgets.s3_group
  }
  
  # Parse widget files with template substitution
  widgets = {
    for f in local.widget_files :
    replace(basename(f), ".yaml", "") => yamldecode(
      templatefile("${local.widgets_path}/${f}", {
        dashboard_image_url = var.dashboard_image_url
        slack_team          = var.slack_team
        slo_ids             = var.slo_ids
      })
    )
  }
  
  # Build complete dashboards by merging filtered dashboard outlines with their widgets
  dashboards = {
    for dashboard_name, dashboard_outline in local.filtered_dashboard_outlines :
    dashboard_name => merge(
      dashboard_outline,
      {
        widgets = [
          for widget_ref in dashboard_outline.widgets :
          merge(
            {
              definition = local.widgets[replace(basename(widget_ref.widget_file), ".yaml", "")]["definition"]
            },
            {
              layout = widget_ref.layout
            }
          )
        ]
      }
    )
  }
}

resource "datadog_dashboard_json" "dashboards" {
  for_each = local.dashboards

  dashboard = jsonencode(each.value)

  # Ignore changes to dashboard content after initial creation
  # This allows users to modify dashboards in the Datadog UI without Terraform conflicts
  # This is essential for template initialization workflows where dashboards are managed via UI
  lifecycle {
    ignore_changes = [
      dashboard
    ]
  }
}
