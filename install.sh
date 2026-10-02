#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in lib packages git link java; do
  source "$DOTFILES_DIR/scripts/$script.sh"
done

usage() {
  cat <<EOF
Usage: ./install.sh [step]

Steps:
  all       Everything, in this order (default)
  packages  System packages (apt)
  git       Git identity in ~/.gitconfig.local
  link      Symlink the dotfiles
  java      SDKMAN + JDK, Maven and Gradle
EOF
}

install_all() {
  install_packages
  setup_git_identity
  link_dotfiles
  install_java_toolchain
  info "Done. Open a new terminal or run: source ~/.bashrc"
}

main() {
  case "${1:-all}" in
    all)      install_all ;;
    packages) install_packages ;;
    git)      setup_git_identity ;;
    link)     link_dotfiles ;;
    java)     install_java_toolchain ;;
    *)        usage ;;
  esac
}

main "$@"
