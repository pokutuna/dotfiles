br() {
    local branch_name=$(git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) - %(objectname:short) - %(contents:subject) - %(authorname) (%(committerdate:relative))' | $FILTER --query="$1" | awk '{ print $1 }')
    [[ -n "$branch_name" ]] && git checkout $branch_name
}
