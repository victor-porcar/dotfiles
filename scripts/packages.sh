install_packages() {
  info "System packages (apt)"
  install_apt_list packages/apt.txt
  join_docker_group
}

install_apt_list() {
  local packages
  mapfile -t packages < <(read_list "$1")
  sudo apt-get update -qq
  sudo apt-get install -y "${packages[@]}"
  ok "${#packages[@]} packages installed"
}

# Lets docker run without sudo. Note: the docker group is root-equivalent, which is
# the usual trade-off on a personal development machine.
join_docker_group() {
  if id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then ok "$USER is in the docker group"; return; fi
  sudo usermod -aG docker "$USER"
  warn "$USER added to the docker group: log out and back in for it to take effect"
}
