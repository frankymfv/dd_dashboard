# Template Initialization Example

This example shows how to use the `datadog_dashboards` module to get a **dashboard template**. This is the recommended approach for first-time dashboard deployment.

## ⚠️ Important: Template-Only Usage

This module is designed for **one-time template initialization**. After successful deployment:

1. **Remove the module** from your Terraform configuration
2. **Import dashboards** to your state if needed for future management
3. **Use Datadog UI** for all future modifications to avoid conflicts
4. **Document changes** in your team's dashboard management process

## Prerequisites

- Terraform >= 1.0.0
- Datadog API and Application keys
- Appropriate Datadog permissions to create dashboards

## Quick Start

### 1. Configure Variables

Copy the example variables file and update with your Datadog credentials:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your actual values:

```hcl
# Required: Datadog credentials
datadog_api_key = "your_actual_api_key"
datadog_app_key = "your_actual_app_key"
```

### 2. Customize the Template (Optional)

Edit `main.tf` to customize the dashboard template:

```hcl
# Update these values in main.tf as needed
dashboard_title = "[PROD] My System Dashboard"
slack_team = "my-team"

# Update SLO IDs with your actual values
slo_ids = {
  request_latency = "your_slo_id_1"
  availability_api = "your_slo_id_2"
}
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the template (one-time setup)
terraform apply
```

### 4. Post-Deployment Steps

After successful deployment, follow these steps:

#### Option A: Remove Module and Manage via UI (Recommended)

```bash
# 1. Remove the module from your Terraform configuration
# Edit your main.tf and remove the module block

# 2. Remove from state (optional)
terraform state rm module.datadog_dashboard_templates

# 3. Future dashboard management via Datadog UI
```

#### Option B: Import for Terraform Management

```bash
# 1. Get dashboard IDs from the output
terraform output dashboard_ids

# 2. Import dashboards to your state
terraform import datadog_dashboard_json.dashboards["dashboard_name"] <dashboard_id>

# 3. Remove the module from your configuration
# 4. Manage dashboards directly via Terraform resources
```

## Configuration Options

### Dashboard Customization

- **`dashboard_title`**: Customize the dashboard title
- **`dashboard_image_url`**: Set a custom header image
- **`slack_team`**: Configure team contact information

### SLO Integration

Update the SLO IDs with your actual Datadog SLO identifiers:

```hcl
slo_ids = {
  request_latency = "your_actual_slo_id_1"
  availability_api = "your_actual_slo_id_2"
}
```

### Template Variables

Configure filtering options for your dashboards:

```hcl
template_variables = {
  env = {
    available_values = ["prod", "stg"]
    default         = "prod"
  }
  team = {
    available_values = []  # Empty by default, populate with your values
    default         = "asset-accounting"
  }
  namespace = {
    available_values = []  # Empty by default, populate with your values
    default         = "prod-asset-accounting"
  }
  service = {
    available_values = []  # Empty by default, populate with your values
    default = "asset-accounting-backend"
  }
}
```

### Widget Control

Enable or disable specific widget groups based on your needs:

```hcl
enabled_widgets = {
  access_location = true
  alb_information = false  # Disable if not using ALB
  cpu_mem_kubernetes = true
  application_performance = true
  services_group = true
  rds_group = false  # Disable if not using RDS
  cache_group = true
  s3_group = false   # Disable if not using S3
}
```

**Note**: `dashboard_header` and `overview_group` are always enabled and cannot be disabled through the `enabled_widgets` configuration.

## Available Widgets

| Widget | Description | Default | Configurable |
|--------|-------------|---------|--------------|
| `dashboard_header` | Header with team info and contact details | ✅ | ❌ (Always enabled) |
| `overview_group` | High-level system overview metrics | ✅ | ❌ (Always enabled) |
| `access_location` | Geographic access patterns | ✅ | ✅ |
| `alb_information` | Application Load Balancer metrics | ✅ | ✅ |
| `cpu_mem_kubernetes` | Kubernetes resource utilization | ✅ | ✅ |
| `application_performance` | Application performance metrics | ✅ | ✅ |
| `services_group` | Service health and status monitoring | ✅ | ✅ |
| `rds_group` | Database performance and health metrics | ✅ | ✅ |
| `cache_group` | Cache performance and hit rates | ✅ | ✅ |
| `s3_group` | Storage metrics and usage patterns | ✅ | ✅ |

## Outputs

After deployment, the module provides:

- **`dashboard_titles`**: List of created dashboard titles
- **`dashboard_ids`**: Dashboard IDs for post-deployment management
- **`post_deployment_instructions`**: Step-by-step instructions for next steps

## Troubleshooting

### Common Issues

1. **Invalid SLO IDs**: Ensure your SLO IDs are correct and accessible
2. **Permission Errors**: Verify your Datadog API keys have dashboard creation permissions
3. **Template Variable Conflicts**: Check that your template variable values match your actual infrastructure

### Getting SLO IDs

To find your SLO IDs:

1. Go to Datadog → SLOs
2. Click on the SLO you want to use
3. Copy the ID from the URL or API response

### Validation

Before applying, you can validate your configuration:

```bash
# Check the plan output
terraform plan -detailed-exitcode

# Validate Terraform configuration
terraform validate
```

## Best Practices

1. **Test First**: Use a development environment to test your configuration
2. **Document Changes**: Keep track of any customizations made via Datadog UI
3. **Team Coordination**: Ensure your team knows that dashboards are managed via UI after initial setup
4. **Backup Configuration**: Save your `terraform.tfvars` for future reference
5. **Monitor Resources**: Set up monitoring for the dashboards you create

## Support

For issues with this template:

1. Check the [main module documentation](../../README.md)
2. Review the [widget development guide](../../docs/widget-development.md)
3. Consult the [template variables documentation](../../docs/template-variables.md)

## Next Steps

After successful template initialization:

1. **Customize Dashboards**: Use Datadog UI to customize widgets and layouts
2. **Add Alerts**: Set up alerts based on your dashboard metrics
3. **Team Training**: Train your team on dashboard management via Datadog UI
4. **Documentation**: Document your dashboard management process
5. **Monitoring**: Set up monitoring for your new dashboards

---

**Remember**: This is a template initialization tool. All future modifications should be done via the Datadog UI to maintain dashboard integrity and avoid conflicts.
