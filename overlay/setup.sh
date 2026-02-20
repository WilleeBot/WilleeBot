#!/bin/bash
# WilleeBot overlay setup script
# Applies WilleeBot config on top of a fresh OpenClaw install
# Run from repo root: bash overlay/setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_DIR="$HOME/.openclaw"
WORKSPACE_DIR="$OPENCLAW_DIR/workspace"

escape_sed() {
    printf '%s' "$1" | sed -e 's/[\/&|\\]/\\&/g'
}

echo "=== WilleeBot Overlay Setup ==="
echo ""

# Check OpenClaw is installed
if ! command -v openclaw &> /dev/null; then
    echo "❌ OpenClaw not found. Install with: npm install -g openclaw"
    exit 1
fi
echo "✅ OpenClaw found"

# Check .env exists
if [ ! -f "$OPENCLAW_DIR/.env" ]; then
    echo "❌ No .env found at $OPENCLAW_DIR/.env"
    echo "   Copy overlay/.env.example to ~/.openclaw/.env and fill in your keys"
    exit 1
fi
echo "✅ .env found"

# Load .env
set -a
source "$OPENCLAW_DIR/.env"
set +a

# Validate required keys
REQUIRED_KEYS=("GROQ_API_KEY" "OPENROUTER_API_KEY" "GEMINI_API_KEY" "TELEGRAM_TOKEN")
for key in "${REQUIRED_KEYS[@]}"; do
    if [ -z "${!key}" ]; then
        echo "⚠️  Missing key: $key (check your .env)"
    else
        echo "✅ $key set"
    fi
done

echo ""
echo "=== Applying persona files ==="

# Copy persona files to workspace
mkdir -p "$WORKSPACE_DIR"
cp "$SCRIPT_DIR/../persona/soul.md" "$WORKSPACE_DIR/SOUL.md" 2>/dev/null && echo "✅ soul.md" || echo "⚠️  soul.md not found"
cp "$SCRIPT_DIR/../persona/identity.md" "$WORKSPACE_DIR/IDENTITY.md" 2>/dev/null && echo "✅ identity.md" || echo "⚠️  identity.md not found"
cp "$SCRIPT_DIR/../persona/agents.md" "$WORKSPACE_DIR/AGENTS.md" 2>/dev/null && echo "✅ agents.md" || echo "⚠️  agents.md not found"

echo ""
echo "=== Applying model config ==="

# Apply models.json overlay with key substitution
MODELS_SRC="$SCRIPT_DIR/models.json"
MODELS_DEST="$OPENCLAW_DIR/agents/main/agent/models.json"
if [ -f "$MODELS_SRC" ]; then
    tmp_models="$(mktemp)"
    groq_key_escaped="$(escape_sed "$GROQ_API_KEY")"
    openrouter_key_escaped="$(escape_sed "$OPENROUTER_API_KEY")"
    gemini_key_escaped="$(escape_sed "$GEMINI_API_KEY")"
    sed -e "s|__GROQ_API_KEY__|$groq_key_escaped|g" \
        -e "s|__OPENROUTER_API_KEY__|$openrouter_key_escaped|g" \
        -e "s|__GEMINI_API_KEY__|$gemini_key_escaped|g" \
        "$MODELS_SRC" > "$tmp_models"
    cp "$tmp_models" "$MODELS_DEST" 2>/dev/null && echo "✅ models.json applied" || echo "⚠️  Failed to apply models.json"
    rm -f "$tmp_models"
else
    echo "⚠️  models.json not found in overlay/"
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "1. Start OpenClaw: openclaw start"
echo "2. Test Telegram: send a message to your bot"
echo "3. Check logs for model provider being used"
