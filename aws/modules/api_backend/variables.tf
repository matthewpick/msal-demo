variable "domain_name" {
  type        = string
  description = "Custom domain name (e.g., api1.matthewpick.com) served via CloudFront"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN in us-east-1 for CloudFront"
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "Hosted zone ID for creating alias record to CloudFront"
}

variable "azure_client_id" {
  type        = string
  description = "Azure AD Application (Client) ID for this API"
  default     = ""
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure AD Tenant ID"
  default     = ""
}

variable "frontend_domain" {
  type        = string
  description = "Frontend domain for CORS configuration"
  default     = "demo-frontend.matthewpick.com"
}

