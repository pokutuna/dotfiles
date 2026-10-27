#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///

"""PR のコンテキスト (メタ情報 + レビュースレッド + レビュー本文 + 会話欄) を整形して 1 度で取得する"""

import json
import subprocess
import sys

QUERY = """
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      number
      title
      body
      url
      headRefName
      baseRefName
      headRefOid
      author { login }
      files(first: 100) { nodes { path } }
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first: 100) {
            nodes {
              databaseId
              body
              url
              author { login }
              replyTo { databaseId }
            }
          }
        }
      }
      reviews(first: 100) {
        nodes {
          databaseId
          state
          body
          url
          submittedAt
          author { login }
        }
      }
      comments(first: 100) {
        nodes {
          databaseId
          body
          url
          createdAt
          author { login }
        }
      }
    }
  }
}
"""


def login(node: dict) -> str | None:
    return (node.get("author") or {}).get("login")


def main() -> None:
    if len(sys.argv) != 4:
        print("Usage: pr-context.py <owner> <repo> <pr_number>", file=sys.stderr)
        sys.exit(1)

    owner, repo, pr_number = sys.argv[1], sys.argv[2], sys.argv[3]

    result = subprocess.run(
        [
            "gh",
            "api",
            "graphql",
            "-f",
            f"query={QUERY}",
            "-f",
            f"owner={owner}",
            "-f",
            f"repo={repo}",
            "-F",
            f"pr={pr_number}",
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        sys.exit(result.returncode)

    raw = json.loads(result.stdout)
    pr = raw["data"]["repository"]["pullRequest"]
    pr_author = login(pr)

    threads = []
    for t in pr["reviewThreads"]["nodes"]:
        comments = []
        first_id = None
        for c in t["comments"]["nodes"]:
            cid = c["databaseId"]
            if c.get("replyTo") is None and first_id is None:
                first_id = cid
            comments.append(
                {
                    "id": cid,
                    "author": login(c),
                    "body": c["body"],
                    "url": c["url"],
                }
            )
        # PR 作成者の最後の返信より後のコメント = 未返信のコメント
        last_own = max(
            (i for i, c in enumerate(comments) if c["author"] == pr_author),
            default=-1,
        )
        threads.append(
            {
                "threadId": t["id"],
                "isResolved": t["isResolved"],
                "isOutdated": t["isOutdated"],
                "path": t["path"],
                "line": t["line"] if t["line"] is not None else t["originalLine"],
                "replyToCommentId": first_id,
                "lastAuthor": comments[-1]["author"] if comments else None,
                "pendingCommentIds": [c["id"] for c in comments[last_own + 1 :]],
                "comments": comments,
            }
        )

    # レビュー本文と会話欄のコメントはスレッドを持たないので、PR 作成者が後から
    # 会話欄にコメントしたかで返信済みかを推定する
    own_comment_times = [
        c["createdAt"] for c in pr["comments"]["nodes"] if login(c) == pr_author
    ]

    def commented_after(ts: str | None) -> bool:
        return ts is not None and any(t > ts for t in own_comment_times)

    reviews = [
        {
            "id": r["databaseId"],
            "author": login(r),
            "state": r["state"],
            "body": r["body"],
            "url": r["url"],
            "submittedAt": r["submittedAt"],
            "authorCommentedAfter": commented_after(r["submittedAt"]),
        }
        for r in pr["reviews"]["nodes"]
        if r["body"].strip() and login(r) != pr_author
    ]

    conversation = [
        {
            "id": c["databaseId"],
            "author": login(c),
            "body": c["body"],
            "url": c["url"],
            "createdAt": c["createdAt"],
            "authorCommentedAfter": commented_after(c["createdAt"]),
        }
        for c in pr["comments"]["nodes"]
        if login(c) != pr_author
    ]

    out = {
        "number": pr["number"],
        "title": pr["title"],
        "body": pr["body"],
        "url": pr["url"],
        "author": pr_author,
        "headRefName": pr["headRefName"],
        "baseRefName": pr["baseRefName"],
        "headRefOid": pr["headRefOid"],
        "files": [f["path"] for f in pr["files"]["nodes"]],
        "reviewThreads": threads,
        "reviews": reviews,
        "conversation": conversation,
    }
    json.dump(out, sys.stdout, ensure_ascii=False, indent=2)
    print()


if __name__ == "__main__":
    main()
