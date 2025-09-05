# Multi-Environment Dashboard Example

This example demonstrates how to create Datadog dashboards for multiple environments (Production, Staging, and Development) with environment-specific configurations.

## What This Example Creates

- **Production Dashboard**: Full-featured dashboard with all monitoring capabilities
- **Staging Dashboard**: Simplified dashboard with essential monitoring
- **Development Dashboard**: Minimal dashboard with core metrics only

## Environment-Specific Configurations

### Production Environment
- **Full monitoring**: All widgets enabled for comprehensive monitoring
- **SLO integration**: Production SLO IDs for critical metrics
- **Template variables**: Production-specific services and namespaces
- **Slack integration**: Production team notifications

### Staging Environment
- **Selective monitoring**: Disabled geographic access patterns, RDS, and S3 metrics
- **SLO integration**: Staging SLO IDs
- **Template variables**: Staging-specific services and namespaces
- **Slack integration**: Staging team notifications

### Development Environment
- **Minimal monitoring**: Only core widgets enabled (header, overview, Kubernetes, application performance, services)
- **SLO integration**: Development SLO IDs
- **Template variables**: Development-specific services and namespaces
- **Slack integration**: Development team notifications

## Usage

1. Set your Datadog credentials:

```bash
export TF_VAR_datadog_api_key="your-api-key"
export TF_VAR_datadog_app_key="your-app-key"
```

2. Update the SLO IDs in `variables.tf` with your actual SLO IDs for each environment

3. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Environment-Specific Widget Configurations

### Production (Full Monitoring)
```hcl
enabled_widgets = {
  dashboard_header = true
  overview_group = true
  access_location = true
  alb_information = true
  cpu_mem_kubernetes = true
  application_performance = true
  services_group = true
  rds_group = true
  cache_group = true
  s3_group = true
}
```

### Staging (Selective Monitoring)
```hcl
enabled_widgets = {
  dashboard_header = true
  overview_group = true
  access_location = false      # Disabled
  alb_information = true
  cpu_mem_kubernetes = true
  application_performance = true
  services_group = true
  rds_group = false           # Disabled
  cache_group = true
  s3_group = false            # Disabled
}
```

### Development (Minimal Monitoring)
```hcl
enabled_widgets = {
  dashboard_header = true
  overview_group = true
  access_location = false      # Disabled
  alb_information = false      # Disabled
  cpu_mem_kubernetes = true
  application_performance = true
  services_group = true
  rds_group = false           # Disabled
  cache_group = false         # Disabled
  s3_group = false            # Disabled
}
```

## Customization

### Adding New Environments

To add a new environment (e.g., UAT):

1. Create a new module block in `main.tf`:

```hcl
module "uat_dashboard" {
  source = "../../"
  
  dashboard_title     = "[UAT] UAT System Dashboard"
  dashboard_image_url = "https://example.com/uat-dashboard-image.png"
  slack_team          = "uat-team"
  
  slo_ids = {
    request_latency = var.uat_slo_ids.request_latency
    availability_api = var.uat_slo_ids.availability_api
  }
  
  # UAT-specific configuration...
}
```

2. Add corresponding variables in `variables.tf`:

```hcl
variable "uat_slo_ids" {
  description = "UAT environment SLO IDs"
  type = object({
    request_latency = string
    availability_api = string
  })
  default = {
    request_latency = "uat-request-latency-slo-id"
    availability_api = "uat-availability-slo-id"
  }
}
```

3. Add outputs in `main.tf`:

```hcl
output "uat_dashboard_titles" {
  description = "UAT dashboard titles"
  value       = module.uat_dashboard.dashboard_titles
}
```

### Environment-Specific SLO Configuration

Each environment can have different SLO IDs:

```hcl
# Production SLOs (strict SLAs)
prod_slo_ids = {
  request_latency = "prod-strict-latency-slo"
  availability_api = "prod-99.9-availability-slo"
}

# Staging SLOs (relaxed SLAs)
staging_slo_ids = {
  request_latency = "staging-relaxed-latency-slo"
  availability_api = "staging-99.0-availability-slo"
}

# Development SLOs (informational only)
dev_slo_ids = {
  request_latency = "dev-info-latency-slo"
  availability_api = "dev-info-availability-slo"
}
```

## Outputs

After applying, you'll see:
- `prod_dashboard_titles`: Production dashboard titles
- `staging_dashboard_titles`: Staging dashboard titles
- `dev_dashboard_titles`: Development dashboard titles
- `all_dashboard_count`: Total number of dashboards created across all environments

## Best Practices

1. **Environment Isolation**: Use separate SLO IDs for each environment
2. **Gradual Monitoring**: Start with minimal monitoring in dev, add more in staging, full monitoring in production
3. **Team-Specific Slack Channels**: Use different Slack teams for each environment
4. **Naming Conventions**: Use consistent naming patterns across environments
5. **Resource Management**: Consider disabling expensive widgets in non-production environments
