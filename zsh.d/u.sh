__TRAVERSE_DIR_STOP_FILES=(
  "README.md" "README"
  ".git" ".hg"
  "package.json" "node_modules"
  "requirements.txt" "pyproject.toml" "Pipfile"
  "go.mod"
  "Cargo.toml"
  "Gamefile"
)


function u() {
  local dir=$(dirname $(pwd))
  while [ "$dir" != "/" ]; do
    for f in "${__TRAVERSE_DIR_STOP_FILES[@]}"; do
      if [ -e "$dir/$f" ]; then
        cd "$dir"
        return 0
      fi
    done
    dir=$(dirname "$dir")
  done
}

function d() {
  local patterns=()
  for file in "${__TRAVERSE_DIR_STOP_FILES[@]}"; do
    patterns+=("*/$file")
  done
  cd $(git ls-files "${patterns[@]}" | sed -E 's!/[^/]+$!!' | sort -u | fzf)
}
