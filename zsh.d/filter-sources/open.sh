__FILTER_EXCLUDE_DIRS=(
  ".git"
  "node_modules"
  ".venv"
  "__pycache__"
  "target"
  "dist"
  "build"
)

_file_candidates() {
    if type fd &>/dev/null; then
        local excludes=""
        for dir in "${__FILTER_EXCLUDE_DIRS[@]}"; do
            excludes="$excludes --exclude $dir"
        done
        echo "fd --type f --max-depth 3 --color=never$excludes;FD>"
    elif git rev-parse --is-inside-work-tree &>/dev/null; then
        echo 'git ls-files;GIT>'
    else
        echo 'find . -type f -maxdepth 3 -not -path "*.git*" -not -path "*node_modules*";FIND>'
    fi
}

_dir_candidates() {
    if type fd &>/dev/null; then
        local excludes=""
        for dir in "${__FILTER_EXCLUDE_DIRS[@]}"; do
            excludes="$excludes --exclude $dir"
        done
        echo "fd --type d --max-depth 3 --color=never$excludes;FD>"
    elif git rev-parse --is-inside-work-tree &>/dev/null; then
        echo 'git ls-files | sed "s|/[^/]*$|/|" | grep ".*/$" | sort | uniq;GIT>'
    else
        echo 'find . -type d -maxdepth 3 -not -path "*.git*" -not -path "*node_modules*" | uniq;FIND>'
    fi

}

# git か find でファイルを選ぶ
f() {
    IFS=';' read command prompt < <(_file_candidates);
    eval $command | $FILTER --prompt=$prompt --query="$1"
}

# ファイルを選んでコマンドに渡す
# $ p cat
p() {
    f | xargs $@
}

# ファイルを選んで syntax highlight 付き less で開く
l() {
    IFS=';' read command prompt < <(_file_candidates);
    local file=$(eval $command | $FILTER --prompt=$prompt --query="$1")
    if [ -n "$file" ]; then
        if type bat &> /dev/null; then
            bat --style=plain --paging=always "$file"
        else
            cat "$file" | less
        fi
    fi
}

# ディレクトリを選んで移動する
d() {
    IFS=';' read command prompt < <(_dir_candidates);
    local dir=$(eval $command | $FILTER --prompt=$prompt --query="$1")
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}


__TRAVERSE_DIR_STOP_FILES=(
  "README.md" "README"
  ".git" ".hg"
  "package.json" "node_modules"
  "requirements.txt" "pyproject.toml" "Pipfile"
  "go.mod"
  "Cargo.toml"
  "Gamefile"
)
# 1つ上のルートディレクトリ的なディレクトリへ移動する
u() {
  local dir=$(dirname "$(pwd)")
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
