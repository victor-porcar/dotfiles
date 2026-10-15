# retro-console (github.com/victor-porcar/retro-console): desktop launchers that open
# as tabs of one retro terminal window. Installed, or updated with git pull, and then
# the launchers in desktop/launchers.txt are (re)created.

RETRO_CONSOLE_REPO=https://github.com/victor-porcar/retro-console.git
RETRO_CONSOLE_BIN="$HOME/.local/bin/retro-console"

install_retro_console() {
  local repo
  if [[ -x "$RETRO_CONSOLE_BIN" ]]; then
    repo="$(dirname "$(dirname "$(readlink -f "$RETRO_CONSOLE_BIN")")")"
    git -C "$repo" pull -q --ff-only || warn "retro-console: could not update $repo"
  else
    repo="$HOME/.local/share/retro-console"
    git clone -q "$RETRO_CONSOLE_REPO" "$repo" || { warn "retro-console: clone failed"; return; }
  fi
  "$repo/install.sh" >/dev/null && ok "retro-console installed ($repo)"
}

# Lines: name | tab | icon | command
install_launchers() {
  local name tab icon command
  while IFS='|' read -r name tab icon command; do
    "$RETRO_CONSOLE_BIN" add "$(trim "$name")" --tab "$(trim "$tab")" \
      --icon "$(trim "$icon")" --run "$(trim "$command")"
  done < <(read_list desktop/launchers.txt)
}
