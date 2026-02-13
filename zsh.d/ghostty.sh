if [[ -z "$GHOSTTY_RESOURCES_DIR" ]]; then
  return
fi

ghostty-random-theme() {
  local config="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
  local -a themes
  themes=("${(@f)$(sed -n 's/^#*[[:space:]]*theme[[:space:]]*=[[:space:]]*//p' "$config")}")
  local selected=${themes[$((RANDOM % ${#themes[@]} + 1))]}
  sed -i '' "s/^theme = .*/theme = ${selected}/" "$config"
  osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}'
  echo "Theme: ${selected}"
}
