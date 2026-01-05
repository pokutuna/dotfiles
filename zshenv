. ~/.zsh.d/stopwatch.sh
stopwatch_on zshenv

setopt no_global_rcs

## basic path
export PATH=~/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:/usr/bin:/bin:$PATH
export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH

## basic config ##
export LANG=ja_JP.UTF-8
export PAGER=less
export EDITOR=nano
export HOMEBREW_HOME=/opt/homebrew
export SHELL=$HOMEBREW_HOME/bin/zsh

. ~/.zsh.d/completion.sh

# homebrew
export HOMEBREW_HOME=/opt/homebrew
eval "$($HOMEBREW_HOME/bin/brew shellenv)"

# mise
() {
  local mise_path=$HOMEBREW_HOME/bin/mise
  eval "$($mise_path activate zsh)"
}

export LDFLAGS="-L$HOMEBREW_HOME/lib $LDFLAGS"

# scala
export SCALA_HOME=$BREW/opt/scala
export PATH=$SCALA_HOME/bin:$PATH

# java
if [[ -e "$HOMEBREW_HOME/opt/openjdk/bin/java" ]]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk"
  export PATH="$JAVA_HOME/bin:$PATH"
#   alias java="java -Dfile.encoding=UTF-8"
#   alias javac="javac -J-Dfile.encoding=UTF-8"
fi

# go
export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH


# python
if [[ -e "$HOME/.rye/env" ]]; then
  source "$HOME/.rye/env"
fi
if [[ -e "$HOMEBREW_HOME/bin/uv" ]]; then
  source <(uv generate-shell-completion zsh)

  # https://github.com/astral-sh/uv/issues/8432#issuecomment-2453494736
  _uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files'
    else
        _uv "$@"
    fi
  }
  compdef _uv_run_mod uv
fi
if [[ -e "$HOMEBREW_HOME/bin/uvx" ]]; then
  source <(uvx --generate-shell-completion zsh)
fi

# pnpm
export PNPM_HOME="/Users/pokutuna/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# pkg-config
if type pkg-config &>/dev/null; then
    export PKG_CONFIG_PATH=`which pkg-config`
    export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig:$PKG_CONFIG_PATH"
fi


# coreutils
export PATH=$HOMEBREW_HOME/opt/coreutils/libexec/gnubin:$PATH

## secret ##
[ -f ~/.zsh.d/env_secret ] && source ~/.zsh.d/env_secret

# emacs
EMACSAPP_BIN="/Applications/Emacs.app/Contents/MacOS/bin/"
if [[ -e $EMACSAPP_BIN ]]; then
    export PATH=$EMACSAPP_BIN:$PATH
fi

# vscode
VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
if [[ -e $VSCODE_BIN ]]; then
    export PATH=$VSCODE_BIN:$PATH
fi



# 2021-12-04 switching to asdf
# mysqlenv https://github.com/xaicron/mysqlenv
# if [[ -s "$HOME/.mysqlenv/etc/bashrc" ]]; then
#     source "$HOME/.mysqlenv/etc/bashrc"
#     export DBD_MYSQL_CONFIG="$(mysqlenv which mysql_config)"
#     export DYLD_LIBRARY_PATH="$(mysql_config --variable=pkglibdir)":$DYLD_LIBRARY_PATH
#
#     MYSQL_PREFIX="$HOME/.mysqlenv/mysqls/$(head -n1 $HOME/.mysqlenv/version)"
#     export PATH=$MYSQL_PREFIX/scripts:$MYSQL_PREFIX/support-files:$PATH
# fi

# openssl with homebrew
OPENSSLDIR=$(brew --prefix openssl 2>/dev/null)
if [ -e $OPENSSLDIR ]; then
  export PATH="$OPENSSLDIR/bin:$PATH"
  export C_INCLUDE_PATH="$OPENSSLDIR/include:$C_INCLUDE_PATH"
  export LIBRARY_PATH="$OPENSSLDIR/lib:$LIBRARY_PATH"
  export LDFLAGS="-L$OPENSSLDIR/lib $LDFLAGS"
  export CPPFLAGS="-I$OPENSSLDIR/include $CPPFLAGS"
fi

# gcloud
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'; fi

# kubectl
if type kubectl &>/dev/null; then
  source <(kubectl completion zsh)

  # krew
  # https://github.com/kubernetes-sigs/krew
  export KREW_ROOT="$HOME/.krew"
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

  # kube-ps1
  # https://github.com/jonmosco/kube-ps1
  export KUBE_PS1="$HOMEBREW_HOME/opt/kube-ps1/share/kube-ps1.sh"
  if [ -e $KUBE_PS1 ]; then
    source $KUBE_PS1
    # set prompt on _update_prompt() in prompt.sh
    # PROMPT='$(kube_ps1)'$PROMPT

    # for kube-ps1 cluster name shortener
    _kube_ps1_get_cluster_short() {
      if [[ $1 =~ "^gke_" ]]; then
        # GKE {project}.{cluster}
        # this requries GNU cut (coreutils)
        echo "$1" | cut -d_ -f2,4 --output-delimiter='.'
      else
        echo "$1"
      fi
    }
    export KUBE_PS1_SYMBOL_USE_IMG=true
    export KUBE_PS1_CLUSTER_FUNCTION=_kube_ps1_get_cluster_short
  fi
fi

# psql
POSTGRESDIR=$(brew --prefix postgresql@15 2>/dev/null)
if [ -e $POSTGRESDIR ]; then
  export PATH="$POSTGRESDIR/bin:$PATH"
fi

# Coding Agents
export CLAUDE_CONFIG_DIR=$HOME/.claude
alias codex="op run --no-masking --env-file=/Users/pokutuna/.codex/env -- codex"
export PATH="/Users/pokutuna/.antigravity/antigravity/bin:$PATH"

stopwatch_off zshenv
