variable "domain_name" {
  type        = string
  description = "Frontend custom domain (e.g., demo-frontend.matthewpick.com)"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for the frontend domain (us-east-1)"
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "Hosted zone ID for Route53 alias record"
}

