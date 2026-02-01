---
description: GitHub PullRequest に対応する GitHub Actions の CI 実行を確認し、失敗を分析・修正する
allowed-tools:
  - Bash(gh pr checks:*)
  - Bash(gh run view:*)
  - Bash(gh pr checkout:*)
---
ゴール: GitHub PullRequest に対応する GitHub Actions の CI 実行を確認し、失敗を分析・修正する

<PR_IDENTIFIER>
$ARGUMENTS
</PR_IDENTIFIER>

## PR と CI 情報の取得

`<PR_IDENTIFIER>` から PR を特定 (空なら現在のブランチの PR を使用)

```bash
gh pr checks [<number>]  # 引数なしで現在ブランチの PR
gh pr checks --json name,state,bucket --jq '.[] | select(.bucket == "fail")'
gh run view <run_id> --log-failed
```

## 修正フロー

1. 失敗ログからエラー箇所と原因を特定
2. 必要に応じて `gh pr checkout <number>` でブランチをチェックアウト
3. PR の意図を損なわない最小限の修正を実施
4. 可能ならローカルでビルド/テスト/lint を実行して検証

## 報告

- **CI 状況**: 失敗した job とエラー内容
- **修正内容**: 変更したファイルと根拠
- **残課題**: CI 環境固有の問題など

## 注意

- **`git push` を実行しない** - プッシュはユーザーに任せる
