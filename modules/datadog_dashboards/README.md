# terraform-datadog-dashboards

[![Latest Release](https://img.shields.io/github/release/your-org/terraform-datadog-dashboards.svg)](https://github.com/your-org/terraform-datadog-dashboards/releases/latest)
[![Terraform Version](https://img.shields.io/badge/terraform-%3E%3D%201.0.0-blue.svg)](https://www.terraform.io/downloads.html)
[![Datadog Provider](https://img.shields.io/badge/datadog%20provider-%3E%3D%203.0.0-orange.svg)](https://registry.terraform.io/providers/DataDog/datadog/latest)

A Terraform module that creates comprehensive Datadog dashboards with modular widget components, SLO monitoring, and customizable template variables for filtering and organization.

> **⚠️ Template Initialization Only**: This module is designed for initial template setup. After initial deployment, all updates and modifications should be handled directly in the Datadog UI. The module includes built-in `ignore_changes` lifecycle rule to prevent Terraform conflicts when you modify dashboards in the UI.

## Features

- **Template Initialization**: Designed for one-time dashboard template setup
- **Modular Dashboard Architecture**: Create dashboards using reusable widget components
- **SLO Integration**: Built-in support for Service Level Objective monitoring
- **Template Variables**: Configurable filtering by environment, team, namespace, and service
- **Widget Toggle Control**: Enable/disable specific widget groups based on your needs
- **YAML-based Configuration**: Easy-to-maintain dashboard layouts and widget definitions
- **Multi-Environment Support**: Flexible configuration for different environments
- **Post-Deployment Independence**: Once deployed, dashboards are managed via Datadog UI

## Usage

> **Important**: This module is intended for **template initialization only**. After the initial deployment:
> 1. **Safe UI Management**: Modify dashboards freely in the Datadog UI - the module includes `ignore_changes` to prevent conflicts
> 2. **Optional**: Remove the module from your Terraform configuration or keep it for reference
> 3. **Optional**: Import the created dashboards into your state if you need Terraform management

### Template Initialization Example

```hcl
module "datadog_dashboards" {
  source = "path/to/terraform-datadog-dashboards"
  
  # Dashboard customization
  dashboard_title     = "[PROD] System Dashboard"
  dashboard_image_url = "https://example.com/dashboard-image.png"
  slack_team          = "your-slack-team"
  
  # SLO IDs configuration
  slo_ids = {
    request_latency = "your-slo-id-1"
    availability_api = "your-slo-id-2"
  }
  
  # Template variables for filtering
  template_variables = {
    env = {
      available_values = ["prod", "stg"]
      default         = "prod"
    }
    team = {
      available_values = []
      default         = "asset-accounting"
    }
    namespace = {
      available_values = []
      default         = "prod-asset-accounting"
    }
    service = {
      available_values = []
      default = "asset-accounting-backend"
    }
  }
}
```

### Advanced Template Example with Widget Control

```hcl
module "datadog_dashboards" {
  source = "path/to/terraform-datadog-dashboards"
  
  dashboard_title     = "[PROD] Custom System Dashboard"
  dashboard_image_url = "https://example.com/custom-image.png"
  slack_team          = "production-team"
  
  slo_ids = {
    request_latency = "55851b7bf8d15e6597a0b55aa15ceadc"
    availability_api = "b8c13e6ff68e500eb487c3aac7eaaa8a"
  }
  
  template_variables = {
    env = {
      available_values = ["prod", "stg"]
      default         = "prod"
    }
    team = {
      available_values = []
      default         = "asset-accounting"
    }
    namespace = {
      available_values = []
      default         = "prod-asset-accounting"
    }
    service = {
      available_values = []
      default = "asset-accounting-backend"
    }
  }
  
  # Enable/disable specific widget groups
  enabled_widgets = {
    access_location = false
    alb_information = true
    cpu_mem_kubernetes = true
    application_performance = true
    services_group = true
    rds_group = false
    cache_group = true
    s3_group = true
  }
}
```

## Architecture

The module uses a modular architecture with the following components:

### Dashboard Layout (`dashboard/`)
- **`dashboard_layout.yaml`**: Main dashboard configuration with widget references and layout positioning

### Widget Components (`dashboard_widgets/`)
- **`dashboard_header_note.yaml`**: Header with team information and contact details
- **`overview_group.yaml`**: High-level system overview metrics
- **`access_location_widget.yaml`**: Geographic access patterns
- **`alb_information_widget.yaml`**: Application Load Balancer metrics
- **`cpu_mem_kubernetes_widget.yaml`**: Kubernetes resource utilization
- **`application_performance_group.yaml`**: Application performance metrics
- **`services_group.yaml`**: Service health and status monitoring
- **`rds_group.yaml`**: Database performance and health metrics
- **`cache_group.yaml`**: Cache performance and hit rates
- **`s3_group.yaml`**: Storage metrics and usage patterns

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| datadog | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| datadog | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dashboard_title | Title for the dashboard | `string` | `"[Franky]System Dashboard"` | no |
| dashboard_image_url | URL for the dashboard header image | `string` | `"https://dlaudio.fineshare.net/cover/song-ai/covers/mackenzie-border-collie.webp"` | no |
| slack_team | Slack team name for contact information | `string` | `"your_slack_team"` | no |
| slo_ids | SLO IDs for dashboard widgets | `object` | See variables.tf | no |
| template_variables | Template variables configuration for dashboard filtering | `object` | See variables.tf | no |
| enabled_widgets | Configuration to enable/disable individual widget groups | `object` | All enabled | no |

### SLO IDs Object Structure

```hcl
slo_ids = {
  request_latency = "string"    # SLO ID for request latency monitoring
  availability_api = "string"   # SLO ID for API availability monitoring
}
```

### Template Variables Object Structure

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

### Enabled Widgets Object Structure

```hcl
enabled_widgets = {
  access_location = bool       # Geographic access patterns
  alb_information = bool       # Load balancer metrics
  cpu_mem_kubernetes = bool    # Kubernetes resource metrics
  application_performance = bool # Application performance metrics
  services_group = bool        # Service health monitoring
  rds_group = bool            # Database metrics
  cache_group = bool          # Cache performance metrics
  s3_group = bool             # Storage metrics
}
```

**Note**: `dashboard_header` and `overview_group` are always enabled and cannot be disabled through the `enabled_widgets` configuration.

## Outputs

| Name | Description |
|------|-------------|
| dashboard_titles | The dashboard titles after applying prefix |
| dashboard_ids | The Datadog dashboard IDs for each created dashboard |
| dashboard_urls | The Datadog dashboard URLs for each created dashboard |
| widget_counts | The number of widgets in each dashboard |
| enabled_widgets_status | Shows which widgets are enabled/disabled in the current configuration |
| template_variables | The template variables configuration used for dashboard filtering |

## Examples

See the [examples](./examples) directory for complete working examples:

- [Template Initialization](./examples/template-initialization) - **Recommended for first-time setup**

This example demonstrates how to use the module for initial dashboard template creation and provides comprehensive outputs for post-deployment management.

## Widget Customization

### Adding New Widgets

1. Create a new YAML file in the `dashboard_widgets/` directory
2. Add the widget reference to `dashboard/dashboard_layout.yaml`
3. Update the `widget_enabled_map` in `main.tf`
4. Add the widget to the `enabled_widgets` variable

### Modifying Existing Widgets

Edit the corresponding YAML file in the `dashboard_widgets/` directory. The module supports template substitution for dynamic values.

### Template Variables

Widgets can use the following template variables:
- `${dashboard_image_url}`: Dashboard header image URL
- `${slack_team}`: Slack team name
- `${slo_ids.request_latency}`: Request latency SLO ID
- `${slo_ids.availability_api}`: API availability SLO ID

## Development

### Prerequisites

- Terraform >= 1.0.0
- Datadog API and App keys
- Go 1.19+ (for testing)

### Template Initialization Workflow

```bash
# 1. Initialize Terraform
terraform init

# 2. Plan the template deployment
terraform plan

# 3. Apply the template (one-time setup)
terraform apply

# 4. After successful deployment, remove the module from your configuration
# 5. Import dashboards to state if needed for future management
terraform import datadog_dashboard_json.dashboards["dashboard_name"] <dashboard_id>

# 6. Destroy the module resources (optional, if you want to manage via UI)
terraform destroy
```

### Post-Deployment Management

After the initial template deployment:

1. **Remove the module** from your Terraform configuration
2. **Import dashboards** to your state if you need Terraform management
3. **Use Datadog UI** for all future modifications to avoid conflicts
4. **Document changes** in your team's dashboard management process

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:

- Create an issue in the GitHub repository
- Contact the team via Slack: `#datadog-dashboards`
- Review the [documentation](./docs) for detailed guides

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.

## Related Projects

- [terraform-datadog-monitors](https://github.com/your-org/terraform-datadog-monitors) - Datadog monitoring and alerting
- [terraform-datadog-slos](https://github.com/your-org/terraform-datadog-slos) - Service Level Objectives management
- [terraform-datadog-logs](https://github.com/your-org/terraform-datadog-logs) - Log management and processing

---

Made with ❤️ by the Platform Team
