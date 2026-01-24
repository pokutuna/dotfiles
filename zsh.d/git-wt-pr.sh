# git-wt with PR number support (zsh)
# Extends git-wt shell integration to support: git wt #123
# Requires: gh CLI, git-wt shell integration already initialized

# Save the original git function
functions[_git_wt_original]=$functions[git]

# Override git function to preprocess PR numbers
git() {
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
