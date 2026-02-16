# InfiniKitchen

> **A Generative Gastronomy Sandbox Game**

---

## Overview

InfiniKitchen is a cross-platform game where players mix virtual ingredients using physics-based interactions to discover AI-generated recipes. The unique "Real-World Bridge" transforms digital discoveries into personalized cooking instructions.

## Key Features

- 🎮 **Sandbox Cooking** — Drag-and-drop physics with solids, liquids, and powders
- 🤖 **Smart Chef AI** — Gemini-powered recipe generation
- 🌍 **Regional Logic** — Localized ingredients and substitutions
- 🛡️ **Safety Layers** — Allergen detection and dietary filtering
- 🍳 **Print to Kitchen** — Export recipes to PDF, Apple Notes, or Google Keep
- 👥 **Community Feed** — Share and remix recipes

## Documentation

| Document | Description |
|----------|-------------|
| [TECH_STACK.md](docs/TECH_STACK.md) | Technology versions and dependencies |
| [PROJECT_SCOPE.md](docs/PROJECT_SCOPE.md) | Features and mechanics specification |
| [EXECUTION_PLAN.md](docs/EXECUTION_PLAN.md) | 5-phase development roadmap |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design and database schemas |

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.38.9 + Flame Engine |
| Backend | FastAPI 0.124.4 (Python 3.12.9) |
| AI | LangChain 1.2.7 + Gemini 3.0 Flash |
| Database | PostgreSQL 18.1 + pgvector 0.8.0 |
| Cache | Redis 7.4.2 |
| Platforms | Android 15+, iOS 19+, Web (Wasm) |

## Quick Start

```bash
# Clone repository
git clone https://github.com/your-org/infinikitchen.git
cd infinikitchen

# Start backend services
docker compose up -d

# Run Flutter app
cd app
flutter run
```

## Project Structure

```
infinikitchen/
├── app/                    # Flutter application
│   ├── lib/
│   │   ├── game/          # Flame engine game logic
│   │   ├── features/      # Feature modules
│   │   └── core/          # Shared utilities
│   └── pubspec.yaml
├── backend/                # FastAPI backend
│   ├── app/
│   │   ├── api/           # API routes
│   │   ├── services/      # Business logic
│   │   └── models/        # Pydantic models
│   └── pyproject.toml
├── docs/                   # Documentation
└── docker-compose.yml
```

## License

Proprietary — All Rights Reserved

---

*Built with ❤️ and AI*
