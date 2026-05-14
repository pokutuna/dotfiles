# Pyright LSP は user-level config を持たないため、プロジェクトごとに pyrightconfig.json
# を作る必要がある。`pyright-setup-venv` でリポジトリルートに `.venv` があるとき
# 最小限の pyrightconfig.json を生成する。
#
# 既に pyrightconfig.json か pyproject.toml [tool.pyright] が存在する場合は何もしない。
# git リポジトリでない or .venv がない場合は警告して終了。

pyright-setup-venv() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$root" ]; then
    echo "pyright-setup-venv: not in a git repository" >&2
    return 1
  fi
  if [ ! -d "$root/.venv" ]; then
    echo "pyright-setup-venv: $root/.venv not found, skip" >&2
    return 1
  fi
  if [ -f "$root/pyrightconfig.json" ]; then
    echo "pyright-setup-venv: $root/pyrightconfig.json already exists, skip" >&2
    return 0
  fi
  if [ -f "$root/pyproject.toml" ] && grep -q '^\[tool.pyright\]' "$root/pyproject.toml"; then
    echo "pyright-setup-venv: [tool.pyright] already in pyproject.toml, skip" >&2
    return 0
  fi
  cat > "$root/pyrightconfig.json" <<'JSON'
{
  "venvPath": ".",
  "venv": ".venv"
}
JSON
  echo "pyright-setup-venv: wrote $root/pyrightconfig.json" >&2
}
