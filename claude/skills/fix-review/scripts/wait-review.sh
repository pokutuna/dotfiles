#!/usr/bin/env bash
#
# PR の最新 commit に対するレビューが付くまで待つ。
# Usage: wait-review.sh <owner> <repo> <pr_number>
#
# 終了コード:
#   0: 最新 commit に対するレビューが存在
#   1: タイムアウト (10 分)
#   2: 引数エラー / gh コマンド失敗

set -euo pipefail

INTERVAL=30
TIMEOUT=600

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <owner> <repo> <pr_number>" >&2
  exit 2
fi

owner=$1
repo=$2
pr=$3

head_sha=$(gh pr view "$pr" --repo "$owner/$repo" --json headRefOid --jq '.headRefOid')
if [[ -z "$head_sha" ]]; then
  echo "headRefOid を取得できませんでした" >&2
  exit 2
fi
echo "対象 commit: $head_sha"

reviewed_count() {
  gh api "repos/$owner/$repo/pulls/$pr/reviews" \
    --jq "[.[] | select(.commit_id == \"$head_sha\")] | length"
}

if [[ "$(reviewed_count)" -gt 0 ]]; then
  echo "既にレビュー済み"
  exit 0
fi

echo "待機中"

elapsed=0
while (( elapsed < TIMEOUT )); do
  sleep "$INTERVAL"
  elapsed=$(( elapsed + INTERVAL ))
  if [[ "$(reviewed_count)" -gt 0 ]]; then
    echo "レビュー完了 (経過: ${elapsed}s)"
    exit 0
  fi
  echo "経過 ${elapsed}s"
done

echo "タイムアウト (${TIMEOUT}s)" >&2
exit 1
