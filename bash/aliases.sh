alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lhA'
alias grep='grep --color=auto'

alias ..='cd ..'
alias ...='cd ../..'

alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias du='du -h'

alias g='git'
alias gs='git status -sb'
alias gl='git lg'

alias reload='source ~/.bashrc'
alias dotfiles='cd "$DOTFILES_DIR"'

alias startAll='"$DOTFILES_DIR"/local-env/startAll.sh'
alias stopAll='"$DOTFILES_DIR"/local-env/stopAll.sh'
