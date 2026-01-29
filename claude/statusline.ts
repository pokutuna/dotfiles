#!/usr/bin/env bun
// Simple statusline for Claude Code
// Docs: https://code.claude.com/docs/en/statusline

import { $ } from "bun";

// Claude Code statusline hook input
// https://code.claude.com/docs/en/statusline#json-input-structure
type HookInput = {
  hook_event_name?: string;
  session_id?: string;
  transcript_path?: string;
  cwd?: string;
  model?: {
    id?: string;
    display_name?: string;
  };
  workspace?: {
    current_dir?: string;
    project_dir?: string;
  };
  version?: string;
  output_style?: {
    name?: string;
  };
  cost?: {
    total_cost_usd?: number;
    total_duration_ms?: number;
    total_api_duration_ms?: number;
    total_lines_added?: number;
    total_lines_removed?: number;
  };
  context_window?: {
    total_input_tokens?: number;
    total_output_tokens?: number;
    context_window_size?: number;
    used_percentage?: number;
    remaining_percentage?: number;
    current_usage?: {
      input_tokens?: number;
      output_tokens?: number;
      cache_creation_input_tokens?: number;
      cache_read_input_tokens?: number;
    };
  };
};

const input: HookInput = JSON.parse(await Bun.stdin.text());

const model = input.model?.display_name ?? "Unknown";
const cost = input.cost?.total_cost_usd ?? 0;
const durationMs = input.cost?.total_duration_ms ?? 0;
const apiDurationMs = input.cost?.total_api_duration_ms ?? 0;
const currentDir = input.workspace?.current_dir ?? process.cwd();
const projectDir = input.workspace?.project_dir ?? currentDir;

// Context usage - prefer current_usage (actual context), fallback to used_percentage
const contextWindow = input.context_window;
const currentUsage = contextWindow?.current_usage;
const contextSize = contextWindow?.context_window_size ?? 200000;

const contextTokens = currentUsage
  ? Object.values(currentUsage).reduce((sum, v) => sum + (v ?? 0), 0)
  : contextWindow?.used_percentage != null
    ? Math.round((contextWindow.used_percentage * contextSize) / 100)
    : (contextWindow?.total_input_tokens ?? 0);
const contextPercent = Math.round((contextTokens * 100) / contextSize);

// Format duration: "1h 23m" or "45m" or "30s"
function formatDuration(ms: number): string {
  const totalSeconds = Math.floor(ms / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  if (hours > 0) return `${hours}h${minutes}m`;
  if (minutes > 0) return `${minutes}m${seconds}s`;
  return `${seconds}s`;
}

const costFmt = `$${cost.toFixed(2)}`;
const formatK = (n: number) =>
  n >= 1000 ? `${(n / 1000).toFixed(0)}k` : `${n}`;
const totalIn = formatK(contextWindow?.total_input_tokens ?? 0);
const totalOut = formatK(contextWindow?.total_output_tokens ?? 0);
const durationFmt = formatDuration(durationMs);
const apiDurationFmt = formatDuration(apiDurationMs);

// Context progress bar
const contextK = formatK(contextTokens);
const contextSizeK = formatK(contextSize);
const barLength = 10;
const filledLength = Math.round((contextPercent / 100) * barLength);
const progressBar =
  "▰".repeat(filledLength) + "▱".repeat(barLength - filledLength);

// ANSI color codes
const color = (code: number) => (s: string) => `\x1b[${code}m${s}\x1b[0m`;
const [red, green] = [31, 32].map(color);

// Shorten path: abbreviate leading segments to uppercase first letter until under maxLength
// Always keep at least minFullSegments at the end
function shortenPath(
  path: string,
  maxLength = 32,
  minFullSegments = 3,
): string {
  const segments = path.split("/").filter(Boolean);
  if (segments.length <= minFullSegments || path.length <= maxLength)
    return path;

  const result = [...segments];
  for (let i = 0; i < segments.length - minFullSegments; i++) {
    result[i] = result[i].charAt(0).toUpperCase();
    if (result.join("/").length <= maxLength) break;
  }
  return result.join("/");
}

// Format path: strip ghq root or home prefix
async function formatPath(fullPath: string): Promise<string> {
  const ghqRoot = await $`ghq root`
    .quiet()
    .text()
    .then((s) => s.trim())
    .catch(() => "");
  if (ghqRoot && fullPath.startsWith(ghqRoot))
    return fullPath.slice(ghqRoot.length + 1);

  const home = process.env.HOME ?? "";
  if (home && fullPath.startsWith(home))
    return "~" + fullPath.slice(home.length);

  return fullPath;
}

const gitInfo = await (async () => {
  const branch = await $`git -C ${projectDir} branch --show-current`
    .quiet()
    .text()
    .then((s) => s.trim())
    .catch(() => "");
  if (!branch) return "";

  const path = shortenPath(await formatPath(currentDir));
  const arrow = currentDir.startsWith(projectDir) ? "" : "↗ ";
  return ` | ${green(arrow + path)}:${red(branch)}`;
})();

// Model | Context | Session | Path:Branch
console.log(
  `${model} | ${contextK}/${contextSizeK} ${progressBar}  ${contextPercent}% | Session: ${costFmt}・↥ ${totalIn} ↧ ${totalOut}・◷ ${durationFmt} ⧗ ${apiDurationFmt}${gitInfo}`,
);
