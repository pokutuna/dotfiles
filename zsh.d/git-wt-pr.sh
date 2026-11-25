# git-wt with PR number support (zsh)
# Extends git-wt shell integration to support: git wt #123
# Requires: gh CLI, git-wt

type git-wt &>/dev/null || return

eval "$(git-wt --init zsh)"
functions[_git_wt_original]=$functions[git]

git() {
    # Fall back to command git if _git_wt_original is not available
    if [[ -z "$functions[_git_wt_original]" ]]; then
        command git "$@"
        return
    fi

    if [[ "$1" == "wt" ]]; then
        local args=(wt)
        local arg branch pr_num
        for arg in "${@:2}"; do
            if [[ "$arg" =~ ^#([0-9]+)$ ]]; then
                pr_num="${match[1]}"
                branch=$(gh pr view "$pr_num" --json headRefName --jq '.headRefName' 2>/dev/null)
                if [[ -z "$branch" ]]; then
                    echo "Error: failed to resolve PR #${pr_num}" >&2
                    return 1
                fi
                if ! command git show-ref --verify --quiet "refs/heads/${branch}"; then
                    if ! command git fetch origin "${branch}" 2>/dev/null; then
                        if ! command git fetch origin "refs/pull/${pr_num}/head:${branch}"; then
                            echo "Error: failed to fetch branch for PR #${pr_num}" >&2
                            return 1
                        fi
                    fi
                fi
                args+=("$branch")
            else
                args+=("$arg")
            fi
        done
        # herdr の中では、作った worktree を wt.hook (wt-herdr-open) が workspace として開くので、
        # git-wt には cd させない。作ってあった worktree に切り替えるときは今までどおり cd する。
        # 対話シェルでは、hook がこの pane を新しい workspace に移す。移したら hook が
        # WT_HERDR_MOVED のファイルに worktree のパスを書くので、そこへ cd する。
        if [[ "${HERDR_ENV:-}" == 1 && -o interactive && -n "${HERDR_PANE_ID:-}" ]]; then
            local moved rc
            moved=$(mktemp)
            WT_HERDR_PANE=$HERDR_PANE_ID WT_HERDR_MOVED=$moved \
                GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=wt.nocd GIT_CONFIG_VALUE_0=create \
                _git_wt_original "${args[@]}"
            rc=$?
            [[ -s "$moved" ]] && cd "$(<"$moved")"
            command rm -f "$moved"
            return $rc
        elif [[ "${HERDR_ENV:-}" == 1 ]]; then
            GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=wt.nocd GIT_CONFIG_VALUE_0=create \
                _git_wt_original "${args[@]}"
        else
            _git_wt_original "${args[@]}"
        fi
    else
        _git_wt_original "$@"
    fi
}
