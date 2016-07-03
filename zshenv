setopt no_global_rcs

# path
export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:/usr/bin:/bin:$PATH
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"


## basic config ##
export LANG=ja_JP.UTF-8
export SHELL=/bin/zsh
export PAGER=less
export EDITOR=nano


## for languages ##
# ruby
if type rbenv > /dev/null; then
  eval "$(rbenv init -)"
  export RSENSE_HOME=$HOME/Dropbox/etc_emacs/rsense-0.3
fi


# scala
if type brew > /dev/null; then
  export SCALA_HOME=$(brew --prefix scala)
  export PATH=$SCALA_HOME/bin:$PATH
fi

# node
if type npm > /dev/null; then
  export NODE_PATH=$NODE_PATH:$(npm prefix -g 2>/dev/null)/lib/node_modules
  export PATH=$PATH:$(npm bin -g 2>/dev/null)
fi

# perl
export PERLBREW_ROOT=$HOME/perl5/perlbrew
export PERL5LIB=$HOME/perl5/lib
if type plenv > /dev/null; then
   eval "$(plenv init -)"
   export PATH=$(plenv prefix)/bin:$PATH
fi

# java
if type /usr/libexec/java_home > /dev/null; then
  export JAVA_HOME=$(/usr/libexec/java_home)
  export JAVA_BIN=$JAVA_HOME/bin
  alias java="java -Dfile.encoding=UTF-8"
  alias javac="javac -J-Dfile.encoding=UTF-8"
fi

#python
if type $HOME/.pythonbrew/etc/bashrc > /dev/null; then
  source "$HOME/.pythonbrew/etc/bashrc"
fi

# go
if type brew > /dev/null; then
  export GOROOT=`brew --prefix go`/libexec
fi
export GOPATH=~/.gopath
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH


## applications ##
# less
export LESS='-gj10 -R --no-init --quit-if-one-screen'

# emacs
export PATH=/Applications/Emacs.app/Contents/MacOS:/Applications/Emacs.app/Contents/MacOS/bin:$PATH

# pkg-config
if type pkg-config > /dev/null; then
  export PKG_CONFIG_PATH=`which pkg-config`
  export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# aclocal
export ACLOCAL_ARGS="-I /usr/local/share/aclocal"

# android
export ANDROID_HOME=/usr/local/Cellar/android-sdk/r21
export ANDROID_SDK_ROOT=/usr/local/Cellar/android-sdk/r21
export ANDROID_BIN=${ANDROID_HOME}/bin
export ANDROID_TOOLS=${ANDROID_HOME}/tools
export PATH=$PATH:$ANDROID_BIN:$ANDROID_TOOLS

# git
if type brew > /dev/null; then
  export PATH="$(brew --prefix git)/share/git-core/contrib/diff-highlight:$PATH"
fi

# coreutils
if type brew > /dev/null; then
  PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
fi

## secret ##
[ -f ~/.zsh.d/env_secret ] && source ~/.zsh.d/env_secret

# shared-mime-info
if type brew > /dev/null; then
  export XDG_DATA_HOME=`brew --prefix shared-mime-info`/share
  export XDG_DATA_DIRS=`brew --prefix shared-mime-info`/share
fi

# docker
if type docker-machine > /dev/null; then
  eval "$(docker-machine env default)"
fi

# direnv
if type direnv > /dev/null; then
   eval "$(direnv hook zsh)"
fi

# mysqlenv https://github.com/xaicron/mysqlenv
if [[ -s "$HOME/.mysqlenv/etc/bashrc" ]]; then
  source "$HOME/.mysqlenv/etc/bashrc"
  export DBD_MYSQL_CONFIG="$(mysqlenv which mysql_config)"
  export DYLD_LIBRARY_PATH="$(mysql_config --variable=pkglibdir)":$DYLD_LIBRARY_PATH
fi
