#!/bin/bash

LOG_DIR="$HOME/.claude/hook_outputs"
mkdir -p $LOG_DIR

HOOK_NAME="${HOOK_NAME:-unknown}"
LOG_FILE="$LOG_DIR/$(date '+%Y%m%d').log"

read -d '' input
echo "[$(date '+%Y-%m-%dT%H:%M:%S%z')] [$HOOK_NAME] $input" >> "$LOG_FILE"
