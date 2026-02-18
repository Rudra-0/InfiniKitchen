# 🎮 OpenCraft - Project Quick Reference Manual

## 📋 Project Overview

**Type**: Infinite element synthesis game (similar to Infinite Craft)  
**Tech Stack**: Vue 3 + Node.js + SQLite + AI (Local/API)  
**Deployment**: Docker / Local Development  
**AI Mode**: Supports local LLM (node-llama-cpp) or external API (SiliconFlow DeepSeek-V3)

---

## 📁 Project Structure

```
opencraft/
├── server/              # Backend Service (Node.js + Express)
│   ├── index.js        # ★ Core Business Logic
│   ├── cache.db        # SQLite Database
│   ├── package.json    # Dependencies: express, better-sqlite3, node-llama-cpp (optional), axios
│   ├── Dockerfile      # API Mode Container
│   ├── Dockerfile.local# Local Model Mode Container (GPU supported)
│   └── data/           # Data Persistence Directory
│
├── frontend/           # Frontend Application (Vue 3 + TypeScript)
│   ├── src/
│   │   ├── components/ # ★ Core UI Components
│   │   │   ├── Container.vue      # Main Layout Container
│   │   │   ├── Box.vue            # Synthesis Area Element Wrapper
│   │   │   ├── ItemCard.vue       # ★★ Element Card (Display/Interaction)
│   │   │   ├── Resource.vue       # ★★ Resource Area Element (Drag/Long-press)
│   │   │   ├── AvailableResources.vue # Available Element List Container
│   │   │   ├── Example.vue        # DndProvider Configuration
│   │   │   ├── CustomDragLayer.vue# Custom Drag Layer (Mobile)
│   │   │   ├── interfaces.ts      # Type Definitions
│   │   │   └── ItemTypes.ts       # Drag Type Constants
│   │   │
│   │   ├── stores/     # ★ Pinia State Management
│   │   │   ├── useUserStore.ts    # User Authentication (localStorage)
│   │   │   ├── useResourcesStore.ts # Discovered Elements (localStorage)
│   │   │   └── useBoxesStore.ts   # Synthesis Area Elements (localStorage)
│   │   │
│   │   ├── views/      # Page Components
│   │   │   ├── HomeView.vue       # Main Game Interface
│   │   │   ├── LoginView.vue      # ★ Login/Registration (Token prompt)
│   │   │   └── AboutView.vue      # About Page
│   │   │
│   │   ├── router/     # Vue Router Configuration
│   │   ├── App.vue     # ★ Root Component (User Menu/Clean-up popup)
│   │   └── main.ts     # Application Entry
│   │
│   └── package.json    # Dependencies: vue, pinia, vue3-dnd, react-dnd-touch-backend
│
├── docker-compose.yml  # Standard Deployment Configuration
├── docker-compose.gpu.yml # GPU Acceleration Configuration
└── env.example         # Environment Variable Template
```

---

## 🎯 Core Functional Modules

### 1. **User Authentication System** 🔐
- **Path**: `frontend/src/stores/useUserStore.ts`
- **Function**: Token authentication, localStorage persistence.
- **Key Point**: 6-character token, persists on refresh.

### 2. **Element Synthesis Engine** ⚗️
- **Path**: `server/index.js` → `craftNewElement()`
- **Function**: Receives two elements → AI generates new element.
- **AI Mode**:
  - `AI_MODE=local`: node-llama-cpp local model.
  - `AI_MODE=api`: SiliconFlow DeepSeek-V3 API.

### 3. **Drag and Drop Interaction System** 🖱️
- **Core Components**:
  - `Box.vue`: Synthesis area element (Draggable, double-click to copy).
  - `Resource.vue`: Resource area element (Long-press to view details, drag to synthesis area).
  - `CustomDragLayer.vue`: Mobile drag preview layer.
- **Interaction Logic**:
  - **Desktop**: HTML5Backend.
  - **Mobile**: TouchBackend (delayTouchStart=0, touchSlop=5).
  - **Long-press Detection**: 1 second without movement → Show details (prevents timer restart during dragging).
  - **Double-click Synthesis area**: Copy element (offset position).
  - **Drag back to resource area**: Remove element.

### 4. **State Persistence** 💾
- **Path**: `frontend/src/stores/*.ts`
- **Storage Solution**:
  - `userStore`: localStorage `'opencraft_user'`.
  - `resourcesStore`: localStorage `'opencraft_resources'`.
  - `boxesStore`: localStorage `'opencraft_boxes'`.
- **Cleanup Strategy**: 
  - `App.vue` → Cleanup popup (4 options: Logout only/Clean workspace/Clean element area/Clean all).

### 5. **Database Design** 🗄️
- **Path**: `server/index.js` → `initializeDatabase()`
- **Table Structure**:
  ```sql
  users: id, username, token, created_at
  elements: id, word_cn, word_en, emoji, discoverer_name, created_at
  first_discoveries: element_id, recipe_a, recipe_b, discoverer_name, created_at
  ```

### 6. **Responsive Layout** 📱
- **Path**: `frontend/src/components/Container.vue`
- **Layout Strategy**:
  - **Mobile**: `flex-col-reverse` (Fixed element list at bottom, 35vh).
  - **Desktop**: `flex-row` (Fixed element list on the right).
- **Scroll Control**: Only the element list is scrollable; synthesis area is fixed.

---

## 🔧 Quick Reference for Key Modification Points

### ✅ Add New Element Attributes
- **Backend**: `server/index.js` → `craftNewElement()` generation logic.
- **Database**: `initializeDatabase()` table structure.
- **Frontend Type**: `frontend/src/components/interfaces.ts`.
- **UI Display**: `ItemCard.vue`.

### ✅ Modify AI Generation Logic
- **Path**: `server/index.js`
  - `generateElementLocal()`: Local model.
  - `generateElementAPI()`: External API.
  - `systemPrompt` / `userPrompt`: AI prompts.

### ✅ Adjust Drag and Drop Behavior
- **Path**: 
  - `frontend/src/components/Example.vue`: Backend configuration.
  - `Box.vue` / `Resource.vue`: Drag-and-drop logic.
  - `CustomDragLayer.vue`: Mobile preview.

### ✅ Modify Layout Styles
- **Path**: `frontend/src/components/Container.vue`
- **Key CSS**: TailwindCSS responsive classes (`md:`, `h-[35vh]`, `flex-col-reverse`).

### ✅ Increase User Interaction
- **Path**: 
  - `ItemCard.vue`: Double-click/Long-press logic.
  - `Resource.vue`: Long-press details (prevents drag re-timing).
  - `App.vue`: User menu/Cleanup popup.

---

## 🚀 Quick Search for Common Requirements

| Requirement | File Path | Key Function/Variable |
|------|---------|--------------|
| **Modify AI Prompts** | `server/index.js` | `systemPrompt`, `userPrompt` |
| **Change Element Card Style** | `frontend/src/components/ItemCard.vue` | Template section |
| **Adjust Long-press Time** | `Resource.vue` | `setTimeout(..., 1000)` |
| **Modify Token Length** | `server/index.js` | `generateToken()` |
| **Add New Data Table** | `server/index.js` | `initializeDatabase()` |
| **Modify Mobile Layout** | `Container.vue` | `h-[35vh]`, `flex-col-reverse` |
| **Configure Environment Variables** | `env.example` | All ENV variables |
| **Modify Persistence Logic** | `frontend/src/stores/*.ts` | `watch()`, `localStorage` |

---

## ⚙️ Key Environment Variables

```bash
# AI Configuration
AI_MODE=local|api           # ★ Mode Switch
LOCAL_MODEL_PATH=./models/  # Local model path
SILICONFLOW_API_KEY=sk-xxx  # API Secret
AI_MODEL=deepseek-v3        # Model name

# Database
DB_PATH=./data/cache.db     # Database file path

# Frontend
VITE_API_BASE_URL=/api      # API base path
```

---

## 🎨 Core Interaction Flow

```
User drags element A → Synthesis area
  ↓
User drags element B → Synthesis area (Overlap)
  ↓
Frontend: Box.vue → drop() → craftNewElement()
  ↓
Backend: /craft → AI Generation → Return new element
  ↓
Frontend: resourcesStore.addResource() → Update UI
  ↓
localStorage automatic save
```

---

## 📝 Important Notes

1. ⚠️ **Mobile Drag**: Must use `TouchBackend` + `CustomDragLayer`.
2. ⚠️ **Long-press vs Drag**: Use `isDraggingStarted` flag to prevent conflicts.
3. ⚠️ **GPU Support**: Start using `docker-compose.gpu.yml`.
4. ⚠️ **Token Persistence**: Manual `localStorage` + `watch`, do not use `useLocalStorage`.
5. ⚠️ **Double-click Logic**: Differentiate synthesis area/resource area based on `size` property.

---

**Quick search keywords**: Drag and drop (`useDrag`), synthesis (`craftNewElement`), AI (`generateElement`), persistence (`localStorage`), long press (`longPressTimer`).