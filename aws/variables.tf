# Core variables for domain and hosted zone configuration

variable "aws_region" {
  type        = string
  description = "AWS region for core infrastructure (Lambdas + API Gateway). Keep us-east-1 to simplify ACM for CloudFront at this stage."
  default     = "us-east-1"
}

variable "api1_domain" {
  type        = string
  description = "FQDN for API 1 (e.g., api1.matthewpick.com)"
}

variable "api2_domain" {
  type        = string
  description = "FQDN for API 2 (e.g., api2.matthewpick.com)"
}

variable "api3_domain" {
  type        = string
  description = "FQDN for API 3 (e.g., api3.matthewpick.com)"
}

variable "frontend_domain" {
  type        = string
  description = "FQDN for the frontend SPA (e.g., demo-frontend.matthewpick.com)"
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID that manages the above domains."
  default     = "Z2QNLRRF8YAHS9"
}
