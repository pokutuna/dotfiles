#!/bin/bash
# allow-until.sh - Claude Code の時限式自動承認の制御と判定
#
# 概要:
#   PreToolUse hook から呼び出され、Bash コマンドの自動承認を行う。
#   有効化すると指定時間の間、危険なコマンド以外は許可プロンプトなしで実行される。
#
# 設定ファイル:
#   ~/.claude-allow-until.conf  - git config 形式でセッションごとの有効期限を記録
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

# 設定ファイルのパス (git config 形式)
CONFIG_FILE="$HOME/.claude-allow-until.conf"

# セッションIDのチェック
require_session_id() {
    if [[ -z "${CLAUDE_SESSION_ID:-}" ]]; then
        echo "Error: CLAUDE_SESSION_ID is not set" >&2
        exit 1
    fi
}

# セッションIDでセクションを分離
get_section() {
    echo "session.${CLAUDE_SESSION_ID}"
}

# 危険なコマンドパターン (これらは常に許可を求める)
DANGEROUS_PATTERNS=(
    # sudo は全て禁止
    'sudo'
    # ファイル削除系 (様々な書き方に対応)
    'rm -rf /*'
    'rm -rf /[^.]'      # /. 以外の / から始まるパス
    'rm -rf [~$]'       # ~ または $HOME など
    'rm -rf \.'         # カレントディレクトリ
    'rm -rf \*'
    # ファイルシステム破壊
    'mkfs'
    'dd if='
    'truncate'
    'shred'
    # fork bomb
    ':(){:|:&};:'
    # パーミッション変更
    'chmod -R 777 /'
    'chown -R'
    # デバイス書き込み
    '> /dev/sd'
    # リモートコード実行
    'curl.*\| ?bash'
    'curl.*\| ?sh'
    'wget.*\| ?bash'
    'wget.*\| ?sh'
    'bash.*<\(.*curl'
    'bash.*<\(.*wget'
    'sh.*<\(.*curl'
    'sh.*<\(.*wget'
    # git 危険操作
    'git push.*--force'
    'git push.*-f[^i]'  # -f but not -fixup
    'git reset --hard'
    'git clean -fd'
    'git checkout \.'
    'git restore \.'
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
    require_session_id
    local minutes="${1:-10}"
    local until_epoch=$(($(date +%s) + minutes * 60))
    git config -f "$CONFIG_FILE" "$(get_section).until" "$until_epoch"
    local until_time=$(date -r "$until_epoch" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "@$until_epoch" '+%Y-%m-%d %H:%M:%S')
    echo "Auto-approve enabled until $until_time ($minutes minutes)"
}

disable_allow() {
    require_session_id
    git config -f "$CONFIG_FILE" --remove-section "$(get_section)" 2>/dev/null || true
    echo "Auto-approve disabled"
}

show_status() {
    require_session_id
    local until_epoch=$(git config -f "$CONFIG_FILE" "$(get_section).until" 2>/dev/null || echo 0)

    if [[ "$until_epoch" -eq 0 ]]; then
        echo "Auto-approve: disabled"
        return
    fi

    local now=$(date +%s)

    if [[ "$now" -lt "$until_epoch" ]]; then
        local remaining=$(( (until_epoch - now) / 60 ))
        local until_time=$(date -r "$until_epoch" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "@$until_epoch" '+%Y-%m-%d %H:%M:%S')
        echo "Auto-approve: enabled until $until_time ($remaining minutes remaining)"
    else
        echo "Auto-approve: expired"
        git config -f "$CONFIG_FILE" --remove-section "$(get_section)" 2>/dev/null || true
    fi
}

# hook から呼ばれる判定モード
check_approval() {
    local input=$(cat)

    # stdin の JSON から session_id を取得
    export CLAUDE_SESSION_ID=$(echo "$input" | gojq -r '.session_id // empty')
    if [[ -z "$CLAUDE_SESSION_ID" ]]; then
        exit 0  # session_id がなければ通常フロー
    fi

    local command=$(echo "$input" | gojq -r '.tool_input.command // empty')

    # コマンドが空なら何もしない
    if [[ -z "$command" ]]; then
        exit 0
    fi

    # 危険なコマンドは常に許可を求める
    if is_dangerous "$command"; then
        exit 0
    fi

    local until_epoch=$(git config -f "$CONFIG_FILE" "$(get_section).until" 2>/dev/null || echo 0)

    # 設定がなければ通常フロー
    if [[ "$until_epoch" -eq 0 ]]; then
        exit 0
    fi

    local now=$(date +%s)

    # 期限切れなら通常フロー
    if [[ "$now" -ge "$until_epoch" ]]; then
        git config -f "$CONFIG_FILE" --remove-section "$(get_section)" 2>/dev/null || true
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
