---
name: trim-skill
description: 既存の SKILL.md を短く簡潔にする。「skill を短くして」「skill を簡潔にして」「skill を整理して」で使う。
disable-model-invocation: true
metadata:
  inspired: https://github.com/cursor/plugins/blob/main/pstack/skills/poteto-mode/playbooks/authoring-a-skill.md
---

# Trim Skill

対象は依頼で指定された SKILL.md（未指定なら直前に作成・編集したもの）。

迷ったら削る。判断や出力を変えない文は全て削除候補。理由が非自明なら残し、自明なら省く。

- 削る: 自明な説明、当たり前の前置き、同じ指示の言い換え、余分な例、弱い推奨語（命令形に言い換えるか削る）、テンプレ的な締め。
- 圧縮する: 繰り返し現れる同種のルールは、個別の文ではなく表・チェックリストなど構造にまとめる。
- 残す: 判断や出力を変える具体的なルール・閾値・手順、非自明な理由、他 skill への参照や委譲。
- 迷う削除候補は削らずユーザーに確認する。
- 型定義・README・設定ファイルなど、リポジトリ内に一次情報源がある内容は本文に書き写さず、その参照に置き換える提案をユーザーにする（置き換えは実行しない）。

対象ファイルを直接編集する。編集後、frontmatter の `description` が本文の範囲と合っているか確認する。
