# SLO Integration Guide

This guide explains how to integrate Service Level Objectives (SLOs) with the terraform-datadog-dashboards module.

## Overview

SLOs (Service Level Objectives) are key metrics that define the reliability and performance targets for your services. This module provides built-in support for SLO monitoring through configurable SLO IDs.

## SLO Configuration

### Basic SLO Setup

```hcl
module "datadog_dashboards" {
  source = "path/to/terraform-datadog-dashboards"
  
  slo_ids = {
    request_latency = "your-request-latency-slo-id"
    availability_api = "your-availability-slo-id"
  }
  
  # ... other configuration
}
```

### SLO ID Structure

The module expects SLO IDs in the following format:

```hcl
slo_ids = {
  request_latency = string    # SLO ID for request latency monitoring
  availability_api = string   # SLO ID for API availability monitoring
}
```

## Creating SLOs in Datadog

### 1. Request Latency SLO

Create a latency SLO in Datadog:

1. Go to **SLOs** in the Datadog UI
2. Click **New SLO**
3. Choose **Metric-based SLO**
4. Configure:
   - **Name**: "API Request Latency"
   - **Description**: "95% of API requests complete within 200ms"
   - **Metric**: `avg:nginx.response_time{service:api}`
   - **Threshold**: `< 0.2` (200ms)
   - **Target**: `99.9%`
   - **Time Window**: `7d`

### 2. Availability SLO

Create an availability SLO:

1. Go to **SLOs** in the Datadog UI
2. Click **New SLO**
3. Choose **Metric-based SLO**
4. Configure:
   - **Name**: "API Availability"
   - **Description**: "API service availability target"
   - **Metric**: `sum:nginx.requests{service:api,status:success} / sum:nginx.requests{service:api}`
   - **Threshold**: `> 0.99` (99%)
   - **Target**: `99.9%`
   - **Time Window**: `7d`

### 3. Error Rate SLO

Create an error rate SLO:

1. Go to **SLOs** in the Datadog UI
2. Click **New SLO**
3. Choose **Metric-based SLO**
4. Configure:
   - **Name**: "API Error Rate"
   - **Description**: "API error rate should be below 1%"
   - **Metric**: `sum:nginx.requests{service:api,status:error} / sum:nginx.requests{service:api}`
   - **Threshold**: `< 0.01` (1%)
   - **Target**: `99.9%`
   - **Time Window**: `7d`

## Finding SLO IDs

### Method 1: Datadog UI

1. Go to **SLOs** in the Datadog UI
2. Click on your SLO
3. The SLO ID is in the URL: `https://app.datadoghq.com/slo/your-slo-id`

### Method 2: Datadog API

```bash
# List all SLOs
curl -X GET "https://api.datadoghq.com/api/v1/slo" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}"

# Get specific SLO details
curl -X GET "https://api.datadoghq.com/api/v1/slo/your-slo-id" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}"
```

### Method 3: Terraform Data Source

```hcl
data "datadog_slo" "request_latency" {
  name_query = "API Request Latency"
}

data "datadog_slo" "availability" {
  name_query = "API Availability"
}

module "datadog_dashboards" {
  source = "path/to/terraform-datadog-dashboards"
  
  slo_ids = {
    request_latency = data.datadog_slo.request_latency.id
    availability_api = data.datadog_slo.availability.id
  }
}
```

## SLO Widget Types

### 1. SLO Summary Widget

```yaml
definition:
  title: "API Availability SLO"
  type: "slo"
  slo_id: "${slo_ids.availability_api}"
  view_type: "detail"
  time_windows: ["7d", "30d", "90d"]
  show_error_budget: true
```

### 2. SLO Status Widget

```yaml
definition:
  title: "SLO Status Overview"
  type: "query_value"
  requests:
    - q: "slo_status(${slo_ids.availability_api})"
      aggregator: "last"
      conditional_formats:
        - comparator: ">="
          value: 99.9
          palette: "green_on_white"
        - comparator: ">="
          value: 99.0
          palette: "yellow_on_white"
        - comparator: "<"
          value: 99.0
          palette: "red_on_white"
```

### 3. Error Budget Widget

```yaml
definition:
  title: "Error Budget Remaining"
  type: "query_value"
  requests:
    - q: "error_budget(${slo_ids.availability_api})"
      aggregator: "last"
      conditional_formats:
        - comparator: ">"
          value: 0.1
          palette: "green_on_white"
        - comparator: ">"
          value: 0.05
          palette: "yellow_on_white"
        - comparator: "<="
          value: 0.05
          palette: "red_on_white"
```

## Multi-Environment SLO Configuration

### Environment-Specific SLOs

```hcl
# Production SLOs (strict targets)
module "prod_dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  slo_ids = {
    request_latency = "prod-latency-slo-id"
    availability_api = "prod-availability-slo-id"
  }
  
  # ... other configuration
}

# Staging SLOs (relaxed targets)
module "staging_dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  slo_ids = {
    request_latency = "staging-latency-slo-id"
    availability_api = "staging-availability-slo-id"
  }
  
  # ... other configuration
}
```

### Dynamic SLO Selection

```hcl
locals {
  environment_slos = {
    prod = {
      request_latency = "prod-latency-slo-id"
      availability_api = "prod-availability-slo-id"
    }
    staging = {
      request_latency = "staging-latency-slo-id"
      availability_api = "staging-availability-slo-id"
    }
    dev = {
      request_latency = "dev-latency-slo-id"
      availability_api = "dev-availability-slo-id"
    }
  }
}

module "dashboard" {
  source = "path/to/terraform-datadog-dashboards"
  
  slo_ids = local.environment_slos[var.environment]
  
  # ... other configuration
}
```

## SLO Alerting Integration

### Alert on SLO Burn Rate

```hcl
resource "datadog_monitor" "slo_burn_rate" {
  name = "High SLO Burn Rate - ${var.service_name}"
  type = "slo alert"
  
  query = "error_budget(${var.slo_id}) < 0.1"
  
  message = <<-EOT
    SLO burn rate is high for ${var.service_name}.
    
    @slack-${var.slack_channel}
    @pagerduty-${var.pagerduty_service}
  EOT
  
  tags = ["service:${var.service_name}", "env:${var.environment}"]
  
  notify_no_data = false
  renotify_interval = 60
}
```

### Alert on SLO Status

```hcl
resource "datadog_monitor" "slo_status" {
  name = "SLO Status Degraded - ${var.service_name}"
  type = "slo alert"
  
  query = "slo_status(${var.slo_id}) < 99.0"
  
  message = <<-EOT
    SLO status is degraded for ${var.service_name}.
    Current status: {{slo_status}}
    
    @slack-${var.slack_channel}
  EOT
  
  tags = ["service:${var.service_name}", "env:${var.environment}"]
  
  notify_no_data = false
  renotify_interval = 30
}
```

## SLO Best Practices

### 1. SLO Target Selection

- **Availability**: 99.9% for critical services, 99.0% for non-critical
- **Latency**: 95th percentile < 200ms for APIs, < 100ms for internal services
- **Error Rate**: < 0.1% for critical services, < 1% for non-critical

### 2. Time Windows

- **Short-term**: 7 days for immediate feedback
- **Medium-term**: 30 days for trend analysis
- **Long-term**: 90 days for historical context

### 3. Error Budget Management

- **Conservative**: 20% error budget remaining triggers alerts
- **Moderate**: 10% error budget remaining triggers alerts
- **Aggressive**: 5% error budget remaining triggers alerts

### 4. SLO Documentation

Document your SLOs with:

```hcl
# SLO Documentation
slo_documentation = {
  request_latency = {
    description = "95% of API requests complete within 200ms"
    target = "99.9%"
    time_window = "7d"
    business_impact = "User experience degradation"
    owner = "Platform Team"
  }
  availability_api = {
    description = "API service availability target"
    target = "99.9%"
    time_window = "7d"
    business_impact = "Service unavailability"
    owner = "Platform Team"
  }
}
```

## Troubleshooting SLO Integration

### Common Issues

1. **SLO ID not found**: Verify the SLO ID exists in Datadog
2. **SLO not displaying**: Check if SLO has data for the time window
3. **Template variable not working**: Ensure SLO ID is properly referenced
4. **Permission issues**: Verify API key has SLO read permissions

### Debugging Steps

1. **Verify SLO exists**:
   ```bash
   curl -X GET "https://api.datadoghq.com/api/v1/slo/your-slo-id" \
     -H "DD-API-KEY: ${DD_API_KEY}" \
     -H "DD-APPLICATION-KEY: ${DD_APP_KEY}"
   ```

2. **Check SLO data**:
   ```bash
   curl -X GET "https://api.datadoghq.com/api/v1/slo/your-slo-id/history" \
     -H "DD-API-KEY: ${DD_API_KEY}" \
     -H "DD-APPLICATION-KEY: ${DD_APP_KEY}"
   ```

3. **Test template substitution**:
   ```bash
   terraform console
   > templatefile("dashboard_widgets/slo_widget.yaml", {
       slo_ids = {
         availability_api = "your-slo-id"
       }
     })
   ```

## Advanced SLO Features

### Composite SLOs

Create composite SLOs for multiple services:

```hcl
# Create composite SLO
resource "datadog_slo" "composite_api" {
  name = "Composite API SLO"
  type = "composite"
  
  composite_query {
    formula = "slo1 * 0.7 + slo2 * 0.3"
  }
  
  slo_ids = [
    datadog_slo.api_latency.id,
    datadog_slo.api_availability.id
  ]
}
```

### SLO with Tags

Use tags for SLO filtering:

```yaml
definition:
  title: "SLO by Environment"
  type: "slo"
  slo_id: "${slo_ids.availability_api}"
  view_type: "detail"
  time_windows: ["7d"]
  show_error_budget: true
  tags: ["env:${default_env}"]
```

### SLO Trend Analysis

```yaml
definition:
  title: "SLO Trend Analysis"
  type: "timeseries"
  requests:
    - q: "slo_status(${slo_ids.availability_api})"
      display_type: "line"
      style:
        palette: "dog_classic"
        line_type: "solid"
        line_width: "normal"
  yaxis:
    label: "SLO Status %"
    scale: "linear"
    min: "95"
    max: "100"
    include_zero: false
```
