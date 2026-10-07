# Passwordless git access to GitHub over SSH:
#   1. trust github.com, checking its host key against the fingerprint GitHub publishes
#   2. create an SSH key if there is none
#   3. pause while the public key is added on github.com (the only manual step)
#   4. check the login and switch the dotfiles remote from HTTPS to SSH

GITHUB_SSH_KEY="$HOME/.ssh/id_ed25519"
# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
GITHUB_ED25519_FINGERPRINT="SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU"

setup_github() {
  info "GitHub SSH access"
  trust_github_host || return 0
  if ! github_user >/dev/null; then
    create_ssh_key
    register_key_on_github
  fi
  local user
  user="$(github_user)" || { warn "GitHub still rejects the key; re-run: ./install.sh github"; return 0; }
  ok "authenticated as $user"
  use_ssh_remote
}

# ssh -T always exits with 1 on GitHub, so success is read from its greeting
github_user() {
  local greeting
  greeting="$(ssh -T -o BatchMode=yes -o ConnectTimeout=10 git@github.com 2>&1 || true)"
  [[ "$greeting" =~ ^Hi\ ([^!]+)! ]] && echo "${BASH_REMATCH[1]}"
}

trust_github_host() {
  if ssh-keygen -F github.com >/dev/null; then return 0; fi
  local host_key
  host_key="$(ssh-keyscan -t ed25519 github.com 2>/dev/null)"
  if ! has_github_fingerprint "$host_key"; then
    warn "github.com host key does not match GitHub's published fingerprint, stopping"
    return 1
  fi
  mkdir -p -m 700 "$HOME/.ssh"
  echo "$host_key" >>"$HOME/.ssh/known_hosts"
  ok "github.com added to known_hosts (fingerprint verified)"
}

has_github_fingerprint() {
  [[ -n "$1" && "$(ssh-keygen -lf - <<<"$1" | awk '{print $2}')" == "$GITHUB_ED25519_FINGERPRINT" ]]
}

# A passphrase protects the key if the disk is ever copied; Ubuntu's keyring can
# remember it at login so it is never typed again. Empty passphrase = no prompt at all.
create_ssh_key() {
  if [[ -f "$GITHUB_SSH_KEY" ]]; then ok "using existing key $GITHUB_SSH_KEY"; return; fi
  echo "  Creating an SSH key. Passphrase: leave it empty, or set one and tick"
  echo "  'automatically unlock' the first time Ubuntu asks for it."
  ssh-keygen -t ed25519 -f "$GITHUB_SSH_KEY" \
    -C "$(git config --file "$GIT_LOCAL_CONFIG" user.email) ($(hostname))" </dev/tty
}

register_key_on_github() {
  echo
  echo "  Add this public key to GitHub (opening https://github.com/settings/ssh/new):"
  echo "    Title: $(hostname)    Key type: Authentication Key    Key:"
  echo
  cat "$GITHUB_SSH_KEY.pub"
  echo
  xdg-open https://github.com/settings/ssh/new >/dev/null 2>&1 || true
  read -rp "  Press Enter once you have clicked 'Add SSH key'... " </dev/tty
}

# Cloning a fresh machine uses HTTPS (no key yet); pushing needs the SSH remote
use_ssh_remote() {
  local url
  url="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null)" || return 0
  [[ "$url" == https://github.com/* ]] || return 0
  git -C "$DOTFILES_DIR" remote set-url origin "git@github.com:${url#https://github.com/}"
  ok "dotfiles remote switched to SSH"
}
