# Google Chrome is not in Ubuntu's repos. Its official .deb registers Google's apt
# repository on install, so from then on it is updated with the rest of the system.

CHROME_DEB_URL=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

install_chrome() {
  if dpkg -s google-chrome-stable >/dev/null 2>&1; then upgrade_chrome; return; fi
  local deb
  deb="$(mktemp --suffix=.deb)"
  if curl -fsSL -o "$deb" "$CHROME_DEB_URL" && sudo apt-get install -y "$deb"; then
    ok "google-chrome: installed"
  else
    warn "google-chrome: installation failed"
  fi
  rm -f "$deb"
}

upgrade_chrome() {
  if sudo apt-get install -y --only-upgrade google-chrome-stable; then ok "google-chrome: up to date"; return; fi
  warn "google-chrome: could not update"
}
