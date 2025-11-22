"""
Configuration management for the backend API

Loads configuration from environment variables with sensible defaults.
"""

import os
from typing import Optional


class Config:
    """Application configuration"""

    # Azure AD Configuration
    AZURE_CLIENT_ID: str = os.getenv("AZURE_CLIENT_ID", "")
    AZURE_TENANT_ID: str = os.getenv("AZURE_TENANT_ID", "")

    # Application Configuration
    APP_DOMAIN: str = os.getenv("APP_DOMAIN", "")
    FRONTEND_DOMAIN: str = os.getenv("FRONTEND_DOMAIN", "demo-frontend.matthewpick.com")

    # CORS Configuration
    ALLOWED_ORIGINS: list[str] = [
        f"https://{FRONTEND_DOMAIN}",
        "http://localhost:5173",
    ]

    @classmethod
    def validate(cls) -> bool:
        """Validate that required configuration is present"""
        if not cls.AZURE_CLIENT_ID:
            print("WARNING: AZURE_CLIENT_ID not set - authentication will not work")
            return False
        if not cls.AZURE_TENANT_ID:
            print("WARNING: AZURE_TENANT_ID not set - authentication will not work")
            return False
        return True

    @classmethod
    def is_auth_enabled(cls) -> bool:
        """Check if authentication is enabled"""
        return bool(cls.AZURE_CLIENT_ID and cls.AZURE_TENANT_ID)


config = Config()

