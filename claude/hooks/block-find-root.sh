#!/bin/bash
# PreToolUse hook: block `find` starting from / or $HOME (full-disk scans).
# Checks every non-option argument of each `find` invocation, since path
# operands can appear in any order relative to find's own flags.
set -eu

input=$(cat)
command=$(printf '%s' "$input" | gojq -r '.tool_input.command // empty')

case "$command" in
	*find*) ;;
	*) exit 0 ;;
esac

home_real=$(cd "$HOME" && pwd)
blocked=0

while IFS= read -r segment; do
	[ -n "$segment" ] || continue
	set -- $segment
	if [ "${1:-}" = "find" ]; then
		shift
		for arg in "$@"; do
			case "$arg" in
				-H|-L|-P) continue ;;
				-*) break ;;
			esac
			case "$arg" in
				/|'$HOME'|'~'|"$home_real")
					blocked=1
					;;
			esac
		done
	fi
done <<< "$(printf '%s' "$command" | tr ';|&' '\n\n\n')"

if [ "$blocked" -eq 1 ]; then
	gojq -n '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "deny",
			permissionDecisionReason: "find の起点が / または $HOME になっています。スキャン範囲を絞って再実行してください。"
		}
	}'
fi
