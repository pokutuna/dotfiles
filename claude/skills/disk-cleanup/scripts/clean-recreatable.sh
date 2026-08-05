#!/usr/bin/env bash
# リポジトリ配下の再生成可能なディレクトリを探して一覧ファイルに書き出す。
# 対象: node_modules / .venv / __pycache__ / 各種ツールキャッシュ / ビルド成果物 (dist/build/target)
#
# このスクリプトは削除しない。一覧を作るだけ。
# 実際に消すコマンドは一覧ファイルの冒頭にコメントとして書き込むので、
# 中身を確認したうえでそのコマンドを実行する。
#
# 使い方:
#   clean-recreatable.sh <out.txt> <path>...   # 候補を探索して一覧を書き出す
#   less <out.txt>                             # 中身を確認する
#   (冒頭に書かれた削除コマンドを実行する)
#
#   --older-than <days> で、最終コミットが <days> 日より古いリポジトリだけに絞る。
#   現役リポジトリの node_modules を消さずに済む。worktree も個別に判定するので、
#   親が現役でも放置された worktree は対象になる。
#
#   clean-recreatable.sh /tmp/c.txt --older-than 90 ~/ghq/github.com/myorg
set -euo pipefail

list_file=""
older_than=""
paths=()
# オプションと位置引数が混ざって渡されるので、最後まで走査する。
# 最初の非オプション引数が一覧ファイル、残りが対象パス。
while [ $# -gt 0 ]; do
  case "$1" in
    --older-than) older_than="${2:-}"; shift 2 ;;
    -h|--help)    sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --) shift; while [ $# -gt 0 ]; do paths+=("$1"); shift; done ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *)  if [ -z "$list_file" ]; then list_file="$1"; else paths+=("$1"); fi; shift ;;
  esac
done

if [ -z "$list_file" ]; then
  echo "error: 一覧ファイルの出力先を指定する" >&2
  echo "  usage: $(basename "$0") <out.txt> [--older-than <days>] <path>..." >&2
  exit 2
fi
if [ ${#paths[@]} -eq 0 ]; then
  echo "error: 対象パスを1つ以上指定する (カレントディレクトリ既定はない)" >&2
  exit 2
fi
set -- "${paths[@]}"
if [ -n "$older_than" ] && ! [ "$older_than" -gt 0 ] 2>/dev/null; then
  echo "error: --older-than には正の整数 (日数) を渡す: $older_than" >&2
  exit 2
fi

# .cache は ~/.cache 等を巻き込み得るので意図的に含めない。
patterns='^(node_modules|\.venv|__pycache__|\.mypy_cache|\.ruff_cache|\.pytest_cache|\.next|\.turbo|\.tox|\.gradle|dist|build|target)$'

# fd は既定でスマートケースなので、小文字パターンが Build/Dist にもマッチする。
# Perl の local/lib/perl5/Module/Build (モジュール実体) を誤検出したため -s で固定する。
# dist/build/target は言語エコシステムの install 先とも衝突するので、そちらは除外パターンで弾く。
EXCLUDE_RE='/(perl5|local/lib|vendor/bundle|\.terraform)/'

MAX_DIRS=${MAX_DIRS:-2000}

home_real=$(cd "$HOME" && pwd -P)
for t in "$@"; do
  [ -d "$t" ] || continue
  t_real=$(cd "$t" && pwd -P)
  if [ "$t_real" = "/" ] || [ "$t_real" = "$home_real" ]; then
    echo "error: 対象が広すぎる: $t" >&2
    echo "  ホームや / は受け付けない。リポジトリ単位・組織単位のパスを渡す。" >&2
    exit 3
  fi
done

# 最終コミットが cutoff より古いリポジトリだけを列挙する。
# 対象自身がリポジトリの場合も日付判定を通す (現役リポジトリを素通しさせない)。
stale_repos() {
  local root="$1" cutoff now
  now=$(date +%s)
  cutoff=$((now - older_than * 86400))
  {
    # .git はディレクトリ (通常) とファイル (worktree) の両方がある
    fd -H -u -t d -t f --max-depth 4 '^\.git$' "$root" 2>/dev/null
    # 対象自身がリポジトリのとき fd は .git を返さないことがあるので明示的に足す
    [ -e "$root/.git" ] && printf '%s/.git\n' "${root%/}"
  } | while IFS= read -r g; do
    local repo last
    repo=$(dirname "$g")
    # 末尾スラッシュを落として正規化する (重複排除のため)
    repo="${repo%/}"
    last=$(git -C "$repo" log -1 --format=%ct 2>/dev/null || true)
    # コミットが無い/読めないリポジトリは判定不能なので触らない
    [ -n "$last" ] || continue
    [ "$last" -lt "$cutoff" ] && printf '%s\n' "$repo"
  done | sort -u
}

targets=()
if [ -n "$older_than" ]; then
  for t in "$@"; do
    [ -d "$t" ] || { echo "skip (not a dir): $t" >&2; continue; }
    while IFS= read -r r; do
      [ -n "$r" ] && targets+=("$r")
    done < <(stale_repos "$t")
  done
  if [ ${#targets[@]} -eq 0 ]; then
    echo "no repositories older than ${older_than} days under: $*"
    exit 0
  fi
  echo "=== ${older_than} 日以上更新のないリポジトリ: ${#targets[@]} 件 ==="
  for r in "${targets[@]}"; do
    printf '  %-58s last:%s\n' "${r#"$HOME"/}" "$(git -C "$r" log -1 --format=%cs 2>/dev/null)"
  done
  echo
else
  targets=("$@")
fi

# 候補を集める。対象がネストしている場合に同じパスが二重に載るので、
# 末尾スラッシュを正規化して重複を排除する。
tmp_list=$(mktemp)
trap 'rm -f "$tmp_list"' EXIT
for t in "${targets[@]}"; do
  [ -d "$t" ] || continue
  fd -s -H -u -t d "$patterns" --prune "$t" 2>/dev/null \
    | grep -Ev "$EXCLUDE_RE" >> "$tmp_list" || true
done
sed -i '' 's|/$||' "$tmp_list" 2>/dev/null || sed -i 's|/$||' "$tmp_list"
sort -u "$tmp_list" -o "$tmp_list"

count=$(wc -l < "$tmp_list" | tr -d ' ')
if [ "$count" -eq 0 ]; then
  echo "nothing to clean."
  exit 0
fi
if [ "$count" -gt "$MAX_DIRS" ]; then
  echo "error: $count dirs が一致した (上限 $MAX_DIRS)" >&2
  echo "  対象を絞るか、意図的なら MAX_DIRS=$count を指定して再実行する。" >&2
  exit 3
fi

total=$(tr '\n' '\0' < "$tmp_list" | xargs -0 du -sk 2>/dev/null \
  | awk -F'\t' '{s+=$1} END {printf "%.1fG", s/1048576}')

# 一覧ファイルを書き出す。冒頭に削除コマンドをコメントで置く。
# コメント行があるので、消すときは grep -v '^#' で剥がしてから xargs に渡す。
{
  echo "# 再生成可能ディレクトリの削除候補"
  echo "# 生成: $(date '+%Y-%m-%d %H:%M:%S')  対象: $*"
  [ -n "$older_than" ] && echo "# 条件: 最終コミットが ${older_than} 日以上前のリポジトリのみ"
  echo "# 件数: ${count} dirs  合計: ${total}"
  echo "#"
  echo "# 中身を確認したうえで、以下を実行して削除する:"
  echo "#"
  echo "#   grep -v '^#' $list_file | tr '\\n' '\\0' | xargs -0 rm -rf"
  echo "#"
  echo "# 復旧: 各ディレクトリで uv sync / npm install などを実行する"
  echo "#"
  cat "$tmp_list"
} > "$list_file"

echo "=== 削除候補: $count dirs / $total ==="
tr '\n' '\0' < "$tmp_list" | xargs -0 du -sk 2>/dev/null | sort -rn \
  | awk -F'\t' 'NR<=40 {printf "%8.2fG  %s\n", $1/1048576, $2}'
[ "$count" -gt 40 ] && echo "(上位40件のみ表示)"

cat <<EOS

一覧: $list_file
中身を確認してから削除する:
  grep -v '^#' $list_file | tr '\\n' '\\0' | xargs -0 rm -rf
EOS
