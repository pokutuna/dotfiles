#!/bin/zsh
# runpod-ps1: Show RunPod pod count and cost in prompt
# Usage: runpodon / runpodoff

zmodload -F zsh/stat b:zstat

RUNPOD_PS1_ENABLED="${RUNPOD_PS1_ENABLED:-off}"
RUNPOD_PS1_CACHE_TTL="${RUNPOD_PS1_CACHE_TTL:-60}"
_RUNPOD_PS1_CACHE="/tmp/runpod-ps1-${UID}"
_RUNPOD_PS1_LOCK="/tmp/runpod-ps1-${UID}.lock"

runpodon() {
  if ! type runpodctl &>/dev/null; then
    echo "runpodon: runpodctl not found" >&2
    return 1
  fi
  RUNPOD_PS1_ENABLED=on
}
runpodoff() { RUNPOD_PS1_ENABLED=off }

_runpod_ps1_fetch() {
  local now=$(date +%s)
  local mtime=0

  if [[ -f "$_RUNPOD_PS1_CACHE" ]]; then
    mtime=$(zstat +mtime "$_RUNPOD_PS1_CACHE" 2>/dev/null)
    mtime=${mtime:-0}
  fi

  if (( now - mtime >= RUNPOD_PS1_CACHE_TTL )); then
    # Skip if another fetch is already running
    [[ -f "$_RUNPOD_PS1_LOCK" ]] && return

    (
      touch "$_RUNPOD_PS1_LOCK"
      # Skip header (NR>1), sum $/HR (field 12), count pods
      runpodctl get pod --allfields 2>/dev/null \
        | awk -F'\t' 'NR>1 && $1!="" { count++; cost+=$12 } END { if(count>0) printf "%d %.2f\n", count, cost }' \
        > "$_RUNPOD_PS1_CACHE" 2>/dev/null
      rm -f "$_RUNPOD_PS1_LOCK"
    ) &!
  fi
}

runpod_ps1() {
  [[ "$RUNPOD_PS1_ENABLED" == "off" ]] && return

  _runpod_ps1_fetch

  [[ -f "$_RUNPOD_PS1_CACHE" ]] || return
  local data
  data=$(<"$_RUNPOD_PS1_CACHE")
  [[ -z "$data" ]] && return

  local count cost
  count=${data%% *}
  cost=${data#* }
  echo "(⚡${count}:\$${cost}/hr)"
}
