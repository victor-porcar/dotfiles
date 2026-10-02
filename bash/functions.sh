mkcd() {
  mkdir -p "$1" && cd "$1"
}

port() {
  ss -tulpn | grep -E "(State|:$1\b)"
}

extract() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz)       tar xJf "$1" ;;
    *.tar)          tar xf "$1" ;;
    *.zip|*.jar)    unzip "$1" ;;
    *.gz)           gunzip "$1" ;;
    *)              echo "Don't know how to extract '$1'" >&2; return 1 ;;
  esac
}
