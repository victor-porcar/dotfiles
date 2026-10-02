install_packages() {
  info "System packages (apt)"
  install_apt_list packages/apt.txt
}

install_apt_list() {
  local packages
  mapfile -t packages < <(read_list "$1")
  sudo apt-get update -qq
  sudo apt-get install -y "${packages[@]}"
  ok "${#packages[@]} packages installed"
}
