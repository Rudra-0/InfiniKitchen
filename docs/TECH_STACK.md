# InfiniKitchen — Technology Stack

> **Document Version:** 1.0.0  
> **Last Updated:** February 2026  
> **Status:** Approved

---

## Overview

This document defines the authoritative technology stack for InfiniKitchen, a cross-platform generative gastronomy sandbox game. All versions are strictly pinned to ensure reproducibility and compatibility across development, staging, and production environments.

---

## 1. Frontend & Game Engine

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Framework** | Flutter | `3.38.9` | Cross-platform UI toolkit |
| **Language** | Dart | `3.10.8` | Null-safe, AOT compiled |
| **Game Engine** | Flame | `1.18.0` | 2D game engine for Flutter |
| **Rendering** | Impeller | Enabled | Metal (iOS), Vulkan (Android), Skia fallback (Web) |
| **State Management** | Riverpod | `3.0.0` | Compile-safe dependency injection |
| **Networking** | Dio | `5.7.0` | HTTP client with interceptors |

### Rendering Configuration

```yaml
# flutter run configuration
flutter:
  uses-material-design: true
  
  # Impeller enabled by default in Flutter 3.38+
  # Explicit flags for CI/CD:
  # --enable-impeller (iOS/Android)
  # --wasm (Web compilation)
```

### Platform-Specific Requirements

| Platform | Minimum Version | Architecture | Notes |
|----------|-----------------|--------------|-------|
| **Android** | API 35 (Android 15+) | arm64-v8a, x86_64 | 16KB page size ready |
| **iOS** | iOS 19+ | arm64 | Metal 3.2 required |
| **Web** | Modern browsers | Wasm | Chrome 120+, Safari 18+, Firefox 125+ |

---

## 2. Backend Services

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Framework** | FastAPI | `0.124.4` | Async Python web framework |
| **Runtime** | Python | `3.12.9` | LTS Release (Stable) |
| **ASGI Server** | Uvicorn | `0.34.0` | HTTP/2, WebSocket support |
| **Validation** | Pydantic | `2.12.0` | Data validation with TypeAdapter |
| **Task Queue** | Celery | `5.5.0` | Distributed task processing |
| **Message Broker** | Redis | `7.4.2` | Also used for caching |

### API Configuration

```python
# pyproject.toml dependencies
[project]
dependencies = [
    "fastapi==0.124.4",
    "uvicorn[standard]==0.34.0",
    "pydantic==2.12.0",
    "celery==5.5.0",
    "redis==5.2.0",
]
```

---

## 3. AI & Intelligence Layer

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Orchestration** | LangChain | `0.3.0` | Agentic workflow management |
| **Primary LLM** | Gemini 3.0 Flash | Latest | Low-latency generation |
| **Grounding** | Google Search | Vertex AI | Real-time web validation |
| **Embeddings** | Gemini Embeddings | `text-embedding-005` | 768-dimensional vectors |
| **Guardrails** | LangChain Safety | `0.3.0` | Content filtering, allergen detection |
| **Prompt Management** | LangSmith | `0.3.0` | Prompt versioning, A/B testing |

### AI Pipeline Configuration

```python
# LangChain configuration
LANGCHAIN_CONFIG = {
    "model": "gemini-3.0-flash",
    "temperature": 0.7,
    "max_tokens": 2048,
    "timeout_ms": 5000,
    "retry_attempts": 3,
    "safety_settings": {
        "allergen_filter": True,
        "dietary_compliance": True,
    }
}
```

---

## 4. Data Layer

### Primary Database

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Database** | PostgreSQL | `18.1` | Primary data store |
| **Vector Extension** | pgvector | `0.8.0` | Semantic similarity search |
| **Connection Pool** | PgBouncer | `1.23.0` | Connection management |
| **ORM** | SQLAlchemy | `2.0.27` | Async support enabled |
| **Migrations** | Alembic | `1.15.0` | Schema version control |

### Cache Layer

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Cache** | Redis | `7.4.2` | In-memory data store |
| **Client** | redis-py | `5.2.0` | Async Redis client |
| **Strategy** | Hash-based | — | O(1) ingredient lookups |

### Database Configuration

```sql
-- PostgreSQL extensions required
CREATE EXTENSION IF NOT EXISTS pgvector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;  -- Fuzzy text search
CREATE EXTENSION IF NOT EXISTS btree_gin; -- Composite indexing

-- Vector index configuration
CREATE INDEX idx_ingredient_embedding 
ON ingredients 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

---

## 5. DevOps & Infrastructure

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Containerization** | Docker | `29.2.0` | Multi-stage builds |
| **Orchestration** | Docker Compose | `2.32.0` | Local development |
| **Cloud Platform** | Google Cloud Run | Latest | Serverless containers |
| **CI/CD** | GitHub Actions | Latest | Automated pipelines |
| **Monitoring** | OpenTelemetry | `1.30.0` | Distributed tracing |
| **Logging** | Structured JSON | — | Cloud Logging compatible |

### Container Configuration

```dockerfile
# Base images
FROM python:3.14.2-slim AS backend
FROM ghcr.io/cirruslabs/flutter:3.38.9 AS frontend

# Docker Compose version
version: "3.9"
```

---

## 6. Security & Compliance

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Authentication** | Firebase Auth | Latest | OAuth 2.0, Social logins |
| **API Security** | OAuth 2.0 + JWT | RFC 7519 | Token-based auth |
| **Secrets** | Google Secret Manager | Latest | Encrypted at rest |
| **HTTPS** | TLS 1.3 | — | Certificate via Cloud Run |

---

## 7. Development Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **Flutter SDK** | `3.38.9` | Mobile/Web development |
| **Python** | `3.14.2` | Backend development |
| **Docker Desktop** | `4.38.0` | Container management |
| **VS Code** | Latest | Primary IDE |
| **Android Studio** | Ladybug (2025.2) | Android tooling |
| **Xcode** | `17.0` | iOS development |

---

## 8. Version Lock File

```yaml
# .tool-versions (asdf compatible)
flutter 3.38.9
python 3.14.2
postgres 18.1
redis 7.4.2
```

```toml
# Cargo-style lock summary
[metadata]
lock-version = "1.0"
generated-date = "2026-02-04"

[frontend]
flutter = "3.38.9"
dart = "3.10.8"
flame = "1.18.0"

[backend]
python = "3.12.9"
fastapi = "0.124.4"
langchain = "0.3.0"

[database]
postgresql = "18.1"
pgvector = "0.8.0"
redis = "7.4.2"

[devops]
docker = "29.2.0"
```

---

## Compatibility Matrix

| Platform | Flutter | Dart | Min OS | Rendering |
|----------|---------|------|--------|-----------|
| Android | 3.38.9 | 3.10.8 | API 35 | Impeller (Vulkan) |
| iOS | 3.38.9 | 3.10.8 | iOS 19 | Impeller (Metal) |
| Web | 3.38.9 | 3.10.8 | Wasm-ready browsers | CanvasKit/Skia |

---

> **Note:** All version updates must go through the Architecture Review Board (ARB) and require a compatibility assessment before deployment.
