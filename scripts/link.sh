link_dotfiles() {
  info "Enlaces simbólicos"
  link_file bash/bashrc               "$HOME/.bashrc"
  link_file bash/inputrc              "$HOME/.inputrc"
  link_file git/gitconfig             "$HOME/.gitconfig"
  link_file git/ignore                "$HOME/.config/git/ignore"
  link_file vim/vimrc                 "$HOME/.vimrc"
  link_file editorconfig/editorconfig "$HOME/.editorconfig"
  copy_if_missing java/maven/settings.xml "$HOME/.m2/settings.xml"
}
