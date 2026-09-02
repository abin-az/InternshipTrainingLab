# 🚀 OmniRoute AI Gateway — Local Setup & Configuration Guide

**OmniRoute** is a unified, resilient, free AI gateway that sits between your AI coding tools / applications and 352+ LLM providers. It provides automatic fallback, quota tracking, token compression, and OpenAI-compatible `/v1` endpoints with zero configuration required out of the box.

---

## 📌 Gateway Status & Quick Endpoints

- **Web Dashboard**: [http://localhost:20128](http://localhost:20128)
- **OpenAI Compatible Endpoint**: `http://localhost:20128/v1`
- **Models Endpoint**: `http://localhost:20128/v1/models`
- **Chat Completions**: `http://localhost:20128/v1/chat/completions`

---

## ⚡ Quick Start Scripts

| Script | Purpose |
| :--- | :--- |
| `.\start-omniroute.ps1` | Starts OmniRoute in the background on port `20128` |
| `.\status-omniroute.ps1` | Checks health, uptime, active providers, and catalog models |
| `.\stop-omniroute.ps1` | Stops the running OmniRoute daemon |
| `node test-client.mjs` | Sends a sample test request to the gateway |

---

## 🛠️ CLI Management Commands

You can run these commands directly from PowerShell:

```powershell
# Check doctor diagnostics
omniroute doctor

# List available models
omniroute models

# List active provider connections
omniroute providers list

# List all available providers in the 352+ catalog
omniroute providers available

# Add an API key provider (e.g. OpenAI, Anthropic, Gemini, Groq)
omniroute providers add openai --credential "sk-..."
omniroute providers add anthropic --credential "sk-ant-..."
omniroute providers add gemini --credential "AIzaSy..."
omniroute providers add groq --credential "gsk_..."

# Test connection to a provider
omniroute test opencode
omniroute test openai

# Interactive REPL chat session
omniroute repl
```

---

## 🔌 Connecting Your IDEs & Tools

OmniRoute exposes standard OpenAI-compatible endpoints that work seamlessly with any AI coding tool.

### 1. Cursor
1. Go to **Settings > Models > OpenAI API Key**.
2. Set API Base URL to: `http://localhost:20128/v1`
3. Enter any dummy key (e.g. `omniroute`).
4. Enter model: `auto` (or any model from `omniroute models`).

### 2. Claude Code
Run the built-in configuration helper:
```powershell
omniroute setup-claude
```
Or launch directly:
```powershell
omniroute launch
```

### 3. Cline / Roo Code / Continue
Run the automated config generators:
```powershell
omniroute setup-cline
omniroute setup-continue
omniroute setup-roo
```

### 4. Python / OpenAI SDK
```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:20128/v1",
    api_key="omniroute"  # dummy key when REQUIRE_API_KEY=false
)

response = client.chat.completions.create(
    model="auto",
    messages=[{"role": "user", "content": "Hello!"}]
)

print(response.choices[0].message.content)
```

---

## 🛡️ Key Features

- **Auto-Fallback**: If one provider runs out of rate limits or fails, OmniRoute seamlessly routes requests to the next available provider.
- **Zero-Config Free Tiers**: Pre-configured with free keyless backends (`opencode`, `aihorde`) so it functions immediately with no credentials.
- **Token Compression**: Built-in RTK and Caveman compression reduces token usage by 15-95%.
- **Local-First & Secure**: AES-256-GCM encryption for stored API keys at rest.
