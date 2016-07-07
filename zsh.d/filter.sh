### filter(fzf/peco)

export FILTER=$(available "peco:fzf")

if type fzf > /dev/null; then
  export FZF_DEFAULT_OPTS='--bind=ctrl-j:accept,ctrl-k:kill-line'
fi

if type $FILTER &>/dev/null; then
    # load all sources
    for f (~/.zsh.d/peco-sources/*) source "${f}"

    bindkey '^r' peco-select-history
    bindkey '^@' peco-cdr

    repo() { cd $(ghq list -p | $FILTER) }

    br() {
        local branch_name=$(git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) - %(objectname:short) - %(contents:subject) - %(authorname) (%(committerdate:relative))' | $FILTER | awk '{ print $1 }')
      [[ -n "$branch_name" ]] && git checkout $branch_name
    }

    agp() { ag $@ | $FILTER --query "$LBUFFER" | awk -F : '{print $1}' }
    agec() { emacsclient -n $(ag $@ | $FILTER --query "$LBUFFER" | awk -F : '{print "+" $2 " " $1}') }
fi
