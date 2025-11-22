import { useState } from 'react'
import { useIsAuthenticated, useMsal } from '@azure/msal-react'
import { loginRequest } from './authConfig'
import { useApiCall } from './hooks/useApiCall'
import './App.css'

function App() {
  const isAuthenticated = useIsAuthenticated();
  const { instance, accounts } = useMsal();
  const { callApi } = useApiCall();

  const [api1Response, setApi1Response] = useState(null)
  const [api2Response, setApi2Response] = useState(null)
  const [api3Response, setApi3Response] = useState(null)
  const [api1Error, setApi1Error] = useState(null)
  const [api2Error, setApi2Error] = useState(null)
  const [api3Error, setApi3Error] = useState(null)
  const [loading, setLoading] = useState({ api1: false, api2: false, api3: false })

  const handleLogin = async () => {
    try {
      await instance.loginPopup(loginRequest);
    } catch (error) {
      console.error('Login failed:', error);
    }
  };

  const handleLogout = () => {
    instance.logoutPopup();
  };

  const callAPI = async (apiNumber) => {
    const apiUrls = {
      1: import.meta.env.VITE_API1_URL,
      2: import.meta.env.VITE_API2_URL,
      3: import.meta.env.VITE_API3_URL
    }

    const setResponse = {
      1: setApi1Response,
      2: setApi2Response,
      3: setApi3Response
    }

    const setError = {
      1: setApi1Error,
      2: setApi2Error,
      3: setApi3Error
    }

    const apiKey = `api${apiNumber}`
    setLoading(prev => ({ ...prev, [apiKey]: true }))
    setError[apiNumber](null)
    setResponse[apiNumber](null)

    try {
      // Pass apiNumber so the hook knows which API scope to request
      const data = await callApi(`${apiUrls[apiNumber]}/hello`, apiNumber)
      setResponse[apiNumber](data)
    } catch (err) {
      setError[apiNumber](err.message)
    } finally {
      setLoading(prev => ({ ...prev, [apiKey]: false }))
    }
  }

  const ApiCard = ({ apiNumber, response, error, isLoading }) => (
    <div className="api-card">
      <h2>API {apiNumber}</h2>
      <p className="api-url">{import.meta.env[`VITE_API${apiNumber}_URL`]}</p>
      <button
        onClick={() => callAPI(apiNumber)}
        disabled={isLoading || !isAuthenticated}
        className="call-button"
      >
        {isLoading ? 'Loading...' : `Call API ${apiNumber}`}
      </button>
      {!isAuthenticated && (
        <p className="auth-warning">⚠️ Please sign in to call APIs</p>
      )}
      {response && (
        <div className="response success">
          <strong>Response:</strong>
          <pre>{JSON.stringify(response, null, 2)}</pre>
        </div>
      )}
      {error && (
        <div className="response error">
          <strong>Error:</strong>
          <p>{error}</p>
        </div>
      )}
    </div>
  )

  return (
    <div className="app">
      <div className="header">
        <h1>MSAL Multi-API Demo</h1>
        <p className="subtitle">Azure AD Authentication with Multiple Backend APIs</p>

        <div className="auth-section">
          {!isAuthenticated ? (
            <div className="auth-info">
              <p>Sign in to call protected APIs</p>
              <button onClick={handleLogin} className="auth-button">
                Sign In
              </button>
            </div>
          ) : (
            <div className="auth-info">
              <p className="user-info">
                👤 Signed in as: <strong>{accounts[0]?.username}</strong>
              </p>
              <button onClick={handleLogout} className="auth-button logout">
                Sign Out
              </button>
            </div>
          )}
        </div>
      </div>

      <div className="api-container">
        <ApiCard
          apiNumber={1}
          response={api1Response}
          error={api1Error}
          isLoading={loading.api1}
        />
        <ApiCard
          apiNumber={2}
          response={api2Response}
          error={api2Error}
          isLoading={loading.api2}
        />
        <ApiCard
          apiNumber={3}
          response={api3Response}
          error={api3Error}
          isLoading={loading.api3}
        />
      </div>

      {isAuthenticated && (
        <div className="token-info">
          <p>✅ Tokens acquired on-demand per API (MSAL caches and reuses them automatically)</p>
        </div>
      )}
    </div>
  )
}

export default App
