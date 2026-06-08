## Rules
- ユーザーが質問したとき(入力が ? で終わっているとき)は、作業を開始せず、質問に答えること
- 「調べて」「調査して」と入力した場合は Web 検索や DeepWiki など外部情報源を参照して回答すること
- ユーザの指示でエディタで開く際は `code` コマンドを使用すること (例: `code tmp/output.txt`)

## Bash Tool Rules
- 都度リポジトリルートに cd しない
- 都度 git コマンドで -C project_root を指定しない
  - サブディレクトリから git や gh コマンドを利用する
  - 異なるリポジトリの操作を行う -> cd が必要

## Text Input Rules
- 英数字, カッコや記号は半角で入力する

## Recommend CLI Tools
- `rg`: text search, use instead of `grep` (e.g., `rg -t py 'def foo'`)
- `fd`: file search by name, use instead of `find` (e.g., `fd -e py`)
- `jq`: JSON processing (e.g., `jq '.items[] | select(.price > 100)'`)
- `duckdb`: cross-file aggregation/JOIN/stats over CSV/JSON/Parquet (e.g., `duckdb -s "SELECT * FROM '*.csv'"`)

## Language-Specific Rules

### Python
- Python 開発時は原則として uv を使う
