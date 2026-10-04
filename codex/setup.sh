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
for file in $(ls "${CODEX_SRC}")
do
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

## Codex の skill 置き場 ~/.agents/skills を用意する ##
## Codex がユーザーレベルで読むのは ~/.agents/skills だけ (~/.codex/skills は旧配置)。
## 実体ディレクトリにする: npx skills add -g が他人の skill をここに実体で置くので、
## 丸ごと symlink にすると dotfiles リポジトリに紛れ込む。
## 自前 skill の symlink は codex/sync-own-skills.sh が allowlist に沿って張る。
AGENTS_DST="${HOME_PATH}/.agents"

## 旧構成 (~/.agents を dotfiles/agents へ丸ごと symlink) なら外す。
## リンク先が生きていれば退避し、dangling なら消す。
if [ -L "${AGENTS_DST}" ]; then
    if [ -e "${AGENTS_DST}" ]; then
        mv "${AGENTS_DST}" "${HOME_PATH}/.old_dotfiles/.agents"
    else
        echo "remove dangling symlink ${AGENTS_DST}"
        rm -f "${AGENTS_DST}"
    fi
fi
mkdir -p "${AGENTS_DST}/skills"

## 旧配置 ~/.codex/skills に残る claude/skills 向け symlink を掃除する。
## ~/.agents/skills と二重に見えるため。Codex の .system や plugin 由来のものは残す。
OLD_SKILLS_DST="${HOME_PATH}/.codex/skills"
if [ -d "${OLD_SKILLS_DST}" ]; then
    for link in "${OLD_SKILLS_DST}"/*
    do
        [ -L "${link}" ] || continue
        case "$(readlink "${link}")" in
            "${DOTFILES_PATH}/claude/skills/"*|"${CODEX_SRC}/skills/"*)
                echo "remove legacy ${link}"; rm -f "${link}" ;;
        esac
    done
fi

sh "${CODEX_SRC}/sync-own-skills.sh" "${HOME_PATH}" "${DOTFILES_PATH}"
