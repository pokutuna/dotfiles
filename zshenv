# path
export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:/usr/bin:/bin:$PATH


## basic config ##
export LANG=ja_JP.UTF-8
export SHELL=/bin/zsh
export PAGER=less
export EDITOR=nano


## for languages ##
# ruby
export PATH=$HOME/.rvm/bin:$PATH
export RSENSE_HOME=$HOME/.emacs.d/elisp/rsense-0.3
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.

# scala
export SCALA_HOME=/usr/local/share/scala
export PATH=$SCALA_HOME/bin:$PATH
export SBT_OPTS="-XX:+CMSClassUnloadingEnabled -XX:PermSize=256m -XX:MaxPermSize=256m"

# perl
export PERLBREW_ROOT=$HOME/perl5/perlbrew
export PERL5LIB=$HOME/perl5/lib
[ -f $HOME/perl5/perlbrew/etc/bashrc ] && source $HOME/perl5/perlbrew/etc/bashrc

# java
[ -f /usr/libexec/java_home ] && export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_BIN=$JAVA_HOME/bin

#python
[ -f $HOME/.pythonbrew/etc/bashrc ] && source $HOME/.pythonbrew/etc/bashrc



## applications ##
# tex
export PATH=/usr/texbin:$PATH

# pkg-config
export PKG_CONFIG_PATH=`which pkg-config`

# aclocal
export ACLOCAL_ARGS="-I /usr/local/share/aclocal"

# android
export ANDROID_SDK_ROOT=/usr/local/Cellar/android-sdk/r18
export ANDROID_BIN=$ANDROID_SDK_HOME/tools
export ANDROID_SDK_ROOT=$ANDROID_SDK_HOME

# git
export GISTY_DIR=$HOME/gists
#export GIT_PROXY_COMMAND='~/bin/git-proxy.sh'

# coreutils
PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

## secret ##
[ -f ~/.zsh.d/env_secret ] && source ~/.zsh.d/env_secret