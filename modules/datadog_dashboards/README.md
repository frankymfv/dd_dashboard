# Datadog Dashboards Module

This Terraform module manages Datadog dashboards using YAML files with flexible widget group controls.

## Usage

### Basic Usage
```hcl
module "datadog_dashboards" {
  source     = "./modules/datadog_dashboards"
  add_prefix = "[PROD] "
}
```

### Advanced Usage with Widget Controls
```hcl
module "datadog_dashboards" {
  source = "./modules/datadog_dashboards"
  
  add_prefix = "[PROD] "
  
  # Customize template variables
  template_variables = {
    env = {
      available_values = ["prod", "staging", "dev"]
      default         = "prod"
    }
    team = {
      available_values = ["backend", "frontend", "devops"]
      default         = "backend"
    }
    namespace = {
      available_values = ["prod-backend", "staging-backend"]
      default         = "prod-backend"
    }
    service = {
      available_values = ["api-service", "worker-service", "web-service"]
      default         = "api-service"
    }
  }
  
  # Enable/disable specific widget groups
  enabled_widgets = {
    dashboard_header = true
    overview_group = true
    access_location = false          # Disable access location widget
    alb_information = true
    cpu_mem_kubernetes = true
    application_performance = true
    services_group = true
    rds_group = false               # Disable RDS monitoring
    cache_group = false             # Disable cache monitoring
    s3_group = true
  }
}
```

### Minimal Dashboard (Only Core Widgets)
```hcl
module "minimal_dashboard" {
  source = "./modules/datadog_dashboards"
  
  enabled_widgets = {
    dashboard_header = true
    overview_group = true
    alb_information = true
    cpu_mem_kubernetes = true
    # All other widgets disabled by default
    access_location = false
    application_performance = false
    services_group = false
    rds_group = false
    cache_group = false
    s3_group = false
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| add_prefix | Optional prefix for all dashboard titles | `string` | `""` | no |
| template_variables | Template variables configuration for dashboard filtering | `object` | See below | no |
| enabled_widgets | Configuration to enable/disable individual widget groups | `object` | All enabled | no |

### template_variables Object Structure
```hcl
template_variables = {
  env = {
    available_values = list(string)  # List of environment values
    default         = string         # Default environment value
  }
  team = {
    available_values = list(string)  # List of team values
    default         = string         # Default team value
  }
  namespace = {
    available_values = list(string)  # List of namespace values
    default         = string         # Default namespace value
  }
  service = {
    available_values = list(string)  # List of service values
    default         = string         # Default service value
  }
}
```

### enabled_widgets Object Structure
```hcl
enabled_widgets = {
  dashboard_header = bool           # Dashboard header with branding
  overview_group = bool            # SLO overview and monitors
  access_location = bool           # Access location geomap widget
  alb_information = bool           # ALB information table
  cpu_mem_kubernetes = bool        # Kubernetes CPU/Memory table
  application_performance = bool   # Application performance group
  services_group = bool            # Services health and monitoring
  rds_group = bool                # RDS database monitoring
  cache_group = bool              # Cache (ElastiCache) monitoring
  s3_group = bool                 # S3 storage monitoring
}
```

## Available Widget Groups

| Widget Group | Description | Use Case |
|--------------|-------------|----------|
| `dashboard_header` | Dashboard branding, title, and contact info | Always recommended |
| `overview_group` | SLO tracking, availability metrics, monitors | Core monitoring |
| `access_location` | Geographic access distribution map | Web applications |
| `alb_information` | Load balancer metrics and health | AWS ALB users |
| `cpu_mem_kubernetes` | Kubernetes resource utilization | Kubernetes deployments |
| `application_performance` | HTTP response codes, latency, errors | Application monitoring |
| `services_group` | Container states, dependency maps | Microservices |
| `rds_group` | Database connections, performance, queries | RDS/Aurora users |
| `cache_group` | Cache hit rates, memory usage, commands | Redis/ElastiCache users |
| `s3_group` | Storage usage, request metrics, errors | S3 storage users |

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
