link_dotfiles() {
  info "Symlinks"
  link_file bash/bashrc               "$HOME/.bashrc"
  link_file bash/inputrc              "$HOME/.inputrc"
  link_file git/gitconfig             "$HOME/.gitconfig"
  link_file git/ignore                "$HOME/.config/git/ignore"
  link_file vim/vimrc                 "$HOME/.vimrc"
  link_file tmux/tmux.conf            "$HOME/.config/tmux/tmux.conf"
  link_file systemd/tmp.conf          "$HOME/.config/user-tmpfiles.d/tmp.conf"
  copy_if_missing bash/bashrc.local.example "$HOME/.bashrc.local"
  copy_if_missing java/maven/settings.xml   "$HOME/.m2/settings.xml"
}
