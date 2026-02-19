#!/usr/bin/env bash
# System Interruption Recovery - Full Continue Bootstrap
# Triggers on: model change, session loss, hardware reset

BOOTSTRAP_DIR="/home/willee/.openclaw/workspace/.openclaw"
WORKSPACE="/home/willee/.openclaw/workspace"

# Mark bootstrap event
echo "$(date -Iseconds)" > "$BOOTSTRAP_DIR/last-bootstrap.txt"

# Bootstrap complete marker
echo "BOOTSTRAP_PROTOCOL: FULL_CONTINUE" > "$BOOTSTRAP_DIR/bootstrap-status.txt"

# Log protocol for pattern retrieval
cat > "$BOOTSTRAP_DIR/bootstrap-pattern.json" << 'EOF'
{
  "pattern": "System Interruption Recovery",
  "auto_trigger": true,
  "sequence": [
    "detect_interruption",
    "load_identity_layer",
    "load_calibration_data",
    "load_task_state",
    "load_technical_state",
    "present_bootstrap_summary",
    "await_steering"
  ],
  "default_mode": "FULL_CONTINUE",
  "user_override_window": 5,
  "handoff_verification": "agent confirms identity + latest state + awaits steering"
}
EOF

echo "Bootstrap protocol installed. FULL_CONTINUE mode ready."