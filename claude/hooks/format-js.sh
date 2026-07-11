#!/bin/sh
# PostToolUse hook: format edited JS/TS files.
# Prefer the repo's formatter (oxfmt) when .oxfmtrc.json exists at the repo root,
# otherwise fall back to prettier. stdin: hook JSON payload.
set -eu

file=$(gojq -r '.tool_input.file_path | select(test("[.](?:js|ts|tsx)$"))')
[ -n "${file:-}" ] || exit 0

root=$(cd "$(dirname "$file")" && git rev-parse --show-toplevel 2>/dev/null || true)
if [ -n "$root" ] && [ -f "$root/.oxfmtrc.json" ]; then
	cd "$root" && npx oxfmt --write "$file"
else
	npx prettier --write "$file"
fi
