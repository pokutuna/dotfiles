#!/bin/sh
#
# ~/.claude 配下の symlink を配置する。
# 親 setup.sh から呼ばれるほか、単体でも実行できる。
#   sh claude/setup.sh [HOME_PATH] [DOTFILES_PATH]
# 引数省略時は HOME_PATH=$HOME、DOTFILES_PATH=スクリプト位置から導出する。

# このスクリプトは <dotfiles>/claude/setup.sh に置かれる前提なので
# スクリプトのあるディレクトリの親を dotfiles ルートとみなす。
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

HOME_PATH=${1:-$HOME}
DOTFILES_PATH=${2:-$(dirname -- "${SCRIPT_DIR}")}
CLAUDE_SRC=${DOTFILES_PATH}/claude

mkdir -p "${HOME_PATH}/.claude"
# 退避先。親 setup.sh が用意するが、単体実行でも動くよう自分でも確保する。
mkdir -p "${HOME_PATH}/.old_dotfiles"

## .claude 直下のエントリを個別 symlink ##
## skills だけは別扱い (npx skills add -g と共存させるため下で個別 symlink)
for file in $(ls "${CLAUDE_SRC}")
do
    [ "${file}" = "skills" ] && continue
    [ "${file}" = "setup.sh" ] && continue  # このスクリプト自身は ~/.claude に置かない
    echo "claude/${file}"
    dst="${HOME_PATH}/.claude/${file}"
    # 既存を必ず退避してからターゲットを空にする。
    # symlink をターゲットに残したまま ln -s すると、リンク先ディレクトリの
    # 中に入れ子の symlink が出来てしまう (claude/agents/agents 問題)。
    # 退避先が既にあれば連番を付けてバックアップを失わない。
    if [ -e "${dst}" ] || [ -h "${dst}" ]; then
        bak="${HOME_PATH}/.old_dotfiles/claude.${file}"
        n=1
        while [ -e "${bak}" ] || [ -h "${bak}" ]; do
            bak="${HOME_PATH}/.old_dotfiles/claude.${file}.${n}"
            n=$((n + 1))
        done
        mv "${dst}" "${bak}"
    fi
    ln -s "${CLAUDE_SRC}/${file}" "${dst}"
done

## .claude/skills は実体ディレクトリにして配下を個別 symlink ##
## ~/.claude/skills をディレクトリごと symlink にすると、npx skills add -g が
## ~/.claude/skills/<name> に張る相対 symlink が壊れる
## (createSymlink が canonical(target) 側の symlink を解決しないため)。
## 実体ディレクトリにすれば自前 skill (個別 symlink) と npx skill が共存できる。
SKILLS_DST="${HOME_PATH}/.claude/skills"

## 旧構成 (skills を丸ごと symlink) なら初回だけ退避して実体ディレクトリへ移行。
## 既に実体ディレクトリなら退避しない (npx skills が張ったリンクを温存する)。
if [ -L "${SKILLS_DST}" ]; then
    mv "${SKILLS_DST}" "${HOME_PATH}/.old_dotfiles/claude.skills"
fi
mkdir -p "${SKILLS_DST}"

## 自前 skill を個別 symlink で配置 (rm -f してから張り直すので冪等)。
for skill in "${CLAUDE_SRC}"/skills/*/
do
    [ -d "${skill}" ] || continue
    name=$(basename "${skill}")
    echo "claude/skills/${name}"
    rm -f "${SKILLS_DST}/${name}"
    ln -s "${CLAUDE_SRC}/skills/${name}" "${SKILLS_DST}/${name}"
done

## dotfiles 側から消えた自前 skill の古い symlink を掃除する。
## (dotfiles/claude/skills を指す symlink だけ対象。npx 由来 (~/.agents 指し) は残す)
for link in "${SKILLS_DST}"/*
do
    [ -L "${link}" ] || continue
    case "$(readlink "${link}")" in
        "${CLAUDE_SRC}/skills/"*)
            [ -e "${link}" ] || { echo "remove stale ${link}"; rm -f "${link}"; } ;;
    esac
done
