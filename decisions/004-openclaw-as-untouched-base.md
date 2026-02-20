# Decision 004 — OpenClaw as Untouched Base

**Date:** 2026-02-20
**Status:** Confirmed

## Decision

OpenClaw is treated as an upstream dependency — never modified directly.
WilleeBot is a pure overlay that enhances OpenClaw without touching its internals.

## Context

Previous approach was modifying openclaw.json, models.json, bootstrap scripts
directly. This created:
- Config conflicts on every OpenClaw update
- Bootstrap overwriting our changes on restart
- Keys mixed into OpenClaw's own config files
- No clean separation between platform and application

## New Approach

WilleeBot repo contains ONLY the enhancement layer:
- Persona files (soul.md, identity.md)
- Our model/provider preferences as a separate overlay config
- Custom skills built in OpenClaw skill format
- A setup script that applies our overlay on top of fresh OpenClaw

OpenClaw manages its own internals — sessions, memory, heartbeat, gateway.
We do not fork, patch, or modify OpenClaw files directly.

## What Gets Extracted

From the current mixed state, extract into overlay/:
- Model provider preferences (Groq, OpenRouter, Gemini)
- Telegram config structure (token reference only)
- Agent default model selection

Leave in OpenClaw's hands:
- openclaw.json internals
- Session management
- Bootstrap protocol
- Memory system

## Consequences

- OpenClaw can be updated freely without breaking WilleeBot
- WilleeBot repo is portable — works on any machine with OpenClaw installed
- Keys stay in .env only, never in repo or OpenClaw config
- Setup is reproducible: install OpenClaw → clone repo → run setup script → done
