# CLAUDE.md — WilleeBot Project Orchestration Brief
> Prepared by Claude.ai (chat) for handover to Claude Code CLI
> Date: 2026-02-19 | Target: WSL Ubuntu @ ~/.openclaw/

---

## 🎯 MISSION

You are taking over full orchestration of the WilleeBot project. Your job is to:
1. Audit the current state (configs, models, sessions)
2. Fix the model/provider config mess (ROOT CAUSE FIRST)
3. Restructure as a clean, maintainable git repo
4. Push to GitHub

Work autonomously. Read files before editing. Commit after each major phase.

---

## 🔍 PHASE 0 — AUDIT (do this first, touch nothing)

Read and summarize these files before proceeding:

```
~/.openclaw/openclaw.json
~/.openclaw/openclaw.json.bak
~/.openclaw/.env
~/.openclaw/agents/main/agent/models.json
~/.openclaw/agents/main/agent/models.json.imo
~/.openclaw/agents/main/agent/auth.json
~/.openclaw/agents/main/agent/auth-profiles.json
~/.openclaw/OLD/agent.imo/models.json
~/.openclaw/OLD/agent.imo/auth.json
~/.openclaw/workspace/.openclaw/bootstrap-state.json
~/.openclaw/workspace/.openclaw/workspace-state.json
~/.openclaw/workspace/AGENTS.md
~/.openclaw/workspace/TASKS.md
~/openclaw-schema.json
```

Also read the 3 most recent session files from:
```
~/.openclaw/agents/main/sessions/*.jsonl  (not the .reset ones)
```

And the most recent memory files:
```
~/.openclaw/workspace/memory/2026-02-19-1741.md
~/.openclaw/workspace/memory/2026-02-19-1743.md
~/.openclaw/workspace/memory/2026-02-19-bootstrap.md
```

**Write your audit findings to: `~/.openclaw/workspace/AUDIT.md`**

---

## 🔥 PHASE 1 — FIX THE MODEL CONFIG MESS (root cause)

### The Problem (diagnosed from structure):

There are **multiple competing model config sources** that overwrite each other:

| File | Role | Risk |
|------|------|------|
| `~/.openclaw/agents/main/agent/models.json` | Active config | Gets overwritten by bootstrap |
| `~/.openclaw/agents/main/agent/models.json.imo` | Backup/shadow copy | May be stale, gets restored incorrectly |
| `~/.openclaw/OLD/agent.imo/models.json` | Old config | Should NEVER influence active config |
| `openclaw.json` + `openclaw.json.bak.0-.4` | Global config with 5 rotating backups | Rollback can silently restore wrong model |
| `~/.openclaw/workspace/.openclaw/bootstrap-state.json` | Bootstrap writes here | Can overwrite models on restart |
| `auto-bootstrap.sh` | Runs on session start | May be pulling from OLD/ configs |

### Fix Steps:

**Step 1.1 — Freeze the OLD directory**
```bash
# Prevent OLD configs from ever being read again
chmod -R 444 ~/.openclaw/OLD/
# Add a README so future-you knows
echo "ARCHIVED - Do not use. Frozen $(date)" > ~/.openclaw/OLD/README.md
```

**Step 1.2 — Canonicalize models.json**
- Read current `models.json` and `models.json.imo` 
- Compare them — identify which has the CORRECT/current model
- Write the canonical version to `models.json`
- Delete `models.json.imo` (it's causing confusion)
- Document the canonical model list in `AUDIT.md`

**Step 1.3 — Fix bootstrap to not overwrite models**
- Read `auto-bootstrap.sh` and `bootstrap-protocol.md`
- Find any line that writes/copies to `models.json`
- Replace with a check: "if models.json exists and is valid, skip"
- Pattern to use:
```bash
if [ ! -f "$MODELS_FILE" ] || [ ! -s "$MODELS_FILE" ]; then
    cp "$DEFAULT_MODELS" "$MODELS_FILE"
    echo "Bootstrap: models.json initialized from default"
else
    echo "Bootstrap: models.json exists, skipping (use --reset-models to override)"
fi
```

**Step 1.4 — Add a provider health check wrapper**

Create `~/.openclaw/workspace/provider-health.json`:
```json
{
  "providers": [
    {
      "name": "openrouter",
      "model": "mistralai/mistral-7b-instruct",
      "priority": 1,
      "status": "active",
      "last_checked": null,
      "degraded_until": null
    },
    {
      "name": "ollama_qwen",
      "model": "qwen2.5:3b-instruct-q4_K_M",
      "priority": 2,
      "status": "active",
      "last_checked": null,
      "degraded_until": null
    },
    {
      "name": "ollama_llama",
      "model": "llama3.2:3b-instruct-q4_K_M",
      "priority": 3,
      "status": "active",
      "last_checked": null,
      "degraded_until": null
    }
  ],
  "fallback_message": "🤖 All LLM backends temporarily unavailable. Try again in a moment.",
  "degraded_ttl_minutes": 15
}
```

**Step 1.5 — Create a provider router script**

Create `~/.openclaw/workspace/provider_router.py`:
```python
#!/usr/bin/env python3
"""
Provider Router — self-healing LLM provider selection
Reads provider-health.json, tries providers in priority order,
marks degraded on failure, auto-recovers after TTL.
"""
import json
import time
from datetime import datetime, timedelta
from pathlib import Path

HEALTH_FILE = Path(__file__).parent / "provider-health.json"

def load_health():
    with open(HEALTH_FILE) as f:
        return json.load(f)

def save_health(data):
    with open(HEALTH_FILE, "w") as f:
        json.dump(data, f, indent=2)

def get_active_provider():
    """Returns the highest-priority available provider."""
    data = load_health()
    now = datetime.utcnow()
    
    for provider in sorted(data["providers"], key=lambda x: x["priority"]):
        # Check if degraded TTL has expired → auto-recover
        if provider.get("degraded_until"):
            degraded_until = datetime.fromisoformat(provider["degraded_until"])
            if now > degraded_until:
                provider["status"] = "active"
                provider["degraded_until"] = None
                save_health(data)
        
        if provider["status"] == "active":
            return provider
    
    return None  # All degraded

def mark_degraded(provider_name):
    """Mark a provider as degraded for TTL minutes."""
    data = load_health()
    ttl = data.get("degraded_ttl_minutes", 15)
    degraded_until = (datetime.utcnow() + timedelta(minutes=ttl)).isoformat()
    
    for p in data["providers"]:
        if p["name"] == provider_name:
            p["status"] = "degraded"
            p["degraded_until"] = degraded_until
            print(f"[Router] {provider_name} marked degraded until {degraded_until}")
    
    save_health(data)

def mark_success(provider_name):
    """Update last_checked on successful call."""
    data = load_health()
    for p in data["providers"]:
        if p["name"] == provider_name:
            p["last_checked"] = datetime.utcnow().isoformat()
            p["status"] = "active"
    save_health(data)
```

---

## 📁 PHASE 2 — RESTRUCTURE AS PROPER GIT REPO

### Target Directory Structure:

```
~/.openclaw/workspace/          ← this becomes the git repo root
├── CLAUDE.md                   ← this file (keep it)
├── README.md                   ← create this
├── CHANGELOG.md                ← already exists, keep
├── .gitignore                  ← create this
├── .env.example                ← create this (no real keys)
│
├── bot/
│   ├── bot.py                  ← move from ~ root (the telegram bot)
│   ├── provider_router.py      ← new file from Phase 1
│   └── provider-health.json    ← new file from Phase 1
│
├── agents/
│   ├── config/
│   │   ├── models.json         ← canonical, single source of truth
│   │   ├── auth-profiles.json  ← sanitized (no real keys in git)
│   │   └── models.default.json ← fallback template
│   └── personas/
│       └── WilleeBot_Persona.md
│
├── bootstrap/
│   ├── auto-bootstrap.sh       ← fixed version
│   ├── bootstrap-protocol.md
│   └── install-bootstrap-protocol.sh
│
├── memory/                     ← keep as-is, add to .gitignore
│
├── DOCs/                       ← keep as-is
│
└── scripts/
    └── health-check.sh         ← create this
```

### Step 2.1 — Create .gitignore

Create `~/.openclaw/workspace/.gitignore`:
```gitignore
# Secrets
.env
*.key
auth.json
auth-profiles.json

# Model weights
*.bin
*.gguf
*.ggml
*.pt
*.pth
*.safetensors

# Session data (too large/private)
../agents/main/sessions/
memory/

# OS / cache
__pycache__/
*.pyc
.cache/
*.log
node_modules/
.npm/

# Ollama blobs
.ollama/models/blobs/

# Zone identifiers (Windows artifacts)
*.Zone.Identifier

# Backup files
*.bak
*.bak.*
*.imo
```

### Step 2.2 — Create README.md

Create a proper `README.md` covering: what WilleeBot is, stack (Telegram + OpenRouter + Ollama), setup instructions, provider priority logic, how to run.

### Step 2.3 — Create .env.example

```bash
# Copy to .env and fill in your values
TELEGRAM_TOKEN=your_telegram_bot_token_here
OPENROUTER_API_KEY=sk-or-v1-your_key_here
OLLAMA_HOST=http://localhost:11434
```

---

## 🗄️ PHASE 3 — GIT INIT & PUSH

```bash
cd ~/.openclaw/workspace

# Init
git init
git branch -M main

# Stage only what belongs in git
git add CLAUDE.md README.md CHANGELOG.md .gitignore .env.example
git add AGENTS.md BOOTSTRAP.md FEEDBACK.md HEARTBEAT.md IDEAS.md IDENTITY.md SOUL.md TASKS.md TOOLS.md USER.md
git add bot/ agents/config/models.json agents/config/models.default.json agents/personas/
git add bootstrap/ scripts/ DOCs/

# First commit
git commit -m "feat: initial structured repo — WilleeBot v0.1

- Canonical models.json (single source of truth)
- Provider router with health-check + auto-recovery
- Bootstrap fixed to not overwrite active config
- OLD/ configs archived and frozen
- .gitignore excludes secrets, sessions, model weights"

# Add remote (user provides this URL)
git remote add origin <GITHUB_REPO_URL>
git push -u origin main
```

---

## ⚠️ KNOWN ISSUES TO FLAG (don't fix silently, document them)

1. **`bot.py` has hardcoded API keys** — `TELEGRAM_TOKEN` and `OPENROUTER_API_KEY` are in plaintext in the source. Replace with `os.getenv()` only, add validation on startup, and add to `.env.example`. Never commit the real `.env`.

2. **`models.json.imo` shadow file** — This appears to be openclaw's own backup mechanism restoring a stale model. Deleting it (Phase 1.2) should fix the "wrong model persisting" bug.

3. **5x `openclaw.json.bak.0-.4` rotation** — openclaw rotates its own global config backups. If any rollback points to an old model string, it silently reverts. After fixing models.json, verify `openclaw.json` references the same model names.

4. **`auto-bootstrap.sh` runs on session start** — Check if it's registered in the systemd service (`openclaw-gateway.service`) and whether it unconditionally overwrites config. Fix in Phase 1.3.

5. **Duplicate Ollama manifests** — Both `qwen2.5:3b-instruct-q4_K_M` and `qwen2.5:3b-instruct-q4_k_m` exist (case difference). Standardize to lowercase in `provider-health.json`.

---

## ✅ DEFINITION OF DONE

- [ ] `AUDIT.md` written with findings
- [ ] `models.json` is canonical, `.imo` deleted
- [ ] `auto-bootstrap.sh` does not overwrite existing models.json
- [ ] `provider_router.py` created and importable
- [ ] `provider-health.json` created with 3 providers
- [ ] Hardcoded keys removed from `bot.py`
- [ ] `.gitignore` in place
- [ ] `README.md` written
- [ ] Clean `git log` with meaningful commits
- [ ] Pushed to GitHub

---

## 💬 COMMUNICATION

After each phase, write a brief status update to:
`~/.openclaw/workspace/memory/claude-code-progress.md`

Format: `[PHASE X - STATUS] what was done, what was found, what's next`

This lets the user and claude.ai chat track your progress.
