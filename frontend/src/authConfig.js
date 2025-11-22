/**
 * MSAL Configuration for Azure AD Authentication
 *
 * Since Azure AD doesn't allow requesting scopes from multiple resources in a single token,
 * we acquire tokens on-demand for each API as needed. This is the recommended approach.
 */

import { LogLevel } from '@azure/msal-browser';

// MSAL Configuration
export const msalConfig = {
  auth: {
    clientId: import.meta.env.VITE_AZURE_CLIENT_ID,
    authority: `https://login.microsoftonline.com/${import.meta.env.VITE_AZURE_TENANT_ID}`,
    redirectUri: import.meta.env.VITE_REDIRECT_URI,
    postLogoutRedirectUri: import.meta.env.VITE_REDIRECT_URI,
  },
  cache: {
    cacheLocation: 'sessionStorage', // Use sessionStorage for better security
    storeAuthStateInCookie: false, // Set to true for IE11 or Edge
  },
  system: {
    loggerOptions: {
      loggerCallback: (level, message, containsPii) => {
        if (containsPii) {
          return;
        }
        switch (level) {
          case LogLevel.Error:
            console.error(message);
            return;
          case LogLevel.Info:
            console.info(message);
            return;
          case LogLevel.Verbose:
            console.debug(message);
            return;
          case LogLevel.Warning:
            console.warn(message);
            return;
        }
      },
    },
  },
};

/**
 * Initial login request - just get basic user info
 * We'll request API scopes on-demand when calling each API
 */
export const loginRequest = {
  scopes: ["openid", "profile", "email"],
};

/**
 * Token requests for each API - acquired on-demand
 * MSAL will cache these tokens and reuse them automatically
 */
export const tokenRequests = {
  api1: {
    scopes: [import.meta.env.VITE_API1_SCOPE],
  },
  api2: {
    scopes: [import.meta.env.VITE_API2_SCOPE],
  },
  api3: {
    scopes: [import.meta.env.VITE_API3_SCOPE],
  },
};

/**
 * Helper to get the token request for a specific API
 */
export const getTokenRequestForApi = (apiNumber) => {
  return tokenRequests[`api${apiNumber}`];
};

