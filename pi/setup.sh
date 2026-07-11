#!/bin/sh
#
# ~/.pi/agent 配下の symlink を配置する。
# 親 setup.sh から呼ばれるほか、単体でも実行できる。
#   sh pi/setup.sh [HOME_PATH] [DOTFILES_PATH]
# 引数省略時は HOME_PATH=$HOME、DOTFILES_PATH=スクリプト位置から導出する。

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

HOME_PATH=${1:-$HOME}
DOTFILES_PATH=${2:-$(dirname -- "${SCRIPT_DIR}")}
PI_SRC=${DOTFILES_PATH}/pi

mkdir -p "${HOME_PATH}/.pi/agent"
mkdir -p "${HOME_PATH}/.old_dotfiles"

## .pi/agent 直下の管理対象を個別 symlink ##
## auth.json / sessions / tmp は秘密情報や実行時状態なので対象外。
for file in $(ls "${PI_SRC}")
do
    [ "${file}" = "setup.sh" ] && continue
    echo "pi/${file}"
    dst="${HOME_PATH}/.pi/agent/${file}"
    if [ -e "${dst}" ] || [ -h "${dst}" ]; then
        bak="${HOME_PATH}/.old_dotfiles/pi.${file}"
        n=1
        while [ -e "${bak}" ] || [ -h "${bak}" ]; do
            bak="${HOME_PATH}/.old_dotfiles/pi.${file}.${n}"
            n=$((n + 1))
        done
        mv "${dst}" "${bak}"
    fi
    ln -s "${PI_SRC}/${file}" "${dst}"
done
