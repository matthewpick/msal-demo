"""
Azure AD JWT Token Validation for FastAPI

This module provides middleware and dependencies for validating Azure AD JWT tokens
in FastAPI applications. It validates the token signature, audience, issuer, and
expiration.
"""

import os
import jwt
import requests
from typing import Optional
from fastapi import HTTPException, Security
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from functools import lru_cache

# Security scheme for extracting Bearer tokens from Authorization header
security = HTTPBearer()


class AzureADAuth:
    """Azure AD JWT token validator"""

    def __init__(self, client_id: str, tenant_id: str):
        self.client_id = client_id
        self.tenant_id = tenant_id
        self.issuer = f"https://login.microsoftonline.com/{tenant_id}/v2.0"
        self.jwks_uri = f"https://login.microsoftonline.com/{tenant_id}/discovery/v2.0/keys"
        self._signing_keys = None

    @property
    def signing_keys(self):
        """Fetch and cache Azure AD signing keys"""
        if self._signing_keys is None:
            response = requests.get(self.jwks_uri)
            response.raise_for_status()
            jwks = response.json()
            self._signing_keys = {key['kid']: key for key in jwks['keys']}
        return self._signing_keys

    def get_signing_key(self, kid: str):
        """Get signing key by key ID"""
        signing_key = self.signing_keys.get(kid)
        if not signing_key:
            # Refresh keys and try again
            self._signing_keys = None
            signing_key = self.signing_keys.get(kid)

        if not signing_key:
            raise HTTPException(
                status_code=401,
                detail="Unable to find signing key"
            )

        return jwt.algorithms.RSAAlgorithm.from_jwk(signing_key)

    def validate_token(self, token: str) -> dict:
        """
        Validate Azure AD JWT token

        Args:
            token: JWT token string

        Returns:
            Decoded token payload

        Raises:
            HTTPException: If token is invalid
        """
        try:
            # Decode header to get key ID
            unverified_header = jwt.get_unverified_header(token)
            kid = unverified_header.get('kid')

            if not kid:
                raise HTTPException(
                    status_code=401,
                    detail="Token missing key ID"
                )

            # Get signing key
            signing_key = self.get_signing_key(kid)

            # Decode and validate token
            payload = jwt.decode(
                token,
                signing_key,
                algorithms=["RS256"],
                audience=self.client_id,
                issuer=self.issuer,
                options={
                    "verify_signature": True,
                    "verify_exp": True,
                    "verify_aud": True,
                    "verify_iss": True,
                }
            )

            return payload

        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=401,
                detail="Token has expired"
            )
        except jwt.InvalidAudienceError:
            raise HTTPException(
                status_code=401,
                detail="Invalid token audience"
            )
        except jwt.InvalidIssuerError:
            raise HTTPException(
                status_code=401,
                detail="Invalid token issuer"
            )
        except jwt.InvalidTokenError as e:
            raise HTTPException(
                status_code=401,
                detail=f"Invalid token: {str(e)}"
            )
        except Exception as e:
            raise HTTPException(
                status_code=401,
                detail=f"Token validation failed: {str(e)}"
            )


# Global auth instance (initialized in main.py)
_auth_instance: Optional[AzureADAuth] = None


def init_auth(client_id: str, tenant_id: str):
    """Initialize the global auth instance"""
    global _auth_instance
    _auth_instance = AzureADAuth(client_id, tenant_id)


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> dict:
    """
    FastAPI dependency to get and validate current user from JWT token

    Usage:
        @app.get("/protected")
        def protected_route(user: dict = Depends(get_current_user)):
            return {"user": user}
    """
    if _auth_instance is None:
        raise HTTPException(
            status_code=500,
            detail="Auth not initialized"
        )

    token = credentials.credentials
    return _auth_instance.validate_token(token)

