. ~/.zsh.d/stopwatch.sh
stopwatch_on zshenv

setopt no_global_rcs

## basic path
export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:/usr/bin:/bin:$PATH
export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH

## basic config ##
export LANG=ja_JP.UTF-8
export SHELL=/usr/local/bin/zsh
export PAGER=less
export EDITOR=nano

export BREW=$(brew --prefix)

if [[ -s "$HOME/.anyenv/bin" ]]; then
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init -)"

    # ruby
    export RSENSE_HOME=$HOME/Dropbox/etc_emacs/rsense-0.3

    # use `npm bin -g` and `$(npm prefix -g 2>/dev/null)/lib/node_modules` but slow
    export NODE_PATH=$BREW/lib/node_modules
fi


# scala
export SCALA_HOME=$BREW/opt/scala
export PATH=$SCALA_HOME/bin:$PATH

# java
if type /usr/libexec/java_home &>/dev/null; then
  export JAVA_HOME=$(/usr/libexec/java_home)
  export JAVA_BIN=$JAVA_HOME/bin
  alias java="java -Dfile.encoding=UTF-8"
  alias javac="javac -J-Dfile.encoding=UTF-8"
fi

# go
export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH

# pkg-config
if type pkg-config &>/dev/null; then
    export PKG_CONFIG_PATH=`which pkg-config`
    export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# aclocal
export ACLOCAL_ARGS="-I /usr/local/share/aclocal"

# coreutils
export PATH=$BREW/opt/coreutils/libexec/gnubin:$PATH

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

# mysqlenv https://github.com/xaicron/mysqlenv
if [[ -s "$HOME/.mysqlenv/etc/bashrc" ]]; then
    source "$HOME/.mysqlenv/etc/bashrc"
    export DBD_MYSQL_CONFIG="$(mysqlenv which mysql_config)"
    export DYLD_LIBRARY_PATH="$(mysql_config --variable=pkglibdir)":$DYLD_LIBRARY_PATH

    MYSQL_PREFIX="$HOME/.mysqlenv/mysqls/$(head -n1 $HOME/.mysqlenv/version)"
    export PATH=$MYSQL_PREFIX/scripts:$MYSQL_PREFIX/support-files:$PATH
fi

# openssl with homebrew
OPENSSLDIR=$(brew --prefix openssl 2>/dev/null)
if [ -e $OPENSSLDIR ]; then
  export C_INCLUDE_PATH="$OPENSSLDIR/include:$C_INCLUDE_PATH"
  export LIBRARY_PATH="$OPENSSLDIR/lib:$LIBRARY_PATH"
fi

stopwatch_off zshenv
