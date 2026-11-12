#!/bin/sh
#
# npx skills の global lock (~/.agents/.skill-lock.json) を dotfiles の
# agents/skill-lock.json への symlink にする。
# skills CLI は lock を writeFile で直接上書きするので、symlink のまま書き込まれる。
# 親 setup.sh から呼ばれるほか、単体でも実行できる。
#   sh agents/setup.sh [HOME_PATH] [DOTFILES_PATH]

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

HOME_PATH=${1:-$HOME}
DOTFILES_PATH=${2:-$(dirname -- "${SCRIPT_DIR}")}

src="${DOTFILES_PATH}/agents/skill-lock.json"
dst="${HOME_PATH}/.agents/.skill-lock.json"

mkdir -p "${HOME_PATH}/.agents"
mkdir -p "${HOME_PATH}/.old_dotfiles"

echo "agents/skill-lock.json"
## 実ファイルの lock が既にあれば退避する (中身は手で dotfiles 側へ取り込む)。
if [ -e "${dst}" ] || [ -h "${dst}" ]; then
    if [ "$(readlink "${dst}")" != "${src}" ]; then
        mv "${dst}" "${HOME_PATH}/.old_dotfiles/agents.skill-lock.json"
    fi
fi
ln -sfn "${src}" "${dst}"
