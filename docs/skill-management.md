# Claude Code / Codex / pi Skill 管理方針

## 使う範囲で扱いを分ける

| 使う範囲 | 置き場 | 有効/無効 |
|---|---|---|
| 特定のプロジェクトだけ | そのプロジェクト内 (dotfiles では管理しない) | — |
| ほぼ全プロジェクト (commit, PR 作成など) | global | 常に有効 |
| 一部のプロジェクト (runpod, hydra など) | global | 既定で無効、使うリポジトリの `.claude/settings.json` で有効に上書き |

リポジトリ側の上書きはコミットする `.claude/settings.json` に書く (例: PARC2026-pre)。

## エージェントごとの違い

Codex と pi は `~/.agents/skills` を読む仲間で、置き場は共通。Claude Code だけ別。

| | Claude Code | Codex | pi |
|---|---|---|---|
| global の読み込み先 | `~/.claude/skills` | `~/.agents/skills` | `~/.agents/skills`、`~/.pi/agent/skills` |
| プロジェクトの読み込み先 | `.claude/skills` | `.agents/skills` | `.agents/skills`、`.pi/skills` |
| 自前 skill の配置 | `claude/setup.sh` (全部) | `codex/sync-own-skills.sh` (allowlist) | Codex と同じ |
| `npx skills -a` | `claude-code` | `codex` | `pi` |
| skill 単位の無効化 | `skillOverrides` に `"off"` | `codex/config.toml` の `[[skills.config]]` に `name` と `enabled = false` | settings の `skills` に `-<path>` か `!<pattern>`、または `pi config` |
| プロジェクトでの上書き | `.claude/settings.json` (確認済み) | `.codex/config.toml` (未確認) | `pi config --local` (未確認) |
| plugin / package | `enabledPlugins` で true/false | `codex/sync-plugins.sh` で Codex plugin として入れる | settings の `packages` (今は使っていない) |

## 種類ごとのやり方

### 自前 skill (`claude/skills/*`)

`claude/setup.sh` が `~/.claude/skills/<name>` へ個別に symlink する。

### plugin (pokutuna/claude-plugins)

- global の有効/無効は `claude/settings.json` の `enabledPlugins` で決める。
- リポジトリで有効にするには `.claude/settings.json` の `enabledPlugins` で `true` にする。`claude plugin enable <id> -s project` か toggle-plugin で書ける。

### 他人の skill (`npx skills`)

- 入れる: `npx skills add -g <owner/repo>[#<ref>] -s <skill> -a claude-code -y`
  - 入れ先が `-a claude-code` だけだと、`~/.claude/skills/` へ直接コピーされる (入れ先のディレクトリが 1 つのときはコピーになる)。複数のエージェントに入れると、実体は `~/.agents/skills/` に置かれ、各エージェントからは相対 symlink で参照される。
  - Claude 側の置き場は `CLAUDE_CONFIG_DIR` があればそれに従う。Claude Code の中から実行すると `~/.claude` が入っているので、`HOME` を差し替えて試しても本物の `~/.claude/skills` に入る。
  - 入れた元は `~/.agents/.skill-lock.json` に記録され、`npx skills update -g` の対象になる。
  - `#<ref>` で branch や tag を指定できる。
- 有効/無効: `claude/settings.json` の `skillOverrides` で `"off"` にし、使うリポジトリの `.claude/settings.json` で `"on"` に上書きする。npx の skill にも効き、上位スコープの値がキー単位で勝つことを確認済み。
- `npx skills ls -g` には `~/.agents/skills/` にある自前 skill の symlink も `untracked` として出る。`remove -g` で消さないこと。

## Claude Code の有効/無効の設定

Claude Code で true/false で切り替えられるのは plugin 単位の `enabledPlugins` だけ。skill 単位で true/false にするキーはなく、skill は `skillOverrides` の文字列で切り替える。npx の skill を `enabledPlugins` で扱いたければ plugin として包むしかなく、npx で管理する意味がなくなる。

| キー | 単位 | 値 |
|---|---|---|
| `enabledPlugins` | plugin | `true` / `false` |
| `skillOverrides` | skill (plugin の skill を除く) | 下表 |
| `disableBundledSkills` | 組み込み skill すべて | `true` / `false` |

### `skillOverrides` の値

| 値 | モデルへの提示 | `/` メニュー |
|---|---|---|
| `on` (未記載時) | 名前と説明 | 出る |
| `name-only` | 名前のみ | 出る |
| `user-invocable-only` | 出さない | 出る |
| `off` | 出さない | 出ない |

- plugin の skill には効かない。plugin は `enabledPlugins` で扱う。
- `/skills` メニューで `Space` で状態を切り替え、`Esc` で `.claude/settings.local.json` に保存される。コミットする設定にしたいときは `.claude/settings.json` へ手で移す。
- 組み込み skill (`simplify` など) は `user-invocable-only` にして、モデルが勝手に呼ばないようにしている。

## Codex / pi

- 自前 skill は `codex/sync-own-skills.sh` の `SKILLS` (allowlist) に挙げたものだけ `~/.agents/skills/` へ symlink する。Codex と pi の両方に見える。
- npx で `-a codex` や `-a pi` を含めて入れた skill は実体が `~/.agents/skills/` に置かれ、Codex と pi の両方に見える (同じディレクトリなので片方だけには入れられない)。`-a claude-code` だけなら Codex と pi には見えない。
- プロジェクト側で有効に戻せるかが未確認なので、一部のプロジェクトでしか使わない skill は `-a claude-code` で入れ、Codex と pi には出さない。

## 注意: `~/.claude/skills` と `~/.agents/skills` は実体ディレクトリにする

- `~/.claude/skills` を丸ごと symlink にすると、`npx skills add -g` が張る相対 symlink が壊れる。
- `~/.agents/skills` を dotfiles へ丸ごと symlink にすると、npx が置く他人の skill がリポジトリに紛れ込む。

## npx skill の lock を dotfiles で管理する

`~/.agents/.skill-lock.json` を `agents/skill-lock.json` への symlink にする (`agents/setup.sh`)。skills CLI は lock を `writeFile` で直接上書きするので、`npx skills add/remove/update -g` の結果がそのまま dotfiles 側に入る。

- 復元: global lock から入れ直すコマンドは skills CLI にない (v1.7.6 時点。`experimental_install` はプロジェクトの `skills-lock.json` 専用) ので、`agents/restore-skills.sh` で lock の各項目を `npx skills add -g` し直す。
- 入れ先エージェントは lock に skill ごとには残らない。復元時は `AGENTS` で指定する (既定 `claude-code`)。
- 固定できるのは ref まで。`skillFolderHash` は中身のハッシュで commit ではないので、同じ中身を取り直す手段にはならない。中身まで固定したいときは `#<tag>` で入れる。
- lock が壊れていると CLI は空とみなし、次の書き込みで全項目を消す。git で戻す。
