---
description: 指定または文脈中の Markdown を mo (ローカル Markdown ビューア) で開く
disable-model-invocation: true
---
`mo` で Markdown をブラウザで開く。ARGUMENTS にファイルパスがあればそれを、なければ会話の文脈から「今ユーザーが見たいであろう Markdown」を選ぶ (直前に書いた・編集した・話題にしているファイル)。

- 開きたいファイルが複数あるなら、1 回の `mo` 呼び出しに**まとめて**渡す: `mo a.md b.md`
- `--open` を**コマンド末尾に 1 つだけ**付けてブラウザを確実に前面に出す (`--open` は per-file ではなくコマンド全体に効くフラグ)。最も中心的なファイルを引数の**先頭**に置く: `mo design.md api.md changelog.md --open`
- 渡す前にファイルの存在を確認する。ARGUMENTS のパスが存在しなければ `mo` に渡さず、不在をユーザーに伝える (近いパスの候補があれば提示する)
- `mo` は即座に返る (常駐サーバ化は `mo` 側が行う) ので、実行後は開いた URL (既定 `http://localhost:6275`) を 1 行で伝えるだけでよい

開く対象が文脈から一意に決まらないときだけ、ユーザーに確認する。

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>
