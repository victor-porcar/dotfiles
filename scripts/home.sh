declare -A UNWANTED_XDG_DIRS=(
  [MUSIC]="Music Música"
  [VIDEOS]="Videos Vídeos"
  [TEMPLATES]="Templates Plantillas"
  [PUBLICSHARE]="Public Público"
)

clean_home() {
  info "Home directories"
  local name
  for name in "${!UNWANTED_XDG_DIRS[@]}"; do
    remove_xdg_dir "$name"
  done
  redirect_xdg_dir DOCUMENTS "$HOME/docs" "Documents Documentos"
}

# Pointing the XDG dir to $HOME stops the desktop from recreating it at login
remove_xdg_dir() {
  local name="$1" dir
  set_xdg_dir "$name" "$HOME"
  for dir in ${UNWANTED_XDG_DIRS[$name]}; do
    remove_empty_dir "$HOME/$dir"
  done
}

redirect_xdg_dir() {
  local name="$1" target="$2" old_names="$3" dir
  mkdir -p "$target"
  set_xdg_dir "$name" "$target"
  ok "$name -> $target"
  for dir in $old_names; do
    remove_empty_dir "$HOME/$dir"
  done
}

set_xdg_dir() {
  if command_exists xdg-user-dirs-update; then xdg-user-dirs-update --set "$1" "$2"; fi
}

remove_empty_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then return; fi
  if rmdir "$dir" 2>/dev/null; then ok "$dir: removed"; return; fi
  warn "$dir: not empty, left untouched"
}
