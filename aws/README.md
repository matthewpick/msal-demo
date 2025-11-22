# AWS Infra Repo

Uses Terraform to manage AWS infrastructure.

## SSL Certificates (Step 1.2)
Terraform now provisions individual ACM certificates for each domain:
- api1.matthewpick.com
- api2.matthewpick.com
- api3.matthewpick.com
- demo-frontend.matthewpick.com

They are requested in us-east-1 (required for CloudFront). DNS validation records are created automatically in Route53. After `tofu apply`:
1. Check ACM console for status (should move from PENDING_VALIDATION to ISSUED within a few minutes).
2. If still pending, ensure the hosted zone ID is correct and that no external DNS overrides exist.
3. Once issued, proceed to create CloudFront distributions (Step 1.3 / 1.4).

### Commands
```bash
cd aws
# Initialize providers
tofu init
# Validate configuration
tofu validate
# Show planned changes
tofu plan -var "api1_domain=api1.matthewpick.com" -var "api2_domain=api2.matthewpick.com" -var "api3_domain=api3.matthewpick.com" -var "frontend_domain=demo-frontend.matthewpick.com" -var "route53_hosted_zone_id=ZXXXXXXXXXXXXX"
# Apply (creates certs + DNS records)
tofu apply -var "api1_domain=api1.matthewpick.com" -var "api2_domain=api2.matthewpick.com" -var "api3_domain=api3.matthewpick.com" -var "frontend_domain=demo-frontend.matthewpick.com" -var "route53_hosted_zone_id=ZXXXXXXXXXXXXX"
```

### Outputs
After apply, certificate ARNs will appear in outputs:
- `acm_certificate_arns` (map)
- `acm_certificate_domains` (map)

Use these ARNs when attaching certificates to CloudFront distributions in later steps.
