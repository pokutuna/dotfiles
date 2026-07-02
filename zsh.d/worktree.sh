# git-wt fzf wrapper (zsh)
# Requires: git-wt, fzf
#
# Usage:
#   wt                    fzf で worktree 選択して移動
#   wt -d / -D            fzf で worktree 選択して削除
#   wt -d <name> / -D <name>
#                          worktree/branch を指定して削除 (fzf を経由しない)
#   wt <name>              name が既存ブランチ/worktree なら選択せずそのまま移動
#                          name が新規なら base ブランチを fzf で選び、そこから作成
#   wt #123                git-wt-pr.sh が PR ブランチを解決 (fetch 含む) して作成/移動
#   wt --flag=value <name> git-wt のフラグはそのまま透過 ("--flag value" の分割形式は非対応)

wt() {
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Error: not in a git repository" >&2
        return 1
    fi

    local -a flags=()
    local -a positional=()
    local arg
    for arg in "$@"; do
        if [[ "$arg" == -* ]]; then
            flags+=("$arg")
        else
            positional+=("$arg")
        fi
    done

    local is_delete=0
    for arg in "${flags[@]}"; do
        [[ "$arg" == "-d" || "$arg" == "-D" || "$arg" == --delete* ]] && is_delete=1
    done

    if (( is_delete )); then
        if (( ${#positional[@]} > 0 )); then
            git wt "${flags[@]}" "${positional[@]}"
            return
        fi
        local selected=$(git wt | tail -n +2 | ${FILTER:-fzf} | awk '{print $(NF-1)}')
        [[ -n "$selected" ]] && git wt "${flags[@]}" "$selected"
        return
    fi

    if (( ${#positional[@]} == 0 )); then
        local selected=$(git wt | tail -n +2 | ${FILTER:-fzf} | awk '{print $(NF-1)}')
        [[ -n "$selected" ]] && git wt "${flags[@]}" "$selected"
        return
    fi

    # PR 番号は git-wt-pr.sh の git() ラッパーに解決を任せる
    if [[ "${positional[1]}" =~ ^#[0-9]+$ ]]; then
        git wt "${flags[@]}" "${positional[@]}"
        return
    fi

    local name="${positional[1]}"

    if command git show-ref --verify --quiet "refs/heads/${name}" ||
        command git show-ref --verify --quiet "refs/remotes/origin/${name}"; then
        git wt "${flags[@]}" "${positional[@]}"
        return
    fi

    local current_branch=$(git branch --show-current)
    local base_selected=$(
        {
            echo "HEAD (from ${current_branch:-detached})"
            git branch --sort=-committerdate --format='%(refname:short)'
        } | ${FILTER:-fzf}
    )
    [[ -z "$base_selected" ]] && return 1

    if [[ "$base_selected" == "HEAD ("* ]]; then
        git wt "${flags[@]}" "${positional[@]}"
    else
        git wt "${flags[@]}" "${positional[@]}" "$base_selected"
    fi
}
