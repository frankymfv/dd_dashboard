Great choice! Using datadog_dashboard_json is cleaner because it directly accepts the JSON representation of the dashboard, which is exactly what we get after converting YAML → JSON.

Here’s the updated full guideline:

⸻

✅ Updated Folder Structure

infra/
├── main.tf
├── variables.tf
├── terraform.tfvars
└── modules/
    └── datadog_dashboards/
        ├── main.tf
        ├── variables.tf
        ├── README.md
        └── dashboards/
            ├── dashboard1.yaml
            ├── dashboard2.yaml


⸻

✅ Module Code (Using datadog_dashboard_json)

modules/datadog_dashboards/variables.tf

variable "add_prefix" {
  description = "Optional prefix for all dashboard titles"
  type        = string
  default     = ""
}


⸻

modules/datadog_dashboards/main.tf

locals {
  dashboards_path = "${path.module}/dashboards"
  yaml_files      = fileset(local.dashboards_path, "*.yaml")

  dashboards = {
    for f in local.yaml_files :
    basename(f) => yamldecode(file("${local.dashboards_path}/${f}"))
  }
}

resource "datadog_dashboard_json" "dashboards" {
  for_each = local.dashboards

  dashboard = jsonencode(
    merge(
      each.value,
      {
        title = "${var.add_prefix}${each.value.title}"
      }
    )
  )
}


⸻

✅ Example YAML File

modules/datadog_dashboards/dashboards/dashboard1.yaml

title: "API Performance"
description: "Tracks latency and error rates"
layout_type: "ordered"
is_read_only: false
tags:
  - "env:prod"
  - "team:backend"
notify_list:
  - "alerts@company.com"
widgets:
  - definition:
      type: "note"
      content: "Welcome to API Dashboard"
      background_color: "yellow"
    layout:
      x: 0
      y: 0
      width: 24
      height: 4
  - definition:
      type: "timeseries"
      requests:
        - q: "avg:system.cpu.user{*}"
      title: "CPU Usage"
    layout:
      x: 0
      y: 4
      width: 47
      height: 20


⸻

✅ Root Terraform Code

main.tf

terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.0.0"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

module "datadog_dashboards" {
  source     = "./modules/datadog_dashboards"
  add_prefix = "[PROD] "
}


⸻

variables.tf

variable "datadog_api_key" {}
variable "datadog_app_key" {}


⸻

terraform.tfvars

datadog_api_key = "YOUR_DATADOG_API_KEY"
datadog_app_key = "YOUR_DATADOG_APP_KEY"


⸻

✅ CI/CD with GitHub Actions

Same as before, but terraform apply will now apply datadog_dashboard_json resources.

⸻

✅ Why datadog_dashboard_json is Better

✔ No need to match the Terraform dashboard schema → easier upgrades
✔ Supports raw JSON from YAML conversion → simpler pipeline
✔ Easier for large dashboards with complex widgets

⸻

✅ Next Enhancements
	1.	Add per-branch prefixes (e.g., [STAGING] if dev branch).
	2.	Validate YAML schema before apply.
	3.	Add GitHub Actions check for terraform validate + yamllint.

⸻

👉 Do you want me to extend this module to automatically add branch-based prefixes and integrate YAML validation into GitHub Actions? Or should I write the YAML schema validator and CI check first?