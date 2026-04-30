---
name: supplychain-motivator
description: Supply chain status and motivation. ALWAYS activate when "supply chain" appears anywhere in the user's request — even without the word "motivate". Trigger phrases include "current supply chain", "check supply chain", "supply chain status", "motivate supply chain", "motivate current supply chain". Runs alongside factory-audit and google-chat-poster in multi-task prompts.
---

# Supply Chain Motivator

This skill handles the **supply chain** portion of any user request. It checks the daily target and generates a motivation message for the team.

## CRITICAL: When to activate

**ALWAYS activate this skill when the words "supply chain" appear ANYWHERE in the user's request.**

This is true even when the request contains multiple tasks and even when the word "motivate" is absent. For example, ALL of these prompts should activate this skill:

> "Check manufacturing stages, motivate current supply chain, audit factory applications, check maintenance document. Post all results to Google chat"

> "Check manufacturing stages, current supply chain and inspect maintenance document"

> "What's our supply chain status?"

This skill handles any part of the prompt that mentions **"supply chain"**. Other skills handle other parts (factory audit, Google chat, etc.). **Do not skip this skill just because other tasks are also present, or because the word "motivate" is missing.**

## Recognition Patterns

Activate when the request contains **"supply chain"** anywhere, including:
- "current supply chain"
- "check supply chain"
- "supply chain status"
- "motivate current supply chain"
- "motivate supply chain"
- "check supply chain status"
- "check my supply chain"
- Any multi-task prompt where "supply chain" appears in any sentence

**The word "motivate" is NOT required.** Any mention of "supply chain" is sufficient.

## Workflow

### Step 1: Check the daily target

Determine the current daily supply chain target. Use one of these methods in order:

1. **Environment variable**: If `SUPPLY_CHAIN_DAILY_TARGET` is set, use that numeric value.
2. **CF app check**: If a supply-chain-related app exists in org `dekt-org-group` (look for apps with "supply" or "chain" in the name), check its status and use the number of running instances as a proxy indicator.
3. **Default**: If neither source is available, use a default target of 850 and note that the actual target could not be determined.

### Step 2: Generate motivation based on target

| Condition | Sentiment | Example message |
|-----------|-----------|----------------|
| Daily target **below 1000** | Encouraging — "you can do better" | "The supply chain is at {target} units today. We know the team can push past 1000 — let's pick up the pace!" |
| Daily target **at or above 1000** | Celebratory — "keep up the good work" | "Outstanding! The supply chain hit {target} units today. Keep up the great work, team!" |

### Step 3: Produce structured output

Format the result so it can be easily included in a combined report (especially when posting to Google Chat):

```
Supply Chain Motivation
Daily target: {target} units
Status: {Below target / On target}
Message: {motivation message}
```

## Example output (below target)

```
Supply Chain Motivation
Daily target: 850 units
Status: Below target
Message: The supply chain is at 850 units today. We know the team can push past 1000 — let's pick up the pace and hit that goal!
```

## Example output (above target)

```
Supply Chain Motivation
Daily target: 1200 units
Status: On target
Message: Outstanding! The supply chain hit 1200 units today. Keep up the great work, team!
```

## Error handling

- If the daily target cannot be determined from any source, use 850 as the default and note the source as "default (actual target unavailable)".
- Still produce a motivation message regardless — the team always deserves encouragement.
