# git worktree を扱いやすくする関数
# .worktrees/DIR に worktree を作成していく
#
# Usage:
#   worktree として foobar ブランチを作成して移動
#   $ wt foobar
#
#   PullRequest #123 のブランチを checkout して worktree 作成
#   $ wt #123
#
#   worktree を一覧して fzf で選択
#   $ wt
#
#   worktree を選択して削除
#   $ wt -d

wt() {
    # worktree 内からでも元のリポジトリのルートを取得
    local GIT_COMMON_DIR=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: not in a git repository" >&2
        return 1
    fi
    # .git ディレクトリの親が元のリポジトリのルート
    local GIT_ROOT=$(dirname "$GIT_COMMON_DIR")

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
        local BRANCH_NAME="$1"

        # #123 形式の場合は PR のブランチ名を取得
        if [[ "$1" =~ ^#([0-9]+)$ ]]; then
            local PR_NUMBER="${match[1]}"
            echo "Fetching PR #${PR_NUMBER}..."
            git fetch --quiet
            BRANCH_NAME=$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName' 2>/dev/null)
            if [ -z "$BRANCH_NAME" ]; then
                echo "Error: failed to get branch name for PR #${PR_NUMBER}" >&2
                return 1
            fi
        fi

        local WORKTREE_NAME=$(echo "$BRANCH_NAME" | sed 's/[^a-zA-Z0-9_-]/-/g')
        local WORKTREE_PATH="$GIT_ROOT/.worktrees/$WORKTREE_NAME"
        # 既にディレクトリがあるなら移動
        if [ -d "$WORKTREE_PATH" ]; then
            echo "Error: worktree '$WORKTREE_NAME' already exists" >&2
            cd "$WORKTREE_PATH"
            return 0
        fi
        # worktree 作成
        if ! git worktree add "$WORKTREE_PATH" "$BRANCH_NAME" 2>/dev/null; then
            # ブランチが存在しない場合は新規作成
            if ! git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" 2>/dev/null; then
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
