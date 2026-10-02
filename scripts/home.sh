declare -A UNWANTED_XDG_DIRS=(
  [MUSIC]="Music Música"
  [VIDEOS]="Videos Vídeos"
)

clean_home() {
  info "Unwanted home directories"
  local name
  for name in "${!UNWANTED_XDG_DIRS[@]}"; do
    remove_xdg_dir "$name"
  done
}

# Pointing the XDG dir to $HOME stops the desktop from recreating it at login
remove_xdg_dir() {
  local name="$1" dir
  if command_exists xdg-user-dirs-update; then xdg-user-dirs-update --set "$name" "$HOME"; fi
  for dir in ${UNWANTED_XDG_DIRS[$name]}; do
    remove_empty_dir "$HOME/$dir"
  done
}

remove_empty_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then return; fi
  if rmdir "$dir" 2>/dev/null; then ok "$dir: removed"; return; fi
  warn "$dir: not empty, left untouched"
}
