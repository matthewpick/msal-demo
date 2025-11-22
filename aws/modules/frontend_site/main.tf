# Module: frontend_site
# Provisions S3 bucket for SPA, CloudFront distribution with OAI, and Route53 alias.

locals {
  bucket_name = replace(var.domain_name, ".", "-")
}

resource "aws_s3_bucket" "site" {
  bucket        = local.bucket_name
  force_destroy = true # For demo; remove in production.
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# CloudFront Origin Access Identity (OAI)
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name}"
}

# Bucket policy to allow CloudFront OAI read access
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCloudFrontRead"
        Effect   = "Allow"
        Principal = {
          CanonicalUser = aws_cloudfront_origin_access_identity.oai.s3_canonical_user_id
        }
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::${aws_s3_bucket.site.bucket}/*"]
      }
    ]
  })
}

# Placeholder index.html object
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  content      = <<EOF
<!DOCTYPE html>
<html>
<head><title>Placeholder Frontend</title></head>
<body>
  <h1>MSAL Demo Frontend Placeholder</h1>
  <p>Domain: ${var.domain_name}</p>
</body>
</html>
EOF
  content_type = "text/html"
}

resource "aws_cloudfront_distribution" "site" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "CloudFront distribution for ${var.domain_name}"
  aliases         = [var.domain_name]
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = "s3-site-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-site-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# Route53 alias A record
resource "aws_route53_record" "alias" {
  zone_id = var.route53_hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

