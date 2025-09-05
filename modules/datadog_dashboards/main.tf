locals {
  dashboard_path = "${path.module}/dashboard"
  widgets_path   = "${path.module}/dashboard_widgets"
  
  # Load dashboard outline files
  dashboard_files = fileset(local.dashboard_path, "*.yaml")
  
  # Load all widget files
  widget_files = fileset(local.widgets_path, "*.yaml")
  
  # Parse dashboard outlines
  dashboard_outlines = {
    for f in local.dashboard_files :
    replace(basename(f), ".yaml", "") => yamldecode(file("${local.dashboard_path}/${f}"))
  }
  
  # Parse widget files
  widgets = {
    for f in local.widget_files :
    replace(basename(f), ".yaml", "") => yamldecode(file("${local.widgets_path}/${f}"))
  }
  
  # Build complete dashboards by merging dashboard outlines with their widgets
  dashboards = {
    for dashboard_name, dashboard_outline in local.dashboard_outlines :
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

  dashboard = jsonencode(
    merge(
      each.value,
      {
        title = "${var.add_prefix}${each.value.title}"
      }
    )
  )
}



# Output dashboard_json to a file
# resource "local_file" "dashboard_json_output_result" {
#   filename = "${path.module}/dashboard_json_output_result.json"
#   content  = jsonencode(local.dashboards)
# }