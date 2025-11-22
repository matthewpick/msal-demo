terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }

  # Local backend for now; migrate to remote later if needed
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "azuread" {
  # Configuration will be provided via environment variables:
  # ARM_TENANT_ID
  # ARM_CLIENT_ID (if using service principal)
  # ARM_CLIENT_SECRET (if using service principal)
  # Or use Azure CLI authentication (az login)
}

# Get current client configuration (tenant ID, etc.)
data "azuread_client_config" "current" {}

# API 1 App Registration
resource "azuread_application" "api1" {
  display_name = "MSAL Demo - API 1"
  identifier_uris = ["api://${var.api1_domain}"]

  sign_in_audience = "AzureADMyOrg"

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access API 1 on behalf of the signed-in user."
      admin_consent_display_name = "Access API 1"
      enabled                    = true
      id                         = uuidv5("url", "api://${var.api1_domain}/access_as_user")
      type                       = "User"
      user_consent_description   = "Allow the application to access API 1 on your behalf."
      user_consent_display_name  = "Access API 1"
      value                      = "access_as_user"
    }
  }

  web {
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }
}

resource "azuread_service_principal" "api1" {
  client_id                    = azuread_application.api1.client_id
  app_role_assignment_required = false
}

# API 2 App Registration
resource "azuread_application" "api2" {
  display_name = "MSAL Demo - API 2"
  identifier_uris = ["api://${var.api2_domain}"]

  sign_in_audience = "AzureADMyOrg"

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access API 2 on behalf of the signed-in user."
      admin_consent_display_name = "Access API 2"
      enabled                    = true
      id                         = uuidv5("url", "api://${var.api2_domain}/access_as_user")
      type                       = "User"
      user_consent_description   = "Allow the application to access API 2 on your behalf."
      user_consent_display_name  = "Access API 2"
      value                      = "access_as_user"
    }
  }

  web {
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }
}

resource "azuread_service_principal" "api2" {
  client_id                    = azuread_application.api2.client_id
  app_role_assignment_required = false
}

# API 3 App Registration
resource "azuread_application" "api3" {
  display_name = "MSAL Demo - API 3"
  identifier_uris = ["api://${var.api3_domain}"]

  sign_in_audience = "AzureADMyOrg"

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access API 3 on behalf of the signed-in user."
      admin_consent_display_name = "Access API 3"
      enabled                    = true
      id                         = uuidv5("url", "api://${var.api3_domain}/access_as_user")
      type                       = "User"
      user_consent_description   = "Allow the application to access API 3 on your behalf."
      user_consent_display_name  = "Access API 3"
      value                      = "access_as_user"
    }
  }

  web {
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }
}

resource "azuread_service_principal" "api3" {
  client_id                    = azuread_application.api3.client_id
  app_role_assignment_required = false
}

# Frontend SPA App Registration
resource "azuread_application" "frontend" {
  display_name     = "MSAL Demo - Frontend SPA"
  sign_in_audience = "AzureADMyOrg"

  single_page_application {
    redirect_uris = [
      "https://${var.frontend_domain}/",
      "http://localhost:5173/"
    ]
  }

  # API permissions to access all three backend APIs
  required_resource_access {
    resource_app_id = azuread_application.api1.client_id

    resource_access {
      id   = uuidv5("url", "api://${var.api1_domain}/access_as_user")
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = azuread_application.api2.client_id

    resource_access {
      id   = uuidv5("url", "api://${var.api2_domain}/access_as_user")
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = azuread_application.api3.client_id

    resource_access {
      id   = uuidv5("url", "api://${var.api3_domain}/access_as_user")
      type = "Scope"
    }
  }

  web {
    logout_url = "https://${var.frontend_domain}"

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "frontend" {
  client_id                    = azuread_application.frontend.client_id
  app_role_assignment_required = false
}

