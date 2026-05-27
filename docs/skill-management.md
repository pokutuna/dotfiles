# Claude Code Skill 管理方針

## 運用

1. **自前 skill** … `claude/skills/*` を `setup.sh` (実体は `claude/setup.sh`) が `~/.claude/skills/` へ個別 symlink する。
2. **他人の skill** … 使うとき `npx skills add -g <source>` で global 導入するだけ。lockfile は dotfiles 管理しない（global lockfile からの復元コマンドが未実装で旨味がないため）。
3. **project 単位の有効/無効** … `skillOverrides` で制御する（下記）。

## skillOverrides（project 単位 ON/OFF）

`~/.claude/settings.json`（= dotfiles 実体）の `skillOverrides` で skill 可視性を制御する。SKILL.md を編集せず settings 側から制御できるので、他人の skill にも効く。

- 既定 `"off"` にして、使うプロジェクトの `.claude/settings.local.json` で `"on"` 上書き（project が user より優先）。
- `/skills` メニューの `Space`（状態サイクル）/ `Enter`（保存）で書ける。
- 値は `on` / `name-only` / `user-invocable-only` / `off`。未記載は `on`。
- plugin skill は対象外。plugin は `enabledPlugins` / toggle-plugin で管理する。

## 注意: `~/.claude/skills` は実体ディレクトリにする

`~/.claude/skills` を丸ごと symlink にすると `npx skills add -g` が張る相対 symlink が壊れる（npx 側の既知バグ）。`setup.sh` は `~/.claude/skills` を実体ディレクトリにして自前 skill を個別 symlink で置くので、npx skill と共存できる。
