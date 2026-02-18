# OpenCraft Deployment Guide

This document describes the two deployment modes for OpenCraft: API Mode and Local Model Mode.

## Table of Contents

- [Quick Start (API Mode)](#quick-start-api-mode)
- [Local Model Deployment](#local-model-deployment)
- [GPU Acceleration Configuration](#gpu-acceleration-configuration)
- [Persistence Description](#persistence-description)
- [Environment Variable Description](#environment-variable-description)

---

## Quick Start (API Mode)

API Mode uses an external AI API (such as SiliconFlow), which does not require downloading large model files and has fast response times.

### 1. Configure Environment Variables

```bash
# Copy environment variable example file
cp env.example .env

# Edit .env file and set the following required parameters
# SILICONFLOW_API_KEY=your_api_key_here  # Get from https://cloud.siliconflow.cn/
# AI_MODE=api
# DOCKERFILE=Dockerfile
```

### 2. Start Service

```bash
docker-compose up -d
```

### 3. Access Application

- Frontend: http://localhost:5173
- Backend: http://localhost:3000

---

## Local Model Deployment

Local Model Mode runs completely offline without needing an external API and supports GPU acceleration.

### 1. Prepare Model File

```bash
# Create model directory
mkdir -p server/models

# Download model file (HuggingFace mirror recommended)
# Option 1: Using git-lfs (requires git-lfs to be installed first)
cd server/models
git lfs install
git clone https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF
mv Mistral-7B-Instruct-v0.1-GGUF/mistral-7b-instruct-v0.1.Q8_0.gguf ./model.gguf

# Option 2: Manual download
# Visit https://hf-mirror.com/TheBloke/Mistral-7B-Instruct-v0.1-GGUF
# Download mistral-7b-instruct-v0.1.Q8_0.gguf, rename to model.gguf
# Place in server/models/ directory
```

### 2. Configure Environment Variables

```bash
# Edit .env file
AI_MODE=local
DOCKERFILE=Dockerfile.local
LOCAL_MODEL_DIR=./server/models
LOCAL_MODEL_PATH=/app/models/model.gguf
HF_ENDPOINT=https://hf-mirror.com
```

### 3. Start Service (CPU Mode)

```bash
docker-compose up -d
```

---

## GPU Acceleration Configuration

When using local models, enabling GPU acceleration can significantly improve inference speed.

### Prerequisites

1. Install NVIDIA Docker Runtime

```bash
# Ubuntu/Debian
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

2. Verify GPU Availability

```bash
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

### Enable GPU Support

1. Configure Environment Variables

```bash
# Edit .env file
AI_MODE=local
DOCKERFILE=Dockerfile.local
LOCAL_MODEL_DIR=./server/models
LOCAL_MODEL_PATH=/app/models/model.gguf
```

2. Start using GPU configuration

```bash
docker-compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
```

---

## Persistence Description

OpenCraft achieves data persistence through Docker volumes, ensuring data is not lost when containers restart.

### Backend Persistence

1. **Database Persistence**
   - Host directory: `./server/data/`
   - Path in container: `/app/data/`
   - Stored contents: User data, element data, synthesis records, discovery records.

2. **Model File Persistence** (Local Model Mode only)
   - Host directory: `./server/models/` (can be configured via `LOCAL_MODEL_DIR`)
   - Path in container: `/app/models/`
   - Stored contents: AI model files (.gguf format).

### Frontend Persistence

1. **Browser LocalStorage**
   - User token (auto-login).
   - Discovered element list.
   - Synthesis workspace content.

### Data Backup

```bash
# Back up database
cp server/data/cache.db server/data/cache.db.backup

# Back up model files (if using local models)
tar -czf models-backup.tar.gz server/models/
```

---

## Environment Variable Description

### Docker Configuration

| Variable Name | Description | Default Value |
|--------|------|--------|
| `DOCKERFILE` | Dockerfile selection | `Dockerfile` |
| `LOCAL_MODEL_DIR` | Local model directory (host) | `./server/models` |

### AI Mode Configuration

| Variable Name | Description | Optional Values | Default Value |
|--------|------|--------|--------|
| `AI_MODE` | AI running mode | `api` / `local` | `api` |

### API Mode Configuration

| Variable Name | Description | Default Value |
|--------|------|--------|
| `SILICONFLOW_API_KEY` | SiliconFlow API Key | - |
| `SILICONFLOW_API_URL` | API URL | `https://api.siliconflow.cn/v1/chat/completions` |
| `AI_MODEL` | Model name | `deepseek-ai/DeepSeek-V3.2-Exp` |

### Local Model Configuration

| Variable Name | Description | Default Value |
|--------|------|--------|
| `LOCAL_MODEL_PATH` | Model file path (container) | `/app/models/model.gguf` |
| `HF_ENDPOINT` | HuggingFace Mirror | `https://hf-mirror.com` |

### Universal AI Configuration

| Variable Name | Description | Default Value |
|--------|------|--------|
| `AI_TEMPERATURE` | AI Temperature (0.0-2.0) | `0.7` |
| `AI_MAX_TOKENS` | Maximum Token Count | `200` |

### Frontend Configuration

| Variable Name | Description | Default Value |
|--------|------|--------|
| `VITE_API_BASE_URL` | Backend API address | `http://backend:3000` |
| `VITE_APP_TITLE` | Application title | `OpenCraft` |

---

## FAQ

### Q1: How to switch between API Mode and Local Model Mode?

Modify `AI_MODE` and `DOCKERFILE` in the `.env` file:

**Switch to API Mode:**
```bash
AI_MODE=api
DOCKERFILE=Dockerfile
```

**Switch to Local Model Mode:**
```bash
AI_MODE=local
DOCKERFILE=Dockerfile.local
```

After modification, rebuild and start:
```bash
docker-compose down
docker-compose up -d --build
```

### Q2: Local model inference is very slow?

1. Use GPU acceleration (see [GPU Acceleration Configuration](#gpu-acceleration-configuration)).
2. Choose smaller quantization models (e.g., Q4_0 instead of Q8_0).
3. Increase server memory and CPU resources.

### Q3: Out of memory in GPU mode?

1. Choose smaller model files.
2. Reduce `AI_MAX_TOKENS` value.
3. Limit GPU usage (modify the `count` parameter in `docker-compose.gpu.yml`).

### Q4: How to view logs?

```bash
# View all logs
docker-compose logs -f

# View backend logs
docker-compose logs -f backend

# View frontend logs
docker-compose logs -f frontend
```

### Q5: How to update model files?

Replace model files in `server/models/` and restart the container:

```bash
# Stop service
docker-compose down

# Replace model file
cp /path/to/new-model.gguf server/models/model.gguf

# Start service
docker-compose up -d
```

---

## Production Deployment Suggestions

1. **Use Reverse Proxy** (e.g., Nginx, Traefik).
2. **Enable HTTPS**.
3. **Configure Firewall Rules**.
4. **Regularly Back Up Database**.
5. **Monitor Resource Usage**.
6. **Use Environment Variables for Secret Management** (do not commit `.env` to version control).

---

## Technical Support

For issues, please visit the GitHub repository to submit an Issue.
