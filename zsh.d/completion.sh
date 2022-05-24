autoload -U predict-on
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:cd:*' tag-order local-directories path-directories

fpath=(~/.zsh.d/functions /usr/local/share/zsh/site-functions $fpath)

if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
  autoload -U chpwd_recent_dirs cdr
  chpwd_functions+=chpwd_recent_dirs
  zstyle ":chpwd:*" recent-dirs-max 500
  zstyle ":chpwd:*" recent-dirs-default true
  zstyle ":completion:*" recent-dirs-insert always
fi
