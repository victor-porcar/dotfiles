#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in lib packages git github link java home desktop terminal-profiles chrome; do
  source "$DOTFILES_DIR/scripts/$script.sh"
done

usage() {
  cat <<EOF
Usage: ./install.sh [step]

Steps:
  all       Everything, in this order (default)
  packages  System packages (apt)
  git       Git identity in ~/.gitconfig.local
  github    Passwordless SSH access to GitHub (pauses to add the key on github.com)
  link      Symlink the dotfiles
  java      SDKMAN + JDK, Maven and Gradle
  home      Tidy home dirs, Documents -> ~/docs, create ~/personal and ~/work

Optional (not part of all):
  desktop   GNOME extensions, terminal profiles, wallpaper and dconf settings
EOF
}

install_all() {
  install_packages
  setup_git_identity
  setup_github
  link_dotfiles
  install_java_toolchain
  clean_home
  info "Done. Open a new terminal or run: source ~/.bashrc"
}

main() {
  case "${1:-all}" in
    all)      install_all ;;
    packages) install_packages ;;
    git)      setup_git_identity ;;
    github)   setup_github ;;
    link)     link_dotfiles ;;
    java)     install_java_toolchain ;;
    home)     clean_home ;;
    desktop)  install_desktop ;;
    *)        usage ;;
  esac
}

main "$@"
