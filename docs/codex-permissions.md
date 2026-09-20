# Codex と Claude Code の権限設定

Codex は、実行可能な範囲を sandbox で定め、範囲外の操作だけ承認する。Claude Code は、`Bash(...)`、`Edit(...)` などのツール・コマンドを許可リストで制御する。したがって、Claude の `permissions.allow` を Codex のコマンド許可ルールへそのまま移植しない。

| 目的 | Claude Code | Codex |
| --- | --- | --- |
| ワークスペースを編集する | `Edit(...)` | filesystem の `write` |
| 開発コマンドを実行する | `Bash(...)` | sandbox 内なら filesystem と network の権限で実行 |
| sandbox 外で特定コマンドを実行する | `Bash(...)` | `rules/*.rules` の `prefix_rule` |
| 危険な操作を止める | `deny` / `ask` | filesystem の `deny`、または `prefix_rule(decision = "prompt" | "forbidden")` |

Codex のルールで `allow` を指定すると、そのコマンドは sandbox の外で承認なしに実行される。そのため、`git`、`npm`、`gcloud` など Claude で許可済みのコマンドを一括で `allow` にするのは避ける。まず sandbox 内で必要なファイルとネットワークだけを許可する。

## `claude/settings.json` からの対応

この文書の設定例は、`claude/settings.json` の次の項目を移植対象にしている。Codex には、読み取り系の外部サービス操作と `git fetch` / `git pull` の一部を移植している。

| Claude Code の設定 | Codex での移植先 | 扱い |
| --- | --- | --- |
| `defaultMode: "auto"` | `approval_policy = "on-request"` | sandbox 内の通常作業は継続し、境界を越える操作で確認する。完全な等価ではない。 |
| `Edit(docs/**)`、`Edit(src/**)` など | `filesystem.":workspace_roots"." = "write"` | 提案ではワークスペース全体を書き込み可能にする。Claude より広いので、必要なら `docs/**`、`src/**` などへ絞る。 |
| `Edit(/tmp/**)`、npm・uv・Yarn・pnpm のキャッシュ | `filesystem` の個別 `write` | 一時ファイルと依存関係キャッシュへの書き込みを引き継ぐ。 |
| `Read(~/ghq/.../coding-instructions)` と `additionalDirectories` | `filesystem` の `coding-instructions = "read"` | 編集権限を与えず、参照だけを引き継ぐ。 |
| `Edit(/etc/**)` と `Edit(~/.ssh/**)` の `deny` | `filesystem` の `/etc`、`~/.ssh` を `deny` | 同じ保護を引き継ぐ。`.npmrc` も資格情報を含み得るため追加で拒否する。 |
| `Bash(git ...)`、`Bash(go ...)`、`Bash(npm run ...)`、`Bash(ruff ...)` などローカル開発コマンド | workspace の `write` と最小 read 権限 | ネットワーク不要な範囲では、個々のコマンドルールは不要。 |
| `Bash(gh pr view/list ...)`、`Bash(gcloud ... list/describe ...)`、`Bash(bq ls/show ...)` | `rules/default.rules` の狭い `prefix_rule(..., decision = "allow")` | 読み取り専用のサブコマンドを個別に移植する。 |
| `Bash(gh issue/pr comment ...)` と `Bash(gh issue create ...)` の `ask` | ルールを作らず、ネットワークなしの既定プロファイルに残す | sandbox 外の承認を維持する。 |
| `Bash(gh repo fork ...)`、`Bash(git pull ...)`、`Bash(npm install ...)`、`Bash(uv sync ...)` | `rules/default.rules` に移植済み | Claude Code 側で許可しているため移植する。依存関係変更や外部サービス変更を含む。 |
| `Bash(docker ...)`、`Bash(docker-compose ...)` | `rules/default.rules` に移植済み | Claude Code 側で許可しているため移植する。Docker socket はホストへの広い操作権限になる。 |
| `Bash(rm -rf ...)` の `deny` と `Bash(rm ...)` の `ask` | 完全な移植不可 | Codex の `prefix_rule` は sandbox 外の実行だけを制御する。sandbox 内の削除を常に確認させるユーザー設定はない。 |
| MCP、Skill、`WebFetch`、`WebSearch` の許可 | 個別の MCP / Skill / Web 構成 | sandbox プロファイルの対象外。既存の Codex プラグイン・MCP 設定は維持する。 |

## 推奨するプロファイル

`codex/config.toml` は現在の `sandbox_mode = "workspace-write"` と `approval_policy = "on-request"` を使っている。既定ではネットワークを無効にし、ワークスペース編集とローカルのビルド・テストだけを自動化する。`.env`、SSH 鍵、システム設定を保護できる。

`default_permissions` を使う場合、既存の `sandbox_mode` と `sandbox_workspace_write.*` は同時に指定しない。

```toml
# `sandbox_mode = ...` の代わりに指定する。
default_permissions = "pokutuna-dev"
approval_policy = "on-request"
approvals_reviewer = "user"

[features] # 既存の `[features]` テーブルには追記する。
network_proxy = true

[permissions.pokutuna-dev.filesystem]
":minimal" = "read"
"/tmp" = "write"
"/Users/pokutuna/.npm" = "write"
"/Users/pokutuna/Library/Caches/uv" = "write"
"/Users/pokutuna/Library/Caches/Yarn" = "write"
"/Users/pokutuna/Library/pnpm" = "write"
"/Users/pokutuna/ghq/github.com/pokutuna/coding-instructions" = "read"
"/Users/pokutuna/.npmrc" = "deny"
"/Users/pokutuna/.ssh" = "deny"
"/etc" = "deny"

[permissions.pokutuna-dev.filesystem.":workspace_roots"]
"." = "write"
"**/*.env" = "deny"

[permissions.pokutuna-dev.network]
enabled = false
```

`coding-instructions` は Claude の `additionalDirectories` と違い、明示的に `read` のみを与えている。Docker は Unix socket を介してホストを操作できるため、この共通プロファイルには含めない。必要なプロジェクトだけで追加する。

ネットワークを有効にしたプロファイルは、許可ドメインに対する `gcloud`、`gh`、`npm` などの**全サブコマンド**を実行できる。CLI の「読み取り」と「書き込み」を Codex のネットワーク設定だけで分けることはできない。したがって、`gh pr comment` や `gcloud run deploy` も止めたい既定プロファイルにはネットワークを入れない。

## 承認を残す操作

ネットワークを無効にした既定プロファイルでは、次の操作は sandbox の外へ出るため、`approval_policy = "on-request"` で承認対象になる。

- `gh issue/pr comment`、`gh issue create`、`gh repo fork` など外部サービスを書き換える操作
- Docker の socket を使う操作
- リポジトリ外への書き込み

`rm` のような sandbox 内のコマンドを、Codex のユーザー設定だけで「必ず都度確認」にすることはできない。`prefix_rule` は sandbox 外でのコマンドを制御する仕組みである。削除を技術的に止める必要がある作業は、`read-only` プロファイルで開始するか、書き込み可能な workspace を限定する。

同じ安全な昇格を繰り返す場合だけ、Codex の承認画面で提示される prefix を確認して「このセッションで許可」または恒久許可にする。恒久ルールは `~/.codex/rules/default.rules` に保存される。手で追加する例は次のとおり。

```starlark
# sandbox 外での GitHub PR 閲覧だけを許可する例。
prefix_rule(
    pattern = ["gh", "pr", ["view", "list"]],
    decision = "allow",
    justification = "GitHub の PR 情報を読み取るため。",
)

# Google Cloud の読み取り専用コマンドだけを許可する。
prefix_rule(
    pattern = ["gcloud", "run", "services", ["list", "describe"]],
    decision = "allow",
    justification = "Cloud Run サービスの状態確認のため。",
)

# sandbox 外での削除は常に確認する。
prefix_rule(
    pattern = ["rm"],
    decision = "prompt",
    justification = "ファイル削除にはユーザー確認が必要。",
)
```

`npm install`、`uv sync`、Docker、`git pull` は副作用や入力の幅が大きいため、最初はルールに追加しない。頻繁に使う場合でも、プロジェクト限定の `.codex/rules/` に `decision = "prompt"` を置くか、専用のネットワークプロファイルをその作業時だけ選ぶ。

## 公式ドキュメント

- [Codex Permissions](https://learn.chatgpt.com/docs/permissions)
- [Codex Rules](https://learn.chatgpt.com/docs/agent-configuration/rules)
- [Codex Configuration Reference](https://learn.chatgpt.com/docs/config-file/config-reference)
- [Claude Code CLI reference](https://code.claude.com/docs/en/cli-usage)
