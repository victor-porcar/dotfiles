GIT_LOCAL_CONFIG="$HOME/.gitconfig.local"

setup_git_identity() {
  info "Identidad de git ($GIT_LOCAL_CONFIG)"
  if git config --file "$GIT_LOCAL_CONFIG" user.email >/dev/null; then
    ok "ya configurada"
    return
  fi
  write_git_identity
}

write_git_identity() {
  local name email
  name="$(ask 'Nombre' "$(git config --global user.name || true)")"
  email="$(ask 'Email' "$(git config --global user.email || true)")"
  git config --file "$GIT_LOCAL_CONFIG" user.name "$name"
  git config --file "$GIT_LOCAL_CONFIG" user.email "$email"
  ok "guardada"
}
