# Template Variables Guide

This guide explains how to use and configure template variables in the terraform-datadog-dashboards module.

## Overview

Template variables allow you to create dynamic, filterable dashboards that can be customized for different environments, teams, services, and namespaces. They provide a way to make your dashboards more flexible and reusable.

## Available Template Variables

The module supports four main template variable categories:

- **Environment** (`env`): Production, staging, development environments
- **Team** (`team`): Different teams or departments
- **Namespace** (`namespace`): Kubernetes namespaces or service groups
- **Service** (`service`): Individual services or applications

## Basic Configuration

### Default Template Variables

```hcl
module "datadog_dashboards" {
  source = "path/to/terraform-datadog-dashboards"
  
  template_variables = {
    env = {
      available_values = ["prod", "stg", "dev"]
      default         = "prod"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    namespace = {
      available_values = ["prod-platform", "stg-platform", "dev-platform"]
      default         = "prod-platform"
    }
    service = {
      available_values = ["api-service", "web-service", "worker-service"]
      default = "api-service"
    }
  }
}
```

### Template Variable Structure

Each template variable has the following structure:

```hcl
variable_name = {
  available_values = list(string)  # List of possible values
  default         = string         # Default selected value
}
```

## Using Template Variables in Widgets

### Basic Usage

Template variables can be used in widget queries and configurations:

```yaml
# In a widget YAML file
definition:
  title: "Requests for ${default_service}"
  requests:
    - q: "sum:nginx.requests{service:${default_service},env:${default_env}}"
      display_type: "line"
```

### Available Template Variables in Widgets

- `${default_env}`: Default environment value
- `${default_team}`: Default team value
- `${default_namespace}`: Default namespace value
- `${default_service}`: Default service value
- `${env_values}`: JSON array of all environment values
- `${team_values}`: JSON array of all team values
- `${namespace_values}`: JSON array of all namespace values
- `${service_values}`: JSON array of all service values

## Advanced Template Variable Configurations

### Environment-Specific Variables

```hcl
# Production environment
module "prod_dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  template_variables = {
    env = {
      available_values = ["prod", "production"]
      default         = "prod"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    namespace = {
      available_values = ["prod-platform", "prod-data", "prod-frontend"]
      default         = "prod-platform"
    }
    service = {
      available_values = [
        "prod-api-service",
        "prod-web-service",
        "prod-worker-service"
      ]
      default = "prod-api-service"
    }
  }
}

# Staging environment
module "staging_dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  template_variables = {
    env = {
      available_values = ["stg", "staging"]
      default         = "stg"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    namespace = {
      available_values = ["stg-platform", "stg-data", "stg-frontend"]
      default         = "stg-platform"
    }
    service = {
      available_values = [
        "stg-api-service",
        "stg-web-service"
      ]
      default = "stg-api-service"
    }
  }
}
```

### Dynamic Template Variables

```hcl
locals {
  # Define available services per environment
  environment_services = {
    prod = [
      "prod-api-service",
      "prod-web-service",
      "prod-worker-service",
      "prod-data-pipeline"
    ]
    stg = [
      "stg-api-service",
      "stg-web-service"
    ]
    dev = [
      "dev-api-service"
    ]
  }
  
  # Define available namespaces per environment
  environment_namespaces = {
    prod = [
      "prod-platform",
      "prod-data",
      "prod-frontend"
    ]
    stg = [
      "stg-platform",
      "stg-data"
    ]
    dev = [
      "dev-platform"
    ]
  }
}

module "dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  template_variables = {
    env = {
      available_values = ["prod", "stg", "dev"]
      default         = var.environment
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    namespace = {
      available_values = local.environment_namespaces[var.environment]
      default         = "${var.environment}-platform"
    }
    service = {
      available_values = local.environment_services[var.environment]
      default = "${var.environment}-api-service"
    }
  }
}
```

## Template Variable Best Practices

### 1. Naming Conventions

Use consistent naming conventions across environments:

```hcl
# Good: Consistent naming
template_variables = {
  env = {
    available_values = ["prod", "stg", "dev"]
    default         = "prod"
  }
  service = {
    available_values = [
      "prod-api-service",
      "stg-api-service", 
      "dev-api-service"
    ]
    default = "prod-api-service"
  }
}

# Bad: Inconsistent naming
template_variables = {
  env = {
    available_values = ["production", "staging", "development"]
    default         = "production"
  }
  service = {
    available_values = [
      "api-prod",
      "staging-api",
      "dev-api-service"
    ]
    default = "api-prod"
  }
}
```

### 2. Logical Grouping

Group related values together:

```hcl
template_variables = {
  env = {
    available_values = ["prod", "stg", "dev"]
    default         = "prod"
  }
  team = {
    available_values = ["platform", "data-team", "frontend"]
    default         = "platform"
  }
  namespace = {
    available_values = [
      "prod-platform", "stg-platform", "dev-platform",
      "prod-data", "stg-data", "dev-data",
      "prod-frontend", "stg-frontend", "dev-frontend"
    ]
    default = "prod-platform"
  }
}
```

### 3. Default Value Selection

Choose sensible defaults:

```hcl
# Good: Production as default for critical dashboards
template_variables = {
  env = {
    available_values = ["prod", "stg", "dev"]
    default         = "prod"  # Most important environment
  }
}

# Good: Most common service as default
template_variables = {
  service = {
    available_values = ["api-service", "web-service", "worker-service"]
    default = "api-service"  # Most commonly monitored service
  }
}
```

## Widget Examples with Template Variables

### Service-Specific Metrics

```yaml
definition:
  title: "Request Rate - ${default_service}"
  type: "timeseries"
  requests:
    - q: "sum:nginx.requests{service:${default_service}} by {env}"
      display_type: "line"
      style:
        palette: "dog_classic"
```

### Environment Comparison

```yaml
definition:
  title: "Error Rate Comparison"
  type: "timeseries"
  requests:
    - q: "sum:nginx.requests{service:${default_service},status:error} by {env}"
      display_type: "line"
      style:
        palette: "dog_classic"
```

### Team-Specific Dashboard

```yaml
definition:
  title: "Team Performance - ${default_team}"
  type: "query_value"
  requests:
    - q: "avg:response_time{team:${default_team},env:${default_env}}"
      aggregator: "avg"
```

### Namespace Resource Usage

```yaml
definition:
  title: "CPU Usage - ${default_namespace}"
  type: "timeseries"
  requests:
    - q: "avg:kubernetes.cpu.usage{namespace:${default_namespace}} by {pod}"
      display_type: "line"
      style:
        palette: "dog_classic"
```

## Template Variable Validation

### Input Validation

```hcl
variable "template_variables" {
  description = "Template variables configuration"
  type = object({
    env = object({
      available_values = list(string)
      default         = string
    })
    team = object({
      available_values = list(string)
      default         = string
    })
    namespace = object({
      available_values = list(string)
      default         = string
    })
    service = object({
      available_values = list(string)
      default         = string
    })
  })
  
  validation {
    condition = contains(var.template_variables.env.available_values, var.template_variables.env.default)
    error_message = "Default environment must be in available_values list."
  }
  
  validation {
    condition = contains(var.template_variables.team.available_values, var.template_variables.team.default)
    error_message = "Default team must be in available_values list."
  }
  
  validation {
    condition = contains(var.template_variables.namespace.available_values, var.template_variables.namespace.default)
    error_message = "Default namespace must be in available_values list."
  }
  
  validation {
    condition = contains(var.template_variables.service.available_values, var.template_variables.service.default)
    error_message = "Default service must be in available_values list."
  }
}
```

## Troubleshooting Template Variables

### Common Issues

1. **Template variable not rendering**: Check variable name spelling
2. **Default value not in list**: Ensure default is in available_values
3. **Empty values**: Verify template variable configuration
4. **Query errors**: Check if tags exist in Datadog

### Debugging Steps

1. **Check template substitution**:
   ```bash
   terraform console
   > templatefile("dashboard_widgets/my_widget.yaml", {
       default_env = "prod"
       default_service = "api-service"
     })
   ```

2. **Validate variable configuration**:
   ```bash
   terraform validate
   ```

3. **Check Datadog tags**:
   ```bash
   # Verify tags exist in Datadog
   curl -X GET "https://api.datadoghq.com/api/v1/tags/hosts" \
     -H "DD-API-KEY: ${DD_API_KEY}" \
     -H "DD-APPLICATION-KEY: ${DD_APP_KEY}"
   ```

## Advanced Use Cases

### Conditional Template Variables

```hcl
locals {
  # Different services per team
  team_services = {
    platform = ["api-service", "worker-service", "scheduler-service"]
    data-team = ["data-pipeline", "etl-service", "analytics-service"]
    frontend = ["web-service", "mobile-api", "cdn-service"]
  }
}

module "dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  template_variables = {
    env = {
      available_values = ["prod", "stg", "dev"]
      default         = "prod"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
    service = {
      available_values = local.team_services[var.selected_team]
      default = local.team_services[var.selected_team][0]
    }
  }
}
```

### Multi-Environment Template Variables

```hcl
module "dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  template_variables = {
    env = {
      available_values = ["prod", "stg", "dev"]
      default         = var.environment
    }
    team = {
      available_values = var.available_teams
      default         = var.default_team
    }
    namespace = {
      available_values = var.available_namespaces
      default         = var.default_namespace
    }
    service = {
      available_values = var.available_services
      default = var.default_service
    }
  }
}
```

### Template Variable Inheritance

```hcl
# Base configuration
locals {
  base_template_variables = {
    env = {
      available_values = ["prod", "stg", "dev"]
      default         = "prod"
    }
    team = {
      available_values = ["platform", "data-team", "frontend"]
      default         = "platform"
    }
  }
}

# Environment-specific overrides
module "prod_dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  template_variables = merge(local.base_template_variables, {
    namespace = {
      available_values = ["prod-platform", "prod-data", "prod-frontend"]
      default         = "prod-platform"
    }
    service = {
      available_values = ["prod-api-service", "prod-web-service"]
      default = "prod-api-service"
    }
  })
}
```
