stopwatch_on zshrc

## setopt ##
setopt auto_cd
setopt auto_pushd
setopt correct
setopt list_packed
setopt noautoremoveslash
setopt nolistbeep
setopt auto_menu
setopt auto_param_keys
setopt auto_param_slash
setopt complete_aliases
setopt long_list_jobs

# less
export LESS='-gj10 -R --no-init'
type src-hilite-lesspipe.sh &>/dev/null &&
    alias -g cless='LESSOPEN="| src-hilite-lesspipe.sh %s" less'

# git diff-highlight
export PATH=$HOMEBREW_HOME/opt/git/share/git-core/contrib/diff-highlight:$PATH

# direnv
type direnv &>/dev/null && eval "$(direnv hook zsh)"

## alias ##
alias ls="ls --color"
alias la="ls -a"
alias lf="ls -F"
alias ll="ls -l"
alias du="du -h"
alias du1="du -d 1 ./"
alias df="df -h"

alias -g ec="emacsclient -n"

# Rust made tools
if type bat &> /dev/null; then
    alias _cat="\cat"
    alias cat="bat --style=plain"
fi

if type exa &> /dev/null; then
    alias _ls="\ls"
    alias ls="exa"
fi

# vscode
alias code='PATH="/usr/bin:$PATH" code'
pec() {
    f $1 | PATH="/usr/bin:$PATH" xargs code
}
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"


# git alias
alias g='git'
alias gs='git status '
alias ga='git add '
alias gc='git commit '
alias gd='git diff '
alias gdc='git diff --cached '
alias gf='git diff --function-context '
alias gp='git grep '
type hub &>/dev/null && eval "$(hub alias -s)" # for alias git=hub

alias dateu='date -u +"%Y-%m-%dT%H:%M:%SZ"'
alias datel='date +%Y-%m-%dT%H:%M:%S%z'

# kube
alias k='kubectl'

alias curl_header='curl -D - -s -o /dev/null'

# keybind
stty -ixon -ixoff # C-s C-q
bindkey -e
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end
bindkey "^[[1~" beginning-of-line # home gets to line head
bindkey "^[[4~" end-of-line # end gets to line end
bindkey "^[[3~" delete-char # del
bindkey "\e[Z" reverse-menu-complete # reverse menu complete


## commands
# simple finds
[ -f ~/.zsh.d/simple_find.sh ] && source ~/.zsh.d/simple_find.sh

# cd functions from hitode909
[ -f ~/.zsh.d/hitode_cd.sh ] && source ~/.zsh.d/hitode_cd.sh

[ -f ~/.zsh.d/u.sh ] && source ~/.zsh.d/u.sh

[ -f ~/.zsh.d/tmp.sh ] && source ~/.zsh.d/tmp.sh

# available command
[ -f ~/.zsh.d/available.sh ] && source ~/.zsh.d/available.sh

# filter
[ -f ~/.zsh.d/filter.sh ] && source ~/.zsh.d/filter.sh

# 単語区切り設定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " _-./;@"
zstyle ':zle:*' word-style unspecified

# zsheditor
autoload zed

# history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups     # ignore duplication command history list
setopt hist_ignore_space    # スペースから始まるコマンドはヒストリから削除
setopt hist_reduce_blanks
setopt share_history        # share command history data

## prompt setting
. ~/.zsh.d/prompt.sh

stopwatch_off zshrc

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
