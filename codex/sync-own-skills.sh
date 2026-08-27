#!/bin/sh
#
# dotfiles 自前の skill (dotfiles/claude/skills/*) のうち、下の SKILLS に
# 列挙したものだけを ~/.codex/skills/ に symlink する。
# symlink 先の実体をそのまま参照するので、dotfiles には symlink 自体を置かない。
#
# 有効にする skill を増減させたいときは SKILLS の行をコメントアウト/追記して
# 再実行する。コメントアウトしたものの symlink は次回実行時に削除される。
#
# claude-plugins リポジトリのプラグインはこのスクリプトの担当外。そちらは
# codex/sync-plugins.sh が codex plugin として install/uninstall する
# (skill を symlink で二重に置くと plugin 由来のものと重複するため)。
#
#   sh codex/sync-own-skills.sh [--dry-run] [HOME_PATH] [DOTFILES_PATH]

set -e

SKILLS=$(cat <<'LIST'
browser-context
commit
create-pr
deepwiki
design-doc
# disk-cleanup
# empirical-prompt-tuning
fix-ci
fix-review
git-commit-agent
# github-issue-pr-writer
handover
# improve-claude-md
# japanese-tech-writing
# memory-cleaner
mo-it
offload-subagent
remove-artifact-noise
remove-slops
task-interview
# teach-me
LIST
)

DRY_RUN=0
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=1
    shift
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

HOME_PATH=${1:-$HOME}
DOTFILES_PATH=${2:-$(dirname -- "${SCRIPT_DIR}")}

OWN_SKILLS_DIR="${DOTFILES_PATH}/claude/skills"
SKILLS_DST="${HOME_PATH}/.codex/skills"

WANTED=$(echo "${SKILLS}" | sed 's/#.*//' | tr -d ' \t' | grep -v '^$' || true)

run() {
    if [ "${DRY_RUN}" = "1" ]; then
        echo "  (dry-run) $*"
    else
        "$@"
    fi
}

mkdir -p "${SKILLS_DST}"

## 列挙された skill を symlink する ##
for name in ${WANTED}
do
    src="${OWN_SKILLS_DIR}/${name}"
    if [ ! -d "${src}" ]; then
        echo "warn: ${name} が ${OWN_SKILLS_DIR} にないので skip" >&2
        continue
    fi
    echo "link claude/skills/${name}"
    run rm -f "${SKILLS_DST}/${name}"
    run ln -s "${src}" "${SKILLS_DST}/${name}"
done

## 列挙から外れた / dotfiles 側から消えた自前 skill の symlink を掃除する ##
for link in "${SKILLS_DST}"/*
do
    [ -L "${link}" ] || continue
    case "$(readlink "${link}")" in
        "${OWN_SKILLS_DIR}/"*) ;;
        *) continue ;;
    esac
    name=$(basename "${link}")
    if ! echo "${WANTED}" | grep -qx "${name}"; then
        echo "remove ${name}"
        run rm -f "${link}"
    fi
done
