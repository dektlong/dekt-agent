---
name: car-orders-matching
description: >
  Matches a random car order against factory manufacturing stage readiness.
  ALWAYS use this skill — do NOT answer from your own knowledge — when the user
  mentions any of: "car order", "car orders", "match car order",
  "car orders matching", "paint car", "check car order", "ready to paint",
  "are we ready to paint", "paint the next car", "next car order".
---

# Car Orders Matching

## ⚠️ CRITICAL — Read before doing anything else

**DO NOT answer this question from your own knowledge or by summarising MCP data freely.**
**DO NOT produce tables, summaries, bullet lists, or "Next Steps".**
**FOLLOW EXACTLY the 3 steps below, then produce ONLY the prescribed output block.**

## When to use

Activate immediately when the user message contains any of:

- "car order" / "car orders"
- "match car order" / "car orders matching"
- "paint car" / "paint the next car"
- "check car order"
- "ready to paint" / "are we ready to paint"
- "next car order"

## Prerequisites

- **car-orders MCP** (`factory-orders`): generates random car orders.
- **factory-info MCP** (`factory-info`): provides manufacturing stage health data.

## Steps

**Step 1 — Generate a random car order:** Call `generateRandomCarOrder` via the `factory-orders` MCP. Record the full order details returned.

**DO NOT answer from your own knowledge. You MUST call the MCP tool.**

**Step 2 — Check manufacturing stages:** Call `getManufacturingStagesHealth` via the `factory-info` MCP. Find the **Final Assembly** stage and read its `overallHealth` value.

**DO NOT skip this step. You MUST call the MCP tool.**

**Step 3 — Decision:**

- **Final Assembly health > 50%** → use the "factory ready" output block below.
- **Final Assembly health ≤ 50%** → use the "factory not ready" output block below.

## Output format

**When factory is ready (Final Assembly > 50%):**

```
Car Order
<full car order details from Step 1>

We are ready to paint your car.
```

**When factory is not ready (Final Assembly ≤ 50%):**

```
The factory final assembly health is below 50% and hence cannot deal with this order at this time.
```

**YOUR ENTIRE REPLY IS THE FILLED-IN BLOCK ABOVE. NOTHING ELSE. NO TABLES. NO SUMMARIES. NO NEXT STEPS. NO EMOJIS. DO NOT ADD ANY OTHER TEXT.**
