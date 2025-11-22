# Placeholder outputs for resources that will be added in later phases.
# Using null values so terraform validate still succeeds. Replace `null` with actual resource references as they are created.

output "api1_cloudfront_domain_name" {
  description = "Domain name of CloudFront distribution for API 1"
  value       = null # e.g., aws_cloudfront_distribution.api1.domain_name
}

output "api2_cloudfront_domain_name" {
  description = "Domain name of CloudFront distribution for API 2"
  value       = null
}

output "api3_cloudfront_domain_name" {
  description = "Domain name of CloudFront distribution for API 3"
  value       = null
}

output "frontend_cloudfront_domain_name" {
  description = "Domain name of CloudFront distribution for the frontend"
  value       = null
}

output "api1_lambda_arn" {
  description = "Lambda function ARN for API 1"
  value       = null # e.g., aws_lambda_function.api1.arn
}

output "api2_lambda_arn" {
  description = "Lambda function ARN for API 2"
  value       = null
}

output "api3_lambda_arn" {
  description = "Lambda function ARN for API 3"
  value       = null
}

output "frontend_s3_bucket_name" {
  description = "S3 bucket name hosting the frontend static site"
  value       = null # e.g., aws_s3_bucket.frontend.bucket
}

output "acm_certificate_arns" {
  description = "Map of certificate logical key to ACM certificate ARN"
  value       = { for k, cert in aws_acm_certificate.cert : k => cert.arn }
}

output "acm_certificate_domains" {
  description = "Map of certificate logical key to domain name"
  value       = { for k, cert in aws_acm_certificate.cert : k => cert.domain_name }
}
