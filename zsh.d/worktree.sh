# git-wt fzf wrapper (zsh)
# Requires: git-wt, fzf
#
# Usage:
#   wt              fzf で worktree 選択して移動
#   wt -d           fzf で worktree 選択して削除
#   wt <options>    fzf で worktree 選択して git wt <options> <selected>

wt() {
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Error: not in a git repository" >&2
        return 1
    fi

    local selected=$(git wt | tail -n +2 | ${FILTER:-fzf} | awk '{print $(NF-1)}')
    [[ -n "$selected" ]] && git wt "$@" "$selected"
}
