---
name: disk-cleanup
description: ローカルディスクの空き容量を回収する。既知の候補 (uv/npm/brew/HF/Ollama のキャッシュ、mise や go/rust/scala のツールチェーン、node_modules/.venv、使っていないアプリ) を狙って測り、影響の小さい順に提案する。探索は足りないときだけ範囲を絞って行う。「ディスクが足りない」「容量を空けたい」「No space left on device」のとき、また定期的な棚卸しに使う。
allowed-tools:
  - Bash
  - Bash(*clean-recreatable.sh *)
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# ディスククリーンアップ

空き容量を回収する。**既知の候補を提案 → 確認 → 実行 → (足りなければ) 範囲を絞って探索** の順に進める。
調査は自分で進めてよいが、**削除は必ずユーザーの承認を得てから実行する**。

## 大原則: 探索より知識を先に使う

ホーム全体の `du` や `fd` から始めない。遅いうえに、結果はたいてい既知の候補 (手順2の表) と同じ場所を指す。

1. **知識で当てる** — 決まったパスを狙って測る (1コマンドで候補が出揃う)
2. **影響の小さいものから提案する** — 再生成可能キャッシュ → 再取得コストの高いもの → ユーザー判断が必要なもの
3. **目標に届いたら終わる** — 探索しない
4. **足りないときだけ探索する** — しかも1階層ずつ、大きい枝だけ

「全部調べてから提案する」のではなく「安全な提案を先に出して、必要になったら調べる」。

## 大原則: 削除の確認ルール

| 種別 | 例 | 扱い |
|---|---|---|
| **再生成可能キャッシュ** | uv / npm / Homebrew / puppeteer のキャッシュ、`__pycache__` | 候補としてまとめて提示し、一括承認でよい |
| **再取得に時間や帯域がかかるもの** | HuggingFace モデル、Ollama モデル、Docker イメージ | **個別に中身を列挙**して承認を取る (再DLに数十分かかる) |
| **アクティブな作業環境** | 使用中リポジトリの `.venv`、シミュレータ環境 | 原則対象外。消すなら復旧コマンド (`uv sync` 等) を明示して承認を取る |
| **ユーザーデータ** | `~/Documents` `~/Downloads` `~/Desktop`、写真、ソースコード、`~/.claude` のセッション履歴 | **勝手に消さない。** 一覧を出して判断を仰ぐだけ |
| **アプリケーション** | `/Applications/*.app` | **提案のみ。** 最終使用日を根拠として示し、削除はユーザーに任せる |

守ること:

- `rm -rf` を打つ前に、対象パスを**実際に列挙して**ユーザーに見せる。glob やパターンだけ見せて承認を取らない
- 専用のクリーンアップコマンドがあるなら生 `rm` より優先する (`uv cache clean`, `brew cleanup`, `npm cache clean --force`, `ollama rm`, `docker image prune`)
- **回収量はツールの申告値を使い、ディレクトリサイズの合計から推測しない。** 共有レイヤや hard link があると二重計上される (Docker イメージ、pnpm store、HF cache が該当)
- パターン一括削除は `-n` / dry-run を必ず先に通し、件数とサイズを見せる
- 「空き容量が目標に届いた」時点で止める。目標がなければ何割空けたいかを聞く
- ゴミ箱に入れる操作は容量を回収しない。`~/.Trash` を空にするところまでが1セット

## 手順

### 1. 現状を測る

```sh
df -h /
```

空きと使用率を記録する。ユーザーに「何GB空けたいか」の目標がなければ聞く。

### 2. 知っている候補を、狙って測る

**探索から始めない。** `du ~/*` や `fd` でホーム全体を歩くのは遅く、しかも結局下の表と同じ場所に行き着く。
まず既知のパスだけを**1回の `du -sh` にまとめて**渡す。存在しないパスは黙って落ちるので、全部並べてよい。

存在しないパスは `2>/dev/null` で黙って落ちるので、**入っていないツールの分も含めて全部並べてよい**:

```sh
du -sh \
  ~/Library/Caches/uv ~/.cache/huggingface ~/.ollama/models \
  ~/.npm/_cacache ~/.npm/_npx ~/Library/Caches/Homebrew \
  ~/.cache/puppeteer ~/.cache/ms-playwright \
  ~/Library/Developer/Xcode/DerivedData ~/.Trash \
  ~/.local/share/mise ~/.cache/mise \
  ~/go/pkg/mod ~/Library/Caches/go-build \
  ~/.cargo/registry ~/.rustup ~/.cache/sccache \
  ~/.m2/repository ~/.gradle/caches ~/.ivy2 ~/.sbt ~/Library/Caches/Coursier ~/.cache/coursier \
  ~/Library/pnpm ~/.local/share/pnpm ~/.bun/install/cache ~/.deno \
  ~/.rbenv/versions ~/.nvm/versions ~/.pyenv/versions \
  2>/dev/null | sort -rh
```

1回で候補が出揃う (初回は1分程度かかることがある。それでもホーム全体を歩くより速く、結果は具体的)。
**ここで目標に届くなら探索は不要** — 手順3に飛んで承認を取る。

表に無いツールを使っているなら候補に足す。

下の表は「どこを見るか」の知識であって、サイズの記録ではない。**サイズは必ずその場で測る**
(前回の実行やユーザー自身の手作業で既に空になっていることがある)。

| パス | 内容 | 回収コマンド |
|---|---|---|
| `~/Library/Caches/uv` | uv のパッケージ/ビルドキャッシュ | `uv cache clean` |
| `~/.cache/huggingface` | HF モデル/データセット | `hf cache ls` で内訳を見せ、`hf cache prune` (detached revision のみ) → 足りなければ `hf cache rm <repo>`。旧 CLI は `huggingface-cli scan-cache` / `delete-cache` |
| `~/.ollama/models` | ローカル LLM モデル | `ollama list` を見せて不要分を `ollama rm <model>` |
| `~/.npm/_cacache`, `~/.npm/_npx` | npm/npx キャッシュ | `npm cache clean --force` |
| `~/Library/Caches/Homebrew`, `$(brew --cache)` | brew ダウンロードキャッシュ | `brew cleanup -s` |
| `~/.cache/puppeteer`, `~/.cache/ms-playwright` | ブラウザバイナリ | 削除して再DL可 |
| `~/Library/Developer/Xcode/DerivedData` | Xcode ビルド成果物 | 削除可 |
| Docker/OrbStack の VM ディスク | コンテナイメージ・ビルドキャッシュ | `docker system df` で実際の reclaimable を見る。下の注意を必ず読む |
| `~/.Trash` | ゴミ箱 | 中身を列挙してから空にする |

**Docker は見積もりを間違えやすい。** 次の3点を踏まえて提案する:

- **`docker images` のサイズは合計しても回収量にならない。** 各行は共有レイヤを含む apparent size なので二重計上される。`docker system df` の `RECLAIMABLE` を唯一の根拠にする (それでも共有分だけ楽観的に出る)
- **`--volumes` を安易に付けない。** named volume は DB やエミュレータの実データ置き場で、キャッシュではない。`docker volume ls` で中身を列挙し、回収量 (`docker system df` の Local Volumes 行) と引き換えに失うものを示して個別に承認を取る。回収量が数MBなら**やる意味がない**
- **VM バックエンド (OrbStack / Docker Desktop) では `df` が動かない。** VM 内で解放されてもホストのスパースディスクは縮まないので、`docker system df` は減っても空き容量は増えないことがある。ホスト側の空きを増やすには VM の縮小/再作成が必要

安全度の順は `docker image prune` (dangling のみ) → `docker builder prune` → `docker image prune -a` (**未使用のタグ付きも消える**ので要承認)。
`prune -a` の前には稼働中コンテナが参照するイメージだけでなく、**再 build に時間がかかる巨大イメージ**が含まれないか確認する
(`docker images --format '{{.Size}}\t{{.Repository}}:{{.Tag}}' | sort -rh | head`)。関連リポジトリの最新コミットが最近なら作業中の可能性が高い。

**compose ビルドのイメージは worktree と対で増える。** compose はディレクトリ名をプロジェクト名にするので、
`<dir>-<service>:latest` 形式のイメージ・`<dir>_*` volume・network が worktree ごとに積まれ、worktree を消しても残る。
由来は `com.docker.compose.project` ラベルで機械的に引ける
(`docker images --filter "label=com.docker.compose.project=<name>"`)。現存 worktree と稼働コンテナに突き合わせて残骸を特定し、
worktree が残っていれば `docker compose --project-directory <dir> down --rmi local --volumes --remove-orphans` が正規手段、
消えていればラベル指定で `docker rmi` / `docker volume rm` する。
このマシンでは git-wt の `wt.deletehook` (`~/bin/wt-compose-cleanup`) が worktree 削除時に回収するので、
残骸があるならフック導入 (2026-08) より前のものか、wt を経由せず消された worktree のもの。

`~/.claude` が大きい場合はセッション履歴なので**自動削除しない**。内訳だけ報告する。

#### 言語ツールチェーン / バージョンマネージャ

Python/Node に偏った表だけ見ていると見落とす。**Go の module cache や mise の旧バージョンは数GB〜十数GB規模になる。**

| パス | 内容 | 回収コマンド |
|---|---|---|
| `~/.local/share/mise/installs` | mise が入れたツールの全バージョン | `mise ls --prunable` で対象を見せ、`mise prune -n` (dry-run) → `mise prune` |
| `~/go/pkg/mod` | Go module cache (読み取り専用で `rm` しにくい) | `go clean -modcache` |
| `~/Library/Caches/go-build` | Go ビルドキャッシュ | `go clean -cache` |
| `~/.cargo/registry`, `~/.cache/sccache` | Rust の crate/ビルドキャッシュ | `~/.cargo/registry/{cache,src}` を削除 (`cargo-cache` があれば `cargo cache -a`) |
| `~/.rustup/toolchains` | Rust ツールチェーン (stable/nightly が積む) | `rustup toolchain list` を見せて `rustup toolchain uninstall <name>` |
| `~/.m2/repository` | Maven ローカルリポジトリ | 削除して再DL可 (全消しは重いので古い版のみでも可) |
| `~/.gradle/caches` | Gradle キャッシュ | 削除可。`~/.gradle/caches/modules-2` が主 |
| `~/Library/Caches/Coursier`, `~/.ivy2`, `~/.sbt` | Scala (sbt/coursier) の依存キャッシュ | 削除して再DL可 |
| `~/Library/pnpm`, `~/.local/share/pnpm` | pnpm の content-addressable store | `pnpm store prune` (**未参照分のみ**消すので安全) |
| `~/.bun/install/cache` | Bun の依存キャッシュ | `bun pm cache rm` |
| `~/.deno` | Deno の依存/ビルドキャッシュ | `deno clean` |
| `~/.rbenv/versions`, `~/.nvm/versions`, `~/.pyenv/versions` | 旧バージョンマネージャの処理系 | mise 等に移行済みなら丸ごと不要な可能性。**移行状況を確認してから提案する** |

判断のポイント:

- **バージョンマネージャは「未参照」を機械的に出せる。** 目で古そうな版を選ぶのではなく `mise ls --prunable` / `mise prune -n` / `pnpm store prune` のような**ツール側の判定に任せる**。プロジェクトの `mise.toml` や `.node-version` が参照している版を誤って消さずに済む
- ただし `mise prune` は `~/.local/state/mise/tracked-configs` に**記録済みの config だけ**を見る。一度も `mise` 経由で入っていないリポジトリの版は「未参照」と判定され得るので、`mise ls --prunable` の一覧はユーザーに見せて確認する
- `mise` の `installs/<tool>/` にはサイズ 0 の**シンボリックリンク** (`22`, `lts`, `latest` 等) が並ぶ。実体は `x.y.z` のディレクトリなので、サイズは実体側で見る
- 複数のバージョンマネージャが併存している (mise + rbenv + nvm 等) なら、**現在どれを使っているか**を聞く。使っていない側は丸ごと候補になる

### 3. 影響の小さい順に提案して承認を取る

手順2の実測値を、**影響度の低い順に並べて**提示する。冒頭の確認ルール表がそのまま優先順位になる:

1. 再生成可能キャッシュ (uv / npm / brew / puppeteer / DerivedData / ゴミ箱) — まとめて一括承認
2. 再取得コストの高いもの (HF / Ollama / Docker) — 中身を列挙してから個別承認

1 だけで目標に届くことが多い。届いたら**そこで終わる** — 探索もリポジトリ走査もしない。

### 4. 足りなければ、範囲を絞って探索する

手順3で目標に届かなかったときだけ実行する。ここで初めて「どこにあるか分からないもの」を探す。
**いきなりホーム全体を歩かない。** 1階層ずつ降りて、大きい枝だけを追う:

```sh
# まずホーム直下を1階層だけ (深く潜らないので速い)
du -sh -d 1 ~ 2>/dev/null | sort -rh | head -20
```

出てきた上位のうち、手順2で説明が付かないものだけを掘る。降りる先は毎回1つに絞る。

注意点:

- `~/Library` や巨大なリポジトリ置き場の全体 `du` はタイムアウトしやすい。`timeout 100 du ...` で打ち切りつつ、`du -sh -d 1 <path>` の形で降りる
- macOS では `df` の空きと `du` の合計は一致しない (APFS スナップショット、purgeable 領域)。差が大きければ `tmutil listlocalsnapshots /` を見る。`com.apple.TimeMachine.*` は `tmutil deletelocalsnapshots <date>` で消せるが、`com.apple.os.update-*` は OS 管理なので触らない
- 単発の巨大ファイルを探すのは、置き場所の見当が付いている場合に限る。`fd -t f -S +1g . ~/Downloads ~/Desktop ~/Movies` のように**ディレクトリを指定する**。`. ~` で全体を走らせない

### 5. 再生成可能ディレクトリを狙い撃つ

手順4でリポジトリ置き場 (`ghq` のルート、`~/src`、`~/dev` など) が大きいと分かった場合のみ。
コードを残したまま依存ディレクトリだけ回収できる。

**範囲を絞って渡すのが前提。** 置き場全体を一度に渡すと `du` の集計だけで固まる。
手順4で当たりが付いたサブディレクトリ (組織単位・リポジトリ単位) に分けて回す:

同梱スクリプトは**一覧を作るだけで、削除はしない**。削除コマンドは一覧ファイルの冒頭に
コメントとして書き込まれるので、中身を確認してからそれを実行する:

```sh
SCRIPTS=~/.claude/skills/disk-cleanup/scripts

# 1. 候補を探して一覧に書き出す (サイズ付きで上位40件が表示される)
$SCRIPTS/clean-recreatable.sh /tmp/cleanup.txt --older-than 90 <パス>...

# 2. 一覧をユーザーに見せて承認を得る

# 3. 承認されたら、一覧の冒頭に書かれたコマンドを実行する
grep -v '^#' /tmp/cleanup.txt | tr '\n' '\0' | xargs -0 rm -rf
```

**`--older-than <日数>` を使う。** 対象パス配下の git リポジトリのうち、最終コミットが
指定日数より古いものだけに絞る。現役リポジトリの `node_modules` を消さずに済む。
worktree (`.git` がファイルの構成) も個別に判定するので、親が現役でも放置 worktree は対象になる。

対象は `node_modules` `.venv` `__pycache__` `.mypy_cache` `.ruff_cache` `.pytest_cache`
`.next` `.turbo` `.tox` `.gradle` `dist` `build` `target` の 13 種。
一覧ファイルのパスと対象パスはどちらも必須で、省略するとエラーで止まる (カレント既定はない)。

- **削除は一覧ファイル経由で行う。** 探索と削除を分けることで、承認された一覧と削除対象が必ず一致する
- **広すぎる対象は exit 3 で拒否される。** ホーム / `/` は無条件、一致件数が 2000 を超える場合も停止する。
  絞り込むのが正解だが、意図的に広く回すなら `MAX_DIRS=<件数>` を付ける
- `dist` / `build` / `target` は**ソース管理下の本物のディレクトリと衝突し得る**。一覧を見て、コミット対象でないか確認する
- **`fd` は既定でスマートケースなので、`build` パターンが `Build` にもマッチする。** Perl の
  `local/lib/perl5/Module/Build` (モジュール実体) を誤検出した実例があるため、スクリプトは `-s` で固定し、
  `perl5` / `local/lib` / `vendor/bundle` / `.terraform` 配下を除外している。同種のパターンを自分で書くときも同じ注意が必要
- 言語構成によって効く対象が変わる (Python 中心なら `.venv` が支配的、Node 中心なら `node_modules`)。実測を見て判断する
- `~/.cache` を巻き込まないよう、パターンに `.cache` は**意図的に含めていない**
- macOS の `xargs` に `-d` はない。`tr '\n' '\0' | xargs -0` を使う

ユーザーが自前のクリーンアップスクリプトを持っていることもある。あれば**そちらを優先する**
(除外条件が調整済みなことが多い)。dry-run オプションの有無を確認し、あれば必ず先に通す。

**使用中のリポジトリを除外する。** 最近コミットのあるものは避ける:

```sh
# 直近のコミット日時で「触っているか」を判定する
git -C <repo> log -1 --format=%cr
```

### 6. 使っていないアプリ・インストーラを提案する

削除はしない。**根拠を添えて一覧で提案する**。
対象は場所が決まっている (`/Applications`, `~/Downloads`) ので探索にはならない。手順3と同時に出してもよい。

```sh
# アプリのサイズと最終使用日
du -sh /Applications/* 2>/dev/null | sort -rh | head -20
mdls -name kMDItemLastUsedDate -name kMDItemDisplayName /Applications/*.app 2>/dev/null

# ~/Downloads の大きいもの・古いもの
fd -t f -S +100m . ~/Downloads -x ls -lh {} \; 2>/dev/null
fd -t f -e dmg -e pkg -e zip . ~/Downloads --changed-before 90d 2>/dev/null
```

提案は「サイズ + 最終使用日 + なぜ不要と見たか」の3点セットで書く。
インストーラ (`.dmg` / `.pkg`) は展開済みなら基本不要なので指摘しやすい。

### 7. 実行して報告する

- 実行するたび `df -h /` を取り、回収量を確認する
- 目標に届いたら止める。まだ足りなければ次の候補に進む
- 期待より回収できていない場合は APFS スナップショットや purgeable を疑う (手順4の注意点)

### 8. 記録を残す

調査した内容は次回のために書き残す。ただし **サイズの表は劣化する情報** なので、残す価値があるのは:

- **削除対象外と判断したもの + その理由** (毎回調べ直さなくて済む。最も価値が高い)
- 実施履歴 (日付・実施内容・回収容量)
- そのマシン固有の発見 (どのキャッシュが効いたか、どの `du` が重いか)

サイズの一覧を長期保存する意味は薄い。書くなら「いつ時点の値か」を明記し、次回は測り直す前提にする。
記録先はユーザーに確認する (プロジェクト内の `CLEANUP.md`、ノート、など)。

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>
