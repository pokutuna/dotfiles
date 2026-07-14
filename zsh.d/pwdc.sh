# カレントディレクトリを pbcopy する
# 無指定: git リポジトリ内なら repo ルートからの相対、それ以外は ~ 表記のホーム相対
# -f: フルパス, -h: 明示的にホーム相対
pwdc() {
  case "$1" in
    -f) pwd ;;
    -h) pwd | sed "s|^$HOME|~|" ;;
    *)
      if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        p=$(git rev-parse --show-prefix | sed 's:/$::')
        [ -n "$p" ] && echo "$p" || pwd | sed "s|^$HOME|~|"
      else
        pwd | sed "s|^$HOME|~|"
      fi
      ;;
  esac | tr -d '\n' | pbcopy
}
