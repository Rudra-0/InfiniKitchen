# InfiniKitchen — System Architecture

> **Version:** 1.0.0 | **Updated:** February 2026

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           CLIENT LAYER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐  │
│  │   Android   │  │     iOS     │  │           Web               │  │
│  │  (Flutter)  │  │  (Flutter)  │  │    (Flutter Wasm)           │  │
│  └──────┬──────┘  └──────┬──────┘  └─────────────┬───────────────┘  │
└─────────┼────────────────┼───────────────────────┼──────────────────┘
          │                │                       │
          └────────────────┼───────────────────────┘
                           │ HTTPS/WSS
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         API GATEWAY (Cloud Run)                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    FastAPI Application                       │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐  │   │
│  │  │   Auth     │  │   Recipe   │  │      Community         │  │   │
│  │  │  Service   │  │   Service  │  │       Service          │  │   │
│  │  └────────────┘  └────────────┘  └────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────┘   │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
          ▼                     ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐
│     REDIS       │  │   POSTGRESQL    │  │       AI LAYER          │
│     Cache       │  │   + pgvector    │  │  ┌─────────────────┐    │
│  ┌───────────┐  │  │  ┌───────────┐  │  │  │   LangChain     │    │
│  │ Recipe    │  │  │  │ Recipes   │  │  │  │   Agent/Router  │    │
│  │ Cache     │  │  │  │ Users     │  │  │  └────┬───────┬────┘    │
│  │ Sessions  │  │  │  │ Ingreds   │  │  │       │       │         │
│  └───────────┘  │  │  │ Community │  │  │       ▼       ▼         │
└─────────────────┘  │  └───────────┘  │  │  ┌─────────┐ ┌────────┐ │
                     └─────────────────┘  │  │ Google  │ │ Gemini │ │
                                          │  │ Search  │ │ 3.0    │ │
                                          │  └─────────┘ └────────┘ │
                                          └─────────────────────────┘
```

---

## Data Flow: Recipe Generation

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  CLIENT  │────▶│   API    │────▶│  REDIS   │────▶│ AI AGENT │◀───▶│ Tools    │
│  Action  │     │ Gateway  │     │  Cache   │     │ (LangChain)│     │ (DB/Web) │
└──────────┘     └──────────┘     └──────────┘     └──────────┘     └──────────┘
     │                │                │                │                │
     │ POST /recipe   │                │                │                │
     │ {ingredients}  │                │                │                │
     │───────────────▶│                │                │                │
     │                │ hash(ingreds)  │                │                │
     │                │───────────────▶│                │                │
     │                │                │                │                │
     │                │◀──── HIT ──────│                │                │
     │                │     (return)   │                │                │
     │                │                │                │                │
     │                │◀─── MISS ──────│                │                │
     │                │                │ Invoke Agent   │                │
     │                │                │───────────────▶│                │
     │                │                │                │ 1. Search DB   │
     │                │                │                │───────────────▶│                
     │                │                │                │ 2. Search Web  │
     │                │                │                │───────────────▶│
     │                │                │                │ (if needed)    │
     │                │                │                │                │
     │                │                │◀── Synthesis ──│                │
     │                │                │                │                │
     │                │◀───────────── Recipe JSON ───────────────────────│
     │◀─── 200 OK ────│                │                │                │
     │  {recipe}      │                │                │                │
```

---

## Database Schema

### Ingredient Table

```sql
CREATE TABLE ingredients (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    canonical_name  VARCHAR(255) NOT NULL,
    category        VARCHAR(100) NOT NULL,
    state           VARCHAR(50) CHECK (state IN ('solid', 'liquid', 'powder', 'gas')),
    flavor_profile  JSONB NOT NULL,
    embedding       vector(768),
    regions         JSONB NOT NULL,
    allergens       TEXT[] DEFAULT '{}',
    substitutes     UUID[] DEFAULT '{}',
    nutrition       JSONB,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ingredient_embedding 
ON ingredients USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

### Ingredient JSON Schema

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "canonical_name": "Onion",
  "category": "vegetable",
  "state": "solid",
  "flavor_profile": {
    "primary": ["pungent", "sulfurous"],
    "cooked": ["sweet", "caramelized"],
    "intensity": 0.7,
    "heat_level": 0.1
  },
  "regions": {
    "US": {
      "local_name": "Yellow Onion",
      "availability": "year-round",
      "typical_size_g": 150
    },
    "IN": {
      "local_name": "Sambar Onion",
      "availability": "year-round", 
      "typical_size_g": 50
    }
  },
  "allergens": [],
  "substitutes": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002"
  ],
  "nutrition": {
    "calories_per_100g": 40,
    "carbs_g": 9.3,
    "protein_g": 1.1,
    "fat_g": 0.1
  }
}
```

### Recipe Table

```sql
CREATE TABLE recipes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_hash VARCHAR(32) UNIQUE NOT NULL,
    name            VARCHAR(255) NOT NULL,
    ingredients     JSONB NOT NULL,
    instructions    JSONB NOT NULL,
    embedding       vector(768),
    origin_region   VARCHAR(5),
    dietary_tags    TEXT[] DEFAULT '{}',
    prep_time_min   INTEGER,
    cook_time_min   INTEGER,
    servings        INTEGER DEFAULT 2,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### User Table

```sql
CREATE TABLE users (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid      VARCHAR(128) UNIQUE NOT NULL,
    display_name      VARCHAR(100),
    region            VARCHAR(5) DEFAULT 'US',
    dietary_profile   JSONB NOT NULL DEFAULT '{}',
    measurement_system VARCHAR(10) DEFAULT 'metric',
    created_at        TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Caching Strategy

### Redis Key Structure

```
recipe:{hash}           → Full recipe JSON (TTL: 30 days)
recipe:{hash}:hits      → Hit counter (no TTL)
user:{id}:session       → Session data (TTL: 24 hours)
user:{id}:recent        → Recent recipes list (TTL: 7 days)
ingredient:search:{q}   → Search results cache (TTL: 1 hour)
```

### Cache Invalidation

| Event | Invalidation |
|-------|--------------|
| Recipe updated | Delete `recipe:{hash}` |
| Ingredient modified | Flush `ingredient:search:*` |
| User profile change | Delete `user:{id}:*` |

---

## API Endpoints

### Recipe Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/recipe/generate` | Generate recipe from ingredients |
| GET | `/api/v1/recipe/{id}` | Get recipe by ID |
| POST | `/api/v1/recipe/{id}/export` | Export to PDF/Notes |

### Ingredient Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/ingredients/search` | Search ingredients |
| GET | `/api/v1/ingredients/{id}` | Get ingredient details |
| GET | `/api/v1/ingredients/{id}/substitutes` | Get substitutes |

### Community Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/feed` | Get personalized feed |
| POST | `/api/v1/recipes/share` | Share recipe |
| POST | `/api/v1/recipes/{id}/remix` | Fork recipe |

---

## Security Architecture

```
┌─────────────────────────────────────────────────┐
│                  SECURITY LAYERS                 │
├─────────────────────────────────────────────────┤
│  1. Firebase Auth (OAuth 2.0 + JWT)             │
│  2. API Rate Limiting (100 req/min)             │
│  3. Input Validation (Pydantic)                 │
│  4. SQL Injection Prevention (SQLAlchemy ORM)   │
│  5. Content Moderation (AI + Manual)            │
│  6. HTTPS/TLS 1.3 Encryption                    │
└─────────────────────────────────────────────────┘
```

---

## Infrastructure

### Cloud Run Configuration

```yaml
service: infinikitchen-api
region: us-central1
cpu: 2
memory: 2Gi
min-instances: 1
max-instances: 100
concurrency: 80
timeout: 300s
```

### Scaling Triggers

| Metric | Threshold | Action |
|--------|-----------|--------|
| CPU | > 70% | Scale up |
| Memory | > 80% | Scale up |
| Request latency | > 2s p95 | Scale up |
| Instances idle | > 5 min | Scale down |
