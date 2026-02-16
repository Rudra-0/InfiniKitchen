# InfiniKitchen — Development Guide

> **Status:** Draft | **Updated:** February 2026

This document outlines the development environment requirements and setup instructions for the InfiniKitchen project.

---

## 1. System Requirements

Ensure your development machine meets the following criteria:

-   **Operating System**: macOS 15+ (Sequoia) or Linux (Ubuntu 24.04 LTS). *Windows support is experimental.*
-   **RAM**: Minimum 16GB (32GB recommended for running Android Emulator + Docker + LLM stack).
-   **Disk Space**: At least 50GB free (for Docker images and SDKs).
-   **Architecture**: Apple Silicon (M-series) or x86_64.

---

## 2. Tools & Dependencies

Strict version pinning is enforced. Use the versions listed below to avoid compatibility issues.

### Core SDKs

| Tool | Version | Purpose | Check Command |
|------|---------|---------|---------------|
| **Flutter SDK** | `3.38.9` | Frontend & Game Logic | `flutter --version` |
| **Dart SDK** | `3.10.8` | Bundled with Flutter | `dart --version` |
| **Python** | `3.12.9` | Backend Services | `python3 --version` |
| **Node.js** | `22.0.0` | Firebase Tools support | `node -v` |

### Infrastructure

| Tool | Version | Purpose | Check Command |
|------|---------|---------|---------------|
| **Docker Engine** | `29.2.0` | Container runtime | `docker version` |
| **Docker Compose**| `2.32.0` | Local orchestration | `docker compose version` |
| **PostgreSQL** | `18.1 client` | Database CLI | `psql --version` |

### IDEs & Editors

-   **VS Code** (Latest) - Recommended for Backend/Python.
    -   Extensions: *Python, Pylance, Docker, Flutter, HashiCorp Terraform*.
-   **Android Studio** (Ladybug 2025.2) - Required for Android emulators.
-   **Xcode** (17.0+) - Required for iOS simulation (macOS only).

---

## 3. Environment Setup

### 3.1 Clone & Initialize

```bash
git clone https://github.com/your-org/infinikitchen.git
cd infinikitchen
```

### 3.2 Backend Setup

1.  **Install Python Dependencies** (using `uv` or `pip`):
    ```bash
    cd backend
    pip install -r requirements.txt
    ```
2.  **Environment Variables**: Create `.env` in `backend/`:
    ```ini
    # Database
    POSTGRES_USER=infinikitchen
    POSTGRES_PASSWORD=dev_password
    POSTGRES_DB=kitchen_db
    
    # AI Services
    GOOGLE_API_KEY=AIzaSy...
    LANGCHAIN_API_KEY=lsv2_...
    
    # Firebase
    FIREBASE_CREDENTIALS=configs/firebase-service-account.json
    ```

### 3.3 Frontend Setup

1.  **Install Flutter Dependencies**:
    ```bash
    cd app
    flutter pub get
    ```
2.  **Game Asset Generation**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

### 3.4 Infrastructure Start

Start the local database (Postgres + pgvector) and Redis cache:

```bash
docker compose up -d db redis
```

---

## 4. Verification

Run the following sanity checks to ensure your environment is ready:

1.  **Flutter Doctor**:
    ```bash
    flutter doctor -v
    ```
    *Ensure no issues are reported for Android Studio or Xcode.*

2.  **Backend Health**:
    ```bash
    curl http://localhost:8000/health
    # Expected: {"status": "ok", "db": "connected", "redis": "connected"}
    ```

---

## 5. Troubleshooting

-   **Create-Flutter Project**: If `app/` folder is missing, run:
    ```bash
    flutter create --org com.infinikitchen --platforms android,ios,web app
    ```
-   **Docker Connectivity**: If containers cannot talk to each other, ensure they are on the `infinikitchen_net` bridge network.

---
