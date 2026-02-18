# OpenCraft Docker Deployment Guide

## 🚀 Quick Docker Deployment

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- SiliconFlow API Key (Register free: https://cloud.siliconflow.cn/)

### Step 1: Configure Environment Variables

1. Copy the environment variable template:
```bash
cp env.example .env
```

2. Edit the `.env` file and fill in your API Key:
```bash
SILICONFLOW_API_KEY=sk-your-actual-api-key-here
```

### Step 2: Create Data Directory

```bash
mkdir -p server/data
```

### Step 3: Start Service

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f
```

### Step 4: Access Application

- Frontend: http://localhost:5173
- Backend API: http://localhost:3000

## 📋 Common Commands

### Start Service
```bash
docker-compose up -d
```

### Stop Service
```bash
docker-compose down
```

### Restart Service
```bash
docker-compose restart
```

### View Logs
```bash
# View all service logs
docker-compose logs -f

# View only backend logs
docker-compose logs -f backend

# View only frontend logs
docker-compose logs -f frontend
```

### Rebuild
```bash
# Rebuild all services
docker-compose up -d --build

# Rebuild only the backend
docker-compose up -d --build backend
```

### Enter Container
```bash
# Enter backend container
docker exec -it opencraft-backend sh

# Enter frontend container
docker exec -it opencraft-frontend sh
```

## 💾 Data Persistence

Database files are stored in `./server/data/cache.db` and mounted to the container via Docker volume.

### Back Up Database
```bash
# Back up database
cp server/data/cache.db server/data/cache.db.backup.$(date +%Y%m%d)
```

### Restore Database
```bash
# Stop service
docker-compose down

# Restore database
cp server/data/cache.db.backup.20240101 server/data/cache.db

# Start service
docker-compose up -d
```

### Clear Database
```bash
# Stop service
docker-compose down

# Delete database
rm server/data/cache.db

# Start service (a new database will be created automatically)
docker-compose up -d
```

## 🌐 Using Traefik Reverse Proxy

If you use Traefik as a reverse proxy, `docker-compose.yml` is already configured with the relevant labels.

### Configure Domain

1. Edit the `.env` file:
```bash
FRONTEND_DOMAIN=opencraft.yourdomain.com
BACKEND_DOMAIN=api.opencraft.yourdomain.com
NETWORK_NAME=your-traefik-network
```

2. Ensure the Traefik network exists:
```bash
docker network create your-traefik-network
```

3. Start Service:
```bash
docker-compose up -d
```

## 🔧 Environment Variable Description

### Required Environment Variables

| Variable Name | Description | Example |
|--------|------|------|
| SILICONFLOW_API_KEY | SiliconFlow API Key | sk-xxxxxxxxxx |

### AI Configuration (Optional)

| Variable Name | Description | Default Value |
|--------|------|--------|
| SILICONFLOW_API_URL | API URL | https://api.siliconflow.cn/v1/chat/completions |
| AI_MODEL | Model Name | deepseek-ai/DeepSeek-V3 |
| AI_TEMPERATURE | Temperature Parameter (0-2) | 0.7 |
| AI_MAX_TOKENS | Maximum Token Count | 200 |

### Service Configuration (Optional)

| Variable Name | Description | Default Value |
|--------|------|--------|
| PORT | Backend Port | 3000 |
| DB_PATH | Database Path | /app/data/cache.db |
| VITE_API_BASE_URL | Frontend API Address | http://backend:3000 |
| VITE_APP_TITLE | Application Title | OpenCraft |

### Traefik Configuration (Optional)

| Variable Name | Description | Default Value |
|--------|------|--------|
| NETWORK_NAME | Traefik Network Name | reverse-proxy-docker-traefik_routing |
| FRONTEND_DOMAIN | Frontend Domain | opencraft.bufferhead.com |
| BACKEND_DOMAIN | Backend Domain | api.opencraft.bufferhead.com |

📖 **Detailed Configuration Instructions**: See [API Configuration Guide](API_CONFIG.md)

## 📊 Monitoring and Health Checks

### Check Container Status
```bash
docker-compose ps
```

### Check Container Resource Usage
```bash
docker stats opencraft-backend opencraft-frontend
```

### Backend Health Check
```bash
curl http://localhost:3000/elements/base
```

## 🐛 Troubleshooting

### Issue 1: Backend Startup Failure
**Symptom**: Container keeps restarting.
```bash
docker-compose logs backend
```
**Possible Causes**:
- SILICONFLOW_API_KEY is not set.
- Port 3000 is already in use.
- Data directory permission issues.

**Solution**:
```bash
# Check environment variables
docker-compose config

# Check port usage
netstat -ano | findstr :3000  # Windows
lsof -i :3000                 # Mac/Linux

# Fix data directory permissions
chmod 755 server/data
```

### Issue 2: Frontend Cannot Connect to Backend
**Symptom**: Synthesis function is unavailable.
**Solution**:
```bash
# Check network connection
docker exec opencraft-frontend ping backend

# Check if backend is normal
curl http://localhost:3000/elements/base
```

### Issue 3: Data Loss
**Symptom**: Data is gone after restart.
**Solution**:
```bash
# Ensure volume is mounted correctly
docker-compose down
docker-compose up -d

# Check mounts
docker inspect opencraft-backend | grep Mounts -A 10
```

### Issue 4: API Call Failure
**Symptom**: Error during synthesis.
```bash
docker-compose logs backend | grep "SiliconFlow API"
```
**Possible Causes**:
- API Key is invalid or expired.
- API quota has been used up.
- Network connection issue.

**Solution**:
```bash
# Check API Key
docker exec opencraft-backend env | grep SILICONFLOW_API_KEY

# Manually test API
curl -X POST https://api.siliconflow.cn/v1/chat/completions \
  -H "Authorization: Bearer your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-ai/DeepSeek-V3","messages":[{"role":"user","content":"test"}]}'
```

## 🔄 Updating the Application

```bash
# Pull latest code
git pull

# Rebuild and start
docker-compose up -d --build

# View new version status
docker-compose logs -f
```

## 🛡️ Security Suggestions

1. **Protect API Key**:
   - Do not commit the `.env` file to Git.
   - Regularly rotate API Key.
   - Use environment variable management tools (such as Docker Secrets).

2. **Database Backup**:
   - Regularly back up `server/data/cache.db`.
   - Use automated backup scripts.

3. **Access Control**:
   - If deployed to the public internet, use a firewall to limit access.
   - Consider adding authentication.

4. **HTTPS**:
   - Use Traefik + Let's Encrypt for automatic HTTPS configuration.
   - Or configure SSL using an Nginx reverse proxy in front.

## 📈 Performance Optimization

### Add Resource Limits
In `docker-compose.yml`, add:
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### Use Production Mode
```bash
# Frontend build optimization
cd frontend
npm run build

# Use Nginx to serve static files
# Refer to frontend/Dockerfile for multi-stage build
```

## 🎯 Best Practices

1. **Always use named containers**: Ease of management and log viewing.
2. **Configure auto-restart**: `restart: unless-stopped`.
3. **Use volume to persist data**: Avoid data loss.
4. **Regularly back up**: Databases and configuration files.
5. **Monitor logs**: Detect and solve issues in a timely manner.
6. **Limit resources**: Prevent a single container from occupying too many resources.

---

**Need help?** View full documentation: [README_CN.md](README_CN.md)
