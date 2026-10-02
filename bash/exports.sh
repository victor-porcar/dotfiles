path_prepend() {
  [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
export PATH

export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESS='-R -F -X'
