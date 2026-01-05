---
description: Interview to clarify task details and ambiguities
allowed-tools:
  - Write
  - Edit
  - Read
  - Grep
  - Glob
  - TodoRead
  - TodoWrite
  - AskUserQuestion
  - EnterPlanMode
  - WebSearch
  - WebFetch
  - mcp__fetch__fetch
  - mcp__deepwiki__ask_question
  - mcp__deepwiki__read_wiki_contents
  - mcp__deepwiki__read_wiki_structure
  - mcp__google-search__web_search
---

AskUserQuestion ツールを使って、タスクについて詳細にインタビューしてください
技術的な実装、UI/UX、懸念点、トレードオフ、エッジケース、依存関係など、何でも質問してください
自明な質問は避け、非自明な側面を深掘りすること
すべての曖昧さが解消されるまで徹底的にインタビューを続け、完了したら仕様を書き出してください

## タスクの特定

1. ARGUMENTS が指定されている場合: テキストまたはファイルパスをタスクの説明として参照
2. ARGUMENTS が空の場合: 現在のセッションの最新の plan ファイルを参照
3. 計画が見つからない場合: 「plan mode で計画を作成するかタスクの説明を与えてください」と伝えて終了

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>

## インタビューの進め方

1. **不明確な点の特定**: 計画を精読し、曖昧な項目をリストアップ
2. **質問**: AskUserQuestion で 2-4 個の質問、各 2-4 個の選択肢 (メリット/デメリット付き)
   - プロダクト仕様: 機能の範囲、ユーザーストーリー、優先度
   - 技術的な詳細: アーキテクチャ、使用ライブラリ、データ構造
   - UI/UX: インタラクション、レイアウト、エラー表示
   - エッジケース: 異常系、境界値、並行処理
   - 依存関係: 外部サービス、既存コードとの整合性
   - 非機能要件: パフォーマンス、セキュリティ、スケーラビリティ
3. **反映**: 決定事項を plan ファイル & タスク説明に反映
4. **繰り返し**: 不明確な点が残れば 2 に戻る (最大 10 ラウンド)
5. **サマリー**: 以下の形式で出力

<OUTPUT_FORMAT>
## Decisions

| Topic | Decision | Pros/Cons | Implementation Notes |
|-------|----------|-----------|----------------------|
| Data storage | PostgreSQL | +Scalability, +ACID / -Ops complexity | Use managed service |

## Next Steps

1. **First task**
- Details...

2. **Second task**
- Details...
</OUTPUT_FORMAT>

---

## 注意事項

- 質問は AskUserQuestion ツールを使用する
- すべての不明確な点が解消されるか、最大ラウンドに達するまで続ける
