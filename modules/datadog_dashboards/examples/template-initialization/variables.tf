# Datadog Provider Configuration
variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application key"
  type        = string
  sensitive   = true
}

variable "datadog_api_url" {
  description = "Datadog API URL (defaults to US1)"
  type        = string
  default     = "https://api.datadoghq.com/"
}
