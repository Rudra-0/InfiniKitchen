# InfiniKitchen — Application Design Document

> **Version:** 1.0.0 | **Updated:** February 2026 | **Status:** Draft

---

## 1. Introduction

This document details the software design and user experience specification for InfiniKitchen. It bridges the gap between the high-level [Architecture](ARCHITECTURE.md) and the code implementation, focusing on Component Design, Game Mechanics, and UI/UX patterns.

---

## 2. Design Principles

1.  **AI-Native**: The AI is not a chatbot sidecar; it is the engine that drives the core gameplay loop (discovery).
2.  **Tactile & Physics-Based**: Digital cooking should feel satisfying. Interactions (chopping, stirring) must have physical feedback.
3.  **Regional First**: The application adapts to the user's location, prioritizing local ingredients and measurement systems.
4.  **Safe Discovery**: Encouraging experimentation while ensuring food safety guidelines are met.

---

## 3. Frontend Design (Flutter + Flame)

### 3.1 Architecture: The "Game-App Hybrid"
InfiniKitchen uses a hybrid architecture where standard Flutter Widgets handle navigation/menus, and the Flame Game Engine acts as a widget for the main "Kitchen" view.

-   **Router**: `go_router` manages navigation.
    -   `/`: Splash/Login
    -   `/home`: Dashboard (Feed, Recent)
    -   `/kitchen`: **Flame Game Widget** (The Sandbox)
    -   `/recipe/:id`: Detail View (Standard Flutter UI)
    -   `/profile`: Settings/Dietary Prefs

### 3.2 State Management (Riverpod)
We use a **Provider** pattern to share state between the Flame Game Loop and Flutter UI.

-   **`GameStateProvider`**: Tracks ingredients currently on the canvas, temperature, and tool selection.
-   **`UserProvider`**: Holds profile, dietary restrictions, and regional settings.
-   **`RecipeProvider`**: Caches recent recipes and handles async generation status.

### 3.3 The "Kitchen" (Flame Engine)
The Kitchen is a `FlameGame` instance.

#### **Components**:
   -   **`IngredientComponent`**:
       -   *Properties*: Position, Mass, State (Solid/Liquid), Color.
       -   *Behaviors*: Draggable, Collidable.
   -   **`ToolComponent`** (Knife, Spoon, Pan):
       -   *interaction*: Modifies `IngredientComponent` state (e.g., Knife splits Solid -> List<Solid>).
   -   **`PhysicsWorld`**:
       -   Standard Forge2D physics for gravity and collisions.

#### **Interaction Loop**:
1.  User drags ingredient from "Pantry Bar" (Flutter Overlay) to "Canvas" (Flame).
2.  Flame instantiates `IngredientComponent`.
3.  User interacts (gestures).
4.  State updates (chopped, mixed).
5.  User taps "Cook/Generate".
6.  `GameWorld` serializes state -> sends to Backend API.

---

## 4. Backend Component Design (FastAPI)

### 4.1 Service Layer Pattern
Business logic is decoupled from API routes using a Service Layer.

-   **`IngredientService`**:
    -   Handles vector search logic (`pgvector`).
    -   Manages regional substitution mapping.
-   **`RecipeService`**:
    -   Orchestrates the Generation Pipeline.
    -   Checks Redis cache.
    -   Delegates to `AgentService` if miss.
-   **`AgentService`** (formerly `AIService`):
    -   **Loop**: ReAct (Reason/Act) or Tool-Use pattern.
    -   **Tools**:
        1.  `VectorSearchTool` (Internal DB)
        2.  `WebSearchTool` (Google Search Grounding)
    -   **Logic**:
        -   First check internal DB for high-confidence matches.
        -   If low confidence or "surprise me" flag, use Web Search to find novel combinations.
        -   Synthesize final recipe JSON.

### 4.2 Dependency Injection
FastAPI's `Depends` is used for injecting services and database sessions.

```python
# Example
@router.post("/generate")
async def generate_recipe(
    request: RecipeRequest,
    recipe_service: RecipeService = Depends(get_recipe_service),
    user: User = Depends(get_current_user)
):
    return await recipe_service.create_recipe(request.ingredients, user)
```

---

## 5. UI/UX Design

### 5.1 Visual Style: "Generative Gastronomy"
-   **Palette**: Organic, warm earth tones with vibrant accent colors for ingredients.
    -   *Primary*: Burnt Orange (#E65100)
    -   *Secondary*: Sage Green (#4CAF50) - Safe/Healthy
    -   *Background*: Cream/Off-White (Paper texture feel)
-   **Typography**:
    -   *Headings*: Serif (e.g., Playfair Display) for a cookbook feel.
    -   *Body*: Sans-Serif (e.g., Inter/Lato) for readability.

### 5.2 Key User Flows

#### **A. The Discovery Flow (Main Loop)**
1.  **Input**: User enters Kitchen Mode.
2.  **Action**: Drags "Tomato", "Basil", "Garlic" into the pot.
3.  **Interaction**: Swipes to crush garlic, chop tomato.
4.  **Trigger**: Taps "Dream Up Recipe".
5.  **Feedback**: "Thinking..." animation (Bubbling pot).
6.  **Result**: "Rustic Tomato Basil Soup" card appears.
7.  **Closure**: User saves to Cookbook or shares.

#### **B. The Safety Check Flow**
1.  **Context**: Ingredient added (e.g., "Peanut Oil").
2.  **Check**: App checks `UserProvider.allergens`.
3.  **Alert**: If conflict, visual warning on the ingredient sprite (Red glow + Icon).
4.  **Resolution**: User can "Substitute" (Auto-swap to Vegetable Oil) or "Remove".

### 5.3 Feedback Mechanisms
-   **Haptic Feedback**: On chopping or collision events.
-   **Toast Notifications**: For save confirmations or API errors.
-   **Skeleton Loaders**: During AI generation latency (approx 2-3s).

---

## 6. AI & Prompt Engineering Design

### 6.1 Prompt Strategy
We use **Chain-of-Thought** prompting to ensure recipe viability.

**Structure**:
1.  **Role**: "You are a Michelin-star chef expert in [User Region] cuisine."
2.  **Context**: "User has these ingredients: [List]. State: [Chopped/Whole]."
3.  **Constraint**: "Dietary restrictions: [Vegan]. Exclude: [None]."
4.  **Task**: "Create a chemically viable recipe using these primary ingredients. Add common pantry staples (salt, oil) if needed."
5.  **Output**: JSON Schema enforcement for UI parsing.

### 6.2 Regional Adaptation
The `AIService` injects region-specific context into the prompt:
-   *User Region = IN (India)* -> "Use metric units. Suggest spices common to Indian cuisine if flavor profile allows."
-   *User Region = US* -> "Use imperial units."

---

## 7. Future Considerations

-   **AR Mode**: projecting recipes onto real kitchen counters.
-   **Voice Control**: "Hey Chef, next step" for hands-free cooking.
