terraform {
}

locals {
  yaml_content = yamldecode(file("${path.module}/yaml_to_json_data.yaml"))
  json_content = jsonencode(local.yaml_content)
}

resource "local_file" "yaml_to_json" {
  filename = "${path.module}/yaml_to_json_data_result.json"
  content  = local.json_content
}

output "yaml_parsed" {
  value = local.yaml_content
}

output "json_result" {
  value = local.json_content
}


### complex


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

# Output all local variables from the complex section
output "dashboard_path" {
  value = local.dashboard_path
}

output "widgets_path" {
  value = local.widgets_path
}

output "dashboard_files" {
  value = local.dashboard_files
}

output "widget_files" {
  value = local.widget_files
}

output "dashboard_outlines" {
  value = local.dashboard_outlines
}

output "widgets" {
  value = local.widgets
}

output "dashboard_json" {
  value = local.dashboards
}

# Output dashboard_json to a file
resource "local_file" "dashboard_json_output" {
  filename = "${path.module}/dashboard_json_output.json"
  content  = jsonencode(local.dashboards)
}