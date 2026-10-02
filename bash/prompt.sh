if [[ -f /usr/lib/git-core/git-sh-prompt ]]; then
  source /usr/lib/git-core/git-sh-prompt
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=auto
fi

prompt_git() {
  declare -F __git_ps1 >/dev/null && __git_ps1 ' (%s)'
}

PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0;33m\]$(prompt_git)\[\e[0m\]\$ '
