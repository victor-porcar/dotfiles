UNWANTED_XDG_DIRS=(MUSIC VIDEOS)

clean_home() {
  info "Unwanted home directories"
  local name
  for name in "${UNWANTED_XDG_DIRS[@]}"; do
    remove_xdg_dir "$name"
  done
}

# Pointing the XDG dir to $HOME stops the desktop from recreating it at login
remove_xdg_dir() {
  local name="$1" lower="${1,,}"
  local dir="$HOME/${lower^}"
  if command_exists xdg-user-dirs-update; then xdg-user-dirs-update --set "$name" "$HOME"; fi
  if [[ ! -d "$dir" ]]; then ok "$dir: not present"; return; fi
  if rmdir "$dir" 2>/dev/null; then ok "$dir: removed"; return; fi
  warn "$dir: not empty, left untouched"
}
