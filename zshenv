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
# export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export RSENSE_HOME=$HOME/Dropbox/etc_emacs/rsense-0.3


# scala
export SCALA_HOME=$(brew --prefix scala)
export PATH=$SCALA_HOME/bin:$PATH

# node
export NODE_PATH=$NODE_PATH:$(npm prefix -g 2>/dev/null)/lib/node_modules
# newer
export PATH=$PATH:$(npm bin -g 2>/dev/null)
# old
export PATH=/usr/local/share/npm/bin:$PATH

# perl
export PERLBREW_ROOT=$HOME/perl5/perlbrew
export PERL5LIB=$HOME/perl5/lib
if which plenv > /dev/null; then
   eval "$(plenv init -)"
   export PATH=$(plenv prefix)/bin:$PATH
fi

# java
[ -f /usr/libexec/java_home ] && export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_BIN=$JAVA_HOME/bin
# export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'

#python
[[ -s "$HOME/.pythonbrew/etc/bashrc" ]] && source "$HOME/.pythonbrew/etc/bashrc"

# go
if command -v brew > /dev/null; then
  export GOROOT=`brew --prefix go`/libexec
fi
export GOPATH=~/.gopath
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH


## applications ##

# less
export LESS='-gj10 -R --no-init --quit-if-one-screen'

# emacs
export PATH=/Applications/Emacs.app/Contents/MacOS:/Applications/Emacs.app/Contents/MacOS/bin:$PATH

# tex
export PATH=/usr/texbin:$PATH

# pkg-config
export PKG_CONFIG_PATH=`which pkg-config`
export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig:$PKG_CONFIG_PATH"

# aclocal
export ACLOCAL_ARGS="-I /usr/local/share/aclocal"

# android
export ANDROID_HOME=/usr/local/Cellar/android-sdk/r21
export ANDROID_SDK_ROOT=/usr/local/Cellar/android-sdk/r21
export ANDROID_BIN=${ANDROID_HOME}/bin
export ANDROID_TOOLS=${ANDROID_HOME}/tools
export PATH=$PATH:$ANDROID_BIN:$ANDROID_TOOLS

# git
export GISTY_DIR=$HOME/gists
export PATH="$(brew --prefix git)/share/git-core/contrib/diff-highlight:$PATH"
#export GIT_PROXY_COMMAND='~/bin/git-proxy.sh'

# coreutils
which brew > /dev/null && PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

## secret ##
[ -f ~/.zsh.d/env_secret ] && source ~/.zsh.d/env_secret

# shared-mime-info
export XDG_DATA_HOME=`brew --prefix shared-mime-info`/share
export XDG_DATA_DIRS=`brew --prefix shared-mime-info`/share

# docker
export DOCKER_HOST=tcp://192.168.59.103:2376
export DOCKER_CERT_PATH=/Users/pokutuna/.boot2docker/certs/boot2docker-vm
export DOCKER_TLS_VERIFY=1

# direnv
if command -v direnv > /dev/null; then
   eval "$(direnv hook zsh)"
fi

# mysqlenv https://github.com/xaicron/mysqlenv
if [[ -s "$HOME/.mysqlenv/etc/bashrc" ]]; then
  source "$HOME/.mysqlenv/etc/bashrc"
  export DBD_MYSQL_CONFIG="$(mysqlenv which mysql_config)"
  export DYLD_LIBRARY_PATH="$(mysql_config --variable=pkglibdir)":$DYLD_LIBRARY_PATH
fi
