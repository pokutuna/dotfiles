---
description: 時限式の自動承認モードを有効化する
allowed-tools:
  - Bash(*/allow-until.sh *)
---
時限式の自動承認モードを制御します。

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>

## 実行

ARGUMENTS を解析して適切なコマンドを実行:

- 空または "enable" → `allow-until.sh enable 10` (10分間有効化)
- "enable N" または数字のみ → `allow-until.sh enable N` (N分間有効化)
- "disable" または "off" → `allow-until.sh disable`
- "status" → `allow-until.sh status`

スクリプトのパス: `~/.claude/bin/allow-until.sh`

実行後、結果をユーザーに報告してください。
