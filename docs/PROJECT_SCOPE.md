# InfiniKitchen — Project Scope

> **Version:** 1.0.0 | **Updated:** February 2026

---

## 1. Sandbox Physics System

### Interaction Model

Drag-and-drop cooking canvas with Flame Engine physics:

| State | Behavior | Interactions |
|-------|----------|--------------|
| **Solid** | Rigid body | Choppable, mashable |
| **Liquid** | Fluid simulation | Mixable, pourable |
| **Powder** | Particle system | Dissolvable |
| **Gas** | Upward drift | Aromatic indicators |

### Gestures

| Gesture | Action |
|---------|--------|
| Tap | Select |
| Drag | Move |
| Swipe Down | Chop |
| Circular Swipe | Stir |
| Long Press | Context menu |

---

## 2. Smart Chef Engine

### Pipeline Flow

```
Ingredient Hash → Redis Cache → pgvector Search → Gemini Generation
```

1. **Hash Generation**: `MD5(sorted(lowercase(ingredients)))`
2. **Cache Check**: O(1) Redis lookup, 30-day TTL
3. **Vector Search**: pgvector similarity > 0.85
4. **LLM Generation**: Gemini 3.0 Flash on cache miss

---

## 3. Regional Logic

### Ingredient Regionalization

```json
{
  "canonical_name": "Onion",
  "regions": {
    "US": {"local_name": "Yellow Onion", "size": "150g"},
    "IN": {"local_name": "Sambar Onion", "size": "50g"},
    "JP": {"local_name": "Tamanegi", "size": "200g"}
  }
}
```

### Substitution Engine

Finds alternatives based on: flavor profile, availability, dietary compatibility.

| Original | US Substitute | India Substitute |
|----------|--------------|------------------|
| Paneer | Firm Tofu | Paneer (native) |
| Lemongrass | Lemon zest + Ginger | Lemongrass |

---

## 4. Safety Layers

### User Dietary Profile

```json
{
  "type": "Vegan",
  "allergens": ["Peanuts", "Tree Nuts"],
  "intolerances": ["Lactose", "Gluten"]
}
```

### 5-Layer Safety Pipeline

1. **Input Validation** — Whitelist, prohibited substances
2. **Allergen Detection** — Direct match, cross-contamination
3. **Dietary Compliance** — Vegan, Halal, Kosher
4. **Recipe Safety** — Temperature, food safety warnings
5. **Physical Recipe Safety** — Equipment, fire safety

### Safety Icons

| Icon | Meaning |
|------|---------|
| 🟢 | Safe |
| 🟡 | Warnings |
| 🔴 | Allergens detected |
| 🚫 | Prohibited |

---

## 5. Real-World Bridge

Transforms digital recipes into physical cooking instructions:

| Output | Platform |
|--------|----------|
| PDF | Universal |
| Apple Notes | iOS/macOS |
| Google Keep | Android |
| Grocery List | All |

---

## 6. Community Feed

- Recipe sharing with photos
- Remix/fork recipes
- Weekly challenges
- Content moderation pipeline

---

## Priority Matrix

| Feature | Priority | Phase |
|---------|----------|-------|
| Sandbox Physics | P0 | 1 |
| Smart Chef Engine | P0 | 2 |
| Safety Layers | P0 | 2 |
| Regional Logic | P1 | 2 |
| Print to Kitchen | P1 | 4 |
| Community Feed | P2 | 4 |
