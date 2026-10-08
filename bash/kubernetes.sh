alias k='kubectl'

# Generating kubectl's completion takes up to ~1.5 s, too slow for every new
# terminal, so it is cached and regenerated once a week
load_kubectl_completion() {
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/bash/kubectl-completion.bash"
  if [[ ! -s "$cache" || -n "$(find "$cache" -mtime +7 2>/dev/null)" ]]; then
    mkdir -p "$(dirname "$cache")"
    kubectl completion bash >"$cache" 2>/dev/null
  fi
  source "$cache"
  complete -o default -F __start_kubectl k
}

command -v kubectl >/dev/null && load_kubectl_completion
unset -f load_kubectl_completion
