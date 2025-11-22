#!/bin/bash

# Deploy script for frontend React app to S3 + CloudFront
# This script builds the production bundle and deploys it to AWS

set -e

echo "Starting frontend deployment..."

# Configuration
S3_BUCKET="demo-frontend-matthewpick-com"
CLOUDFRONT_DISTRIBUTION_ID="E2F6UA1ZXUZ81O"
REGION="us-east-1"

# Build production bundle
echo "Building production bundle..."
npm run build

# Check if build was successful
if [ ! -d "dist" ]; then
    echo "❌ Error: dist/ directory not found. Build may have failed."
    exit 1
fi

# Sync to S3
echo "Syncing files to S3 bucket: $S3_BUCKET..."
aws s3 sync dist/ s3://$S3_BUCKET/ \
    --region $REGION \
    --delete \
    --cache-control "public, max-age=31536000, immutable" \
    --exclude "index.html"

# Upload index.html with no-cache to ensure updates are reflected immediately
echo "Uploading index.html with no-cache..."
aws s3 cp dist/index.html s3://$S3_BUCKET/index.html \
    --region $REGION \
    --cache-control "public, max-age=0, must-revalidate" \
    --content-type "text/html"

# Create CloudFront invalidation
echo "Creating CloudFront invalidation..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)

echo "✓ Deployment complete!"
echo ""
echo "Invalidation ID: $INVALIDATION_ID"
echo "Frontend URL: https://demo-frontend.matthewpick.com"
echo ""
echo "Note: CloudFront invalidation may take a few minutes to complete."
echo "Check status: aws cloudfront get-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --id $INVALIDATION_ID"

