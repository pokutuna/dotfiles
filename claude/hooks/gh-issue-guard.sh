#!/bin/bash
# PreToolUse hook: gh issue comment / create を、宛先が pokutuna のリポジトリと分かるときだけ確認なしで通す。
# 宛先は gh issue create / gh issue comment <番号> の直後に書いたものだけを認める。本文などに書かれた文字列と取り違えないため。
# - -R / --repo が 2 つ以上ある、または issue / PR の URL を含む: ask (後勝ちの -R や URL で宛先が変わりうる)
# - 直後に -R / --repo pokutuna/<repo>: 何もしない (permissions.allow の "-R pokutuna/*" などのルールで許可する)
# - 直後に -R / --repo で他のリポジトリ: ask
# - -R / --repo が直後以外にある: deny して、直後に書いて打ち直すよう Claude に伝える
# - -R / --repo がない:
#   - gh issue create / gh issue comment <番号> だけの単純なコマンド: cwd で gh repo view して owner が pokutuna なら allow、それ以外は ask
#   - cd や ; && | $() グロブなどを含む: 実行時の場所や引数が分からないので deny して、-R を付けて打ち直すよう Claude に伝える
# 単純なコマンドだけを allow するので、他のコマンドが一緒に通ることはない。
# -R は -wR のように短いオプションをまとめた形も数える。本文などに書かれた文字列でも ask / deny になるが、安全側なので許容する。
# settings.json の if "Bash(gh *)" で gh を実行するときだけ呼ばれるので、gh issue comment / create を含むかはここで確かめる。
# if を "Bash(gh issue create *)" のようにコマンド名より細かくすると、$? や $() を含むあらゆるコマンドで hook が起動してしまう。
input=$(cat)
[[ $input =~ gh\ issue\ (create|comment) ]] || exit 0
cmd=$(jq -r .tool_input.command <<<"$input") || exit 1
cwd=$(jq -r .cwd <<<"$input") || exit 1

decide() {
	echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"'"$1"'","permissionDecisionReason":"'"$2"'"}}'
	exit 0
}
retry='put -R owner/repo right after \"gh issue create\" or \"gh issue comment <number>\"'
head='^gh issue (create|comment [0-9]+)'
repo='(-[A-Za-z]*R|--repo)'
[[ $cmd =~ $repo.*$repo ]] && decide ask "multiple -R / --repo"
[[ $cmd =~ github\.com/[^/]+/[^/]+/(issues|pull)/ ]] && decide ask "contains an issue / PR URL"
[[ $cmd =~ $head\ (-R|--repo)\ pokutuna/[A-Za-z0-9._-]+(\ |$) ]] && exit 0
[[ $cmd =~ $head\ (-R|--repo)\  ]] && decide ask "target repo is not owned by pokutuna"
[[ $cmd =~ $repo ]] && decide deny "$retry"

meta='[;&|<>$`()\\*?[{~]'
if [[ $cmd =~ $head(\ |$) && ! $cmd =~ $meta && $cmd != *$'\n'* ]]; then
	owner=$(cd "$cwd" && gh repo view --json owner -q .owner.login 2>/dev/null)
	[[ $owner == pokutuna ]] && decide allow "cwd repo is owned by pokutuna"
	decide ask "cwd repo is not owned by pokutuna"
fi
decide deny "$retry"
