# API Configuration Guide

## Environment Variable Configuration

### Backend Environment Variables

Configure in `server/.env` or Docker's `.env` file:

#### Required Configuration

```bash
# SiliconFlow API Key (Required)
SILICONFLOW_API_KEY=sk-your-api-key-here
```

#### AI Configuration

```bash
# AI API URL
SILICONFLOW_API_URL=https://api.siliconflow.cn/v1/chat/completions

# AI Model Name
AI_MODEL=deepseek-ai/DeepSeek-V3

# AI Temperature Parameter (0.0-2.0)
AI_TEMPERATURE=0.7

# AI Maximum Generation Token Count
AI_MAX_TOKENS=200
```

#### Server Configuration

```bash
# Server Port
PORT=3000

# Database Path
DB_PATH=/app/data/cache.db
```

### Frontend Environment Variables

Configure in `frontend/.env.development` or `frontend/.env.production`:

```bash
# API Base URL
VITE_API_BASE_URL=http://localhost:3000

# Application Title
VITE_APP_TITLE=OpenCraft
```

## Supported AI Models

### Available SiliconFlow Models

| Model Name | Description | Recommended Scenario |
|---------|------|---------|
| `deepseek-ai/DeepSeek-V3` | Latest DeepSeek model | **Recommended** - Best Chinese understanding |
| `deepseek-ai/DeepSeek-V2.5` | Previous generation DeepSeek | Higher stability |
| `Qwen/Qwen2.5-72B-Instruct` | Tongyi Qianwen large model | High accuracy |
| `Qwen/Qwen2.5-7B-Instruct` | Tongyi Qianwen light version | Fast response |

### Switching Models

Just modify the `AI_MODEL` environment variable:

```bash
# Use DeepSeek-V3 (Recommended)
AI_MODEL=deepseek-ai/DeepSeek-V3

# Or use Tongyi Qianwen
AI_MODEL=Qwen/Qwen2.5-72B-Instruct
```

Restart service for changes to take effect:
```bash
docker-compose restart backend
```

## Temperature Parameter Adjustment

`AI_TEMPERATURE` controls generation randomness:

- **0.0-0.3**: Very deterministic, consistent results.
- **0.4-0.7**: Balanced (Recommended).
- **0.8-1.2**: More creative.
- **1.3-2.0**: Very random.

### Example Scenarios

```bash
# Pursue stable results
AI_TEMPERATURE=0.3

# Balance creativity and stability (Recommended)
AI_TEMPERATURE=0.7

# Pursue creativity and variety
AI_TEMPERATURE=1.2
```

## Token Count Configuration

`AI_MAX_TOKENS` controls generation length:

```bash
# Short results (Recommended)
AI_MAX_TOKENS=200

# More detailed results
AI_MAX_TOKENS=500

# Maximum results
AI_MAX_TOKENS=1000
```

**Note**: More tokens mean higher API call costs and longer response times.

## Frontend API Proxy Configuration

### Development Environment

Vite automatically proxies `/api` requests to the backend:

```typescript
// vite.config.ts
proxy: {
  '/api': {
    target: 'http://localhost:3000',
    changeOrigin: true,
    rewrite: (path) => path.replace(/^\/api/, '')
  }
}
```

Frontend request example:
```typescript
// Automatically proxied to http://localhost:3000/register
await request.post('/api/register', { username: 'player' })
```

### Production Environment

When deploying in a production environment, configure `VITE_API_BASE_URL`:

```bash
# .env.production
VITE_API_BASE_URL=https://api.yourdomain.com
```

Or configure a reverse proxy in Nginx.

## Docker Configuration Example

### Complete .env File

```bash
# ==================== Required Configuration ====================
SILICONFLOW_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxx

# ==================== AI Configuration ====================
SILICONFLOW_API_URL=https://api.siliconflow.cn/v1/chat/completions
AI_MODEL=deepseek-ai/DeepSeek-V3
AI_TEMPERATURE=0.7
AI_MAX_TOKENS=200

# ==================== Frontend Configuration ====================
VITE_API_BASE_URL=http://backend:3000
VITE_APP_TITLE=OpenCraft

# ==================== Traefik (Optional) ====================
NETWORK_NAME=reverse-proxy-docker-traefik_routing
FRONTEND_DOMAIN=opencraft.yourdomain.com
BACKEND_DOMAIN=api.opencraft.yourdomain.com
```

### Start Service

```bash
docker-compose up -d
```

### View Configuration

```bash
# View backend configuration
docker-compose logs backend | grep "Server started successfully" -A 5

# Example Output:
# ✅ Server started successfully
#    Port: 3000
#    AI Model: deepseek-ai/DeepSeek-V3
#    API URL: https://api.siliconflow.cn/v1/chat/completions
#    API Key: sk-xxxxxxxx...
```

## API Request Flow

### Development Environment

```
Browser → Vite Dev Server (5173)
                ↓ /api proxy
          Backend Server (3000)
                ↓
          SiliconFlow API
```

### Docker Environment

```
Browser → Frontend Container (5173)
                ↓ /api proxy
          Backend Container (3000)
            ↓ Container Network
     SiliconFlow API (Internet)
```

## FAQ

### Q1: How to switch to other AI providers?

Just modify `SILICONFLOW_API_URL` and authentication method:

```bash
# Use OpenAI
SILICONFLOW_API_URL=https://api.openai.com/v1/chat/completions
SILICONFLOW_API_KEY=sk-your-openai-key
AI_MODEL=gpt-4

# Use Aliyun Bailian
SILICONFLOW_API_URL=https://dashscope.aliyuncs.com/v1/chat/completions
SILICONFLOW_API_KEY=your-dashscope-key
AI_MODEL=qwen-max
```

### Q2: What if the frontend request has CORS issues?

The development environment uses Vite proxy (configured); the production environment has three choices:

1. **Same-domain deployment** (Recommended).
2. **Configure Nginx reverse proxy**.
3. **Backend enable CORS** (enabled by default).

### Q3: How to test API configuration?

```bash
# Test backend health
curl http://localhost:3000/elements/base

# Test frontend proxy
# Visit after starting frontend
curl http://localhost:5173/api/elements/base
```

### Q4: How to access backend within Docker containers?

Containers communicate using container names:

```bash
# Access backend from frontend container
VITE_API_BASE_URL=http://backend:3000

# Instead of
VITE_API_BASE_URL=http://localhost:3000
```

## Performance Optimization Suggestions

1. **Model Selection**:
   - Dev testing: Use lightweight model (Qwen2.5-7B).
   - Production env: Use high-performance model (DeepSeek-V3).

2. **Temperature Parameter**:
   - Pursue stability: 0.3-0.5.
   - Balanced experience: 0.7 (Recommended).
   - Pursue creativity: 1.0-1.2.

3. **Token Limit**:
   - Keep within 200 to ensure quality while controlling cost.

4. **Caching Strategy**:
   - Same combinations automatically use cache, no repeated API calls.
   - Regular database backups to avoid cache loss.

---

**After configuration is complete, enjoy the high-efficiency AI element synthesis game!** 🎮✨
