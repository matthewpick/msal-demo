/**
 * Custom hook for handling API calls with MSAL authentication
 *
 * This hook acquires tokens on-demand for each API. MSAL automatically caches
 * the tokens and reuses them, so this is efficient even though we request
 * tokens separately for each API.
 */

import { useState } from 'react';
import { useMsal } from '@azure/msal-react';
import { InteractionRequiredAuthError } from '@azure/msal-browser';
import { getTokenRequestForApi } from '../authConfig';

export const useApiCall = () => {
  const { instance, accounts } = useMsal();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  /**
   * Acquire an access token for a specific API.
   * Uses silent token acquisition with fallback to interactive login.
   *
   * @param {number} apiNumber - Which API (1, 2, or 3)
   */
  const acquireTokenForApi = async (apiNumber) => {
    const account = accounts[0];

    if (!account) {
      throw new Error('No active account. Please sign in.');
    }

    const tokenRequest = {
      ...getTokenRequestForApi(apiNumber),
      account: account,
    };

    try {
      // Try to acquire token silently (will use cache if available)
      const response = await instance.acquireTokenSilent(tokenRequest);
      return response.accessToken;
    } catch (error) {
      if (error instanceof InteractionRequiredAuthError) {
        // If silent acquisition fails, fall back to interactive
        try {
          const response = await instance.acquireTokenPopup(tokenRequest);
          return response.accessToken;
        } catch (popupError) {
          console.error('Failed to acquire token via popup:', popupError);
          throw popupError;
        }
      }
      throw error;
    }
  };

  /**
   * Make an authenticated API call
   * @param {string} url - The API endpoint URL
   * @param {number} apiNumber - Which API (1, 2, or 3) to acquire token for
   * @param {object} options - Fetch options (method, headers, body, etc.)
   */
  const callApi = async (url, apiNumber, options = {}) => {
    setLoading(true);
    setError(null);

    try {
      // Acquire token for the specific API
      const token = await acquireTokenForApi(apiNumber);

      // Make API call with token
      const response = await fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }

      const data = await response.json();
      setLoading(false);
      return data;
    } catch (err) {
      setError(err.message);
      setLoading(false);
      throw err;
    }
  };

  return { callApi, loading, error };
};

