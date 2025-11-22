from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from mangum import Mangum

# Handle imports for both local dev and Lambda deployment
try:
    from app.config import config
    from app.auth import init_auth, get_current_user
except ImportError:
    from config import config
    from auth import init_auth, get_current_user

app = FastAPI(title="MSAL Demo Backend", version="0.1.0")

# Initialize authentication if credentials are available
if config.is_auth_enabled():
    init_auth(config.AZURE_CLIENT_ID, config.AZURE_TENANT_ID)
    print(f"✓ Authentication enabled for client: {config.AZURE_CLIENT_ID}")
else:
    print("⚠ Authentication disabled - AZURE_CLIENT_ID or AZURE_TENANT_ID not set")

app.add_middleware(
    CORSMiddleware,
    allow_origins=config.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.get("/health")
def health():
    """Public health check endpoint"""
    return {
        "status": "ok",
        "auth_enabled": config.is_auth_enabled(),
        "api_domain": config.APP_DOMAIN
    }

@app.get("/hello")
def hello(user: dict = Depends(get_current_user)):
    """Protected endpoint - requires valid Azure AD token"""
    return {
        "message": "Hello from FastAPI backend",
        "user": {
            "name": user.get("name"),
            "email": user.get("preferred_username"),
            "oid": user.get("oid"),
        },
        "api_domain": config.APP_DOMAIN
    }

@app.get("/me")
def me(user: dict = Depends(get_current_user)):
    """Get current user information from token"""
    return {
        "user": user,
        "api_domain": config.APP_DOMAIN
    }

# Lambda handler for API Gateway integration
lambda_handler = Mangum(app)

# Dev helper
def run_dev():  # pragma: no cover
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

