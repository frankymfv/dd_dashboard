# Basic Dashboard Example

This example demonstrates the minimal configuration needed to create a Datadog dashboard using the terraform-datadog-dashboards module.

## What This Example Creates

- A single Datadog dashboard with all default widgets enabled
- Template variables for environment, team, namespace, and service filtering
- Basic SLO integration for request latency and API availability

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

## Customization

You can customize this example by:

- Changing the `dashboard_title` to match your naming convention
- Updating the `dashboard_image_url` to use your team's logo
- Modifying the `slack_team` name
- Adjusting the `template_variables` values to match your environment
- Replacing the SLO IDs with your actual Datadog SLO IDs

## Outputs

After applying, you'll see:
- `dashboard_titles`: The titles of created dashboards
- `dashboard_count`: The number of dashboards created
