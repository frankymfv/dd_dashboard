# Datadog Dashboards Module

This Terraform module manages Datadog dashboards using YAML files.

## Usage

```hcl
module "datadog_dashboards" {
  source     = "./modules/datadog_dashboards"
  add_prefix = "[PROD] "
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| add_prefix | Optional prefix for all dashboard titles | `string` | `""` | no |

## Dashboard YAML Format

Place your dashboard YAML files in the `dashboards/` directory. The module will automatically:

1. Read all `.yaml` files from the `dashboards/` directory
2. Apply the prefix to dashboard titles
3. Create `datadog_dashboard_json` resources

Example dashboard YAML:
```yaml
title: "System Load & Disk"
background_color: "gray"
show_title: true
layout_type: "ordered"
widgets:
  - definition:
      title: "System Load Average"
      type: "timeseries"
      requests:
        - q: "avg:system.load.1{*}"
```
