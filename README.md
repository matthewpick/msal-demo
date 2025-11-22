# MSAL Demo

## Overview
This project demonstrates authenticating a SPA (Vite + React) with Azure AD using MSAL and securely calling three separate backend APIs (`api1`, `api2`, `api3`). Each API is registered as its own Azure AD Application / resource with its own scope (e.g. `api://api1.matthewpick.com/access_as_user`).

## Why a Single Access Token Cannot Contain Scopes From Multiple Resources in Azure AD
Azure AD (v2 endpoint) issues an access token *per resource (audience)*. The `scope` parameter you send during a token request both:
- Identifies the target resource (via the resource's Application ID URI prefix in each scope value).
- Specifies the delegated permissions (the scope names themselves).

If you include scopes that belong to different resources (e.g. `api://api1.../access_as_user` and `api://api2.../access_as_user`) Azure AD returns `invalid_request` because:
1. Single Audience Principle: An access token has exactly one `aud` (audience). Mixing resources would require multiple audiences, which the JWT structure and validation model do not support.
2. Security Isolation: Prevents a “confused deputy” scenario where a token meant for one API might be replayed to another unintentionally, or an API might over‑trust permissions intended for a different resource.
3. Least Privilege & Consent Boundaries: Consent is tracked per resource. A multi‑resource token would blur consent boundaries and make revocation / audit less precise.
4. Token Validation Simplicity: Each API validates a single audience and set of scopes that it owns. This keeps implementation simple and reduces ambiguity.
5. Performance & Caching Semantics: MSAL and Azure AD can independently cache and refresh tokens with lifetimes tailored per resource. Bundling would complicate renewal flows.

This behavior is by design and confirmed across Microsoft guidance & Q&A discussions (see the referenced Microsoft Q&A thread). To call multiple protected APIs you must obtain (and MSAL will cache) one access token per resource.

### Common Misconception
You *can* request multiple scopes in one token request **only if** they all belong to the *same* resource (share the same Application ID URI prefix). But you *cannot* combine scopes that point to different `api://` application ID URIs.

### Recommended Patterns for Multi‑API Access
1. On‑Demand Token Acquisition (Implemented Here): Acquire a token for each API only when needed. MSAL silently reuses cached tokens until they expire.
2. Aggregator / Gateway API: Create a single “gateway” resource that exposes a composite scope (e.g. `api://gateway.matthewpick.com/all_access`). The gateway then fan‑outs to internal services using its own credentials. Trade‑off: introduces tighter coupling and internal trust boundaries.
3. App Roles + Single Resource: Define broader app roles on one resource and map internal services to those roles. Useful when logical grouping is acceptable.
4. BFF (Backend For Frontend): Frontend gets only an ID token; backend obtains resource tokens server‑side. Reduces token surface in browser.
5. Multi‑Tenant / Dynamic Resource Selection: Use incremental consent (login with basic scopes, then request additional API scope when user first invokes a feature).

### Why Not a “Composite Scope” Across Apps?
Azure AD doesn’t allow defining a scope that inherently spans multiple application registrations. A composite approach requires an intermediary (gateway) app that *owns* the scope and internally dispatches calls. There is no configuration flag to make one scope auto‑authorize multiple distinct audiences.

### Practical Implications in This Repo
- Initial login uses only user info scopes: `openid profile email`.
- Each call helper acquires (or silently fetches) a token for its API using the specific scope provided via environment variables.
- The file `frontend/src/authConfig.js` defines `tokenRequests` per API to keep concerns separated.

## Frontend Authentication Flow
1. User triggers login (`loginPopup` via MSAL) requesting identity scopes.
2. When the user invokes an API action, we call `acquireTokenSilent` (fallback to interactive if needed) with that API’s single scope.
3. Token cached; subsequent calls reuse until expiration; refresh handled by MSAL.

## Potential Future Enhancements
- Implement silent prefetch of tokens for APIs the user is likely to call soon.
- Add an API gateway if cross‑API orchestration logic grows.
- Introduce app roles for finer‑grained authorization inside each API.

## Development Notes
- Never attempt to concatenate multiple `api://...` scopes in one request; let MSAL manage per‑resource tokens.
- If you see `AADSTS28000: Provided value for the input parameter scope is not valid because it contains more than one resource.` it means scopes from different Application ID URIs were combined.

## Troubleshooting
- 400 invalid_request with AADSTS28000: Remove extra resource scopes; request only one resource per token call.
- CORS Issues: Ensure each API returns `Access-Control-Allow-Origin` matching the deployed frontend domain.
- Missing Audience Errors: Confirm the token’s `aud` matches the API’s Application ID URI.

## References
- Microsoft Docs: Azure AD v2 endpoint token & scope model (paraphrased)
- Microsoft Q&A thread discussing multi‑resource scope limitation (paraphrased summary above)

---

