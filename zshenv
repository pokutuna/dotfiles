# path
export PATH=/usr/local/bin:$HOME/bin:/usr/bin:/bin:$PATH


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

# perl
export PERLBREW_ROOT=$HOME/perl5/perlbrew
export PERL5LIB=$HOME/perl5/lib
source $HOME/perl5/perlbrew/etc/bashrc

# java
export JDK_HOME=/usr/lib/jvm/java-6-sun
export JAVA_BIN=/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands


## applications ##
# tex
export PATH=/usr/texbin:$PATH

# pkg-config
export PKG_CONFIG_PATH=`which pkg-config`

# aclocal
export ACLOCAL_ARGS="-I /usr/local/share/aclocal"

# android
export ANDROID_SDK_HOME="/usr/local/Cellar/android-sdk/r12"
export ANDROID_BIN=$ANDROID_SDK_HOME/tools
export ANDROID_SDK_ROOT=$ANDROID_SDK_HOME

# git
export GISTY_DIR=$HOME/gists
#export GIT_PROXY_COMMAND='~/bin/git-proxy.sh'


## secret ##
[ -f ~/.zsh/env_secret ] && source ~/.zsh/env_secret