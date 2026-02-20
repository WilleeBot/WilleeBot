# Decision 002 — Repo Structure and Project Organisation

**Date:** 2026-02-20
**Status:** Confirmed

## Decision

GitHub repo (WilleeBot/WilleeBot) is the single source of truth for
project structure, decisions, and implementation direction.

Agent memory and session history (managed by OpenClaw) are kept
strictly separate from project development tracking.

## Context

Before this decision, the project had:
- No stable repo structure
- Config files scattered across ~/.openclaw/ with no version control
- No way to track why decisions were made
- Agent session memory mixed with implementation intent

This made it impossible to hand off context to Claude Code or
revisit decisions without digging through session logs.

## Structure Adopted

```
WilleeBot/
├── PROJECT.md          ← current state and active goals
├── CLAUDE.md           ← Claude Code orchestration brief
├── decisions/          ← implementation decision log (this folder)
├── persona/            ← I-αM-Ω configs, soul, identity
├── skills/             ← custom OpenClaw skills
├── projects/           ← active work artifacts
├── docs/               ← reference docs and framework papers
└── legacy/             ← archived code, not active
```

## Two Separate Memory Systems

| System | What it tracks | Where |
|--------|---------------|-------|
| OpenClaw memory | Agent conversations, tasks, context | ~/.openclaw/memory/ |
| Project decisions | Implementation choices, rationale | decisions/ in repo |

Never mix these. OpenClaw memory is ephemeral and session-scoped.
Project decisions are permanent and version-controlled.

## Consequences

- Every significant implementation change gets a decision file
- PROJECT.md is updated to reflect current state after each phase
- Claude Code reads PROJECT.md at session start for full context
- No need to replay conversation history to understand project state
