#!/bin/sh
#
# claude/settings.json の enabledPlugins (pokutuna-plugins) を見て、
# 有効なプラグインが持つ skill への symlink を ~/.codex/skills/ に直接張る。
# claude-plugins リポジトリ側の skill をそのまま参照するので、
# dotfiles には symlink 自体を置かない。
#   sh codex/sync-plugin-skills.sh [HOME_PATH] [DOTFILES_PATH]

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

HOME_PATH=${1:-$HOME}
DOTFILES_PATH=${2:-$(dirname -- "${SCRIPT_DIR}")}

SETTINGS_JSON="${DOTFILES_PATH}/claude/settings.json"
MARKETPLACE_JSON="/Users/pokutuna/ghq/github.com/pokutuna/claude-plugins/.claude-plugin/marketplace.json"
SKILLS_DST="${HOME_PATH}/.codex/skills"

mkdir -p "${SKILLS_DST}"

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
        name=$(basename "${skill}")
        echo "${plugin}/skills/${name}"
        rm -f "${SKILLS_DST}/${name}"
        ln -s "${skills_dir%/}/${name}" "${SKILLS_DST}/${name}"
    done
done
