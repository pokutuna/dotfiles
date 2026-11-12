# パスを pbcopy する
# 対象: 無指定ならカレントディレクトリ、引数があればそのパス
#       -s: fd + fzf でファイルを選択 (TAB で複数選択、引数は検索するディレクトリ)
# 書式: 無指定なら git リポジトリ内はリポジトリルートからの相対、それ以外は ~ 表記のホーム相対
#       -f: フルパス, -h: 明示的にホーム相対
# 複数のパスは改行区切りでコピーする
pwdc() {
  local -a o_full o_home o_select targets outs preview
  zparseopts -D -E f=o_full h=o_home s=o_select || return 1

  if (( $#o_select )); then
    command -v bat > /dev/null && preview=(--preview 'bat --color=always --style=plain {}')
    targets=("${(@f)$(fd --type f . "$@" | ${FILTER:-fzf} --multi "${preview[@]}")}")
    targets=(${targets:#})
    (( $#targets )) || return 1
  elif (( $# )); then
    targets=("$@")
  else
    targets=("$PWD")
  fi

  # シンボリックリンクを解決しない論理パスで比較するため、ルートも $PWD から求める
  local root cdup t abs
  cdup=$(git rev-parse --show-cdup 2> /dev/null) && root=${${:-$PWD/$cdup}:a}
  for t in "${targets[@]}"; do
    abs=${t:a}
    if (( $#o_full )); then
      outs+=("$abs")
    elif (( ! $#o_home )) && [[ -n $root && $abs == $root/* ]]; then
      outs+=("${abs#$root/}")
    else
      outs+=("${abs/#$HOME/~}")
    fi
  done

  print -rn -- "${(F)outs}" | pbcopy
}
