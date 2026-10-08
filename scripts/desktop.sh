install_desktop() {
  info "Desktop (GNOME)"
  if ! command_exists gnome-shell; then warn "GNOME not found, skipping"; return; fi
  install_apt_list desktop/apt.txt
  install_snap_list desktop/snaps.txt
  install_chrome
  install_gnome_extensions
  set_wallpaper
  load_dconf_settings
  install_terminal_profiles
  install_launchers
}

# Copied (not linked) and marked trusted, otherwise GNOME won't let them run
install_launchers() {
  local desktop file
  desktop="$(xdg-user-dir DESKTOP)"
  for file in "$DOTFILES_DIR"/desktop/launchers/*.desktop; do
    install -m 755 "$file" "$desktop/"
    gio set "$desktop/$(basename "$file")" metadata::trusted true
    ok "launcher: $(basename "$file" .desktop)"
  done
}

install_gnome_extensions() {
  local uuid
  for uuid in $(read_list desktop/gnome-extensions.txt); do
    install_gnome_extension "$uuid"
  done
}

extension_installed() {
  gnome-extensions info "$1" >/dev/null 2>&1
}

# GNOME Shell downloads the version matching itself and shows a confirmation dialog.
# Its D-Bus reply is unreliable, so the result is checked afterwards.
install_gnome_extension() {
  local uuid="$1"
  if extension_installed "$uuid"; then ok "$uuid: already installed"; return; fi
  gdbus call --session --timeout 300 --dest org.gnome.Shell.Extensions \
    --object-path /org/gnome/Shell/Extensions \
    --method org.gnome.Shell.Extensions.InstallRemoteExtension "$uuid" >/dev/null 2>&1 || true
  if extension_installed "$uuid"; then ok "$uuid: installed"; return; fi
  warn "$uuid: not installed (cancelled or not available for this GNOME version)"
}

set_wallpaper() {
  local image
  image="$(find "$DOTFILES_DIR/desktop/wallpapers" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort | head -n1)"
  if [[ -z "$image" ]]; then ok "no wallpaper in desktop/wallpapers"; return; fi
  gsettings set org.gnome.desktop.background picture-uri "file://$image"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$image"
  ok "wallpaper: $(basename "$image")"
}

# File name is the dconf path with dots: org.gnome.shell.extensions.vitals.conf
load_dconf_settings() {
  local file path
  for file in "$DOTFILES_DIR"/desktop/dconf/*.conf; do
    [[ -e "$file" ]] || continue
    path="/$(basename "$file" .conf | tr . /)/"
    dconf load "$path" <"$file"
    ok "dconf: $path"
  done
}
