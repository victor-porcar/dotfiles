# Ctrl-R: fuzzy search in history   Ctrl-T: insert a file path   Alt-C: cd into a folder
if command -v fzf >/dev/null; then
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  else
    # fzf < 0.48 (Ubuntu 24.04) has no --bash option
    [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]] && source /usr/share/doc/fzf/examples/key-bindings.bash
  fi
fi

# fd is faster than find and skips what .gitignore ignores (target/, node_modules/...)
if command -v fdfind >/dev/null; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'
fi

export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border'
