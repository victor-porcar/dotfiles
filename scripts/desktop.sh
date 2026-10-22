install_desktop() {
  info "Desktop (GNOME)"
  if ! command_exists gnome-shell; then warn "GNOME not found, skipping"; return; fi
  install_apt_list desktop/apt.txt
  install_snap_list desktop/snaps.txt
  install_chrome
  install_gnome_extensions
  set_wallpaper
  load_dconf_settings
  install_desktop_launchers
}

install_desktop_launchers() {
  install_retro_console
  install_launchers
  install_terminal_launcher
  install_openmsx_launcher
  install_redisinsight_launcher
}

# openMSX (MSX emulator): the .deb ships its own launcher, just pin it to the desktop
install_openmsx_launcher() {
  local desktop_file=/usr/share/applications/openmsx.desktop
  if [[ ! -f "$desktop_file" ]]; then warn "openMSX desktop file not found"; return; fi
  copy_to_desktop "$desktop_file" openmsx.desktop
  ok "launcher: openMSX"
}

# RedisInsight: the snap ships its own launcher, just pin it to the desktop
install_redisinsight_launcher() {
  local desktop_file=/var/lib/snapd/desktop/applications/redisinsight_redisinsight.desktop
  if [[ ! -f "$desktop_file" ]]; then warn "RedisInsight desktop file not found"; return; fi
  copy_to_desktop "$desktop_file" redisinsight.desktop
  ok "launcher: RedisInsight"
}

# The system's own terminal launcher: Ptyxis (default since Ubuntu 25.10) if
# installed, GNOME Terminal otherwise
install_terminal_launcher() {
  local app
  for app in org.gnome.Ptyxis org.gnome.Terminal; do
    [[ -f "/usr/share/applications/$app.desktop" ]] || continue
    copy_to_desktop "/usr/share/applications/$app.desktop" terminal.desktop
    ok "launcher: Terminal ($app)"
    return
  done
  warn "no terminal launcher found (Ptyxis or GNOME Terminal)"
}

# Desktop launchers must be executable and marked trusted, or GNOME won't run them
copy_to_desktop() {
  local target
  target="$(xdg-user-dir DESKTOP)/$2"
  install -m 755 "$1" "$target"
  gio set "$target" metadata::trusted true
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
