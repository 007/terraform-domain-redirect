variable "certificate_arn" {
  type        = string
  description = "ARN of certificate for source_domain"
}

variable "destination_domain" {
  type        = string
  description = "Destination domain to redirect to"
}

variable "source_domain" {
  type        = string
  description = "Source domain name to redirect away from"
}
