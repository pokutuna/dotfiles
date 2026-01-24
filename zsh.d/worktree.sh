# git-wt + fzf ラッパー
# git-wt (https://github.com/k1LoW/git-wt) を fzf と組み合わせて使う
#
# Usage:
#   worktree として foobar ブランチを作成して移動
#   $ wt foobar
#
#   PullRequest #123 のブランチを checkout して worktree 作成
#   $ wt #123
#
#   ブランチを一覧して fzf で選択
#   $ wt
#
#   worktree を選択して削除
#   $ wt -d

wt() {
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Error: not in a git repository" >&2
        return 1
    fi

    # 引数なし: fzf で選択
    if [ $# -eq 0 ]; then
        local selected=$(git wt __complete "" 2>/dev/null | grep -v "^:" | grep -v "^Completion" | ${FILTER:-fzf} --no-sort --reverse | cut -f1)
        [ -n "$selected" ] && git wt "$selected"
        return
    fi

    # -d: fzf で選択して削除
    if [ "$1" = "-d" ]; then
        local selected=$(git worktree list | tail -n +2 | ${FILTER:-fzf} --prompt="Remove: " | awk '{print $1}')
        [ -n "$selected" ] && git wt -d "$selected"
        return
    fi

    # #123: PR ブランチ取得
    if [[ "$1" =~ ^#([0-9]+)$ ]]; then
        local pr_num="${match[1]}"
        echo "Fetching PR #${pr_num}..."
        git fetch --quiet
        local branch=$(gh pr view "$pr_num" --json headRefName --jq '.headRefName' 2>/dev/null)
        if [ -z "$branch" ]; then
            echo "Error: failed to get branch for PR #${pr_num}" >&2
            return 1
        fi
        git wt "$branch"
        return
    fi

    # その他: git-wt にそのまま渡す
    git wt "$@"
}
