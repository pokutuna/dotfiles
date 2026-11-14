#!/bin/bash
# rm-guard.sh の判定を、使い捨てのリポジトリに対して確かめる。
#   bash claude/hooks/rm-guard-test.sh
# shellcheck disable=SC2016 # 判定させるコマンドは展開せずに渡す
set -u

hook=$(cd "$(dirname "$0")" && pwd)/rm-guard.sh

# /tmp と $TMPDIR の中は一時ディレクトリとして止められないので、その外に作る
base=${XDG_CACHE_HOME:-$HOME/.cache}
mkdir -p "$base"
repo=$(mktemp -d "$base/rm-guard-test.XXXXXX") || exit 1
repo=$(cd "$repo" && pwd -P)
trap 'rm -rf "$repo"' EXIT

(
	cd "$repo" || exit 1
	git init -q
	mkdir -p a b tmp 'app/[id]' .trash/old
	for f in clean.txt dirty.txt tmp/fixture.json; do echo v1 >"$f"; done
	git add -A
	git add -f tmp/fixture.json # グローバルの gitignore が tmp/ を無視していても追跡する
	git -c user.name=t -c user.email=t@example.com commit -qm init
	echo v2 >dirty.txt
	echo v2 >tmp/fixture.json
	for f in untracked.txt a/same.txt b/same.txt tmp/scratch.txt 'app/[id]/page.tsx' .trash/old/x; do
		echo v1 >"$f"
	done
) || exit 1

fail=0
# check <期待する判定> <コマンド> [理由に一致するはずの正規表現]
check() {
	local out decision reason
	out=$(gojq -n --arg c "$2" --arg cwd "$repo" '{cwd: $cwd, tool_input: {command: $c}}' |
		/bin/bash "$hook" 2>&1) || out="(exit $?) $out"
	decision=$(printf '%s' "$out" | gojq -r '.hookSpecificOutput.permissionDecision' 2>/dev/null)
	reason=$(printf '%s' "$out" | gojq -r '.hookSpecificOutput.permissionDecisionReason' 2>/dev/null)
	[ -n "$out" ] || decision=none
	if [ "$decision" != "$1" ]; then
		fail=1
		printf 'NG  %s: expected %s, got %s\n    %s\n' "$2" "$1" "${decision:-?}" "$out"
	elif [ -n "${3:-}" ] && ! printf '%s' "$reason" | grep -Eq -- "$3"; then
		fail=1
		printf 'NG  %s: reason does not match %s\n    %s\n' "$2" "$3" "$reason"
	fi
}

# 止めない。何も返さず、権限ルールと auto mode による通常の判定に任せる
check none 'ls'
check none 'rm /tmp/a'
check none 'rm -rf /tmp/a /tmp/b 2>/dev/null'
check none 'rm -f /tmp/a 2> /dev/null'
check none 'rm /tmp/a > clean.txt'
check none 'rm /tmp/a >clean.txt'
check none 'rm clean.txt'
check none 'rm no-such-file'
check none 'rm tmp/scratch.txt'
check none 'rm tmp/s*'
check none "rm '/tmp/[id].txt' 'no-such~'"
check none 'rm "tmp/scratch.txt"'
check none 'cd /tmp && rm -rf work'
check none 'rm /tmp/a && echo done'
check none 'X=`true`; rm /tmp/a'
check none '\rm -rf a'

# Claude が書き直すか退避できる
check deny 'rm untracked.txt' '\.trash/'
check deny 'rm dirty.txt' '\.trash/'
check deny 'rm -rf tmp' '\.trash/'
check deny 'rm a/same.txt b/same.txt' '\.trash/[0-9-]+/b/$'
check deny 'rm *.txt'
check deny 'rm $DIR/a'
check deny 'rm "$DIR/a"'
check deny 'rm ^keep'
check deny 'rm clean.txt -f'
check deny 'cd $DIR && rm a'
check deny 'find . -name x -exec rm {} +'
check deny 'rm -r .trash/old'
check deny "rm 'app/[id]/page.tsx'" '\.trash/[0-9-]+/app/'
check deny 'rm "app/[id]/page.tsx"' '\.trash/'
check deny 'rm app/[id]/page.tsx' '引用符'
check deny 'rm "app/[id]/$x"'
check deny $'cat >/tmp/x.sh <<\'EOF\'\nrm -rf "$workdir"\nEOF' 'Write'

# 人に確認する
check ask 'rm untracked.txt>/dev/null'
check ask 'rm <->'
check ask 'rm -rf .git'
check ask 'unlink .git/config'
check ask 'rm "/tmp/a b"'
check ask 'sudo rm /tmp/a'
check ask 'rm -rf .'
check ask 'rm -rf /tmp'

[ $fail -eq 0 ] && echo ok
exit $fail
