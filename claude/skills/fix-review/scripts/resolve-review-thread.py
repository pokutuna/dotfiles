#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///

"""複数のレビュースレッドをまとめて resolve する"""

import subprocess
import sys


def main() -> None:
    thread_ids = sys.argv[1:]
    if not thread_ids:
        print(
            "Usage: resolve-review-thread.py <thread_id> [thread_id...]",
            file=sys.stderr,
        )
        sys.exit(1)

    fragments = " ".join(
        f't{i}: resolveReviewThread(input: {{threadId: "{tid}"}}) {{ thread {{ isResolved }} }}'
        for i, tid in enumerate(thread_ids)
    )
    query = f"mutation {{ {fragments} }}"

    result = subprocess.run(
        ["gh", "api", "graphql", "-f", f"query={query}"],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        sys.exit(result.returncode)

    print(result.stdout)


if __name__ == "__main__":
    main()
