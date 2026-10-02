if [[ -f /usr/lib/git-core/git-sh-prompt ]]; then
  source /usr/lib/git-core/git-sh-prompt
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=auto
fi

prompt_git() {
  declare -F __git_ps1 >/dev/null && __git_ps1 ' (%s)'
}

hg_root() {
  local dir="$PWD"
  while [[ -n "$dir" ]]; do
    if [[ -d "$dir/.hg" ]]; then echo "$dir"; return; fi
    dir="${dir%/*}"
  done
  return 1
}

# Reads .hg files directly: running `hg` on every prompt would be too slow
prompt_hg() {
  local root branch bookmark
  root="$(hg_root)" || return 0
  branch="$(cat "$root/.hg/branch" 2>/dev/null || echo default)"
  bookmark="$(cat "$root/.hg/bookmarks.current" 2>/dev/null)"
  printf ' (hg:%s%s)' "$branch" "${bookmark:+|$bookmark}"
}

PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0;33m\]$(prompt_git)$(prompt_hg)\[\e[0m\]\$ '
