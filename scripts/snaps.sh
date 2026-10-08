install_snap_list() {
  local snaps line
  mapfile -t snaps < <(read_list "$1")
  for line in "${snaps[@]}"; do
    install_snap $line
  done
}

# Installs the latest stable version, or updates it now if already installed
# (snap also auto-updates in the background a few times a day)
install_snap() {
  local name="$1"
  if snap list "$name" >/dev/null 2>&1; then refresh_snap "$name"; return; fi
  if sudo snap install "$@"; then ok "$name: installed"; return; fi
  warn "$name: installation failed"
}

# snap refuses to update an app while it is running
refresh_snap() {
  if sudo snap refresh "$1"; then ok "$1: up to date"; return; fi
  warn "$1: could not update now (close it and re-run, or wait for the automatic update)"
}
