GIT_LOCAL_CONFIG="$HOME/.gitconfig.local"

setup_git_identity() {
  info "Git identity ($GIT_LOCAL_CONFIG)"
  if git config --file "$GIT_LOCAL_CONFIG" user.email >/dev/null; then
    ok "already configured"
    return
  fi
  write_git_identity
}

write_git_identity() {
  local name email
  name="$(ask 'Name' "$(git config --global user.name || true)")"
  email="$(ask 'Email' "$(git config --global user.email || true)")"
  git config --file "$GIT_LOCAL_CONFIG" user.name "$name"
  git config --file "$GIT_LOCAL_CONFIG" user.email "$email"
  ok "saved"
}
