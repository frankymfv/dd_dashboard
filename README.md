# Datadog Dashboard Terraform Module

A comprehensive Terraform module for managing Datadog dashboards using YAML configuration files. This project provides a modular approach to creating and maintaining Datadog dashboards with reusable widget components.

## 🎯 Project Overview

This project consists of two main components:

1. **Main Terraform Configuration** - Deploys Datadog dashboards using the custom module
2. **Datadog Dashboards Module** - A reusable Terraform module that processes YAML dashboard configurations and creates Datadog dashboard resources

## 📁 Project Structure

```
dd_module_2/
├── main.tf                          # Main Terraform configuration
├── variables.tf                     # Input variables
├── backend.tf                       # Terraform Cloud backend configuration
├── dashboard.yaml                   # Simple test dashboard
├── modules/
│   └── datadog_dashboards/          # Custom Datadog dashboards module
│       ├── main.tf                  # Module logic
│       ├── variables.tf             # Module variables
│       ├── outputs.tf               # Module outputs
│       ├── versions.tf              # Provider requirements
│       ├── README.md                # Module documentation
│       ├── dashboard/               # Dashboard layout configurations
│       │   └── dashboard_layout.yaml
│       ├── dashboard_widgets/       # Individual widget definitions
│       │   ├── access_location_widget.yaml
│       │   ├── alb_information_widget.yaml
│       │   ├── application_performance_group.yaml
│       │   ├── cache_group.yaml
│       │   ├── cpu_mem_kubernetes_widget.yaml
│       │   ├── dashboard_header_note.yaml
│       │   ├── overview_group.yaml
│       │   ├── rds_group.yaml
│       │   ├── s3_group.yaml
│       │   └── services_group.yaml
│       ├── raw_data_not_use/        # Reference data
│       └── tasks/                   # Project tasks and documentation
└── 00_test_to_json/                 # Testing and development files
    ├── main.tf                      # Test Terraform configuration
    ├── dashboard/                   # Test dashboard configurations
    └── dashboard_widgets/           # Test widget configurations
```

## 🚀 Features

### Modular Dashboard Management
- **YAML-based Configuration**: Define dashboards and widgets using YAML files
- **Widget Reusability**: Create reusable widget components that can be shared across dashboards
- **Template Variables**: Support for dynamic template variables (env, team, namespace, service, etc.)
- **Automatic Processing**: Terraform automatically processes YAML files and creates Datadog resources

### Comprehensive Monitoring Coverage
The module includes pre-configured widgets for:

- **System Overview**: SLO monitoring, availability metrics, and service health
- **Application Performance**: HTTP response codes, latency metrics, and error rates
- **Infrastructure**: Kubernetes resource utilization, container health, and networking
- **Database Monitoring**: RDS performance, connections, replication lag, and query metrics
- **Cache Monitoring**: ElastiCache performance, hit rates, and resource utilization
- **Storage**: S3 bucket metrics, request patterns, and error tracking
- **Load Balancers**: ALB metrics, request distribution, and response times

### Advanced Widget Types
- **SLO Widgets**: Service Level Objective tracking with error budgets
- **Geographic Maps**: User access location visualization
- **Topology Maps**: Service dependency visualization
- **Query Tables**: Detailed metric breakdowns with conditional formatting
- **Time Series**: Historical performance trends
- **Group Widgets**: Organized sections with multiple related metrics

## 🛠️ Usage

### Prerequisites

1. **Terraform**: Version 1.0 or later
2. **Datadog Account**: API and App keys configured
3. **Terraform Cloud**: Backend configured (optional)

### Basic Setup

1. **Configure Variables**:
   ```hcl
   variable "datadog_api_key" {
     description = "Datadog API key"
     type        = string
   }

   variable "datadog_app_key" {
     description = "Datadog APP key"
     type        = string
   }
   ```

2. **Use the Module**:
   ```hcl
   module "datadog_dashboards" {
     source     = "./modules/datadog_dashboards"
     add_prefix = "[PROD] "
   }
   ```

3. **Initialize and Apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Dashboard Configuration

#### Dashboard Layout File
Create a dashboard layout file in `modules/datadog_dashboards/dashboard/`:

```yaml
title: "[SLO standard] System dashboard Testing"
description: "Comprehensive system dashboard with SLO monitoring"
layout_type: "ordered"
tags: []

# Widget references
widgets:
  - widget_file: "dashboard_header_note.yaml"
    layout:
      x: 0
      y: 0
      width: 4
      height: 7
  
  - widget_file: "overview_group.yaml"
    layout:
      x: 4
      y: 0
      width: 8
      height: 10

# Template variables
template_variables:
  - name: "env"
    prefix: "env"
    available_values: ["prod", "stg"]
    default: "prod"
  
  - name: "team"
    prefix: "team"
    available_values: []
    default: "asset-accounting"
```

#### Widget Definition File
Create widget definitions in `modules/datadog_dashboards/dashboard_widgets/`:

```yaml
definition:
  title: "CPU and Memory by Kubernetes Objects"
  type: "query_table"
  requests:
    - queries:
        - query: "sum:kubernetes.cpu.requests{$env,kube_namespace:$namespace.value} by {kube_namespace,env,kube_deployment}"
          data_source: "metrics"
          name: "query1"
          aggregator: "avg"
      formulas:
        - alias: "CPU requests"
          formula: "query1"
```

## 📊 Dashboard Components

### Overview Group
- **SLO Monitoring**: Request latency and availability tracking
- **Service Health**: Monitor status and alerts
- **Performance Metrics**: Key performance indicators

### Application Performance
- **HTTP Response Codes**: 3xx, 4xx, 5xx error tracking
- **Request Latency**: P95, P99 response times
- **Error Rates**: Application and load balancer errors
- **Request Statistics**: Volume and distribution analysis

### Infrastructure Monitoring
- **Kubernetes Resources**: CPU, memory, and network utilization
- **Container Health**: Pod states, restarts, and OOM kills
- **Service Dependencies**: Topology maps and service relationships

### Database Monitoring (RDS)
- **Connection Management**: Active connections and limits
- **Performance Metrics**: Query latency, throughput, and deadlocks
- **Resource Utilization**: CPU, memory, and I/O metrics
- **Replication**: Lag monitoring and health checks

### Cache Monitoring (ElastiCache)
- **Performance**: Hit rates, miss rates, and evictions
- **Resource Usage**: CPU, memory, and network utilization
- **Command Execution**: GET/SET operation latency and throughput

### Storage Monitoring (S3)
- **Bucket Metrics**: Size, object count, and request patterns
- **Error Tracking**: 4xx and 5xx error rates
- **Data Transfer**: Upload/download volumes and patterns

## 🔧 Configuration Options

### Module Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|:--------:|
| `add_prefix` | Optional prefix for all dashboard titles | `string` | `""` | no |

### Template Variables

The module supports dynamic template variables for filtering and customization:

- **env**: Environment (prod, stg, production, staging)
- **team**: Team identifier (asset-accounting)
- **namespace**: Kubernetes namespace
- **service**: Service name
- **account**: AWS account identifier
- **region**: AWS region
- **dbinstance**: Database instance identifier
- **dbcluster**: Database cluster identifier

## 🧪 Testing

The project includes a test directory (`00_test_to_json/`) for development and testing:

```bash
cd 00_test_to_json
terraform init
terraform plan
terraform apply
```

This will generate JSON output files for validation and testing purposes.

## 📈 Outputs

The module provides several useful outputs:

- **dashboard_titles**: List of created dashboard titles
- **dashboard_configs**: Dashboard configurations in JSON format
- **dashboard_count**: Number of dashboards created
- **dashboard_names**: List of dashboard names
- **dashboard_json_output_result**: Complete dashboard JSON configurations

## 🔄 Workflow

1. **Design**: Create YAML files for dashboard layout and widget definitions
2. **Configure**: Set up template variables and environment-specific settings
3. **Deploy**: Run Terraform to create Datadog dashboard resources
4. **Monitor**: Use the dashboards to monitor your infrastructure and applications
5. **Iterate**: Update YAML files and reapply to modify dashboards

## 🏗️ Architecture

The module uses a sophisticated approach to dashboard management:

1. **File Discovery**: Automatically discovers YAML files in dashboard and widget directories
2. **YAML Processing**: Parses YAML configurations into Terraform data structures
3. **Widget Resolution**: Resolves widget references and merges definitions with layouts
4. **Resource Creation**: Creates `datadog_dashboard_json` resources for each dashboard
5. **Output Generation**: Provides comprehensive outputs for monitoring and debugging

## 📝 Best Practices

1. **Modular Design**: Keep widgets focused and reusable
2. **Consistent Naming**: Use clear, descriptive names for files and widgets
3. **Template Variables**: Leverage template variables for environment-specific configurations
4. **Documentation**: Document complex queries and widget purposes
5. **Testing**: Use the test directory to validate configurations before deployment

## 🤝 Contributing

1. Create new widget files in `modules/datadog_dashboards/dashboard_widgets/`
2. Update dashboard layouts in `modules/datadog_dashboards/dashboard/`
3. Test changes using the `00_test_to_json/` directory
4. Update documentation as needed

## 📄 License

This project is part of a personal development effort for Datadog dashboard management using Terraform.

## 🔗 Related Resources

- [Datadog Dashboard API Documentation](https://docs.datadoghq.com/api/latest/dashboards/)
- [Terraform Datadog Provider](https://registry.terraform.io/providers/DataDog/datadog/latest/docs)
- [Datadog Dashboard Widget Types](https://docs.datadoghq.com/dashboards/widgets/)

---

**Note**: This project is configured for the "FrankyTesting" organization and uses Terraform Cloud for state management. Adjust the backend configuration and organization settings as needed for your environment.
