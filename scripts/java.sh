SDKMAN_DIR="$HOME/.sdkman"

install_java_toolchain() {
  info "Toolchain Java (SDKMAN)"
  install_sdkman
  install_sdk_candidates
}

install_sdkman() {
  if [[ -d "$SDKMAN_DIR" ]]; then ok "SDKMAN ya instalado"; return; fi
  curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash
  ok "SDKMAN instalado"
}

install_sdk_candidates() {
  local candidates line
  mapfile -t candidates < <(read_list java/sdkman-candidates.txt)
  set +u
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdkman_auto_answer=true
  for line in "${candidates[@]}"; do
    sdk install $line || warn "falló: sdk install $line"
  done
  set -u
}
