BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '  \033[1;32m✔\033[0m %s\n' "$*"; }
warn() { printf '  \033[1;33m!\033[0m %s\n' "$*" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

read_list() {
  grep -vE '^[[:space:]]*(#|$)' "$DOTFILES_DIR/$1"
}

ask() {
  local question="$1" default="$2" answer
  read -rp "  $question [$default]: " answer </dev/tty
  echo "${answer:-$default}"
}

backup() {
  local target="$1"
  local destination="$BACKUP_DIR/${target#"$HOME"/}"
  mkdir -p "$(dirname "$destination")"
  mv "$target" "$destination"
  warn "backup: $target -> $destination"
}

link_file() {
  local source="$DOTFILES_DIR/$1" target="$2"
  if [[ "$(readlink "$target")" == "$source" ]]; then ok "$target"; return; fi
  if [[ -e "$target" || -L "$target" ]]; then backup "$target"; fi
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  ok "$target -> $source"
}

copy_if_missing() {
  local source="$DOTFILES_DIR/$1" target="$2"
  if [[ -e "$target" ]]; then ok "$target (already exists, left untouched)"; return; fi
  mkdir -p "$(dirname "$target")"
  cp "$source" "$target"
  ok "$target (copied from template)"
}
