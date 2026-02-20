# Decision 001 — Baseline Stack: OpenClaw Native

**Date:** 2026-02-20
**Status:** Confirmed

## Decision

OpenClaw is the agent runtime. All infrastructure (memory, heartbeat, sessions,
Telegram, model routing) is handled by OpenClaw out of the box.
WilleeBot builds on top — not underneath.

## Context

Initial project used a standalone Python bot (bot.py) with python-telegram-bot,
OpenRouter, and GPT4All. This predates OpenClaw adoption.

Once OpenClaw was introduced it took over Telegram handling, model routing,
memory, and session management natively — making bot.py redundant.

## Consequences

- bot.py is archived to legacy/ — not deleted, but not active
- No custom infrastructure code to maintain
- All future capability additions are OpenClaw skills or persona configs
- OpenClaw updates may introduce breaking changes — monitor version

## Alternatives Considered

- Keep bot.py as primary, use OpenClaw as optional layer → rejected,
  creates dual Telegram handler conflict and duplicates effort
- Build custom agent framework from scratch → rejected,
  OpenClaw already solves this well
