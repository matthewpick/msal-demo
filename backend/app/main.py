from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from mangum import Mangum
import os

# Determine allowed origins (frontend domain + localhost dev)
FRONTEND_DOMAIN = os.getenv("FRONTEND_DOMAIN", "demo-frontend.matthewpick.com")
ALLOWED_ORIGINS = [
    f"https://{FRONTEND_DOMAIN}",
    "http://localhost:5173",
]

app = FastAPI(title="MSAL Demo Backend", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"]
    ,
    allow_headers=["*"]
)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/hello")
def hello():
    return {"message": "Hello from FastAPI backend"}

# Lambda handler for API Gateway integration
handler = Mangum(app)

# Dev helper
def run_dev():  # pragma: no cover
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

