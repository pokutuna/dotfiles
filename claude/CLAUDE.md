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
- `fd`: Fast file finder, use instead of `find` for searching files by name/pattern, supports regex and glob patterns (e.g., `fd -e py` for Python files)
- `rg`: Fast text search in files, use instead of `grep` for code searching
- `ast-grep`: Structural code search using AST patterns, use for refactoring and finding code structures (e.g., `ast-grep --pattern 'foo($$$)'` to find all calls to function foo)
- `jq`: JSON processor for transforming and filtering JSON data (e.g., `jq '.items[] | select(.price > 100)'`)
- `duckdb`: SQL database for cross-file aggregation and analysis (CSV, JSON, Parquet), use for GROUP BY, JOIN, or statistical operations (e.g., `duckdb -s "SELECT * FROM '*.csv'"`)

## Language-Specific Rules

### Python
- Python 開発時は原則として uv を使う
