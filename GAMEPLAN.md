# MSAL demo app

Purpose: Figure out how to do MSAL Auth with multiple backend APIs and a React frontend.

## Architecture Overview

### Backend
FastAPI deployed to Lambda, exposed via CloudFront endpoint.

App Names:
- api1.matthewpick.com
- api2.matthewpick.com
- api3.matthewpick.com

### Frontend
- demo-frontend.matthewpick.com

## Tools
- Terraform (opentofu)
- React
- FastAPI
- AWS (Lambda, API Gateway, S3, CloudFront)
- Azure (App Registration, MSAL)

---

## Implementation Checklist

### Phase 1: AWS Infrastructure Setup (aws/)

Start with AWS since you're most familiar with it. Deploy infrastructure first for all 3 backend APIs and the frontend.

#### 1.1 AWS Terraform Setup
- [x] Create `aws/main.tf` with provider configuration
  - [x] Configure AWS provider (region + required providers) and local backend placeholder
  - [x] Set up backend state storage (local; migrate to remote later)
- [x] Create `aws/variables.tf`
  - [x] Domain names for all 3 APIs
  - [x] Frontend domain name
  - [x] Route53 hosted zone ID
- [x] Create `aws/outputs.tf`
  - [x] CloudFront distribution URLs (placeholders / null for now)
  - [x] Lambda function ARNs (placeholders)
  - [x] S3 bucket name (placeholder)
- [x] Create `aws/.terraform-version` file
  - Version pinned to 1.8.5 (adjust if using opentofu)
  
> Next: Request ACM certs (1.2). Consider installing Terraform locally (brew install terraform) before proceeding.

#### 1.2 SSL Certificates (ACM)
- [x] Request/import SSL certificates in ACM (us-east-1 for CloudFront)
  - [x] Certificate for api1.matthewpick.com
  - [x] Certificate for api2.matthewpick.com
  - [x] Certificate for api3.matthewpick.com
  - [x] Certificate for demo-frontend.matthewpick.com
- [ ] Validate certificates via DNS (Route53)  
  > Terraform has created DNS validation records; after they propagate ACM will mark certificates as ISSUED. Re-run `tofu apply` if initial status remains PENDING for too long.

#### 1.3 Lambda + API Gateway for Backend APIs
Create modules for reusable infrastructure (3 identical deployments):

- [x] Create Lambda function module for API 1
  - [x] Lambda function with Python runtime (stub)
  - [x] Lambda execution role with necessary permissions
  - [x] Environment variables placeholder (APP_DOMAIN)
  - [ ] Add future environment variables (AZURE_CLIENT_ID, AZURE_TENANT_ID, etc.)
  - [x] Archive provider to build stub zip inline
- [x] Create API Gateway (HTTP API) for API 1
  - [x] Configure default route ($default)
  - [x] Integrate with Lambda (AWS_PROXY)
  - [x] Auto-deploy stage
- [x] Create CloudFront distribution for API 1
  - [x] Origin pointing to API Gateway endpoint
  - [x] Custom domain (api1.matthewpick.com)
  - [x] SSL certificate from ACM
  - [x] Caching disabled (TTL 0) ready for auth headers
- [x] Duplicate setup for API 2 (api2.matthewpick.com)
- [x] Duplicate setup for API 3 (api3.matthewpick.com)

#### 1.4 S3 + CloudFront for Frontend
- [x] Create S3 bucket for frontend static files
  - [x] Configure bucket settings (ownership controls, block public access)
  - [x] Block public access (CloudFront OAI used for access)
- [x] Create CloudFront distribution for frontend
  - [x] Origin: S3 bucket
  - [x] Custom domain (demo-frontend.matthewpick.com)
  - [x] SSL certificate from ACM
  - [x] Default root object: index.html
  - [x] Custom error responses (404/403 -> /index.html)
  - [x] Origin Access Identity (OAI)
- [x] Create Route53 record
  - [x] A record (alias) for demo-frontend.matthewpick.com -> CloudFront
  > Placeholder index.html deployed; will be replaced by React build in later phases.

#### 1.5 Deploy AWS Infrastructure
- [x] Run `terraform init` in aws/ directory
- [x] Run `terraform plan` and review
- [x] Run `terraform apply`
- [x] Verify all resources created successfully
  - API stubs respond 200 with JSON message
  - Frontend placeholder index.html served (HTTP 200)
  - Custom domains resolving via CloudFront
- [x] Note outputs (CloudFront URLs, S3 bucket names, etc.)
  - api1 CloudFront: d3negntvroeihe.cloudfront.net
  - api2 CloudFront: djp6q20xs3vwt.cloudfront.net
  - api3 CloudFront: d2cug53w0d6z9j.cloudfront.net
  - frontend CloudFront: draa5yr1wxkrq.cloudfront.net
  - frontend bucket: demo-frontend-matthewpick-com
  > Next: Proceed to Phase 2 - Backend API Development

---

### Phase 2: Backend API Development (backend/)

Build a simple backend first without auth, then add Azure AD authentication later.

#### 2.1 Backend Setup
- [x] Initialize Python project with uv / pip
  - [x] Add FastAPI dependency
  - [x] Add uvicorn dependency
  - [x] Add mangum for AWS Lambda handler
  - [x] Add python-dotenv for environment variables
- [x] Create `backend/main.py` with FastAPI app
  - [x] Create hello world endpoint (no auth yet)
  - [x] Create health check endpoint
  - [x] Add Lambda handler using Mangum
- [x] Add CORS middleware configuration
  - [x] Allow frontend domain
  - [x] Allow localhost for development
- [x] Create `backend/requirements.txt` from dependencies

#### 2.2 Local Testing
- [x] Test backend locally with `uv run start`
- [x] Test endpoints via browser or curl
- [x] Verify CORS headers

---

### Phase 3: Backend Deployment to AWS

#### 3.1 Build and Package
- [x] Create `backend/deploy.sh` script
  - [x] Zip Lambda function code + dependencies using Docker for Lambda-compatible binaries
- [x] Build deployment package

#### 3.2 Deploy to Lambda (All 3 API Instances)
- [x] Deploy API 1 code to Lambda via AWS CLI
  - [x] Upload zip file
  - [x] Set handler to `main.lambda_handler`
  - [x] Test function with test event
- [x] Deploy API 2 code to Lambda (same package)
  - [x] Upload zip file
  - [x] Test function
- [x] Deploy API 3 code to Lambda (same package)
  - [x] Upload zip file
  - [x] Test function

#### 3.3 Verify Backend Endpoints
- [x] Test https://api1.matthewpick.com/health (or hello endpoint)
- [x] Test https://api2.matthewpick.com/health
- [x] Test https://api3.matthewpick.com/health
- [x] All APIs working successfully

---

### Phase 4: Frontend Development (frontend/)

Build a simple React frontend first without MSAL auth, then add authentication later.

#### 4.1 React Setup
- [ ] Initialize React app (Vite recommended)
  - [ ] `npm create vite@latest frontend -- --template react`
- [ ] Create `.env` file for configuration (add to .gitignore!)
  - [ ] VITE_API1_URL=https://api1.matthewpick.com
  - [ ] VITE_API2_URL=https://api2.matthewpick.com
  - [ ] VITE_API3_URL=https://api3.matthewpick.com
- [ ] Create simple UI components
  - [ ] Component for calling API 1
  - [ ] Component for calling API 2
  - [ ] Component for calling API 3
  - [ ] Display response from each API
  - [ ] Basic error handling

#### 4.2 Local Testing
- [ ] Test frontend locally (`npm run dev`)
- [ ] Test calling all 3 APIs
- [ ] Verify CORS is working
- [ ] Check browser console for errors

---

### Phase 5: Frontend Deployment to AWS

#### 5.1 Build and Deploy
- [ ] Create production `.env` with production values
- [ ] Create production build (`npm run build`)
- [ ] Create `frontend/deploy.sh` script
  - [ ] Sync build folder to S3 bucket
  - [ ] Invalidate CloudFront cache
- [ ] Deploy to S3 via AWS CLI
  - [ ] `aws s3 sync dist/ s3://your-bucket-name`
  - [ ] `aws cloudfront create-invalidation --distribution-id XXX --paths "/*"`

#### 5.2 Verify Frontend
- [ ] Access https://demo-frontend.matthewpick.com
- [ ] Test calling all 3 APIs
- [ ] Check browser console for errors
- [ ] Verify CORS is working

---

### Phase 6: Azure AD Setup & Integration (azure/)

Now that AWS infrastructure is working, add Azure AD authentication.

#### 6.1 Azure Terraform Setup
- [ ] Create `azure/main.tf` with provider configuration
  - [ ] Configure azuread provider
  - [ ] Configure azurerm provider (if needed for key vault)
  - [ ] Set up backend state storage (save locally for now)
- [ ] Create `azure/variables.tf` for input variables
  - [ ] Define domain names for 3 APIs
  - [ ] Define frontend domain name
  - [ ] Define tenant ID variable
  - [ ] Define redirect URIs
- [ ] Create `azure/outputs.tf` for exporting important values
  - [ ] Output all 3 API application (client) IDs
  - [ ] Output all 3 API application ID URIs
  - [ ] Output frontend application (client) ID
  - [ ] Output tenant ID
- [ ] Create `azure/terraform.tfvars` (add to .gitignore!)
- [ ] Create `azure/.terraform-version` file

#### 6.2 Azure AD App Registrations - Backend APIs
- [ ] Create app registration for API 1 (api1.matthewpick.com)
  - [ ] Define API permissions (expose an API)
  - [ ] Create custom scope (e.g., "api://api1.matthewpick.com/access_as_user")
  - [ ] Configure authentication settings
  - [ ] Set identifier URI (api://api1.matthewpick.com)
- [ ] Create app registration for API 2 (api2.matthewpick.com)
  - [ ] Define API permissions (expose an API)
  - [ ] Create custom scope (e.g., "api://api2.matthewpick.com/access_as_user")
  - [ ] Configure authentication settings
  - [ ] Set identifier URI (api://api2.matthewpick.com)
- [ ] Create app registration for API 3 (api3.matthewpick.com)
  - [ ] Define API permissions (expose an API)
  - [ ] Create custom scope (e.g., "api://api3.matthewpick.com/access_as_user")
  - [ ] Configure authentication settings
  - [ ] Set identifier URI (api://api3.matthewpick.com)

#### 6.3 Azure AD App Registration - Frontend SPA
- [ ] Create app registration for frontend (demo-frontend.matthewpick.com)
  - [ ] Set platform to "Single-page application"
  - [ ] Configure redirect URIs (https://demo-frontend.matthewpick.com, http://localhost:5173 for dev)
  - [ ] Enable implicit flow (ID tokens) if needed
  - [ ] Add API permissions for all 3 backend APIs
  - [ ] Grant admin consent for API permissions
  - [ ] Configure logout URL

#### 6.4 Deploy Azure Infrastructure
- [ ] Run `terraform init` in azure/ directory
- [ ] Run `terraform plan` and review
- [ ] Run `terraform apply` and save outputs
- [ ] Store outputs in a secure location (for backend/frontend configuration)
- [ ] Document client IDs and tenant ID

---

### Phase 7: Add Authentication to Backend

#### 7.1 Update Backend with Azure AD JWT Validation
- [ ] Add authentication dependencies
  - [ ] Add python-jose[cryptography] for JWT validation
  - [ ] Add msal or azure-identity (optional, for token validation)
- [ ] Create `backend/auth.py` for Azure AD JWT validation
  - [ ] Implement token validation middleware
  - [ ] Validate audience (app ID)
  - [ ] Validate issuer (Azure AD tenant)
  - [ ] Validate signature using Azure AD public keys
  - [ ] Extract user info from token
- [ ] Update `backend/config.py` for environment variables
  - [ ] AZURE_CLIENT_ID (from Azure Terraform outputs)
  - [ ] AZURE_TENANT_ID
  - [ ] API_DOMAIN (e.g., api1.matthewpick.com)
- [ ] Update endpoints to require authentication
  - [ ] Add auth dependency to protected routes
  - [ ] Test with and without valid tokens

#### 7.2 Redeploy Backend APIs with Auth
- [ ] Update Lambda environment variables via AWS Console or Terraform
  - [ ] API 1: Set AZURE_CLIENT_ID for API 1
  - [ ] API 2: Set AZURE_CLIENT_ID for API 2
  - [ ] API 3: Set AZURE_CLIENT_ID for API 3
  - [ ] All 3: Set AZURE_TENANT_ID
- [ ] Rebuild deployment package with new dependencies
- [ ] Deploy updated code to all 3 Lambda functions
- [ ] Test endpoints (should now require auth)

---

### Phase 8: Add MSAL Authentication to Frontend

#### 8.1 Install and Configure MSAL
- [ ] Install MSAL React library
  - [ ] `npm install @azure/msal-react @azure/msal-browser`
- [ ] Update `.env` file with Azure AD configuration
  - [ ] VITE_AZURE_CLIENT_ID (frontend app ID from Terraform outputs)
  - [ ] VITE_AZURE_TENANT_ID
  - [ ] VITE_REDIRECT_URI=https://demo-frontend.matthewpick.com
  - [ ] VITE_API1_SCOPE=api://api1.matthewpick.com/access_as_user
  - [ ] VITE_API2_SCOPE=api://api2.matthewpick.com/access_as_user
  - [ ] VITE_API3_SCOPE=api://api3.matthewpick.com/access_as_user

#### 8.2 Implement MSAL in React
- [ ] Create `frontend/src/authConfig.js`
  - [ ] Configure MSAL instance with client ID, tenant ID, redirect URI
  - [ ] Define scopes for each API
- [ ] Wrap app with `MsalProvider` in `main.jsx` or `App.jsx`
- [ ] Create Login component
  - [ ] Sign-in button
  - [ ] Display user info when authenticated
  - [ ] Sign-out button
- [ ] Update API call components to use MSAL
  - [ ] Implement acquireTokenSilent for API 1 calls
  - [ ] Implement acquireTokenSilent for API 2 calls
  - [ ] Implement acquireTokenSilent for API 3 calls
  - [ ] Handle InteractionRequiredAuthError
  - [ ] Fallback to acquireTokenPopup/Redirect
  - [ ] Add token to Authorization header (Bearer token)

#### 8.3 Local Testing with Auth
- [ ] Update local `.env` for development
  - [ ] Set VITE_REDIRECT_URI=http://localhost:5173
- [ ] Test frontend locally (`npm run dev`)
- [ ] Test login flow
- [ ] Test calling each API with acquired tokens
- [ ] Test logout flow
- [ ] Test token refresh
- [ ] Check for error handling

---

### Phase 9: Production Deployment with Auth

#### 9.1 Redeploy Frontend with MSAL
- [ ] Update production `.env` with Azure AD values
- [ ] Build production bundle (`npm run build`)
- [ ] Deploy to S3
  - [ ] `aws s3 sync dist/ s3://your-bucket-name`
  - [ ] `aws cloudfront create-invalidation --distribution-id XXX --paths "/*"`

#### 9.2 End-to-End Testing
- [ ] Access https://demo-frontend.matthewpick.com
- [ ] Test complete authentication flow
- [ ] Test token acquisition for all 3 APIs
- [ ] Test calling all 3 APIs with auth
- [ ] Test token expiry and refresh
- [ ] Test error scenarios (invalid token, expired token, no token)
- [ ] Test logout flow
- [ ] Test on multiple browsers
- [ ] Verify CORS is working with auth headers

---

### Phase 10: Documentation & Polish

#### 10.1 Documentation
- [ ] Document Azure AD configuration in `azure/README.md`
  - [ ] Required permissions
  - [ ] How to run Terraform
  - [ ] Where to find output values
  - [ ] Azure AD app registration details
- [ ] Document AWS infrastructure in `aws/README.md`
  - [ ] Architecture diagram
  - [ ] How to deploy infrastructure
  - [ ] How to update Lambda functions
  - [ ] CloudFront and S3 setup details
- [ ] Document backend in `backend/README.md`
  - [ ] How to run locally
  - [ ] Environment variables needed
  - [ ] How to build deployment package
  - [ ] How to deploy to Lambda
  - [ ] How JWT validation works
- [ ] Document frontend in `frontend/README.md`
  - [ ] How to run locally
  - [ ] Environment variables needed
  - [ ] How to build and deploy
  - [ ] MSAL configuration details
- [ ] Update main README.md with overall architecture and setup instructions

#### 10.2 Security Review
- [ ] Verify all secrets are in environment variables (not hardcoded)
- [ ] Ensure .gitignore includes sensitive files
  - [ ] `.env` files
  - [ ] `terraform.tfvars`
  - [ ] Deployment packages
- [ ] Review CORS configuration (restrictive for production)
- [ ] Review token validation in backend
- [ ] Review redirect URIs in Azure AD
- [ ] Enable CloudWatch logging for Lambda functions
- [ ] Enable CloudFront logging

#### 10.3 Optional Enhancements
- [ ] Add CI/CD with GitHub Actions
  - [ ] Backend deployment workflow
  - [ ] Frontend deployment workflow
  - [ ] Terraform plan/apply workflow
- [ ] Add monitoring and alerting
- [ ] Add API rate limiting
- [ ] Add comprehensive error handling
- [ ] Add unit and integration tests

---

## Quick Reference

### Phase Order Summary
1. **AWS Infrastructure** - Set up all AWS resources (Lambda, API Gateway, CloudFront, S3, Route53)
2. **Backend Development** - Build FastAPI app (no auth initially)
3. **Backend Deployment** - Deploy to all 3 Lambda functions
4. **Frontend Development** - Build React app (no auth initially)
5. **Frontend Deployment** - Deploy to S3/CloudFront
6. **Azure AD Setup** - Create app registrations via Terraform
7. **Add Backend Auth** - Implement JWT validation in FastAPI
8. **Add Frontend Auth** - Integrate MSAL in React
9. **Production Testing** - Test full auth flow end-to-end
10. **Documentation** - Complete all README files

### Azure Terraform Resources Needed
```hcl
azuread_application (x4 - 3 APIs + 1 frontend)
azuread_application_api_access (frontend to APIs)
azuread_service_principal (x4)
azuread_application_password (optional, for backend)
```

### Key Azure AD Concepts
- **Application (Client) ID**: Unique ID for each app registration
- **Tenant ID**: Your Azure AD tenant ID
- **Scope**: Permission format is `api://{app-id-uri}/scope-name`
- **Audience**: In JWT validation, must match the API's client ID
- **Issuer**: Must match Azure AD tenant issuer URL `https://login.microsoftonline.com/{tenant-id}/v2.0`

### Environment Variables Quick Reference

**Backend (each API instance):**
```bash
AZURE_CLIENT_ID=<api-specific-client-id>
AZURE_TENANT_ID=<your-tenant-id>
API_DOMAIN=<api-specific-domain>
```

**Frontend (Vite):**
```bash
VITE_AZURE_CLIENT_ID=<frontend-client-id>
VITE_AZURE_TENANT_ID=<your-tenant-id>
VITE_REDIRECT_URI=https://demo-frontend.matthewpick.com
VITE_API1_URL=https://api1.matthewpick.com
VITE_API2_URL=https://api2.matthewpick.com
VITE_API3_URL=https://api3.matthewpick.com
VITE_API1_SCOPE=api://api1.matthewpick.com/access_as_user
VITE_API2_SCOPE=api://api2.matthewpick.com/access_as_user
VITE_API3_SCOPE=api://api3.matthewpick.com/access_as_user
```

### Helpful Commands

**Backend:**
```bash
# Local development
uvicorn main:app --reload

# Create deployment package
pip install -r requirements.txt -t package/
cp main.py package/
cd package && zip -r ../lambda-deployment.zip . && cd ..

# Deploy to Lambda
aws lambda update-function-code --function-name api1-function --zip-file fileb://lambda-deployment.zip
```

**Frontend:**
```bash
# Local development
npm run dev

# Production build
npm run build

# Deploy to S3
aws s3 sync dist/ s3://your-frontend-bucket/
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

**Terraform:**
```bash
# AWS
cd aws/
terraform init
terraform plan
terraform apply

# Azure
cd azure/
terraform init
terraform plan
terraform apply
```
