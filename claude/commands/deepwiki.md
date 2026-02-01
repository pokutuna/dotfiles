---
description: MCP DeepWiki を利用してリポジトリについて調査する
allowed-tools:
  - mcp__deepwiki__ask_question
  - mcp__deepwiki__read_wiki_contents
  - mcp__deepwiki__read_wiki_structure
---
MCP DeepWiki を利用して調査してください

調査内容: $ARGUMENTS

注意：調査内容がない(空)の場合は、"調査内容は何ですか?" と返して中断してください

手順：
1. 最近の作業内容と質問内容から、対応する GitHub リポジトリを特定する
  - 特定できない場合はユーザに問いかける
2. ユーザの調査内容を `ask_question` Tool を用いて調査する
  - 質問が曖昧であればユーザに問いかける
3. DeepWiki の結果を理解し、1行で説明する
  - コンテキストに積むのが目的なので長々とした説明は不要
