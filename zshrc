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

## alias ##
alias ls="ls --color"
alias la="ls -a"
alias lf="ls -F"
alias ll="ls -l"
alias du="du -h"
alias du1="du -d 1 ./"
alias df="df -h"

alias java="java -Dfile.encoding=UTF-8"
alias javac="javac -J-Dfile.encoding=UTF-8"

alias emacsclient="emacsclient -n"

# git alias
alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit '
alias gd='git diff '
alias gdc='git diff --cached '
alias go='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'
alias got='git '
alias get='git '
alias gp='git grep '
eval "$(hub alias -s)" # for alias git=hub

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

# 単語区切り設定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " _-./;@"
zstyle ':zle:*' word-style unspecified

# zsheditor
autoload zed

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data



## completion ##
fpath=(~/.zsh.d/functions $fpath)
autoload -U compinit
compinit -u
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
autoload -U predict-on


## commands
# cd functions from hitode909
[ -f ~/.zsh.d/hitode_cd.sh ] && source ~/.zsh.d/hitode_cd.sh

# temp from kimoto
[ -f ~/.zsh.d/kimoto_temp.sh ] && source ~/.zsh.d/kimoto_temp.sh

# glitch
[ -f ~/.zsh.d/glitch.sh ] && source ~/.zsh.d/glitch.sh


# hub completion
[ -f ~/.zsh.d/hub.zsh_completion ] && source ~/.zsh.d/hub.zsh_completion


## for git ##
_set_env_git_current_branch() {
    GIT_CURRENT_BRANCH=$( git branch 2> /dev/null | grep '^\*' | cut -b 3- )
}

_update_prompt () {
    case ${UID} in
        0)
            ;;
        *)
            if [ "`git ls-files 2>/dev/null`" ]; then
                PROMPT="[%{${fg[green]}%}%B%~%b%{${reset_color}%}:%{${fg[red]}%}%B$GIT_CURRENT_BRANCH%b%{${reset_color}%}]$%{${reset_color}%} "
                [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
                PROMPT="[%{${fg[magenta]}%}%B${HOST}%b%{${reset_color}%}:%{${fg[green]}%}%B%~%b%{${reset_color}%}:%{${fg[red]}%}%B$GIT_CURRENT_BRANCH%b%{${reset_color}%}]$%{${reset_color}%} "
            else
                PROMPT="[%{${fg[green]}%}%B%~%b%{${reset_color}%}]$%{${reset_color}%} "
                [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
                PROMPT="[%{${fg[magenta]}%}%B${HOST}%b%{${reset_color}%}:%{${fg[green]}%}%B%~%b%{${reset_color}%}]$%{${reset_color}%} "
            fi
            ;;
    esac
}

_update_rprompt()
{}

precmd()
{
    _update_title
    _set_env_git_current_branch
    _update_prompt
    _update_rprompt

    case "${TERM}" in screen)
        echo -ne "\ek$(basename $(pwd))\e\\"
    esac
}

chpwd()
{
    _set_env_git_current_branch
    _update_prompt
    _update_rprompt
}



# set terminal title including current directory
case "${TERM}" in
    xterm|xterm-256color|kterm|kterm-color|screen)
    _update_title(){
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# # ls
# case "${OSTYPE}" in
#     freebsd*|darwin*)
#     alias ls="ls -G -w"
#     ;;
#     linux*)
#     alias ls="ls --color"
#     ;;
# esac


## other ##
# report time spending more than 3 seconds
REPORTTIME=3

#open new window for tmux
function chpwd(){
  [ $TMUX ] && tmux setenv TMUXPWD_$(tmux display -p "#I") $PWD
}


## prompt ##
autoload colors
colors

case ${UID} in
    0)
        PROMPT="%{${fg[cyan]}%}%/%%%{${reset_color}%} "
        PROMPT2="%{${fg[cyan]}%}%_%%%{${reset_color}%} "
        SPROMPT="%{${fg[cyan]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
        [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
        PROMPT="%{${fg[red]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
        ;;
    *)
#        PROMPT="%B%{${fg[green]}%}%n@%m$%{${reset_color}%}%b "
#        PROMPT2="%B%{${fg[green]}%}%n@%m_$%{${reset_color}%}%b "
        PROMPT="[%{${fg[green]}%}%B%~%b%{${reset_color}%}]$%{${reset_color}%} "
        PROMPT2="[%{${fg[green]}%}%B%~%b%{${reset_color}%}]_>%{${reset_color}%} "
        RPROMPT="%B%{${fg[cyan]}%}(%D %*)%{${reset_color}%}%b"
        SPROMPT="%B%{${fg[yellow]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
        [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
        PROMPT="[%{${fg[magenta]}%}%B${HOST}%b%{${reset_color}%}:%{${fg[green]}%}%B%~%b%{${reset_color}%}]$%{${reset_color}%} "
        ;;
esac

case "${TERM}" in
    xterm|xterm-256color|screen)
        export LSCOLORS=ExFxCxdxBxegedabagacad
        export LS_COLORS='di=34;01:ln=35;01:so=32:pi=33:ex=31;01:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
        zstyle ':completion:*' list-colors 'di=34;01' 'ln=35;01' 'so=32' 'ex=31;01' 'bd=46;34' 'cd=43;34'
        ;;
    kterm-color)
        stty erase '^H'
        export LSCOLORS=exfxcxdxbxegedabagacad
        export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
        zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
        ;;
    kterm)
    stty erase '^H'
    ;;
    cons25)
    unset LANG
    export LSCOLORS=ExFxCxdxBxegedabagacad
    export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
    jfbterm-color)
    export LSCOLORS=gxFxCxdxBxegedabagacad
    export LS_COLORS='di=01;36:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;36;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
    dumb | emacs)
    PROMPT="%n@%~%(!.#.$)"
    RPROMPT=""
    PS1='%(?..[%?])%!:%~%# '
    # for tramp to not hang, need the following. cf:
    # http://www.emacswiki.org/emacs/TrampMode
    unsetopt zle
    unsetopt prompt_cr
    unsetopt prompt_subst
    unfunction precmd
    unfunction preexec
    ;;
esac
