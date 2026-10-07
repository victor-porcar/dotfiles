# GNOME Terminal profiles from desktop/terminal-profiles/*.dconf
#
# How GNOME Terminal stores profiles (dconf):
#   /org/gnome/terminal/legacy/profiles:/list       -> ['uuid1', 'uuid2', ...]
#   /org/gnome/terminal/legacy/profiles:/default    -> 'uuid1'
#   /org/gnome/terminal/legacy/profiles:/:<uuid>/   -> the settings of each profile
#
# A profile only shows up if its UUID is in "list". Ubuntu starts with no "list" at
# all and a single built-in profile (BUILTIN_PROFILE), so when creating the first
# extra profile the built-in one must be added to the list too, or it would vanish.
#
# Profiles are matched by visible-name, so running the installer again updates the
# existing profile instead of adding a duplicate.

TERMINAL_PROFILES=/org/gnome/terminal/legacy/profiles:
BUILTIN_PROFILE=b1dcc9dd-5262-4d8d-a863-c897e6d979b9

install_terminal_profiles() {
  local file
  for file in "$DOTFILES_DIR"/desktop/terminal-profiles/*.dconf; do
    [[ -e "$file" ]] || continue
    install_terminal_profile "$file"
  done
}

install_terminal_profile() {
  local file="$1" name uuid
  name="$(sed -n "s/^visible-name='\(.*\)'$/\1/p" "$file")"
  uuid="$(find_terminal_profile "$name")" || uuid="$(add_terminal_profile)"
  dconf load "$TERMINAL_PROFILES/:$uuid/" <"$file"
  ok "terminal profile: $name"
}

# Prints the UUIDs in "list", one per line (empty if "list" was never set)
terminal_profile_uuids() {
  dconf read "$TERMINAL_PROFILES/list" | tr -d "[]',"  | tr ' ' '\n' | grep -v '^$'
}

find_terminal_profile() {
  local name="$1" uuid
  for uuid in $(terminal_profile_uuids); do
    if [[ "$(dconf read "$TERMINAL_PROFILES/:$uuid/visible-name")" == "'$name'" ]]; then
      echo "$uuid"
      return 0
    fi
  done
  return 1
}

# Registers a new UUID in "list", keeping the existing profiles (or the built-in one)
# and pinning the current default so normal terminals don't switch profile.
add_terminal_profile() {
  local uuid uuids
  uuid="$(uuidgen)"
  uuids="$(terminal_profile_uuids)"
  [[ -n "$uuids" ]] || uuids="$BUILTIN_PROFILE"
  dconf write "$TERMINAL_PROFILES/list" "[$(printf "'%s', " $uuids)'$uuid']"
  [[ -n "$(dconf read "$TERMINAL_PROFILES/default")" ]] \
    || dconf write "$TERMINAL_PROFILES/default" "'${uuids%%$'\n'*}'"
  echo "$uuid"
}
