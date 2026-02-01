#!/bin/bash
# allow-until.sh - Claude Code の時限式自動承認の制御と判定
#
# 概要:
#   PreToolUse hook から呼び出され、Bash コマンドの自動承認を行う。
#   有効化すると指定時間の間、危険なコマンド以外は許可プロンプトなしで実行される。
#
# 設定ファイル:
#   ~/.claude-allow-until  - 有効期限の epoch を記録 (自動削除される)
#
# hook 設定 (settings.json):
#   "hooks": {
#     "PreToolUse": [{
#       "matcher": "Bash",
#       "hooks": [{ "type": "command", "command": "~/.claude/bin/allow-until.sh check" }]
#     }]
#   }
#
# Usage:
#   allow-until.sh enable [minutes]  - 自動承認を有効化 (デフォルト10分)
#   allow-until.sh disable           - 自動承認を無効化
#   allow-until.sh status            - 状態を表示
#   allow-until.sh check             - hook から呼ばれる判定モード (stdin から JSON を受け取る)

set -euo pipefail

# 設定ファイルのパス (ホームディレクトリに配置)
APPROVE_FILE="$HOME/.claude-allow-until"

# 危険なコマンドパターン (これらは常に許可を求める)
DANGEROUS_PATTERNS=(
    'rm -rf /'
    'rm -rf ~'
    'rm -rf \*'
    'sudo rm'
    'mkfs'
    'dd if='
    ':(){:|:&};:'
    'chmod -R 777 /'
    'chown -R'
    '> /dev/sd'
    'curl.*| ?bash'
    'curl.*| ?sh'
    'wget.*| ?bash'
    'wget.*| ?sh'
    'git push.*--force'
    'git push.*-f'
    'git reset --hard'
    'git clean -fd'
)

is_dangerous() {
    local cmd="$1"
    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if [[ "$cmd" =~ $pattern ]]; then
            return 0
        fi
    done
    return 1
}

enable_allow() {
    local minutes="${1:-10}"
    local until_epoch=$(($(date +%s) + minutes * 60))
    echo "$until_epoch" > "$APPROVE_FILE"
    local until_time=$(date -r "$until_epoch" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "@$until_epoch" '+%Y-%m-%d %H:%M:%S')
    echo "Auto-approve enabled until $until_time ($minutes minutes)"
}

disable_allow() {
    rm -f "$APPROVE_FILE"
    echo "Auto-approve disabled"
}

show_status() {
    if [[ ! -f "$APPROVE_FILE" ]]; then
        echo "Auto-approve: disabled"
        return
    fi

    local until_epoch=$(cat "$APPROVE_FILE")
    local now=$(date +%s)

    if [[ "$now" -lt "$until_epoch" ]]; then
        local remaining=$(( (until_epoch - now) / 60 ))
        local until_time=$(date -r "$until_epoch" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "@$until_epoch" '+%Y-%m-%d %H:%M:%S')
        echo "Auto-approve: enabled until $until_time ($remaining minutes remaining)"
    else
        echo "Auto-approve: expired"
        rm -f "$APPROVE_FILE"
    fi
}

# hook から呼ばれる判定モード
check_approval() {
    local input=$(cat)
    local command=$(echo "$input" | gojq -r '.tool_input.command // empty')

    # コマンドが空なら何もしない
    if [[ -z "$command" ]]; then
        exit 0
    fi

    # 危険なコマンドは常に許可を求める
    if is_dangerous "$command"; then
        exit 0
    fi

    # 承認ファイルがなければ通常フロー
    if [[ ! -f "$APPROVE_FILE" ]]; then
        exit 0
    fi

    local until_epoch=$(cat "$APPROVE_FILE")
    local now=$(date +%s)

    # 期限切れなら通常フロー
    if [[ "$now" -ge "$until_epoch" ]]; then
        rm -f "$APPROVE_FILE"
        exit 0
    fi

    # 自動承認
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Auto-approved (time-limited mode)"
  }
}
EOF
}

case "${1:-check}" in
    enable)
        enable_allow "${2:-10}"
        ;;
    disable)
        disable_allow
        ;;
    status)
        show_status
        ;;
    check)
        check_approval
        ;;
    *)
        echo "Usage: $0 {enable [minutes]|disable|status|check}" >&2
        exit 1
        ;;
esac
