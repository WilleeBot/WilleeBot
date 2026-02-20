# WilleeBot — Project Status

> Living document. Updated with every significant change.
> Last updated: 2026-02-20 (three-component structure + repo separation)

---

## What This Is

WilleeBot is a personal AI agent running on OpenClaw, accessible via Telegram.
It is not a chatbot — it is a persistent digital partner built on the I-αM-Ω framework,
designed to evolve from reactive assistant toward autonomous, symbiotic companion.

**Core philosophy: Build on the platform, not at the bottom.**
OpenClaw handles infrastructure. WilleeBot is the application layer on top.

---

## Three-Component Structure (Planned)

1. **OpenClaw (Upstream Platform)**
   - Public Git project, installed as-is
   - Managed and updated by OpenClaw maintainers
   - No local modifications

2. **WilleeBot (Implementation Overlay)**
   - This repo: persona, skills, models overlay, setup script
   - Portable across machines
   - Applies on top of a clean OpenClaw install

3. **WilleeBot Data Vault (State & Generated Content)**
   - Separate private repo or container
   - Stores memory/logs, generated content, backups, and any stateful artifacts
   - Enables backup/restore without contaminating overlay or OpenClaw

---

## Current State

| Area | Status | Notes |
|------|--------|-------|
| OpenClaw runtime | ✅ Installed | npm global, v2026.2.17 |
| Telegram integration | ✅ Working | Native OpenClaw plugin |
| Ollama local models | ✅ Running | qwen2.5, llama3.2, custom hp variants |
| GitHub repo | ✅ Live | github.com/WilleeBot/WilleeBot |
| Repo location | ✅ Separated | WilleeBot repo moved out of OpenClaw workspace |
| Data vault | ✅ Initialized | /home/willee/WilleeBot-data (memory/state) |
| Central .env secrets | ✅ Configured | ~/.openclaw/.env |
| Model config sync | ✅ Fixed | openclaw.json defaults aligned; overlay setup injects keys into models.json |
| Persona layer | 🔄 Partial | soul.md, identity.md exist, needs tuning |
| Skills | ❌ Not started | Custom skills not yet built |
| Heartbeat | ❌ Not configured | Using OpenClaw default, not customized |
| Legacy bot.py | 🗄️ To archive | Pre-OpenClaw Python bot, superseded |

---

## Active Goals

### Phase 1 — Stable Baseline (current)
- [x] Fix model config sync between openclaw.json and models.json
- [x] Separate repo from OpenClaw workspace
- [x] Initialize data vault location for stateful artifacts
- [ ] Confirm Telegram bot responding reliably with stable model
- [ ] Archive legacy bot.py to legacy/
- [ ] Restructure repo to match project layers

### Phase 2 — Persona Layer
- [ ] Tune soul.md and identity.md to I-αM-Ω framework
- [ ] Configure heartbeat cadence in openclaw.json
- [ ] Establish default agent behavior and tone

### Phase 3 — Skills & Tooling
- [ ] Define first personal skill (TBD based on daily use)
- [ ] Build skill as OpenClaw SKILL.md format
- [ ] Test and iterate

### Phase 4 — Experimental (ongoing)
- Personal tooling added as needed
- New capabilities one at a time
- Each addition documented in decisions/

---

## Stack

| Component | Role | Version |
|-----------|------|---------|
| OpenClaw | Agent runtime / AOS | 2026.2.17 |
| Ollama | Local model serving | Latest |
| qwen2.5:3b | Primary local model | q4_K_M |
| llama3.2:3b | Fallback local model | q4_K_M |
| glm-4.7:cloud | Cloud-routed via Ollama | — |
| Telegram | User interface channel | Native OpenClaw plugin |
| WSL Ubuntu | Runtime environment | Ubuntu 24 on Win10 |

---

## Repo Structure

```
WilleeBot/
├── PROJECT.md          ← this file
├── CLAUDE.md           ← Claude Code orchestration brief
├── decisions/          ← implementation decision log
├── overlay/            ← OpenClaw overlay (setup + models)
├── persona/            ← soul.md, identity.md, agents.md, I-αM-Ω configs
├── scripts/            ← utilities (backup, maintenance)
├── skills/             ← custom OpenClaw skill files
├── projects/           ← active work artifacts
├── docs/               ← framework docs, architecture references
└── legacy/             ← archived pre-OpenClaw code
```

---

## Key Constraints

- **Don't rebuild the platform** — use OpenClaw defaults for memory, heartbeat, sessions
- **Keep repos separated** — OpenClaw workspace is not the WilleeBot repo
- **One change at a time** — commit each addition, document the decision
- **Secrets never in repo** — all keys in ~/.openclaw/.env only
- **Legacy clearly separated** — bot.py and pre-OpenClaw code in legacy/ only

---

## Links

- Repo: https://github.com/WilleeBot/WilleeBot
- OpenClaw docs: https://openclaw.dev (check for current docs)
- Framework doc: docs/Agentic_OS_Architectural_Patterns.md
