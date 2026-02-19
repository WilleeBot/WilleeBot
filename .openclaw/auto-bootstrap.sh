#!/bin/bash
# Auto-bootstrap script for system interruption recovery
# Triggers on new session when workspace exists but no recent session continuity

WORKSPACE="/home/willee/.openclaw/workspace"
BOOTSTRAP_LOG="$WORKSPACE/.openclaw/bootstrap-state.json"

# Check if this is a continuation vs fresh session
if [ -f "$WORKSPACE/SOUL.md" ] && [ -f "$WORKSPACE/identity.txt" ]; then
    # Workspace exists, trigger bootstrap
    echo "System interruption detected. Initiating FULL CONTINUE bootstrap..."
    touch "$BOOTSTRAP_LOG"
    echo "$(date -Iseconds)" > "$BOOTSTRAP_LOG"
fi