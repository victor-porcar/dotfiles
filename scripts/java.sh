SDKMAN_DIR="$HOME/.sdkman"

install_java_toolchain() {
  info "Java toolchain (SDKMAN)"
  install_sdkman
  install_sdk_candidates
}

install_sdkman() {
  if [[ -d "$SDKMAN_DIR" ]]; then ok "SDKMAN already installed"; return; fi
  curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash
  ok "SDKMAN installed"
}

install_sdk_candidates() {
  local candidates line
  mapfile -t candidates < <(read_list java/sdkman-candidates.txt)
  set +u
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdkman_auto_answer=true
  for line in "${candidates[@]}"; do
    install_sdk_candidate $line
  done
  set -u
}

# sdk exits 0 even when a download fails (e.g. a server answering 429 "too many
# requests" makes it report a corrupt archive), so success is checked on disk
install_sdk_candidate() {
  local candidate="$1"
  sdk install "$@" || true
  [[ -d "$SDKMAN_DIR/candidates/$candidate/current" ]] && return
  warn "$candidate: download failed, retrying in 10 s"
  sleep 10
  sdk install "$@" || true
  [[ -d "$SDKMAN_DIR/candidates/$candidate/current" ]] || warn "$candidate not installed: run ./install.sh java again later"
}
