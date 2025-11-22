output "tenant_id" {
  description = "Azure AD Tenant ID"
  value       = data.azuread_client_config.current.tenant_id
}

output "api1_client_id" {
  description = "Application (client) ID for API 1"
  value       = azuread_application.api1.client_id
}

output "api1_app_id_uri" {
  description = "Application ID URI for API 1"
  value       = "api://${var.api1_domain}"
}

output "api1_scope" {
  description = "OAuth2 scope for API 1"
  value       = "api://${var.api1_domain}/access_as_user"
}

output "api2_client_id" {
  description = "Application (client) ID for API 2"
  value       = azuread_application.api2.client_id
}

output "api2_app_id_uri" {
  description = "Application ID URI for API 2"
  value       = "api://${var.api2_domain}"
}

output "api2_scope" {
  description = "OAuth2 scope for API 2"
  value       = "api://${var.api2_domain}/access_as_user"
}

output "api3_client_id" {
  description = "Application (client) ID for API 3"
  value       = azuread_application.api3.client_id
}

output "api3_app_id_uri" {
  description = "Application ID URI for API 3"
  value       = "api://${var.api3_domain}"
}

output "api3_scope" {
  description = "OAuth2 scope for API 3"
  value       = "api://${var.api3_domain}/access_as_user"
}

output "frontend_client_id" {
  description = "Application (client) ID for Frontend SPA"
  value       = azuread_application.frontend.client_id
}

output "frontend_redirect_uris" {
  description = "Redirect URIs configured for Frontend SPA"
  value       = azuread_application.frontend.single_page_application[0].redirect_uris
}

