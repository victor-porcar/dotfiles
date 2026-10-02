install_packages() {
  info "System packages (apt)"
  local packages
  mapfile -t packages < <(read_list packages/apt.txt)
  sudo apt-get update -qq
  sudo apt-get install -y "${packages[@]}"
  ok "${#packages[@]} packages installed"
}
