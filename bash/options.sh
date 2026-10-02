shopt -s checkwinsize
shopt -s globstar
shopt -s cdspell
shopt -s autocd

if ! shopt -oq posix && [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi
