---
description: 時限式の自動承認モードを有効化する
allowed-tools:
  - Bash(CLAUDE_SESSION_ID=* ~/.claude/bin/allow-until.sh *)
---
時限式の自動承認モードを制御します。

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>

## 実行

以下の形式でコマンドを実行:
`CLAUDE_SESSION_ID=${CLAUDE_SESSION_ID} ~/.claude/bin/allow-until.sh <subcommand>`

ARGUMENTS に応じて subcommand を決定:
- 空または "enable" → `enable 10` (10分間有効化)
- "enable N" または数字のみ → `enable N` (N分間有効化)
- "disable" または "off" → `disable`
- "status" → `status`

実行後、結果をユーザーに報告してください。
