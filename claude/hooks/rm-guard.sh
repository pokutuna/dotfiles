#!/bin/bash
# PreToolUse hook: rm の削除対象を調べ、消すと取り返しがつかないものを止める。
# 設計と、判定できる範囲の説明は docs/rm-guard.md にある。
#
# 返す結果は次のどれか。
#   なし  : rm を含まない。または rm の対象がすべて取り返しがつく。
#           allow は返さず、権限ルールと auto mode による通常の判定に任せる
#   deny  : 取り返しがつくと確かめられないが、Claude が書き直しや退避で対処できる
#   ask   : sudo 経由、退避先がない、リダイレクトや引用符つきの記号を含むなど、
#           Claude では対処できないか、この簡易な読み方では判定できない
#
# 取り返しがつくとみなすのは、一時ディレクトリ (/tmp, $TMPDIR, リポジトリ内の
# tmp/temp/.tmp/.temp) の中、存在しないパス、git で追跡済みかつ未変更のファイル。
#
# テストは rm-guard-test.sh にある。
#
# gojq がない、入力を読めない、5 秒で終わらないなど判定できないときは非 0 で終了する。
# settings.json 側で非 0 終了を ask に変換している。
set -u
set -f # 語分割でグロブを展開しない

input=$(cat) || exit 1

# rm 系の語を含まなければ gojq を起動せずに終わる (すべての Bash 呼び出しが通る経路)
rm_word_re='(^|[^[:alnum:]_-])(rm|rmdir|unlink)([^[:alnum:]_-]|$)'
# 入力は JSON なので、改行やタブは \n、\t と書かれている。直後の rm も拾う
json_rm_word_re='(^|[^[:alnum:]_-]|\\[nrt])(rm|rmdir|unlink)([^[:alnum:]_-]|$)'
[[ $input =~ $json_rm_word_re ]] || exit 0

fields=$(printf '%s' "$input" | gojq -r '(.cwd // ""), (.tool_input.command // "")') || exit 1
cwd=${fields%%$'\n'*}
command=${fields#"$cwd"}
command=${command#$'\n'}
[[ $command =~ $rm_word_re ]] || exit 0

# 5 秒で判定が終わらなければ自分を止める (対象が多い、巨大なリポジトリなど)。
# 非 0 終了になり、settings.json 側で ask に変わる
(sleep 5 && kill $$) >/dev/null 2>&1 &
watchdog=$!
trap 'kill $watchdog 2>/dev/null' EXIT

decide() {
	kill $watchdog 2>/dev/null
	# shellcheck disable=SC2016 # $d, $r は gojq の変数
	gojq -n --arg d "$1" --arg r "rm-guard: $2" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: $d,
			permissionDecisionReason: $r
		}
	}' || exit 1
	exit 0
}

# シェルが展開・解釈する文字 (グロブ、変数、引用符、エスケープ、~、リダイレクト、
# コメント、zsh のグロブ ^ と <->) を含むか。語に現れうる ASCII の記号のうち、
# ここにないのは % + , - . / : = @ _ だけである。
# zsh は語頭の = をコマンドのパスに展開する (=python3 など) ので、これも含める
special_re='[][$*?{}~"'"'"'\\`!#<>^[:cntrl:]]'
is_special() {
	[[ $1 =~ $special_re || $1 == =* ]]
}

# 語全体を囲む引用符を外し、先頭の ~ を展開する。引用符の内側に特殊文字が
# 残っていれば is_special で拒否される
normalize() {
	# shellcheck disable=SC2088 # ~ を文字どおりに照合する
	case "$1" in
	'~' | '~/'*) printf '%s\n' "$HOME${1#'~'}" ;;
	\"*\" | \'*\') printf '%s\n' "${1:1:${#1}-2}" ;;
	*) printf '%s\n' "$1" ;;
	esac
}

# ディレクトリの実パス。存在しなければ失敗する
canon() {
	(cd "$1" 2>/dev/null && pwd -P)
}

temp_roots=()
for d in /tmp "${TMPDIR:-}"; do
	[ -n "$d" ] && r=$(canon "$d") && temp_roots+=("$r")
done

# システムの一時ディレクトリの中か (一時ディレクトリそのものは含まない)
under_temp() {
	local root
	for root in ${temp_roots[@]+"${temp_roots[@]}"}; do
		case "$1" in "$root"/*) return 0 ;; esac
	done
	return 1
}

# 削除対象の実パスを返す。シンボリックリンク自体を消す場合に備えて親だけ解決する。
# 親が存在しなければ空を返す (対象も存在しない)。
resolve() {
	local path=$1 parent
	case "$path" in /*) ;; *) path=$2/$path ;; esac
	case "$path" in
	*/ | */. | */..) canon "$path" ;;
	*)
		parent=$(canon "${path%/*}/") || return 0
		printf '%s/%s\n' "${parent%/}" "${path##*/}"
		;;
	esac
}

# ディレクトリを含む git リポジトリのルートの実パス。リポジトリ外なら失敗する
git_root() {
	local root
	root=$(git -C "${1:-/}" rev-parse --show-toplevel 2>/dev/null) || return 1
	canon "$root"
}

# リポジトリ内の一時ディレクトリの中か、一時ディレクトリそのものか。
# path の最後の要素がグロブなら、それに一致しうる追跡中のファイルがないことを確かめる
temp_name_re='(^|/)\.?te?mp(/|$)'
in_repo_temp() {
	local path=$1 root=$2 rel out
	case "$path" in "$root"/*) ;; *) return 1 ;; esac
	rel=${path#"$root"/}
	case "$rel" in */*) [[ ${rel%/*} =~ $temp_name_re ]] ;; *) false ;; esac ||
		{ [[ ${rel##*/} =~ ^\.?te?mp$ ]] && [ -d "$path" ] && [ ! -L "$path" ]; } ||
		return 1
	out=$(git -C "$root" ls-files -- "$rel") || return 1
	[ -z "$out" ]
}

tracked_and_clean() {
	local path=$1 root=$2 rel out
	case "$path" in "$root"/*) ;; *) return 1 ;; esac
	rel=${path#"$root"/}
	git -C "$root" --literal-pathspecs ls-files --error-unmatch -- "$rel" >/dev/null 2>&1 || return 1
	out=$(git -C "$root" --literal-pathspecs status --porcelain --ignored --untracked-files=all -- "$rel") || return 1
	[ -z "$out" ]
}

# グロブが最後の要素だけにあり、親ディレクトリが一時ディレクトリなら成功する。
# 展開結果は親ディレクトリの直下に限られるので、展開せずに判定できる
glob_in_temp() {
	local arg=$1 base=$2 dir name parent root
	case "$arg" in */*) dir=${arg%/*} name=${arg##*/} ;; *) dir=. name=$arg ;; esac
	# グロブ文字は * と ? だけ。. で始まる名前は .* が .. に一致しうるので除く
	[[ $name =~ ^[A-Za-z0-9_+,@%:*?-][A-Za-z0-9._+,@%:=*?-]*$ ]] || return 1
	[ -n "$dir" ] || dir=/
	is_special "$dir" && return 1
	case "$dir" in /*) ;; *) dir=$base/$dir ;; esac
	# 親が存在しなければ何にも一致しない
	parent=$(canon "$dir") || return 0
	under_temp "$parent/x" && return 0
	root=$(git_root "$parent") && in_repo_temp "${parent%/}/$name" "$root"
}

# 判定の分類。番号は judge_target の終了コードと problems の添字を兼ねる。
# 7 以降は Claude では対処できないので ask にする
labels=(
	[1]="cannot determine targets (glob, variable, quotes, etc.)"
	[2]="cd destination unknown, so relative paths cannot be resolved"
	[3]="word starting with - after targets"
	[4]="rm run via another command"
	[5]="not recoverable from git"
	[6]="contents of .trash/"
	[7]="not recoverable from git and nowhere to move it (outside a repo, the repo itself, or .git)"
	[8]="via sudo / doas"
	[9]="cannot parse: word joined with a redirect, or quoted whitespace"
)
hints=(
	[1]="Rewrite with expanded paths listed explicitly. Quote names containing special characters. If rm is inside a string or heredoc, write the file with the Write tool"
	[2]="Use absolute paths"
	[3]="Put options before targets. Write names starting with - as ./-x"
	[4]="Use a plain rm with the paths listed"
	[6]="Continue without deleting. A human will clean it up"
)
first_ask=7
problems=()
add_problem() {
	problems[$1]="${problems[$1]:+${problems[$1]}, }$2"
}

# .trash/ に退避させる対象の実パスと、そのリポジトリのルート
trash_paths=()
trash_roots=()

sq_literal_re="^'[^']*'\$"
dq_literal_re='^"[^"$`\\]*"$'

# 取り返しがつけば 0、そうでなければ labels の番号を返す
judge_target() {
	local arg path root
	arg=$(normalize "$1")
	[ -n "$arg" ] || return 0
	case "$arg" in /*) ;; *) [ -n "$2" ] || return 2 ;; esac
	# 語全体が引用符で囲まれ、中にシェルが展開するものがなければ、中身がそのまま
	# 対象の名前である ('app/[id]/page.tsx' など)
	if ! [[ $1 =~ $sq_literal_re || $1 =~ $dq_literal_re ]] && is_special "$arg"; then
		glob_in_temp "$arg" "$2" && return 0
		# 変数やコマンド置換は Claude が展開済みのパスに書き直せる。空白を含んで
		# 割れた語は引用符を解釈しないと読めないので、人に確認する
		case "$1" in
		*[\$\`]*) return 1 ;;
		*[\"\']*) return 9 ;;
		esac
		return 1
	fi
	path=$(resolve "$arg" "$2")
	[ -n "$path" ] || return 0
	under_temp "$path" && return 0
	[ -e "$path" ] || [ -L "$path" ] || return 0
	# 入れ子のリポジトリを消す場合に備えて、親ディレクトリのリポジトリで判定する
	if root=$(git_root "${path%/*}"); then
		in_repo_temp "$path" "$root" && return 0
		tracked_and_clean "$path" "$root" && return 0
		case "$path" in
		"$root"/.trash | "$root"/.trash/*) return 6 ;;
		# .git を .trash/ へ動かすとリポジトリが壊れるので、退避を案内しない
		"$root"/.git) return 7 ;;
		"$root"/*)
			trash_paths+=("$path")
			trash_roots+=("$root")
			return 5
			;;
		esac
	fi
	return 7
}

# cd 先を解決する。CDPATH があると相対パスの cd 先が変わるので解決しない
cd_dest() {
	local dest
	dest=$(normalize "$1")
	is_special "$dest" && return 1
	case "$dest" in
	/*) ;;
	*)
		[ -z "${CDPATH:-}" ] && [ -n "$2" ] || return 1
		dest=$2/$dest
		;;
	esac
	canon "$dest"
}

# cd を順に追えるのは && だけでつながったコマンドに限る。括弧、パイプ、||、;、&、
# 改行を含むコマンドで cd や pushd を使っていたら、作業ディレクトリは原則不明とする。
# ただし先頭の cd が &&、;、改行で続くなら、次に cd、pushd、popd が現れるまでの
# 区間はその移動先で実行される (存在を確かめたディレクトリなので cd は失敗しない)。
# ループや関数定義があると実行順が文字の並びと変わるので、そこで区間を打ち切る
track_cd=1
lead_scope=0
chain=${command//&&/}
chain_re='[;|&()]'
cd_word_re='(^|[^[:alnum:]_-])(cd|pushd|popd)([^[:alnum:]_-]|$)'
lead_cd_re='^[[:space:]]*cd[[:space:]]+([^[:space:];&|()]+)[[:space:]]*(&&|;|'$'\n'')(.*)$'
reorder_re='(^|[^[:alnum:]_-])(for|while|until|select|function)([^[:alnum:]_-]|$)'
if [[ $chain =~ $chain_re || $chain == *$'\n'* ]]; then
	track_cd=0
	if [[ $command =~ $cd_word_re ]]; then
		dest=
		if [[ $command =~ $lead_cd_re ]]; then
			dest=${BASH_REMATCH[1]}
			if [[ ${BASH_REMATCH[3]} =~ $cd_word_re ]]; then
				# 関数定義 f() があると、後で呼ばれる本体の位置から実行順を決められない
				case "$command" in *'()'*) dest= ;; *) lead_scope=1 ;; esac
			fi
		fi
		if [ -n "$dest" ]; then
			cwd=$(cd_dest "$dest" "$cwd")
		else
			cwd=
		fi
	fi
fi

redirect_re='^[0-9]*(>>?|<)[^<>]*$'
bare_redirect_re='^[0-9]*(>>?|<)$'

# 語分割は意図したもの (set -f でグロブは展開しない)
# shellcheck disable=SC2206
{
	nl=$'\n'
	IFS=$nl
	segments=(${command//[;|&()]/$nl})
	IFS=$' \t\n'
}

for segment in ${segments[@]+"${segments[@]}"}; do
	# 先頭の cd の区間は、最初の区切り (先頭の cd 自身) より後で cd やループが現れたら終わる
	if [ $lead_scope -eq 2 ] && [[ $segment =~ $cd_word_re || $segment =~ $reorder_re ]]; then
		cwd=
		lead_scope=0
	fi
	[ $lead_scope -eq 1 ] && lead_scope=2

	# shellcheck disable=SC2206
	words=($segment)

	# 先頭の変数代入、後続のコマンドをそのまま実行するだけのコマンド、
	# コマンドの前に置かれる予約語 (then rm a など) を外す
	i=0
	while [ $i -lt ${#words[@]} ]; do
		case "${words[i]}" in
		command | builtin | nice | nohup | time | noglob) ;;
		if | then | elif | else | do | while | until | '!' | '{') ;;
		timeout) i=$((i + 1)) ;; # 時間の引数も外す
		*) [[ ${words[i]} =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || break ;;
		esac
		i=$((i + 1))
	done
	[ $i -lt ${#words[@]} ] || continue
	words=("${words[@]:i}")

	case "${words[0]##*/}" in
	cd)
		[ $track_cd -eq 1 ] || continue
		# cd 先を解決できなければ cwd 不明として扱う
		cwd=$(cd_dest "${words[1]:-$HOME}" "$cwd")
		;;
	pushd | popd) cwd= ;;
	rm | rmdir | unlink)
		targets=()
		opts_done=0
		skip_next=0
		for w in "${words[@]:1}"; do
			if [ $skip_next -eq 1 ]; then
				skip_next=0
				continue
			fi
			# リダイレクト (2>/dev/null など) は削除対象ではない。対象とつながった語
			# (a>b) や zsh のグロブ <-> は対象を読み取れないので、人に確認する
			if [[ $w == *[\<\>]* ]]; then
				if [[ $w =~ $bare_redirect_re ]]; then
					skip_next=1
				elif ! [[ $w =~ $redirect_re ]]; then
					add_problem 9 "$w"
				fi
				continue
			fi
			if [ $opts_done -eq 0 ]; then
				case "$w" in
				-*)
					if [ ${#targets[@]} -eq 0 ]; then
						[ "$w" = -- ] && opts_done=1
					else
						# 対象の後のオプションは BSD と GNU の rm で扱いが違う
						add_problem 3 "$w"
					fi
					continue
					;;
				esac
			fi
			targets+=("$w")
		done
		for t in ${targets[@]+"${targets[@]}"}; do
			judge_target "$t" "$cwd" || add_problem $? "$t"
		done
		;;
	# 後続のコマンドを実行するコマンド。git rm や docker rm、文中の rm は対象外
	sudo | doas | xargs | env | bash | sh | zsh | dash | eval | exec | parallel | find)
		if [[ $segment =~ $rm_word_re ]]; then
			case "${words[0]##*/}" in
			sudo | doas) add_problem 8 "${words[0]}" ;;
			*) add_problem 4 "${words[0]}" ;;
			esac
		fi
		;;
	esac
done

# .trash/ への退避コマンドを、対象ごとに 1 行ずつ作る。同名のファイルが退避先で
# 上書きし合わないよう、リポジトリのルートからの相対パスを保つ
trash_commands() {
	local ts i root rel dir
	ts=$(date +%Y%m%d-%H%M%S)
	for i in "${!trash_roots[@]}"; do
		root=${trash_roots[i]}
		rel=${trash_paths[i]#"$root"/}
		dir=$root/.trash/$ts
		case "$rel" in */*) dir+=/${rel%/*} ;; esac
		printf '\n  mkdir -p %q && mv %q %q/' "$dir" "${trash_paths[i]}" "$dir"
	done
}

deny_msg=
ask_msg=
for i in "${!problems[@]}"; do
	line=$'\n'"- ${labels[i]}: ${problems[i]}"
	if [ "$i" -ge $first_ask ]; then
		ask_msg+=$line
	elif [ "$i" -eq 5 ]; then
		deny_msg+="$line"$'\n'"  → Move to .trash/ instead:$(trash_commands)"
	else
		deny_msg+="$line"$'\n'"  → ${hints[i]}"
	fi
done

if [ -n "$deny_msg" ]; then
	msg="Deletion blocked.$deny_msg"
	[ -n "$ask_msg" ] && msg+=$'\n'"Even after rewriting, human confirmation is needed:$ask_msg"
	decide deny "$msg"
fi
[ -n "$ask_msg" ] && decide ask "Deletion needs confirmation:$ask_msg"
exit 0
