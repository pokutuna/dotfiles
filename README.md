* setup
./setup.sh でひととおりsymlink貼ったりsubmoduleロードしたりする


* env_secret
見られたら良くないtokenとかは zsh.d/env_secret に書いて zshenv の末尾で読み込む


* emacs.d/etc
重かったりelispじゃないやつは ~/Dropbox/etc_emacs に置いて emacs.d/etc にsymlinkを貼る
setup.sh するたび etc_emacs に中身をls -lしておぼえがき


* submodule
別のgitリポジトリの内容を使いたい時は submodule でやることにした
elisp関連は emacs.d/co 以下に submodule を置く
setup.sh で init & update & checkout master するはず

[emacs.d](./emacs.d/)
