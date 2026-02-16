# InfiniKitchen — Security Architecture

> **Version:** 1.0.0 | **Updated:** February 2026 | **Status:** Draft

---

## 1. Security Overview

InfiniKitchen implements a **Defense-in-Depth** strategy, securing data and interactions at multiple layers: Client, API, Data, AI, and Infrastructure. The architecture prioritizes user privacy, content safety (AI generation), and platform integrity.

```mermaid
graph TD
    User[User Device] -->|HTTPS/TLS 1.3| CloudArmor[Cloud Armor / Load Balancer]
    CloudArmor -->|WAF Rules| Gateway[API Gateway (Cloud Run)]
    
    subgraph "Authentication Layer"
        Gateway -->|Verify Token| FirebaseAuth[Firebase Auth]
    end
    
    subgraph "Application Layer"
        Gateway -->|Sanitized Request| AppLogic[FastAPI Backend]
        AppLogic -->|RBAC Check| Services[Business Services]
    end
    
    subgraph "Data Layer"
        Services -->|Encrypted Connection| DB[(PostgreSQL)]
        Services -->|Encrypted Connection| Cache[(Redis)]
    end
    
    subgraph "AI Safety Layer"
        Services -->|Content Filtered| AI[Gemini API]
    end
```

---

## 2. Authentication & Authorization

### 2.1 Identity Management
-   **Provider**: Firebase Authentication (Google Identity Platform).
-   **Methods**: OAuth 2.0 (Google, Apple), Email/Password.
-   **Session Management**:
    -   Stateless authentication via **JWT (JSON Web Tokens)**.
    -   Access Tokens expire in 1 hour; Refresh Tokens managed by Firebase SDK.
    -   Custom User Claims used for role propagation (e.g., `role: 'admin'`, `beta_tester: true`).

### 2.2 Access Control (RBAC)
-   **Role-Based Access Control** implemented at the API Endpoint layer.
-   **Scopes**:
    -   `user:read`, `user:write`: Self-managed profile access.
    -   `recipe:generate`: Rate-limited AI generation.
    -   `community:post`: Posting to public feed.
    -   `admin:*`: System management (moderation, configuration).

---

## 3. Application Security

### 3.1 Input Validation & Sanitization
-   **Strict Schema Validation**: All incoming requests are validated against **Pydantic** models. Requests with extraneous fields or incorrect types are rejected (HTTP 422).
-   **Content Sanitization**:
    -   User-generated text (recipe names, notes) is sanitized to prevent XSS (Cross-Site Scripting) during rendering, especially for the Web (Wasm) target.
    -   SQL Injection prevention via **SQLAlchemy ORM** (parameterized queries by default).

### 3.2 Rate Limiting (DoS Protection)
-   Implemented via **Redis** + **FastAPI Middleware**.
-   **Limits**:
    -   Global API: 100 requests/minute per IP.
    -   AI Generation (`/recipe/generate`): 10 requests/day (Free), 100/day (Premium).
    -   Auth Endpoints: Strict exponential backoff to prevent brute-force attacks.

### 3.3 CSRF & CORS
-   **CORS (Cross-Origin Resource Sharing)**: Strictly allowed only for whitelisted domains (e.g., `app.infinikitchen.com`, `localhost` for dev).
-   **CSRF (Cross-Site Request Forgery)**: Double-submit cookie pattern or similar protection for any cookie-based sessions (though primarily Bearer token based).

---

## 4. Data Security

### 4.1 Encryption
-   **At Rest**:
    -   Database (PostgreSQL) volumes encrypted via Google Cloud managed keys.
    -   Redis persistence encrypted.
    -   Backups encrypted.
-   **In Transit**:
    -   All communications enforced over **TLS 1.3** (HTTPS/WSS).
    -   Internal traffic (Service-to-Database) encrypted using SSL connections.

### 4.2 Sensitive Data Handling
-   **PII (Personally Identifiable Information)**:
    -   User IDs are opaque UUIDs/Firebase UIDs.
    -   Email addresses stored only in Firebase Auth; API backend references Users by UID.
    -   Dietary profiles considered sensitive; strict access controls applied.
-   **Secrets Management**:
    -   API Keys (Gemini, Database Config) stored in **Google Secret Manager**.
    -   Injected as environment variables at runtime; never committed to version control.

---

## 5. AI Safety & Content Security

### 5.1 Prompt Injection Protection
-   **System Instructions**: Robust system prompts ("You are a chef...") with specific instructions to ignore contradictory user commands.
-   **Input Analysis**: Pre-processing user ingredients list to detect non-food items or malicious instructions before sending to LLM.

### 5.2 Search Grounding Safety
-   **Source Filtering**: Restrict Google Search Grounding to trusted domains (e.g., major food sites, verified encyclopedias) to avoid scraping SEO spam or malicious content.
-   **Hallucination Check**: Comparing the "Grounding Source" against the generated output to ensure the AI isn't inventing dangerous chemical reactions.

### 5.3 Content Moderation (Safety Layers)
-   **Input Filtering**:
    -   **Cloud Vision API** (future) for checking uploaded image safety.
    -   Keyword blocklists for prohibited substances/ingredients.
-   **Output Guardrails**:
    -   **Gemini Safety Settings**: Configured to block HATE_SPEECH, DANGEROUS_CONTENT, HARASSMENT, SEXUALLY_EXPLICIT.
    -   **Structured Output**: Enforcing JSON schema response to prevent "jailbreak" free-text responses.
-   **Allergen Safety**:
    -   Deterministic code layer checks generated recipe against User's allergen profile *after* AI generation as a fail-safe.

---

## 6. Infrastructure Security

### 6.1 Container Security
-   **Minimal Base Images**: Using `python:slim` to reduce attack surface.
-   **Non-Root Execution**: Application runs as a non-root user within the container.
-   **Vulnerability Scanning**: CI/CD pipeline includes container scanning (e.g., Trivy) before deployment to Cloud Run.

### 6.2 Network Security
-   **Service Isolation**: Cloud Run services are deployed with internal ingress settings where public access is not required.
-   **DDoS Protection**: Google Cloud Armor protecting the external load balancer.

---

## 7. Compliance & Auditing

### 7.1 Logging & Monitoring
-   **Audit Logs**: Critical actions (Login, Recipe Gen, Admin actions) logged to structured logs (JSON).
-   **Alerting**: Security anomalies (e.g., spike in 401/403 errors, rate limit breaches) trigger alerts via OpenTelemetry/Cloud Monitoring.

### 7.2 Privacy (GDPR/CCPA)
-   **Right to Erasure**: Endpoint `/api/v1/user/delete` cascades deletion to Firebase, Postgres, and Vector Store.
-   **Data Export**: Users can export their recipe history and profile data.

---

## 8. Incident Response

| Incident Level | Response Time | Contacts |
|----------------|---------------|----------|
| **P0 (Critical)** | < 1 Hour | CTO, Lead DevOps, Security Officer |
| **P1 (High)** | < 4 Hours | Lead Dev |
| **P2 (Medium)** | < 24 Hours | Dev Team |

**Breach Protocol**:
1.  Isolate affected systems (Scale down/revoke keys).
2.  Analyze logs to determine scope.
3.  Patch vulnerability.
4.  Notify affected users (if data leaked) within 72 hours.
