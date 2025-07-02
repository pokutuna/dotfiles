#!/bin/bash

# 各プロジェクトの settings.local.json に含まれていて
# ~/.claude/settings.json に含まれていない permissoins を出力するスクリプト

if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
    CLAUDE_SETTINGS_FILE="$CLAUDE_CONFIG_DIR/.claude.json"
    CLAUDE_USER_SETTINGS="${CLAUDE_USER_SETTINGS:-$CLAUDE_CONFIG_DIR/settings.json}"
else
    CLAUDE_SETTINGS_FILE="$HOME/.claude/.claude.json"
    CLAUDE_USER_SETTINGS="${CLAUDE_USER_SETTINGS:-$HOME/.claude/settings.json}"
fi

# グローバル設定の allow 取得
global_allow=$(
    [[ -f "$CLAUDE_USER_SETTINGS" ]] && jq -c '.permissions.allow // []' "$CLAUDE_USER_SETTINGS" || echo '[]'
)

# ローカル設定の allow 取得
local_allow=$(
    {
        [[ -f "$CLAUDE_SETTINGS_FILE" ]] && jq -r '.projects | keys[]' "$CLAUDE_SETTINGS_FILE" | while read -r path; do
            settings_file="$path/.claude/settings.local.json"
            [[ -f "$settings_file" ]] && jq -r '.permissions.allow[]? // empty' "$settings_file"
        done
        [[ -f "$CLAUDE_SETTINGS_FILE" ]] && jq -r '.projects[].allowedTools[]? // empty' "$CLAUDE_SETTINGS_FILE"
    } | jq -R -s 'split("\n") | map(select(length > 0)) | unique'
)

# jq で差分計算
jq -n --argjson global "$global_allow" --argjson local "$local_allow" '$local - $global'
