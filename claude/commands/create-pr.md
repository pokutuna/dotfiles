ゴール: 現在のブランチの内容で PullRequest を作成する

<EXTRA_CONTEXT>
$ARGUMENTS
</EXTRA_CONTEXT>

### EXTRA_CONTEXT の考慮
`<EXTRA_CONTEXT>` に追加の指示が与えられます
- PR 作成先が含まれていれば、そのブランチをターゲットに PullRequest を作成してください
- PR 作成先が含まれていなければ、デフォルトのベースブランチへ PullRequest を作成してください
- デフォルトで Draft PullRequest として作成してください
  - `ready` 等のワードが含まれていれば、通常の PullRequest として作成してください

### PullRequest Template の検索
- リポジトリ中に PullRequest Template が存在するか確認し、あれば利用してください
- PullRequest Template はリポジトリルートの .github/ 以下に配置されている可能性があります
  - git rev-parse --show-toplevel でルートディレクトリを確認し、.github/ 以下を確認してください
- 複数のテンプレートが存在する場合は現在の修正内容から適切なものを選択してください


### PullRequest の作成
- もしブランチが remote に push されていなければ push してください
- description に変更内容を適切に記述してください
  - 作業過程ではなく、ベースブランチとの差分を説明してください
  - `git diff origin/main...HEAD` でリモートのベースブランチとの差分を確認してください
  - もし必要であれば、トレードオフや未解決の問題についても言及してください
- 確認した内容があれば簡潔に箇条書きで加えてください
  - 例: テストが通った、ビルドが成功したことを確認した など
- `--assignee=pokutuna` を指定してください
- 作成したのち `gh pr view --web` でブラウザで開いてください

### Copilot レビューの依頼 (ブラウザで開いた後に実行)
- リポジトリの owner が `hatena` の場合、Copilot レビューを依頼してください
  - ただし `<EXTRA_CONTEXT>` に「レビュー不要」「no review」等の指示があれば依頼しない
- `gh pr create` の `--reviewer` では bot を指定できないため、以下を実行:
  ```
  gh api repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers \
    --method POST -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
  ```
- PR 番号は `gh pr view --json number -q .number` で取得できます
