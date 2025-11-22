terraform {
  required_version = ">= 1.6.0"
  backend "local" {
    # Local state file (suitable for initial demo; move to remote backend like S3 + DynamoDB for prod)
    path = "terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

# Primary AWS provider (single region for initial setup). CloudFront + ACM certs will use us-east-1.
provider "aws" {
  region = var.aws_region
}

# Future: If you need a separate provider alias for us-east-1 (CloudFront/ACM) while deploying Lambdas in another region,
# add a second provider block like:
# provider "aws" {
#   alias  = "us_east_1"
#   region = "us-east-1"
# }
# And reference resources with provider = aws.us_east_1

# -----------------------------------------------------------------------------
# ACM Certificates (one per domain) with DNS validation (Step 1.2)
# -----------------------------------------------------------------------------
# We create individual certificates rather than a single SAN cert to keep mapping
# simple across environments. All in us-east-1 (required for CloudFront).
#
# NOTE: After applying, ACM will show them as "Pending validation" until the
# DNS validation records propagate. Terraform handles validation automatically
# via aws_acm_certificate_validation resources below.

locals {
  certificate_domains = {
    api1     = var.api1_domain
    api2     = var.api2_domain
    api3     = var.api3_domain
    frontend = var.frontend_domain
  }
}

resource "aws_acm_certificate" "cert" {
  for_each             = local.certificate_domains
  domain_name          = each.value
  validation_method    = "DNS"
  key_algorithm        = "RSA_2048"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Project = "msal-demo"
    Service = each.key
  }
}

# Create DNS validation records in the hosted zone for each certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for k, v in aws_acm_certificate.cert : k => one(v.domain_validation_options)
  }
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  zone_id = var.route53_hosted_zone_id
  ttl     = 300
  records = [each.value.resource_record_value]
}

# Validate certificates once DNS records exist
resource "aws_acm_certificate_validation" "cert" {
  for_each = aws_acm_certificate.cert
  certificate_arn         = each.value.arn
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}

module "api1" {
  source                = "./modules/api_backend"
  domain_name           = var.api1_domain
  certificate_arn       = aws_acm_certificate.cert["api1"].arn
  route53_hosted_zone_id = var.route53_hosted_zone_id
}

module "api2" {
  source                = "./modules/api_backend"
  domain_name           = var.api2_domain
  certificate_arn       = aws_acm_certificate.cert["api2"].arn
  route53_hosted_zone_id = var.route53_hosted_zone_id
}

module "api3" {
  source                = "./modules/api_backend"
  domain_name           = var.api3_domain
  certificate_arn       = aws_acm_certificate.cert["api3"].arn
  route53_hosted_zone_id = var.route53_hosted_zone_id
}

module "frontend" {
  source                 = "./modules/frontend_site"
  domain_name            = var.frontend_domain
  certificate_arn        = aws_acm_certificate.cert["frontend"].arn
  route53_hosted_zone_id = var.route53_hosted_zone_id
}
