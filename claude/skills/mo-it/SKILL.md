---
name: mo-it
description: 指定または文脈中の Markdown を mo (ローカル Markdown ビューア) で開く
disable-model-invocation: true
---
`mo` で Markdown をブラウザで開く。ARGUMENTS にファイルパスがあればそれを、なければ会話の文脈から「今ユーザーが見たいであろう Markdown」を選ぶ (直前に書いた・編集した・話題にしているファイル)。

- 渡す前にファイルの存在を確認する。ARGUMENTS のパスが存在しなければ `mo` に渡さず、不在をユーザーに伝える (近いパスの候補があれば提示する)
- 開きたいファイルをまとめて `--json --no-open` で渡す (`--open` は使わない): `mo design.md api.md changelog.md --json --no-open`
- 出力 JSON の `files[].url` から最も中心的なファイルの url を選び、`open <url>` でブラウザをそのファイルにフォーカスさせる
- 実行後は開いた URL を 1 行で伝えるだけでよい

開く対象が文脈から一意に決まらないときだけ、ユーザーに確認する。

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>
