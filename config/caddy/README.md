# caddy — localhost.pokutuna.com プロキシ

`https://{port}.localhost.pokutuna.com` へのアクセスを `localhost:{port}`（同じポート番号）に
TLS付きでリバースプロキシする常駐設定。

`localhost.pokutuna.com` は公開DNS上で `127.0.0.1` を指す実在ドメイン（ワイルドカード
`*.localhost.pokutuna.com` も同様）。ローカルで動いている開発サーバーに、正規のTLS証明書付きで
`https://` アクセスしたいときに使う。この仕組みはローカル専用で、リモートサーバーには持ち出せない
（ドメインの実体が127.0.0.1である以上、リモートに置いても「そのリモート自身」を指すだけになる）。

## 構成

- `Caddyfile` — `*.localhost.pokutuna.com` のワイルドカードで受けて、サブドメインの先頭ラベル
  (`{labels.3}`) をそのままポート番号として `localhost:{labels.3}` に `reverse_proxy` する。
  1ブロックで任意のポートに対応できる。`brew services` 経由で常駐させる前提のため、
  Caddyは443番のみを使う。ポート番号をURLのポートとして使う方式（`localhost.pokutuna.com:3000`
  のような形）は採用していない — 他アプリ（例: Docker Desktop）がホストの同じポート番号を
  使っていると単純に競合して起動できなくなるため
- `setup.sh` — caddyのインストール、Caddyfileへのリンク、`brew services` での起動を行う

## 証明書について（このリポジトリには実体を置かない）

TLS証明書・秘密鍵の実体はこのリポジトリの外、別の場所で管理している（秘密鍵を公開リポジトリに
置きたくないため）。取得・更新手順やDNS設定はそちら側にメモがあるので参照すること。

- 証明書は `*.localhost.pokutuna.com` と `localhost.pokutuna.com` をカバーするワイルドカード証明書
- Let's Encryptなので90日で失効する。**自動更新は組んでいない**（`--manual` の dns-01 チャレンジで
  DNSレコードを手動追加する必要があるため）

Caddyfile内の証明書パスはこのマシンの絶対パス決め打ち。別マシンでこの設定を使う場合はパスを
書き換えること。

`{labels.N}` はホスト名のラベルをTLD側から`0`始まりで数える（`labels.0`=`com`,
`labels.1`=`pokutuna`, `labels.2`=`localhost`, `labels.3`=ポート番号）。ドメイン名の
段数が変わったらインデックスも変える必要がある。

## セットアップ

dotfilesの `setup.sh` が `config/` 配下を自動で `~/.config/` にシンボリックリンクするので、
`~/.config/caddy` は自動的にこのディレクトリを指すようになる。そのうえで:

```sh
~/.config/caddy/setup.sh
```

を実行すると、caddyのインストール・`$(brew --prefix)/etc/Caddyfile` へのリンク・
`brew services` での常駐起動（Mac再起動時も自動起動）まで行われる。

## 新しいポートを使いたくなったら

何もしなくてよい。`*.localhost.pokutuna.com` のワイルドカードで任意のポート番号を受けるので、
`https://12345.localhost.pokutuna.com` のように使いたいポート番号でそのままアクセスできる。

## 証明書を更新したら（90日ごと）

取得し直したら、Caddyは古い証明書を読み込んだままなので **`caddy reload`（上記コマンド）または
`brew services restart caddy` を忘れずに実行する**。

## 動作確認

```sh
brew services list | grep caddy       # started になっているか
curl -sk https://3000.localhost.pokutuna.com/ -o /dev/null -w '%{http_code}\n'
```
