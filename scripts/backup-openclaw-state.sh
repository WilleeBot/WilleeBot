#!/bin/bash
set -euo pipefail

SRC="$HOME/.openclaw"
DEST_ROOT="$HOME/WilleeBot-data/openclaw"
STAMP="$(date -Iseconds | tr ':' '-')"
DEST="$DEST_ROOT/$STAMP"

mkdir -p "$DEST"

copy_dir() {
  local src="$1"
  local dest="$2"
  if [ ! -d "$src" ]; then
    echo "⚠️  Missing: $src"
    return 0
  fi
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$src" "$dest"
  else
    cp -a "$src" "$dest"
  fi
  echo "✅ Backed up: $src"
}

# Allowed stateful data (no credentials/identity)
copy_dir "$SRC/memory" "$DEST"
copy_dir "$SRC/logs" "$DEST"
copy_dir "$SRC/agents/main/sessions" "$DEST"
copy_dir "$SRC/media" "$DEST"
copy_dir "$SRC/telegram" "$DEST"
copy_dir "$SRC/cron" "$DEST"

cat <<INFO > "$DEST/backup-info.txt"
Backup timestamp: $STAMP
Source: $SRC
Included: memory, logs, agents/main/sessions, media, telegram, cron
Excluded: credentials, identity, devices, exec-approvals.json, .env
INFO

echo ""
echo "Backup complete: $DEST"
