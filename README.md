# dekt-factory-agent

An AI agent for managing factory operations — supply chain status, manufacturing stages, and car order processing — deployed on Tanzu Application Service (TAS) via the Cursor AI platform.

---

## Deployment

### Prerequisites

#### 1. Tanzu Platform org and space

Ensure you are logged in and targeting the correct org and space:

```bash
cf login
cf target -o <your-org> -s <your-space>
```

#### 2. Create the MCP Gateway

The MCP Gateway is the entry point that routes agent tool calls to the MCP server instances. Deploy it first:

```bash
cf create-service mcp-gateway standard dekt-mcp-gw
```

Note the gateway's public URL — you will use it when registering each MCP server as a user-provided service (e.g. `https://dekt-mcp-gw.apps.<domain>`).

#### 3. Push the MCP server instances

Each MCP server is a standalone Spring Boot app. Clone and push each one, then register it as a user-provided service pointing to its route through the MCP Gateway.

**factory-mcp-server** — manufacturing stage data and supply chain dashboard

```bash
git clone https://github.com/dektlong/factory-mcp-server
cd factory-mcp-server
cf push -f manifest.yml
cd ..

cf create-user-provided-service factory-info \
  -p '{"url": "https://dekt-mcp-gw.apps.<domain>/factory-mcp-server/mcp"}' \
  -t mcp-server
```

**car-orders-mcp-server** — car order management tools

```bash
git clone https://github.com/dektlong/car-orders-mcp-server
cd car-orders-mcp-server
cf push -f manifest.yml
cd ..

cf create-user-provided-service factory-orders \
  -p '{"url": "https://dekt-mcp-gw.apps.<domain>/car-orders-mcp-server/mcp"}' \
  -t mcp-server
```

**doc-analyzer-mcp** — document analysis via RAG (analyze-document tool)

```bash
git clone https://github.com/dektlong/doc-analyzer-mcp
cd doc-analyzer-mcp
cf push -f manifest.yml
cd ..

cf create-user-provided-service factory-documents \
  -p '{"url": "https://dekt-mcp-gw.apps.<domain>/doc-analyzer-mcp/mcp"}' \
  -t mcp-server
```

#### 4. GenAI service with tool-calling support

Create a GenAI service instance backed by a model that supports **tool calling** (required for MCP tool invocation and skill execution):

```bash
cf create-service genai <tools-capable-plan> factory-genai
```

> The model plan must support function/tool calling. Examples: `gpt-4o`, `claude-3-5-sonnet`, or any plan advertised with `tools` capability in the CF marketplace (`cf marketplace -e genai`).

### Push the agent

Once all prerequisites are in place:

```bash
cf push -f manifest.yml
```

The `agent_buildpack` packages the agent, loads the system prompt from `factory-agent.md`, and mounts the `.agents/skills/` directory.

---


## Agent Skills

Skills extend the agent's behaviour for domain-specific workflows. They live in `.agents/skills/` and are loaded automatically by the agent buildpack.

| Skill | Trigger | Description |
|---|---|---|
| `car-orders-matching` | "car order", "ready to paint", "next car order" | Matches a random car order against Final Assembly health. Uses `factory-orders` and `factory-info` MCPs. |
| `supplychain-motivator` | "supply chain" (anywhere in request) | Reads daily supply chain target and generates a motivational team message. |

---

## Example Prompts

```
Check manufacturing stages and current supply chain. Inspect maintenance document.
```

> Triggers `supplychain-motivator` for the supply chain status, calls `getManufacturingStages` via `factory-info`, and uses `analyze-document` via `factory-documents` to inspect the maintenance document.

```
Are we ready to paint the next car order?
```

> Triggers `car-orders-matching` — generates a random car order via `factory-orders` and checks Final Assembly health via `factory-info` to decide if painting can proceed.
