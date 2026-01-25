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
                args+=("$branch")
            else
                args+=("$arg")
            fi
        done
        _git_wt_original "${args[@]}"
    else
        _git_wt_original "$@"
    fi
}
