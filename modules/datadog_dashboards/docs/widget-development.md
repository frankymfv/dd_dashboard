# Widget Development Guide

This guide explains how to create, modify, and customize widgets for the terraform-datadog-dashboards module.

## Widget Architecture

The module uses a modular widget system where each widget is defined in a separate YAML file in the `dashboard_widgets/` directory. Widgets are referenced in the main dashboard layout and can be enabled/disabled individually.

## Creating a New Widget

### 1. Create the Widget YAML File

Create a new YAML file in the `dashboard_widgets/` directory:

```yaml
# dashboard_widgets/my_custom_widget.yaml
definition:
  title: "My Custom Widget"
  title_size: "16"
  title_align: "left"
  type: "timeseries"
  requests:
    - q: "avg:system.cpu.user{*} by {host}"
      display_type: "line"
      style:
        palette: "dog_classic"
        line_type: "solid"
        line_width: "normal"
  yaxis:
    label: ""
    scale: "linear"
    min: "auto"
    max: "auto"
    include_zero: true
  time:
    live_span: "1h"
```

### 2. Add Widget Reference to Dashboard Layout

Edit `dashboard/dashboard_layout.yaml` to include your widget:

```yaml
widgets:
  # ... existing widgets ...
  
  - widget_file: "my_custom_widget.yaml"
    layout:
      "x": 0
      "y": 40
      "width": 6
      "height": 4
```

### 3. Update Widget Enable/Disable Map

Edit `main.tf` to add your widget to the `widget_enabled_map`:

```hcl
widget_enabled_map = {
  # ... existing widgets ...
  "my_custom_widget" = var.enabled_widgets.my_custom_widget
}
```

### 4. Add Variable for Widget Control

Edit `variables.tf` to add the widget to the `enabled_widgets` variable:

```hcl
variable "enabled_widgets" {
  description = "Configuration to enable/disable individual widget groups"
  type = object({
    # ... existing widgets ...
    my_custom_widget = optional(bool, true)
  })
  default = {
    # ... existing widgets ...
    my_custom_widget = true
  }
}
```

## Widget Types and Examples

### Time Series Widget

```yaml
definition:
  title: "CPU Usage Over Time"
  type: "timeseries"
  requests:
    - q: "avg:system.cpu.user{*} by {host}"
      display_type: "line"
      style:
        palette: "dog_classic"
        line_type: "solid"
        line_width: "normal"
  yaxis:
    label: "CPU %"
    scale: "linear"
    min: "0"
    max: "100"
    include_zero: true
```

### Top List Widget

```yaml
definition:
  title: "Top Services by Request Count"
  type: "toplist"
  requests:
    - q: "top(avg:nginx.requests{*} by {service}, 10, 'mean', 'desc')"
      style:
        palette: "dog_classic"
```

### Query Value Widget

```yaml
definition:
  title: "Total Requests"
  type: "query_value"
  requests:
    - q: "sum:nginx.requests{*}"
      aggregator: "sum"
      conditional_formats:
        - comparator: ">"
          value: 1000
          palette: "red_on_white"
        - comparator: ">"
          value: 500
          palette: "yellow_on_white"
        - comparator: ">="
          value: 0
          palette: "green_on_white"
```

### Heat Map Widget

```yaml
definition:
  title: "Response Time Heatmap"
  type: "heatmap"
  requests:
    - q: "avg:nginx.response_time{*} by {service}"
      style:
        palette: "YlOrRd"
```

### Log Stream Widget

```yaml
definition:
  title: "Application Logs"
  type: "log_stream"
  query: "service:my-app status:error"
  columns: ["timestamp", "service", "status", "message"]
  logset: "main"
```

## Template Variables in Widgets

Widgets can use template variables for dynamic content:

```yaml
definition:
  title: "Requests for ${slack_team}"
  requests:
    - q: "sum:nginx.requests{env:${default_env}}"
      display_type: "line"
```

Available template variables:
- `${dashboard_image_url}`: Dashboard header image URL
- `${slack_team}`: Slack team name
- `${slo_ids.request_latency}`: Request latency SLO ID
- `${slo_ids.availability_api}`: API availability SLO ID
- `${default_env}`: Default environment value
- `${default_team}`: Default team value
- `${default_namespace}`: Default namespace value
- `${default_service}`: Default service value

## Widget Layout and Positioning

### Layout Properties

```yaml
layout:
  "x": 0          # X position (0-11 for 12-column grid)
  "y": 0          # Y position (starts from 0)
  "width": 6      # Width in grid units (1-12)
  "height": 4     # Height in grid units
  "is_column_break": true  # Optional: force column break
```

### Grid System

The dashboard uses a 12-column grid system:
- **Width**: 1-12 columns
- **Height**: Measured in grid units
- **Positioning**: X,Y coordinates starting from top-left (0,0)

### Layout Best Practices

1. **Consistent Sizing**: Use standard widths (3, 4, 6, 12) for better alignment
2. **Logical Grouping**: Group related widgets together
3. **Column Breaks**: Use `is_column_break: true` to force widgets to new columns
4. **Responsive Design**: Consider how widgets will look on different screen sizes

## Advanced Widget Features

### Conditional Formatting

```yaml
conditional_formats:
  - comparator: ">"
    value: 100
    palette: "red_on_white"
    custom_bg_color: "#ff0000"
    custom_fg_color: "#ffffff"
  - comparator: ">"
    value: 50
    palette: "yellow_on_white"
  - comparator: ">="
    value: 0
    palette: "green_on_white"
```

### Custom Colors and Styling

```yaml
style:
  palette: "dog_classic"  # Predefined palettes
  line_type: "solid"      # solid, dashed, dotted
  line_width: "normal"    # normal, thin, thick
  custom_bg_color: "#ff0000"
  custom_fg_color: "#ffffff"
```

### Time Ranges

```yaml
time:
  live_span: "1h"         # 1h, 4h, 1d, 2d, 1w, 1mo, 3mo, 1y
  # OR
  from: "now-1h"
  to: "now"
```

## Testing Widgets

### 1. Validate YAML Syntax

```bash
# Check YAML syntax
python -c "import yaml; yaml.safe_load(open('my_widget.yaml'))"
```

### 2. Test Template Substitution

```bash
# Test template rendering
terraform console
> templatefile("dashboard_widgets/my_widget.yaml", {
    slack_team = "test-team"
    default_env = "prod"
  })
```

### 3. Preview in Datadog

1. Create a temporary dashboard in Datadog UI
2. Copy the widget JSON from your YAML
3. Test the widget functionality
4. Adjust as needed

## Widget Performance Considerations

### Query Optimization

1. **Use appropriate time ranges**: Don't query too much historical data
2. **Limit series**: Use `top()` or `by` clauses to limit results
3. **Aggregate data**: Use appropriate aggregation functions
4. **Avoid wildcards**: Be specific with tag filters when possible

### Example Optimized Query

```yaml
# Good: Specific, limited query
requests:
  - q: "top(avg:nginx.requests{env:prod,service:api} by {host}, 10, 'mean', 'desc')"

# Bad: Too broad, potentially slow
requests:
  - q: "avg:nginx.requests{*} by {*}"
```

## Common Widget Patterns

### Service Health Dashboard

```yaml
definition:
  title: "Service Health Overview"
  type: "group"
  layout_type: "ordered"
  widgets:
    - definition:
        title: "Request Rate"
        type: "query_value"
        requests:
          - q: "sum:nginx.requests{service:${default_service}}"
      layout:
        x: 0
        y: 0
        width: 3
        height: 2
    - definition:
        title: "Error Rate"
        type: "query_value"
        requests:
          - q: "sum:nginx.requests{service:${default_service},status:error}"
      layout:
        x: 3
        y: 0
        width: 3
        height: 2
```

### SLO Monitoring Widget

```yaml
definition:
  title: "API Availability SLO"
  type: "slo"
  slo_id: "${slo_ids.availability_api}"
  view_type: "detail"
  time_windows: ["7d", "30d", "90d"]
  show_error_budget: true
```

## Troubleshooting

### Common Issues

1. **Widget not appearing**: Check if widget is enabled in `enabled_widgets`
2. **Template variables not working**: Verify variable names match exactly
3. **Layout issues**: Check X,Y coordinates and width/height values
4. **Query errors**: Validate Datadog query syntax

### Debugging Steps

1. Check Terraform plan output for errors
2. Validate YAML syntax
3. Test template substitution manually
4. Check Datadog API logs for widget creation errors
5. Verify SLO IDs and other external references

## Contributing Widgets

When contributing new widgets:

1. Follow the existing naming conventions
2. Include comprehensive documentation
3. Add appropriate template variables
4. Test with different configurations
5. Update the main README with widget descriptions
6. Add examples in the examples directory
