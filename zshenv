# path
export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:/usr/bin:/bin:$PATH


## basic config ##
export LANG=ja_JP.UTF-8
export SHELL=/bin/zsh
export PAGER=less
export EDITOR=nano


## for languages ##
# ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi #rbenv
export RSENSE_HOME=$HOME/Dropbox/etc_emacs/rsense-0.3


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
# emacs
export PATH=/Applications/Emacs.app/Contents/MacOS:/Applications/Emacs.app/Contents/MacOS/bin:$PATH

# tex
export PATH=/Applications/UpTeX.app/teTeX/bin:$PATH

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