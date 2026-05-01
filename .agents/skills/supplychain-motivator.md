---
name: supplychain-motivator
description: Supply chain status and motivation. ALWAYS activate when "supply chain" appears anywhere in the user's request — even without the word "motivate". Trigger phrases include "current supply chain", "check supply chain", "supply chain status", "motivate supply chain", "motivate current supply chain". Runs alongside car-orders-matching in multi-task prompts.
---

# Supply Chain Motivator

This skill handles the **supply chain** portion of any user request. It fetches the live supply chain status via MCP and generates a motivation message for the team.

## CRITICAL: When to activate

**ALWAYS activate this skill when the words "supply chain" appear ANYWHERE in the user's request.**

This is true even when the request contains multiple tasks and even when the word "motivate" is absent.

**The word "motivate" is NOT required.** Any mention of "supply chain" is sufficient.

## Workflow

### Step 1: Call getCurrentSupplyChainStatus via the factory-info MCP

Call the `getCurrentSupplyChainStatus` tool via the `factory-info` MCP toolset.

**DO NOT check environment variables. DO NOT check CF apps. DO NOT use a hardcoded default. Always call the MCP tool.**

The tool returns a `SupplyChainStatusDto` with the following fields:
- `date` — the production date
- `targetUnits` — the daily production target
- `currentOutput` — units produced so far today
- `projectedOutput` — projected end-of-shift output at the current rate
- `targetCompletion` — percentage of the daily target completed
- `onTrack` — boolean indicating if production is on track to meet the daily target

### Step 2: Generate motivation based on the result

| Condition | Sentiment | Example message |
|-----------|-----------|----------------|
| `onTrack` is **true** | Celebratory — "keep up the good work" | "Outstanding! We're on track with {currentOutput} units produced and a projected {projectedOutput} by end of shift. Keep up the great work, team!" |
| `onTrack` is **false** | Encouraging — "you can do better" | "We're at {currentOutput} units today ({targetCompletion:.0f}% of target). Let's push to hit {targetUnits} — the team can do it!" |

### Step 3: Produce structured output

```
Supply Chain Status
Date: {date}
Daily target: {targetUnits} units
Current output: {currentOutput} units
Projected output: {projectedOutput} units
Target completion: {targetCompletion:.0f}%
On track: {onTrack}
Message: {motivation message}
```

## Example output (on track)

```
Supply Chain Status
Date: 2026-05-01
Daily target: 1000 units
Current output: 820 units
Projected output: 1050 units
Target completion: 82%
On track: true
Message: Outstanding! We're on track with 820 units produced and projecting 1050 by end of shift. Keep up the great work, team!
```

## Example output (behind target)

```
Supply Chain Status
Date: 2026-05-01
Daily target: 1000 units
Current output: 430 units
Projected output: 780 units
Target completion: 43%
On track: false
Message: We're at 430 units today (43% of target). Let's push to hit 1000 — the team can do it!
```

## Error handling

- If the MCP tool call fails, report the error clearly. Do NOT fall back to hardcoded values.
