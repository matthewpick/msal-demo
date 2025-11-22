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

