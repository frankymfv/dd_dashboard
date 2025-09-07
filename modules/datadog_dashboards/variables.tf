variable "dashboard_title" {
  description = "Title for the dashboard"
  type        = string
  default     = "[Franky]System Dashboard"
}

variable "dashboard_image_url" {
  description = "URL for the dashboard header image"
  type        = string
  default     = "https://dlaudio.fineshare.net/cover/song-ai/covers/mackenzie-border-collie.webp"
}

variable "slack_team" {
  description = "Slack team name for contact information"
  type        = string
  default     = "your_slack_team"
}

variable "slo_ids" {
  description = "SLO IDs for dashboard widgets"
  type = object({
    request_latency = string
    availability_api = string
  })
  default = {
    request_latency = "55851b7bf8d15e6597a0b55aa15ceadc"
    availability_api = "b8c13e6ff68e500eb487c3aac7eaaa8a"
  }
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
