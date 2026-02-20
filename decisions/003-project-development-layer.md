# Decision 003 — Project Development Layer

**Date:** 2026-02-20
**Status:** Confirmed

## Decision

A dedicated project development layer is introduced to steer implementation
changes over time. This layer is GitHub-based and completely separate from
OpenClaw's agent memory and session history.

## Context

As WilleeBot evolves, there needs to be a clear way to:
- Know what the current state of the project is at any point
- Understand why something was built a certain way
- Hand off context to Claude Code or future collaborators without
  replaying conversation history
- Track what changed between sessions

OpenClaw's memory system is designed for agent context — it is not
a suitable place to track project-level decisions and implementation intent.

## Components

**PROJECT.md** — The north star. Always reflects:
- Current working state
- Active goals by phase
- Known issues
- Stack overview

Updated after every significant change. First thing Claude Code reads
at the start of any session.

**decisions/** — Immutable audit trail. One file per decision:
- What was decided
- Why (context and rationale)
- What alternatives were considered
- What consequences follow

Files are never edited after creation — new decisions supersede old ones.

## Usage Pattern

Start of every development session:
1. Read PROJECT.md — understand current state
2. Read relevant decisions/ — understand why things are the way they are
3. Make changes
4. Update PROJECT.md
5. Add new decision file if a significant choice was made
6. Commit and push

## Consequences

- Project state is always recoverable from repo alone
- No dependency on conversation history or agent memory for project context
- Clean handoff to Claude Code, collaborators, or future self
- Decisions are traceable and reversible with clear rationale
