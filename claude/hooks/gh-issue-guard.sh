#!/bin/bash
# PreToolUse hook: gh issue comment / create を、cwd のリポジトリが pokutuna のものでなければ ask にする。
# 許可は settings.json の permissions.allow で行い、この hook は確認に戻すだけ。
# -R / --repo や comment 直後の URL で宛先を指定したものは、中身を読まずに ask にする。
# 本文中の URL では ask にしない。
# cwd の判定は gh repo view に任せる。gh issue と同じ方法で宛先を決めるので、fork 元が宛先なら fork 元の owner になる。
input=$(cat)
[[ $input =~ gh\ issue\ (comment|create) ]] || exit 0

if ! [[ $input =~ [[:space:]](-R|--repo)[[:space:]=]|comment\ https?:// ]]; then
	owner=$(cd "$(gojq -r .cwd <<<"$input")" && gh repo view --json owner -q .owner.login 2>/dev/null)
	[[ $owner == pokutuna ]] && exit 0
fi
echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"gh issue の宛先が pokutuna のリポジトリだと確かめられない"}}'
