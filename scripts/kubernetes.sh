# Kubernetes CLI tools: kubectl (snap), kubectx/kubens (apt, packages step) and k9s.
# k9s comes from its official .deb on GitHub: the k9s snap stopped being updated in 2023.

K9S_RELEASES=https://github.com/derailed/k9s/releases

install_kubernetes_tools() {
  info "Kubernetes tools"
  install_snap kubectl --classic
  install_k9s
}

install_k9s() {
  local latest installed
  latest="$(curl -fsSL -o /dev/null -w '%{url_effective}' "$K9S_RELEASES/latest")"
  latest="${latest##*/v}"
  installed="$(dpkg-query -W -f='${Version}' k9s 2>/dev/null)"
  if [[ -n "$installed" && "$installed" == "$latest" ]]; then ok "k9s $installed: up to date"; return; fi
  install_k9s_deb && ok "k9s: installed ${latest:-latest}" || warn "k9s: installation failed"
}

install_k9s_deb() {
  local deb status
  deb="$(mktemp --suffix=.deb)"
  curl -fsSL -o "$deb" "$K9S_RELEASES/latest/download/k9s_linux_amd64.deb" && sudo apt-get install -y "$deb"
  status=$?
  rm -f "$deb"
  return $status
}
