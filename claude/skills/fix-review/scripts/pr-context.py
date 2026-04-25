#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///

"""PR のコンテキスト (メタ情報 + レビュースレッド) を整形して 1 度で取得する"""

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
          path
          line
          originalLine
          comments(first: 50) {
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
    }
  }
}
"""


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
    pr_author = (pr.get("author") or {}).get("login")

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
                    "author": (c.get("author") or {}).get("login"),
                    "body": c["body"],
                    "url": c["url"],
                }
            )
        threads.append(
            {
                "threadId": t["id"],
                "isResolved": t["isResolved"],
                "path": t["path"],
                "line": t["line"] if t["line"] is not None else t["originalLine"],
                "replyToCommentId": first_id,
                "lastAuthor": comments[-1]["author"] if comments else None,
                "comments": comments,
            }
        )

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
    }
    json.dump(out, sys.stdout, ensure_ascii=False, indent=2)
    print()


if __name__ == "__main__":
    main()
