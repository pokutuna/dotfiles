---
description: 現在のブラウザタブを参照して情報を集め、文脈に取り込む
allowed-tools:
  - Task
  - mcp__chrome-tabs__list_tabs
  - mcp__chrome-tabs__open_in_new_tab
  - mcp__chrome-tabs__read_tab_content
---
ブラウザで開いているタブを読んで、$ARGUMENTS について調べてください

複数の議事録から経緯や決定をまとめたり、関連ドキュメントやライブラリのリファレンスを大量に開いて内容や登場する要素・関係を把握する、といった用途を想定しています。

進め方:

- `list_tabs` (`includeUrl: true`) でタブ一覧を取得する。関係ないタブも大量に開いている前提なので、$ARGUMENTS に関連するものだけを選ぶ。タイトルと URL で当たりをつける。タイトルは実体とズレることがある (前のページのまま残る等) ので、URL も見て、紛らわしければ中身を少し読んで判断する。指示が曖昧・空なら何を調べたいかユーザに聞く
- 選んだタブは subagent (Task, general-purpose, model: sonnet) でタブごとに並列に読む。多いときは数個ずつ起動する。各 subagent にはタブの ID (`list_tabs` の `ID:...:...`) を渡し、`read_tab_content` で読んで $ARGUMENTS の関心に沿った要点・登場する要素・関係を抜き出して返させる
- 結果を統合する。$ARGUMENTS に答えるのに足りなければ、該当タブを `read_tab_content` で追加で読んだり、`open_in_new_tab` で参照先を開いて深掘りする

最後に、$ARGUMENTS が問いならまずそれに答え、そのうえで後から参照しやすいようにタブの一覧 (タイトル・URL・要点) と、どの情報がどのタブにあるかが分かるようにしてください。コンテキストに積むのが目的なので簡潔に。
