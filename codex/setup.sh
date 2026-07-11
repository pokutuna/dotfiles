#!/bin/sh
#
# ~/.codex 配下の symlink を配置する。
# 親 setup.sh から呼ばれるほか、単体でも実行できる。
#   sh codex/setup.sh [HOME_PATH] [DOTFILES_PATH]
# 引数省略時は HOME_PATH=$HOME、DOTFILES_PATH=スクリプト位置から導出する。

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

HOME_PATH=${1:-$HOME}
DOTFILES_PATH=${2:-$(dirname -- "${SCRIPT_DIR}")}
CODEX_SRC=${DOTFILES_PATH}/codex

mkdir -p "${HOME_PATH}/.codex"
mkdir -p "${HOME_PATH}/.old_dotfiles"

## codex/config.toml は丸ごと symlink するが、Git へ入れる時は
## marker 以降のローカル状態を clean filter で落とす。
if command -v git >/dev/null 2>&1 && [ -d "${DOTFILES_PATH}/.git" ]; then
    git -C "${DOTFILES_PATH}" config filter.codex-config.clean "sh ${DOTFILES_PATH}/bin/git-clean-codex-config"
    git -C "${DOTFILES_PATH}" config filter.codex-config.smudge cat
fi

## .codex 直下の管理対象を個別 symlink ##
## skills だけは別扱い (Codex の system skills と共存させるため下で個別 symlink)
for file in $(ls "${CODEX_SRC}")
do
    [ "${file}" = "skills" ] && continue
    [ "${file}" = "setup.sh" ] && continue
    echo "codex/${file}"
    dst="${HOME_PATH}/.codex/${file}"
    if [ -e "${dst}" ] || [ -h "${dst}" ]; then
        bak="${HOME_PATH}/.old_dotfiles/codex.${file}"
        n=1
        while [ -e "${bak}" ] || [ -h "${bak}" ]; do
            bak="${HOME_PATH}/.old_dotfiles/codex.${file}.${n}"
            n=$((n + 1))
        done
        mv "${dst}" "${bak}"
    fi
    ln -s "${CODEX_SRC}/${file}" "${dst}"
done

## .codex/skills は実体ディレクトリにして配下を個別 symlink ##
## ~/.codex/skills/.system や plugin 由来の skill を温存する。
SKILLS_DST="${HOME_PATH}/.codex/skills"

if [ -L "${SKILLS_DST}" ]; then
    mv "${SKILLS_DST}" "${HOME_PATH}/.old_dotfiles/codex.skills"
fi
mkdir -p "${SKILLS_DST}"

for skill in "${CODEX_SRC}"/skills/*/
do
    [ -d "${skill}" ] || continue
    name=$(basename "${skill}")
    echo "codex/skills/${name}"
    rm -f "${SKILLS_DST}/${name}"
    ln -s "${CODEX_SRC}/skills/${name}" "${SKILLS_DST}/${name}"
done

## dotfiles 側から消えた自前 skill の古い symlink を掃除する。
## Codex の .system や plugin 由来の symlink は残す。
for link in "${SKILLS_DST}"/*
do
    [ -L "${link}" ] || continue
    case "$(readlink "${link}")" in
        "${CODEX_SRC}/skills/"*)
            [ -e "${link}" ] || { echo "remove stale ${link}"; rm -f "${link}"; } ;;
    esac
done
