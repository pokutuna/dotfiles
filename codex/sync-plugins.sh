#!/bin/sh
#
# claude-plugins リポジトリのプラグインを Codex に同期する。
#
# 実行するとこの marketplace のプラグインを全て uninstall し、下の PLUGINS に
# 書かれているものだけを install し直す。使うものを増減させたいときは PLUGINS
# の行をコメントアウト / 追記して再実行する。
#
# Codex は .codex-plugin/plugin.json を読み、skills/ は Claude Code と共有する。
# skills 内の ${CLAUDE_PLUGIN_ROOT} は書き換え不要 — Codex は各 SKILL.md を
# 絶対パスでプロンプトに列挙するので、モデルがそれを読み替えて解決する。
#
# Claude 側の enabledPlugins とは独立に管理する (Claude で有効でも Codex で
# 使いたいとは限らない)。
#
#   sh codex/sync-plugins.sh [--dry-run]

set -e

## Codex で使うプラグイン (# でコメントアウトすると次回実行時に外れる) ##
PLUGINS=$(cat <<'LIST'
cloud-logging
difit
google-style-guide
things-app
uv-features
# actions-ubuntu-slim-migration
# codex                 # Codex から Codex CLI を呼んでもセカンドオピニオンにならない
# github-copilot
# hydra-experiment
# jupyter
# kaggle-helper
# runpod
# vertexai-gemini-batch
# zoom
LIST
)

MARKETPLACE_PATH=${CLAUDE_PLUGINS_PATH:-/Users/pokutuna/ghq/github.com/pokutuna/claude-plugins}
MARKETPLACE_NAME=pokutuna-plugins

DRY_RUN=""
[ "$1" = "--dry-run" ] && DRY_RUN=1

run () {
    if [ -n "${DRY_RUN}" ]; then
        echo "  [dry-run] $*"
    else
        "$@" >/dev/null
    fi
}

command -v codex >/dev/null 2>&1 || { echo "codex not found" >&2; exit 1; }
[ -f "${MARKETPLACE_PATH}/.agents/plugins/marketplace.json" ] || {
    echo "marketplace not found: ${MARKETPLACE_PATH}/.agents/plugins/marketplace.json" >&2
    exit 1
}

## コメントと行内コメントを落として名前だけにする ##
WANTED=$(echo "${PLUGINS}" | sed 's/#.*//' | tr -s ' \t' ' ' | tr -d ' ' | grep -v '^$' || true)

## marketplace を登録する (登録済みなら codex 側が黙って通す) ##
codex plugin marketplace add "${MARKETPLACE_PATH}" >/dev/null 2>&1 || true

## この marketplace の install 済みプラグインを全て uninstall する ##
INSTALLED=$(codex plugin list 2>/dev/null \
    | awk -v mp="@${MARKETPLACE_NAME}" '$1 ~ mp && !/not installed/ && /installed/ { sub(mp, "", $1); print $1 }')

for plugin in ${INSTALLED}
do
    echo "uninstall ${plugin}"
    run codex plugin remove "${plugin}@${MARKETPLACE_NAME}"
done

## PLUGINS のものだけ install する ##
for plugin in ${WANTED}
do
    [ -f "${MARKETPLACE_PATH}/${plugin}/.codex-plugin/plugin.json" ] || {
        echo "skip: no .codex-plugin/plugin.json: ${plugin}" >&2
        continue
    }
    echo "install ${plugin}"
    run codex plugin add "${plugin}@${MARKETPLACE_NAME}"
done
