---
description: GitHub PullRequest に対応する CI (GitHub Actions / Google Cloud Build) の実行を確認し、失敗を分析・修正する
allowed-tools:
  - Bash(gh pr checks:*)
  - Bash(gh run view:*)
  - Bash(gh pr checkout:*)
  - Bash(gcloud builds describe:*)
  - Bash(gcloud builds log:*)
  - Bash(gcloud projects list:*)
---
ゴール: GitHub PullRequest に対応する CI の実行を確認し、失敗を分析・修正する

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>

`<ARGUMENTS>` から以下を抽出する (順不同、空白区切り):
- `wait` トークン: CI 実行中なら完了を待ってから修正フローに入る
- それ以外 (数字 / URL): PR 識別子 (空なら現在のブランチの PR)

## CI 完了待ち (wait が指定された場合のみ)

`gh pr checks [<number>] --watch --fail-fast` をバックグラウンドで起動し、完了まで待つ。
- Bash tool の `run_in_background: true` で起動
- Monitor tool で標準出力/終了を監視し、完了したら次フェーズへ
- 10 分経っても終わらなければ中断してユーザーに報告

## PR と CI 情報の取得

```bash
gh pr checks [<number>]  # 引数なしで現在ブランチの PR
gh pr checks --json name,state,bucket --jq '.[] | select(.bucket == "fail")'
```

### GitHub Actions の場合

```bash
gh run view <run_id> --log-failed
```

### Google Cloud Build の場合

`gh pr checks` の出力に `console.cloud.google.com/cloud-build/builds/` を含む URL があれば Cloud Build。
URL から build ID と project number を抽出して詳細を取得する。

```bash
# Build ID は URL パスから、project number は query parameter から取得
# 例: https://console.cloud.google.com/cloud-build/builds/<build_id>?project=<project_number>

# project number から project ID を取得 (gcloud は project ID が必要)
gcloud projects list --filter="projectNumber=<project_number>" --format="value(projectId)"

gcloud builds describe <build_id> --project=<project_id> --format="yaml(status,statusDetail,failureInfo)"
gcloud builds log <build_id> --project=<project_id>
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
