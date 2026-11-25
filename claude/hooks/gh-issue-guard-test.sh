#!/bin/bash
# gh-issue-guard.sh の判定を確かめる。gh の認証と GitHub への接続が要る。
#   bash claude/hooks/gh-issue-guard-test.sh
set -u

dir=$(cd "$(dirname "$0")" && pwd)
hook=$dir/gh-issue-guard.sh
own_repo=$(cd "$dir" && git rev-parse --show-toplevel) # pokutuna/dotfiles
no_repo=$(mktemp -d) || exit 1
trap 'rm -rf "$no_repo"' EXIT

fail=0
# check <期待する判定 (ask|none)> <cwd> <コマンド>
check() {
	local out got
	out=$(gojq -n --arg c "$3" --arg cwd "$2" '{cwd: $cwd, tool_input: {command: $c}}' | bash "$hook" 2>&1)
	got=$(printf '%s' "$out" | gojq -r '.hookSpecificOutput.permissionDecision' 2>/dev/null)
	[ -n "$out" ] || got=none
	if [ "$got" = "$1" ]; then
		printf 'ok  %-4s %s\n' "$1" "$3"
	else
		printf 'NG  want=%s got=%s: %s\n    %s\n' "$1" "$got" "$3" "$out"
		fail=1
	fi
}

check none "$own_repo" 'gh issue list'
check none "$own_repo" 'gh issue comment 1 --body hello'
check none "$own_repo" 'gh issue create --title t --body b'
check none "$own_repo" 'gh issue comment 1 --body "see https://github.com/cli/cli/issues/1 and -R"'
check none "$own_repo" 'gh issue create --title "t" --body "$(cat <<'"'"'EOF'"'"'
## 概要
https://github.com/cli/cli/issues/1 を参照
EOF
)"'
check ask "$no_repo" 'gh issue create -R pokutuna/dotfiles --title t'
check ask "$own_repo" 'gh issue comment https://github.com/pokutuna/dotfiles/issues/1 --body x'

check ask "$no_repo" 'gh issue create -R cli/cli --title t'
check ask "$own_repo" 'gh issue create --repo cli/cli --title t'
check ask "$no_repo" 'gh issue comment https://github.com/cli/cli/issues/1 --body x'
check ask "$no_repo" 'gh issue create --title t'

exit $fail
