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

    agp() { ag $@ | $FILTER --query "$LBUFFER" | awk -F : '{print $1}' }
    agec() { emacsclient -n $(ag $@ | $FILTER --query "$LBUFFER" | awk -F : '{print "+" $2 " " $1}') }
fi
