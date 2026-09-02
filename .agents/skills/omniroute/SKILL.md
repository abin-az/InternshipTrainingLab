---
name: omniroute-llm-router
description: Directs Antigravity to route LLM requests, completions, model queries, and multi-model fallbacks through the local OmniRoute gateway (http://localhost:20128/v1) using the configured API key.
---

# OmniRoute Integration for Antigravity

When the user asks to query an LLM, run completions, or benchmark models through OmniRoute:

- **Endpoint**: `http://localhost:20128/v1/chat/completions`
- **Models Endpoint**: `http://localhost:20128/v1/models`
- **API Key**: `sk-035ff977e5ffac0a-1814ea-69ef2232` (or `omniroute`)
- **Default Routing Model**: `auto`

## How to Call:
Use Node.js or Python to make requests directly to `http://localhost:20128/v1/chat/completions`.
