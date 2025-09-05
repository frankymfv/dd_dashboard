# Custom Widget Configuration Example

This example demonstrates how to customize which widgets are enabled in your Datadog dashboard by selectively enabling/disabling widget groups.

## What This Example Creates

- A Datadog dashboard with only specific widgets enabled
- Disabled widgets: `access_location` and `rds_group` (not needed for this environment)
- Enabled widgets: All other widget groups for comprehensive monitoring
- Custom template variables for asset-accounting team

## Widget Configuration

This example shows how to:

- **Enable essential widgets**: Dashboard header, overview, ALB info, Kubernetes metrics, application performance, services, cache, and S3
- **Disable unnecessary widgets**: Geographic access patterns and RDS metrics (not applicable to this environment)
- **Customize template variables**: Configured for asset-accounting team with specific services

## Usage

1. Set your Datadog credentials:

```bash
export TF_VAR_datadog_api_key="your-api-key"
export TF_VAR_datadog_app_key="your-app-key"
```

2. Update the SLO IDs in `main.tf` with your actual SLO IDs

3. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Customization Options

### Widget Groups Available

| Widget Group | Description | Default |
|--------------|-------------|---------|
| `dashboard_header` | Header with team info and contact details | `true` |
| `overview_group` | System overview metrics | `true` |
| `access_location` | Geographic access patterns | `true` |
| `alb_information` | Application Load Balancer metrics | `true` |
| `cpu_mem_kubernetes` | Kubernetes resource utilization | `true` |
| `application_performance` | Application performance metrics | `true` |
| `services_group` | Service health and status monitoring | `true` |
| `rds_group` | Database performance and health metrics | `true` |
| `cache_group` | Cache performance and hit rates | `true` |
| `s3_group` | Storage metrics and usage patterns | `true` |

### Common Widget Combinations

**Minimal Dashboard** (Core monitoring only):
```hcl
enabled_widgets = {
  dashboard_header = true
  overview_group = true
  application_performance = true
  services_group = true
  # All others = false
}
```

**Infrastructure Focus** (No application metrics):
```hcl
enabled_widgets = {
  dashboard_header = true
  overview_group = true
  alb_information = true
  cpu_mem_kubernetes = true
  rds_group = true
  cache_group = true
  s3_group = true
  # application_performance = false
  # services_group = false
}
```

**Application Focus** (No infrastructure metrics):
```hcl
enabled_widgets = {
  dashboard_header = true
  overview_group = true
  application_performance = true
  services_group = true
  access_location = true
  # All infrastructure widgets = false
}
```

## Outputs

After applying, you'll see:
- `dashboard_titles`: The titles of created dashboards
- `dashboard_configs`: The complete dashboard configurations in JSON format
- `enabled_widgets_summary`: Summary of which widgets are enabled
