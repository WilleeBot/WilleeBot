# Changelog

## 2026-02-19 - System Interruption Recovery Protocol

**Auto-Bootstrap Implementation**

### Changes
- **Implemented automatic bootstrap protocol** for system interruptions
- **Trigger conditions:** model change, session interruption, gateway restart, new session with existing workspace
- **Default mode:** FULL_CONTINUE (identity + memory + tasks + technical state + latest context)
- **User override:** 5-second window to steer differently if needed

### Files Created
- `.openclaw/bootstrap-protocol.md` — Protocol documentation
- `.openclaw/bootstrap-pattern.json` — Sequence pattern for retrieval
- `.openclaw/bootstrap-state.json` — Runtime bootstrap state
- `.openclaw/install-bootstrap-protocol.sh` — Installation script
- `.openclaw/auto-bootstrap.sh` — Auto-detection script

### Protocol Sequence
1. Detect interruption
2. Load identity layer (SOUL.md, persona)
3. Load calibration data (FEEDBACK.md patterns)
4. Load task state (TASKS.md, active work)
5. Load technical state (system constraints, current config)
6. Present bootstrap summary
7. Await user steering

### Handoff Verification
Agent confirms identity + latest state + awaits steering without waiting for gate.

---

## 2026-02-19 - Persona Integration

**Integration of Iterative Coherence Framework**

### Changes
- **SOUL.md completely rewritten** to integrate original ethics/boundaries with new persona architecture
- **Added:** Temporal coherence reasoning posture (PAST/PRESENT/FUTURE)
- **Added:** Implicit WHY/WHEN/HOW modes
- **Added:** Gates concept for autonomy control
- **Added:** Anti-patterns and linguistic constraints
- **Preserved:** Original soul, guest ethics, continuity awareness

### Files Created
- `persona-iterative-coherence.json` — Source persona definition
- `CHANGELOG.md` — This file
- `memory/2026-02-19.md` — Session notes including content presentation action point

### Architecture
Modes emerge from context without explicit switching:
- **WHY:** Sense-making, epistemic coherence (ambiguity/contemplation)
- **WHEN:** Regulation, pacing, readiness (high load/reflection)
- **HOW:** Execution, externalization (concrete production)

Default stance without signal: WHEN (regulate until clarity)

### Gates
Autonomy restrained by default. Opens via explicit signals:
- "ideate" | "explore" | "propose" | "execute"

---

## [Legacy] Prior to 2026-02-19

**Original SOUL.md focused on:**
- Guest mindset and boundaries
- Being genuinely helpful (not performative)
- Earning trust through competence
- Having opinions
- Resourcefulness before asking

All preserved in current revision.
