_update_title()
{}

# git current branch to prompt
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

    if [ -e $KUBE_PS1 ]; then
        PROMPT='$(kube_ps1)'$PROMPT
    fi;
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
    xterm|xterm-256color|kterm|kterm-color|screen|screen-256color)
    _update_title(){
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

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
        # Cline/RooCode で Terminal 読めないので RPROMPT 消す、$TERM_PROGRAM で分岐したらよさそうではある
        # RPROMPT="%B%{${fg[cyan]}%}(%D %*)%{${reset_color}%}%b"
        SPROMPT="%B%{${fg[yellow]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
        [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
        PROMPT="[%{${fg[magenta]}%}%B${HOST}%b%{${reset_color}%}:%{${fg[green]}%}%B%~%b%{${reset_color}%}]$%{${reset_color}%} "
        ;;
esac

case "${TERM}" in
    xterm|xterm-256color|screen|screen-256color)
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
