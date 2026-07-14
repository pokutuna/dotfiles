#!/bin/sh
#
# Claude Code 側の skill を ~/.codex/skills/ に直接 symlink する。
# - dotfiles/claude/skills/* (自前 skill) は常に全件
# - claude/settings.json の enabledPlugins (pokutuna-plugins) で有効な
#   claude-plugins リポジトリ側の skill
# いずれも symlink 先の実体をそのまま参照するので、dotfiles には
# symlink 自体を置かない。
#   sh codex/sync-plugin-skills.sh [HOME_PATH] [DOTFILES_PATH]

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

HOME_PATH=${1:-$HOME}
DOTFILES_PATH=${2:-$(dirname -- "${SCRIPT_DIR}")}

SETTINGS_JSON="${DOTFILES_PATH}/claude/settings.json"
OWN_SKILLS_DIR="${DOTFILES_PATH}/claude/skills"
MARKETPLACE_JSON="/Users/pokutuna/ghq/github.com/pokutuna/claude-plugins/.claude-plugin/marketplace.json"
SKILLS_DST="${HOME_PATH}/.codex/skills"

mkdir -p "${SKILLS_DST}"

link_skill () {
    name=$(basename "$1")
    echo "$2/${name}"
    rm -f "${SKILLS_DST}/${name}"
    ln -s "${1%/}" "${SKILLS_DST}/${name}"
}

## dotfiles 自前の skill を全件 symlink ##
for skill in "${OWN_SKILLS_DIR}"/*/
do
    [ -d "${skill}" ] || continue
    link_skill "${skill}" "claude/skills"
done

PLUGIN_DIRS=$(jq -r '
    .enabledPlugins
    | to_entries[]
    | select(.value == true and (.key | endswith("@pokutuna-plugins")))
    | .key
    | sub("@pokutuna-plugins$"; "")
' "${SETTINGS_JSON}")

MARKETPLACE_ROOT=$(dirname -- "$(dirname -- "${MARKETPLACE_JSON}")")

for plugin in ${PLUGIN_DIRS}
do
    src_dir=$(jq -r --arg name "${plugin}" '
        .plugins[] | select(.name == $name) | .source
    ' "${MARKETPLACE_JSON}")
    [ -n "${src_dir}" ] || { echo "skip: plugin not found in marketplace.json: ${plugin}" >&2; continue; }

    skills_dir="${MARKETPLACE_ROOT}/${src_dir#./}/skills"
    [ -d "${skills_dir}" ] || continue

    for skill in "${skills_dir}"/*/
    do
        [ -d "${skill}" ] || continue
        link_skill "${skill}" "${plugin}/skills"
    done
done
