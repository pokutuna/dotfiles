# herdr のキーバインド

設定は `herdr/config.toml` にある。既定値から変えたものだけを書いている。既定値の一覧は `herdr --default-config` で確認できる。

## 割り当ての方針

- prefix は tmux と同じ `C-t` にする。`C-q` も prefix にしておき、tmux の中で herdr を動かすときに使う。
- 移動系のキーは、prefix の ctrl を押したまま次のキーを押せるように ctrl 付きにそろえる。
- 左のサイドバーに並ぶもの (workspace と agent) は、ctrl を押したまま移る。
  - workspace は `ctrl+n` / `ctrl+p` で移る。
  - agent は縦に並ぶので、上下の `ctrl+j` / `ctrl+k` を使う。
- tab を workspace をまたいで順に移るのは、tmux の `n` / `p` (window 移動) と同じく ctrl を離した `n` / `p` にする。
- 今の workspace の中で tab を移るのは、横に並ぶ向きに合わせて `ctrl+f` / `ctrl+b` にする。`prefix+b` は既定でサイドバーの開閉に使われているので、ここだけ ctrl 付きのままにしている。
- 既定の `prefix+h/j/k/l` (pane のフォーカス移動) と `prefix+shift+h/j/k/l` (pane の入れ替え) は残す。

## 一覧

「既定」の列が空の行は、`herdr/config.toml` で追加したキー。

### workspace

| キー | 動作 | 既定 |
|---|---|---|
| `prefix+ctrl+n` / `prefix+ctrl+p` | 次 / 前の workspace へ | |
| `prefix+w` | 一覧を出して選ぶ。一覧の中では `n` / `p` (または ↓ / ↑) で上下に移る | ○ (`n` / `p` は追加) |
| `prefix+g` | workspace・tab・pane のツリーを検索して移動する | ○ |
| `prefix+ctrl+o` | ghq のリポジトリを fzf で選び、そこで workspace を作る | |
| `prefix+shift+s` | pane のディレクトリのパス順に並べ替える (`bin/herdr-sort-workspaces`) | |
| `prefix+shift+n` | workspace を作る | ○ |
| `prefix+shift+g` | git worktree を作って workspace として開く | ○ |
| `prefix+shift+w` / `prefix+shift+d` | 名前を変える / 閉じる | ○ |

### agent

| キー | 動作 | 既定 |
|---|---|---|
| `prefix+ctrl+j` / `prefix+ctrl+k` | サイドバーで次 (下) / 前 (上) の agent へ | |
| `prefix+ctrl+1..9` | 上から N 番目の agent へ | |
| `prefix+o` | 通知を出した agent へ | ○ |

サイドバーの agent は、手を入れる必要がある順に並ぶ (`agent_panel_sort = "priority"`)。そのため `prefix+ctrl+1` で、一番対応が必要な agent に飛べる。

### tab

| キー | 動作 | 既定 |
|---|---|---|
| `prefix+n` / `prefix+p` | 次 / 前の tab へ。workspace の端では、サイドバーで隣の workspace の tab に移る (`bin/herdr-tab-cycle`) | |
| `prefix+ctrl+f` / `prefix+ctrl+b` | 今の workspace の中で、次 / 前の tab へ | |
| `prefix+1..9` | N 番目の tab へ | ○ |
| `prefix+c` / `prefix+ctrl+c` | tab を作る。名前は聞かない (`prompt_new_tab_name = false`) | `prefix+c` のみ |
| `prefix+shift+t` | tab の名前を変える | ○ |
| `prefix+shift+x` | tab を閉じる | ○ |

### pane

| キー | 動作 | 既定 |
|---|---|---|
| `prefix+h/j/k/l` | 左 / 下 / 上 / 右の pane へ | ○ |
| `prefix+shift+h/j/k/l` | 左 / 下 / 上 / 右の pane と入れ替える | ○ |
| `prefix+tab` / `prefix+shift+tab` | 次 / 前の pane へ | ○ |
| `prefix+;` | 直前の pane に戻る。workspace や tab をまたいでも戻れる | |
| `prefix+0` / `prefix+!` | 新しい tab に切り出す (tmux の break-pane) | |
| `prefix+v` / `prefix+-` | 縦 / 横に分割する | ○ |
| `prefix+z` | 全画面にする | ○ |
| `prefix+r` | サイズを変えるモードに入る | ○ |
| `prefix+x` | 閉じる | ○ |

### コピー・スクロール・検索

| キー | 動作 | 既定 |
|---|---|---|
| `prefix+[` | コピーモードに入る | ○ |
| `prefix+]` | クリップボードの中身を pane に送る | |
| `prefix+e` | スクロールバックを `$EDITOR` で開く | ○ |

コピーモードの中では vim に似たキーが使える。

- 移動: `w` / `b` / `e`、`W` / `B` / `E`、`$`、`Ctrl+u` / `Ctrl+d` など
- 検索: `?` で上へ、`/` で下へ。`n` / `N` で次の一致へ。正規表現ではなく文字列で探し、大文字と小文字は smart-case で扱う
- ヤンクすると macOS のクリップボードに入る

コピーモードは画面の一番下から始まるので、過去の出力を探すときは `?` を使う。

### その他

| キー | 動作 | 既定 |
|---|---|---|
| `prefix+?` | キーの一覧を出す | ○ |
| `prefix+s` | 設定画面を開く | ○ |
| `prefix+shift+r` | 設定を読み直す | ○ |
| `prefix+b` | サイドバーを開閉する | ○ |
| `prefix+q` | デタッチする | ○ |

## 注意点

- **設定の再読み込み**: `prefix+shift+r` と `herdr server reload-config` はサーバーで設定を読む。herdr を更新したあと、古いサーバーが動いたままだと新しい書き方を読めない。このとき `[keys]` は全体が読み込まれず、前の設定のまま残る。`herdr status` で `server_binary_stale: yes` なら、`herdr server stop` と `herdr` で起動し直す。agent は `resume_agents_on_restore` で元の会話に戻る。
- **prefix を 2 回押す**: prefix の文字がそのまま pane に送られる。`prefix+ctrl+t` に別の動作を割り当てると、この動作とぶつかるかもしれないので避けている。
- **ctrl 付きで使えないキー**: 端末によっては、`ctrl+h` は Backspace、`ctrl+i` は Tab、`ctrl+m` は Enter、`ctrl+[` は Esc と区別できない。tmux の `C-t C-[` (copy-mode) を herdr で同じにできないのはこのため。
- **変えられないキー**: コピーモードに入るキー (`keys.copy_mode`) は変えられる。一方、コピーモードの中のキーや PageUp / PageDown などのスクロールキーには設定項目がない。
- **`prefix+]` の複数行**: `herdr pane send-text` で送っている。複数行のテキストが 1 回の貼り付けとして届くかは確かめていない。複数行は `Cmd+V` で貼るほうが確実。
- **通知**: `ui.toast.delivery = "herdr"` で herdr の中に通知を出している。`prefix+o` は通知が出ている間だけ効く。
