output "bucket_name" {
  description = "Name of S3 bucket hosting frontend"
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.site.id
}

