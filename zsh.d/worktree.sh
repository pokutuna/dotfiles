# git worktree を扱いやすくする関数
# .git/wt/DIR に worktree を作成していく
#
# Usage:
#   worktree として foobar ブランチを作成して移動
#   $ wt foobar
#
#   worktree を一覧して fzf で選択
#   $ wt
#
#   worktree を選択して削除
#   $ wt -d

wt() {
    local GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: not in a git repository" >&2
        return 1
    fi

    # -d で fzf で選択して worktree 削除
    if [ "$1" = "-d" ]; then
        local worktree_list=$(git worktree list)
        if [ $(echo "$worktree_list" | wc -l) -eq 1 ]; then
            echo "Error: no worktrees to remove" >&2
            return 1
        fi

        local target=$(echo "$worktree_list" | tail -n +2 | ${FILTER:-fzf} --prompt="Select worktree to remove: " | awk '{print $1}')
        if [ -z "$target" ]; then
            echo "No worktree selected" >&2
            return 1
        fi

        cd "$GIT_ROOT"
        if ! git worktree remove "$target" 2>/dev/null; then
            echo "Error: failed to remove worktree" >&2
            return 1
        fi
        echo "Removed worktree: $target"
        return 0
    fi

    # 引数がある場合 worktree 作成
    if [ $# -gt 0 ]; then
        local WORKTREE_NAME=$(echo "$1" | sed 's/[^a-zA-Z0-9_-]/-/g')
        local WORKTREE_PATH="$GIT_ROOT/.git/wt/$WORKTREE_NAME"
        # 既にディレクトリがあるなら移動
        if [ -d "$WORKTREE_PATH" ]; then
            echo "Error: worktree '$WORKTREE_NAME' already exists" >&2
            cd "$WORKTREE_PATH"
            return 0
        fi
        # worktree 作成
        if ! git worktree add "$WORKTREE_PATH" "$1" 2>/dev/null; then
            # ブランチが存在しない場合は新規作成
            if ! git worktree add -b "$1" "$WORKTREE_PATH" 2>/dev/null; then
                echo "Error: failed to create worktree '$WORKTREE_NAME'" >&2
                return 1
            fi
        fi
        echo "Created worktree: $WORKTREE_PATH"
        cd "$WORKTREE_PATH"

    # 引数がない場合 worktree 選択 & 移動
    else
        local WORKTREE_OUTPUT=$(git worktree list)
        local WORKTREE_COUNT=$(echo "$WORKTREE_OUTPUT" | wc -l)

        if [ "$WORKTREE_COUNT" -eq 1 ]; then
            echo "Error: no worktrees exists" >&2
            return 1
        fi

        local SELECTED_LINE=$(echo "$WORKTREE_OUTPUT" | ${FILTER:-fzf} --prompt="Select worktree: ")
        if [ -n "$SELECTED_LINE" ]; then
            local SELECTED_WORKTREE=$(echo "$SELECTED_LINE" | awk '{print $1}')
            cd "$SELECTED_WORKTREE"
        else
            echo "No worktree selected" >&2
            return 1
        fi
    fi
}
