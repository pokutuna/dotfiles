import type { EngineInterface, Register } from "claude-code";

// モデルの応答に付いてくる rate limit (5h / 7d) を ~/.cache/claude-usage-record/ に記録する。
// CLI と Claude.app はログインが別のことがあるため、cli.json と desktop.json に分ける。

type UsageRecord = {
  session: "cli" | "desktop";
  recordedAt: string;
  rateLimits: { kind: string; percentUsed: number; resetsAt?: string }[];
};

export const register: Register = (on) => {
  on("session.measure", async ($, e, next) => {
    if (e.changed.includes("rateLimits") && e.rateLimits.length > 0) {
      await record($, e.rateLimits).catch((error) =>
        $.ui.log(`${$.plugin.name}: could not record: ${String(error)}`),
      );
    }
    return next(e);
  });
};

async function record(
  $: EngineInterface,
  rateLimits: UsageRecord["rateLimits"],
): Promise<void> {
  const home = await $.env.get("HOME");
  if (home === undefined) return;

  const isDesktop =
    (await $.env.get("CLAUDE_CODE_ENTRYPOINT")) === "claude-desktop" ||
    (await $.session.surface()) === "desktop";
  const session = isDesktop ? "desktop" : "cli";

  const value: UsageRecord = {
    session,
    recordedAt: new Date(await $.clock.now()).toISOString(),
    rateLimits: rateLimits.map(({ kind, percentUsed, resetsAt }) => ({
      kind,
      percentUsed,
      resetsAt,
    })),
  };
  await $.fs.write(
    `${home}/.cache/claude-usage-record/${session}.json`,
    `${JSON.stringify(value, null, 2)}\n`,
  );
}
