#!/bin/sh
# localhost.pokutuna.com 用 Caddy のセットアップ
# 前提: 証明書 (fullchain.pem, privkey.pem) は別途取得済みであること (README.md 参照)

set -e

if ! command -v caddy >/dev/null 2>&1; then
    echo "installing caddy..."
    brew install caddy
fi

echo "linking Caddyfile to $(brew --prefix)/etc/Caddyfile"
ln -sf "${HOME}/.config/caddy/Caddyfile" "$(brew --prefix)/etc/Caddyfile"

echo "starting caddy as a background service (auto-start on login)"
brew services restart caddy

echo "done. logs: $(brew --prefix)/var/log/caddy.log"
