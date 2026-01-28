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

let contextTokens: number;
let contextPercent: number;

if (currentUsage) {
  // Sum of tokens currently in context
  const {
    input_tokens,
    output_tokens,
    cache_creation_input_tokens,
    cache_read_input_tokens,
  } = currentUsage;
  contextTokens = [
    input_tokens,
    output_tokens,
    cache_creation_input_tokens,
    cache_read_input_tokens,
  ].reduce((sum, v) => sum + (v ?? 0), 0);
  contextPercent = Math.round((contextTokens * 100) / contextSize);
} else if (contextWindow?.used_percentage != null) {
  contextPercent = Math.round(contextWindow.used_percentage);
  contextTokens = Math.round((contextPercent * contextSize) / 100);
} else {
  contextTokens = contextWindow?.total_input_tokens ?? 0;
  contextPercent = Math.round((contextTokens * 100) / contextSize);
}

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
const durationFmt = formatDuration(durationMs);
const apiDurationFmt = formatDuration(apiDurationMs);
const tokenFmt = contextTokens.toLocaleString();

// ANSI color codes
const color = (code: number) => (s: string) => `\x1b[${code}m${s}\x1b[0m`;
const [red, green] = [31, 32].map(color);

// Shorten path: keep last 2+ segments full, abbreviate earlier ones to uppercase first letter
// Only abbreviate if path exceeds maxLength
function shortenPath(
  path: string,
  maxLength = 32,
  minFullSegments = 2,
): string {
  const segments = path.split("/").filter(Boolean);
  if (segments.length <= minFullSegments) return path;
  if (path.length <= maxLength) return path;

  // Start with all segments abbreviated except the last minFullSegments
  const result = [...segments];
  let currentLength = result.join("/").length;

  // Abbreviate from the beginning until we're under maxLength or hit minFullSegments
  for (
    let i = 0;
    i < segments.length - minFullSegments && currentLength > maxLength;
    i++
  ) {
    const original = result[i];
    const abbreviated = original.charAt(0).toUpperCase();
    result[i] = abbreviated;
    currentLength = result.join("/").length;
  }

  return result.join("/");
}

let gitInfo = "";
try {
  // Use project_dir for branch (stable even when cd to different dirs)
  const branch = (
    await $`git -C ${projectDir} branch --show-current`.quiet().text()
  ).trim();
  if (branch) {
    const gitRoot = (
      await $`git -C ${projectDir} rev-parse --show-toplevel`.quiet().text()
    ).trim();
    // Check if currentDir is inside the git repo
    const isInsideRepo = currentDir.startsWith(gitRoot);
    let shortPath: string;
    if (!isInsideRepo) {
      // Outside repo - show with arrow icon
      const dirName = currentDir.split("/").pop() ?? currentDir;
      shortPath = `↗ ${dirName}`;
    } else if (currentDir === gitRoot) {
      shortPath = ".";
    } else {
      const relPath = currentDir.replace(`${gitRoot}/`, "");
      shortPath = shortenPath(relPath);
    }
    gitInfo = ` | ${green(shortPath)}:${red(branch)}`;
  }
} catch {
  // Not a git repo
}

// Format: 🤖 Model | 💰 $X.XX | ⏱️ elapsed (api) | 🧠 tokens (%) | branch:path
console.log(
  `🤖 ${model} | 💰 ${costFmt} | ⏱️ ${durationFmt} (${apiDurationFmt}) | 🧠 ${tokenFmt} (${contextPercent}%)${gitInfo}`,
);
