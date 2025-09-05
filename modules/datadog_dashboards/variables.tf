variable "add_prefix" {
  description = "Optional prefix for all dashboard titles"
  type        = string
  default     = ""
}

# Template variables for dashboard filtering
variable "template_variables" {
  description = "Template variables configuration for dashboard filtering"
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

  default = {
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

# Widget group enable/disable controls
variable "enabled_widgets" {
  description = "Configuration to enable/disable individual widget groups"
  type = object({
    dashboard_header = optional(bool, true)
    overview_group = optional(bool, true)
    access_location = optional(bool, true)
    alb_information = optional(bool, true)
    cpu_mem_kubernetes = optional(bool, true)
    application_performance = optional(bool, true)
    services_group = optional(bool, true)
    rds_group = optional(bool, true)
    cache_group = optional(bool, true)
    s3_group = optional(bool, true)
  })
  default = {
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
}
