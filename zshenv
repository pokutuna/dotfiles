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
export SCALA_HOME=/usr/local/share/scala
export PATH=$SCALA_HOME/bin:$PATH
export SBT_OPTS="-XX:+CMSClassUnloadingEnabled -XX:PermSize=256m -XX:MaxPermSize=256m"


# node
export PATH=/usr/local/share/npm/bin:$PATH

# perl
export PERLBREW_ROOT=$HOME/perl5/perlbrew
export PERL5LIB=$HOME/perl5/lib
[ -f $HOME/perl5/perlbrew/etc/bashrc ] && source $HOME/perl5/perlbrew/etc/bashrc

# java
[ -f /usr/libexec/java_home ] && export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_BIN=$JAVA_HOME/bin
# export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'

#python
[[ -s "$HOME/.pythonbrew/etc/bashrc" ]] && source "$HOME/.pythonbrew/etc/bashrc"



## applications ##
# emacs
export PATH=/Applications/Emacs.app/Contents/MacOS:/Applications/Emacs.app/Contents/MacOS/bin:$PATH

# tex
export PATH=/usr/texbin:$PATH

# pkg-config
export PKG_CONFIG_PATH=`which pkg-config`

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
#export GIT_PROXY_COMMAND='~/bin/git-proxy.sh'

# coreutils
PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

## secret ##
[ -f ~/.zsh.d/env_secret ] && source ~/.zsh.d/env_secret


# shared-mime-info
export XDG_DATA_HOME=/usr/local/share