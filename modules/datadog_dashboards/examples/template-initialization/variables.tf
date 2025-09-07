# Datadog Provider Configuration
variable "datadog_api_key" {
  description = "Datadog API key (can be set via DD_API_KEY environment variable)"
  type        = string
  sensitive   = true
  default     = null
}

variable "datadog_app_key" {
  description = "Datadog Application key (can be set via DD_APP_KEY environment variable)"
  type        = string
  sensitive   = true
  default     = null
}

variable "datadog_api_url" {
  description = "Datadog API URL (defaults to US1)"
  type        = string
  default     = "https://api.datadoghq.com/"
}
