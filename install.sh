#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in lib packages git link java; do
  source "$DOTFILES_DIR/scripts/$script.sh"
done

usage() {
  cat <<EOF
Uso: ./install.sh [paso]

Pasos:
  all       Todo, en este orden (por defecto)
  packages  Paquetes del sistema (apt)
  git       Identidad de git en ~/.gitconfig.local
  link      Enlaces simbólicos de los dotfiles
  java      SDKMAN + JDK, Maven y Gradle
EOF
}

install_all() {
  install_packages
  setup_git_identity
  link_dotfiles
  install_java_toolchain
  info "Listo. Abre una terminal nueva o ejecuta: source ~/.bashrc"
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
