#!/bin/sh
#
# agents/skill-lock.json に記録された skill を npx skills add -g で入れ直す。
# skills CLI には global lock から復元するコマンドがないための代替。
# 新しいマシンでは agents/setup.sh で lock を symlink した後に実行する。
#
# lock には skill ごとの入れ先エージェントが残らないので AGENTS で指定する
# (既定は claude-code のみ)。~/.agents/skills/<name> か ~/.claude/skills/<name> が
# 既にある skill は飛ばす。
# 入れ直すと lock の updatedAt が書き換わる。
#
#   sh agents/restore-skills.sh [--dry-run]
#   AGENTS="claude-code codex" sh agents/restore-skills.sh

set -e

DRY_RUN=0
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LOCK="${SCRIPT_DIR}/skill-lock.json"
SKILLS_DIR="${HOME}/.agents/skills"
## 入れ先が claude-code だけだと ~/.agents を経由せずここへ直接コピーされる
CLAUDE_SKILLS_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}/skills"
AGENTS=${AGENTS:-claude-code}

## ref は空のことがあるので最後の列に置く (tab は連続すると read で潰れる)
jq -r '.skills | to_entries[] | [.key, .value.sourceType, .value.sourceUrl, (.value.ref // "")] | @tsv' "${LOCK}" |
while IFS="$(printf '\t')" read -r name type url ref
do
    if [ "${type}" = "local" ]; then
        echo "skip ${name}: local source (${url})" >&2
        continue
    fi
    if [ -e "${SKILLS_DIR}/${name}" ] || [ -e "${CLAUDE_SKILLS_DIR}/${name}" ]; then
        echo "skip ${name}: already installed"
        continue
    fi
    src="${url}${ref:+#${ref}}"
    echo "add ${name} from ${src}"
    if [ "${DRY_RUN}" = "1" ]; then
        echo "  (dry-run) npx skills add -g ${src} -s ${name} -a ${AGENTS} -y"
    else
        # stdin を渡すと while の入力を食うので切る
        # shellcheck disable=SC2086
        npx skills add -g "${src}" -s "${name}" -a ${AGENTS} -y < /dev/null
    fi
done
