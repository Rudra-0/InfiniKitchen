# Update Log - Chinese Version Transformation

## Version 2.0.0 - Chinese Five Elements Version

### 🎉 Major Updates

#### Backend Transformation

1. **Database Structure Reconstruction**
   - ✅ Added `users` table: User authentication system.
   - ✅ Reconstructed `elements` table: Supports bilingual (Chinese/English), records discoverers.
   - ✅ Reconstructed `craft_cache` table: Using element IDs instead of text.
   - ✅ Initialized Five Elements basic elements: Metal, Wood, Water, Fire, Earth.

2. **User Authentication System**
   - ✅ POST `/register` - User registration.
   - ✅ POST `/login` - Token login.
   - ✅ Middleware: Bearer Token authentication.
   - ✅ Automatically generate 64-bit secure Tokens.

3. **Element Management API**
   - ✅ GET `/elements/base` - Get basic elements.
   - ✅ GET `/elements/discovered` - Get elements discovered by the user.
   - ✅ POST `/craft` - Synthesize elements (authentication required).

4. **AI Synthesis Logic Upgrade**
   - ✅ Chinese Prompts: Complete Chinese dialogue.
   - ✅ Bilingual Output: Generates Chinese names and English translations.
   - ✅ Discoverer Records: Records player information for the first synthesis.
   - ✅ Element Deduplication: Judged unique based on Chinese Name + English Name.
   - ✅ Improved Verification Logic: Avoids results containing original words.

#### Frontend Transformation

5. **State Management Reconstruction**
   - ✅ `useUserStore` - New user state management.
   - ✅ `useResourcesStore` - Supports new element data structure.
   - ✅ `useBoxesStore` - Workspace elements support full information.

6. **Data Structure Update**
   ```typescript
   // Old structure
   { title: string, emoji: string }
   
   // New structure
   { 
     id: string,
     word_cn: string,
     word_en: string,
     emoji: string,
     discoverer_name?: string
   }
   ```

7. **Login and Registration Interface**
   - ✅ `/login` - New login page.
   - ✅ Registration function: Enter username to automatically generate token.
   - ✅ Login function: Authenticate using token.
   - ✅ Route Guard: Automatically redirect if not logged in.

8. **UI Component Upgrade**
   - ✅ `App.vue` - Display username, logout button.
   - ✅ `ItemCard.vue` - Display discoverer information.
   - ✅ `Container.vue` - Supports new data structure.
   - ✅ `Resource.vue` - Bilingual support.
   - ✅ `AvailableResources.vue` - Chinese and English search.

9. **API Integration**
   - ✅ All requests carry Authorization header.
   - ✅ Synthesis interface uses new data format.
   - ✅ Error handling and prompts.
   - ✅ Special notification for first discovery.

### 📋 Interface Change Comparison

#### Old Interface
```javascript
// Get predefined combinations
GET /

// Synthesize elements
POST /
{
  "first": "Water",
  "second": "Fire"
}

// Response
{
  "result": "Steam",
  "emoji": "💨"
}
```

#### New Interface
```javascript
// Register
POST /register
{
  "username": "PlayerName"
}

// Login
POST /login
{
  "token": "xxx"
}

// Get basic elements
GET /elements/base

// Synthesize elements
POST /craft
Headers: { Authorization: "Bearer xxx" }
{
  "firstElementId": "base_metal",
  "secondElementId": "base_fire"
}

// Response
{
  "success": true,
  "element": {
    "id": "xxx",
    "word_cn": "Steel",
    "word_en": "Steel",
    "emoji": "🔩",
    "discoverer_name": "PlayerName"
  },
  "isNew": true
}
```

### 🗂️ File Change List

#### Backend Files
- ✏️ `server/index.js` - Completely rewritten.

#### Frontend Files (Modified)
- ✏️ `frontend/src/stores/useResourcesStore.ts`
- ✏️ `frontend/src/stores/useBoxesStore.ts`
- ✏️ `frontend/src/components/interfaces.ts`
- ✏️ `frontend/src/components/ItemCard.vue`
- ✏️ `frontend/src/components/Resource.vue`
- ✏️ `frontend/src/components/AvailableResources.vue`
- ✏️ `frontend/src/components/Container.vue`
- ✏️ `frontend/src/router/index.ts`
- ✏️ `frontend/src/App.vue`

#### Frontend Files (New)
- ➕ `frontend/src/stores/useUserStore.ts`
- ➕ `frontend/src/views/LoginView.vue`

#### Documentation
- ➕ `README_CN.md` - Chinese instructions.
- ➕ `CHANGELOG_CN.md` - This file.

### 🔄 Data Migration

**Note:** This update is not compatible with old version data!

If you have an old version of `server/cache.db`, you need to:
1. Back up the old database.
2. Delete `server/cache.db`.
3. Restart the backend; the system will automatically create a new database.

### 🎮 Gameplay Changes

#### Before
- Start the game directly.
- 4 basic elements: Fire, Water, Earth, Air.
- No user system.
- No discoverer record.

#### Now
- Need to register/login.
- 5 basic elements: Metal, Wood, Water, Fire, Earth.
- Each player has an independent account.
- First discovery records the player's name.

### 🐛 Known Issues

- AI model still uses an English model, but supports Chinese via prompt engineering.
- Suggest using a Chinese-optimized LLM in the future for better Chinese generation.

### 📈 Performance Optimization

- Using element IDs instead of text queries improves database performance.
- Retains original caching mechanism.
- Added database indices (foreign key constraints).

### 🔐 Security

- Token uses 64-bit random string.
- All user operations require authentication.
- Prevents unauthorized access.

### 🌐 Internationalization Readiness

- Data structure supports multiple languages.
- Frontend can be extended for language switching.
- Backend API response includes bilingual information.

---

## Upgrade Guide

### Upgrading from Old Version

1. **Back Up Data**
   ```bash
   cp server/cache.db server/cache.db.backup
   ```

2. **Update Code**
   ```bash
   git pull
   ```

3. **Install Dependencies**
   ```bash
   cd server && npm install
   cd ../frontend && npm install
   ```

4. **Clean Database** (if necessary)
   ```bash
   rm server/cache.db
   ```

5. **Start Service**
   ```bash
   # Start backend
   cd server && npm start
   
   # Start frontend
   cd frontend && npm run dev
   ```

6. **Register Account**
   - Visit http://localhost:5173
   - Will automatically redirect to login page.
   - Click "Register" to create an account.
   - Save the generated token.

### Test Checklist

- [ ] User registration successful.
- [ ] Token login successful.
- [ ] Basic elements displayed correctly (5 Five Elements).
- [ ] Drag elements to workspace.
- [ ] Synthesize two elements to generate a new element.
- [ ] New element displays discoverer information.
- [ ] New element added to resource list.
- [ ] Search function normal.
- [ ] Logout function normal.

---

**Update Complete! Enjoy the brand new version of OpenCraft!** 🎉
