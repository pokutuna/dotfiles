# Claude Code / Codex / pi Skill 管理方針

## 使う範囲で扱いを分ける

| 使う範囲 | 置き場 | 有効/無効 | 例 |
|---|---|---|---|
| ほぼ全プロジェクト | global | 常に有効 | `/commit`, `/create-pr` |
| 一部のプロジェクト | global | global で無効<br>使うリポジトリの `.claude/settings.json` で有効 | `runpod`, `hydra-experiment` |
| 特定のプロジェクトだけ | project | dotfiles では管理しない | `plugin-dev` |
| 共有リポジトリで自分だけ | local | `.claude/settings.local.json` で有効/無効 | `jupyter` |

## エージェントごとの違い

Codex と pi は `~/.agents/skills` を共有する。Claude Code だけ別。

| | Claude Code | Codex | pi |
|---|---|---|---|
| global | `~/.claude/skills` | `~/.agents/skills` | `~/.agents/skills`<br>`~/.pi/agent/skills` |
| project | `.claude/skills` | `.agents/skills` | `.agents/skills`<br>`.pi/skills` |
| 自前 skill の配置 | `claude/setup.sh` で全部 | `codex/sync-own-skills.sh` の allowlist | Codex と同じ |
| `npx skills -a` | `claude-code` | `codex` | `pi` |
| skill の無効化 | `skillOverrides` に `"off"` | `codex/config.toml` の `[[skills.config]]` に `name` と `enabled = false` | settings の `skills` に `-<path>` か `!<pattern>`<br>または `pi config` |
| project での上書き | `.claude/settings.json` | `.codex/config.toml` (未確認) | `pi config --local` (未確認) |
| local での上書き | `.claude/settings.local.json` | 未確認 | 未確認 |
| plugin / package | `enabledPlugins` | `codex/sync-plugins.sh` で入れる | settings の `packages` (未使用) |

## 種類ごとのやり方

### 自前 skill (`claude/skills/*`)

`claude/setup.sh` が `~/.claude/skills/<name>` へ個別に symlink する。

### plugin

- global の有効/無効は `claude/settings.json` の `enabledPlugins` で決める。
- project や local で上書きするには `claude plugin enable <id> -s project` (`-s local`) か toggle-plugin を使う。

### 他人の skill (`npx skills`)

- 入れる: `npx skills add -g <owner/repo>[#<ref>] -s <skill> -a claude-code -y`
  - `-a claude-code` だけなら `~/.claude/skills/` へ直接コピーされる。複数のエージェントに入れると、実体は `~/.agents/skills/` に置かれ、各エージェントから相対 symlink で参照される。
  - Claude 側の置き場は `CLAUDE_CONFIG_DIR` に従う。Claude Code の中では `~/.claude` が入っているので、`HOME` を差し替えても本物の `~/.claude/skills` に入る。
  - `#<ref>` で branch や tag を指定できる。
  - 入れた元は `~/.agents/.skill-lock.json` に記録され、`npx skills update -g` の対象になる。
- 有効/無効は自前 skill と同じく `skillOverrides` で切り替える。npx の skill にも効き、上位スコープの値がキー単位で勝つことを確認済み。
- `npx skills ls -g` には `~/.agents/skills/` にある自前 skill の symlink も `untracked` として出る。`remove -g` で消さないこと。

## Claude Code の有効/無効の設定

true/false で切り替えられるのは plugin 単位の `enabledPlugins` だけ。skill は `skillOverrides` の文字列で切り替える。npx の skill を plugin に包めば `enabledPlugins` で扱えるが、npx で管理する意味がなくなる。

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

- `/skills` メニューで切り替えると `.claude/settings.local.json` に保存される。コミットするなら `.claude/settings.json` へ手で移す。
- 組み込み skill (`simplify` など) は `user-invocable-only` にして、モデルが勝手に呼ばないようにしている。

## Codex / pi

- npx で `-a codex` や `-a pi` を含めて入れた skill は Codex と pi の両方に見える。片方だけには入れられない。
- project で有効に戻せるかが未確認なので、一部のプロジェクトでしか使わない skill は `-a claude-code` だけで入れ、Codex と pi には出さない。

## 注意: `~/.claude/skills` と `~/.agents/skills` は実体ディレクトリにする

- `~/.claude/skills` を丸ごと symlink にすると、`npx skills add -g` が張る相対 symlink が壊れる。
- `~/.agents/skills` を dotfiles へ丸ごと symlink にすると、npx が置く他人の skill がリポジトリに紛れ込む。

## npx skill の lock を dotfiles で管理する

`~/.agents/.skill-lock.json` を `agents/skill-lock.json` への symlink にする (`agents/setup.sh`)。skills CLI は lock を直接上書きするので、`npx skills add/remove/update -g` の結果がそのまま dotfiles 側に入る。

- 復元: global の lock から入れ直すコマンドは skills CLI にない (v1.7.6 時点。`experimental_install` はプロジェクトの `skills-lock.json` 専用)。`agents/restore-skills.sh` で各項目を `npx skills add -g` し直す。
- 入れ先エージェントは lock に残らないので、復元時に `AGENTS` で指定する (既定 `claude-code`)。
- 固定できるのは ref まで。`skillFolderHash` は中身のハッシュで commit ではない。中身まで固定したいときは `#<tag>` で入れる。
- lock が壊れていると CLI は空とみなし、次の書き込みで全項目を消す。git で戻す。
