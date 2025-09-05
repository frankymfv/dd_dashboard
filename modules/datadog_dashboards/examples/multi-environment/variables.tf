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

variable "prod_slo_ids" {
  description = "Production environment SLO IDs"
  type = object({
    request_latency = string
    availability_api = string
  })
  default = {
    request_latency = "prod-request-latency-slo-id"
    availability_api = "prod-availability-slo-id"
  }
}

variable "staging_slo_ids" {
  description = "Staging environment SLO IDs"
  type = object({
    request_latency = string
    availability_api = string
  })
  default = {
    request_latency = "staging-request-latency-slo-id"
    availability_api = "staging-availability-slo-id"
  }
}

variable "dev_slo_ids" {
  description = "Development environment SLO IDs"
  type = object({
    request_latency = string
    availability_api = string
  })
  default = {
    request_latency = "dev-request-latency-slo-id"
    availability_api = "dev-availability-slo-id"
  }
}
