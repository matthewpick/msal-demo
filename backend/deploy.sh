#!/bin/bash

# Deploy script for Lambda function packaging
# This script creates a deployment package with dependencies and app code
# Uses Docker to ensure Lambda-compatible binaries (x86_64 Linux)

set -e

echo "Starting Lambda deployment package build..."

# Clean up old build artifacts
rm -rf build
rm -f lambda-package.zip

# Create build directory
mkdir -p build

# Export dependencies to requirements file
echo "Exporting dependencies..."
uv export --no-hashes --frozen > requirements-export.txt

# Install dependencies using Docker with Lambda Python runtime
echo "Installing dependencies using Docker (Lambda-compatible)..."
docker run --rm \
  --platform linux/amd64 \
  -v "$PWD":/var/task \
  -w /var/task \
  --entrypoint /bin/bash \
  public.ecr.aws/lambda/python:3.11 \
  -c "pip install -r requirements-export.txt -t build/ --no-cache-dir"

# Copy application code
echo "Copying application code..."
cp -R app/* build/

# Create deployment package
echo "Creating deployment package..."
cd build
zip -r ../lambda-package.zip . -q
cd ..

# Clean up temporary files
rm requirements-export.txt

# Get package size
SIZE=$(du -h lambda-package.zip | cut -f1)
echo "✓ Deployment package created: lambda-package.zip ($SIZE)"
echo ""
echo "Deploy to Lambda functions with:"
echo "  aws lambda update-function-code --function-name msal-demo-api1-function --zip-file fileb://lambda-package.zip"
echo "  aws lambda update-function-code --function-name msal-demo-api2-function --zip-file fileb://lambda-package.zip"
echo "  aws lambda update-function-code --function-name msal-demo-api3-function --zip-file fileb://lambda-package.zip"

