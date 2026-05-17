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

## When to use

Activate immediately when the user message contains any of:

- "car order" / "car orders"
- "match car order" / "car orders matching"
- "paint car" / "paint the next car"
- "check car order"
- "ready to paint" / "are we ready to paint"
- "next car order"

## Prerequisites

- A bound MCP server that exposes `generateRandomCarOrder` (car order generation).
- A bound MCP server that exposes `getManufacturingStagesHealth` (manufacturing stage health data).

Discover which bound MCP servers provide these tools at runtime by inspecting the available tool list — do NOT hardcode server names.

## Steps

**Step 1 — Generate a random car order:** Call the `generateRandomCarOrder` tool from whichever bound MCP server exposes it. Record the full order details returned.

**DO NOT answer from your own knowledge. You MUST call the MCP tool.**

**Step 2 — Check manufacturing stages:** Call the `getManufacturingStagesHealth` tool from whichever bound MCP server exposes it. Find the **Final Assembly** stage and read its `overallHealth` value.

**DO NOT skip this step. You MUST call the MCP tool.**

**Step 3 — Decision:**

- **Final Assembly health > 50%** → use the "factory ready" output block below.
- **Final Assembly health ≤ 50%** → use the "factory not ready" output block below.

## Output format

After completing both tool calls, respond with one of the following:

**When factory is ready (Final Assembly overallHealth > 50%):**

```
Car Order
<full car order details from Step 1>

We are ready to paint your car.
```

**When factory is not ready (Final Assembly overallHealth ≤ 50%):**

```
The factory final assembly health is below 50% and hence cannot deal with this order at this time.
```
