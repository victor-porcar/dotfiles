#!/usr/bin/env bash
set -uo pipefail

KUBENV_CONFIG="${KUBENV_CONFIG:-$HOME/work/environments/kubenv.properties}"
NAMESPACE=""
NAMESPACE_ARGS=()

USAGE="Usage: kubenv.sh [-n|--namespace <ns>] <kubeconfig|alias> <forward>...

  forward:  target:localPort[:remotePort[:kubeconfig|alias]]
  target:   deployment/statefulset name, pod name prefix, or resource (svc/solr, deploy/api)

Without --namespace, the namespace of the kubeconfig context is used.
Port-forwards reconnect automatically if the pod restarts. Ctrl-C stops them all.

Aliases are read from \$KUBENV_CONFIG ($KUBENV_CONFIG), one per line,
paths relative to that file:  my-env=kubeconfigs/my-env.yaml

Example: kubenv.sh -n my-namespace my-env search:8080 svc/solr:8984:8983:my-infra"

declare -A ALIASES

fail() {
  echo "$*" >&2
  exit 1
}

parse_args() {
  ARGS=("$@")
  case "${ARGS[0]:-}" in
    -n|--namespace) NAMESPACE="${ARGS[1]:-}"; ARGS=("${ARGS[@]:2}") ;;
    --namespace=*)  NAMESPACE="${ARGS[0]#*=}"; ARGS=("${ARGS[@]:1}") ;;
  esac
  [[ ${#ARGS[@]} -ge 2 ]] || fail "$USAGE"
  [[ -z "$NAMESPACE" ]] || NAMESPACE_ARGS=(--namespace "$NAMESPACE")
}

load_aliases() {
  [[ -f "$KUBENV_CONFIG" ]] || return 0
  local key value
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    ALIASES[$key]="${value%$'\r'}"
  done <"$KUBENV_CONFIG"
}

resolve_kubeconfig() {
  local path="$1"
  if [[ -n "${ALIASES[$1]:-}" ]]; then
    path="${ALIASES[$1]}"
    [[ "$path" == /* ]] || path="$(dirname "$KUBENV_CONFIG")/$path"
  fi
  [[ -f "$path" ]] || fail "kubeconfig not found: $1"
  readlink -f "$path"
}

kube() {
  KUBECONFIG="$1" kubectl "${NAMESPACE_ARGS[@]}" "${@:2}"
}

find_pod() {
  local kubeconfig="$1" target="$2" pods
  if [[ "$target" == */* ]]; then echo "$target"; return; fi
  pods="$(kube "$kubeconfig" get pods --field-selector=status.phase=Running -o name)" || return 1
  match_workload "$pods" "${target%-}" || match_prefix "$pods" "$target"
}

# Pod names are <deployment>-<hash>-<hash>, <daemonset>-<hash> or <statefulset>-<n>;
# the hashes use this alphabet, so "publisher" never matches "publisher-s3-..."
match_workload() {
  local name="${2//./\\.}" hash='[bcdfghjklmnpqrstvwxz2456789]'
  grep -m1 -E "^pod/$name-($hash{6,10}-$hash{5}|$hash{5}|[0-9]+)$" <<<"$1"
}

match_prefix() {
  local candidates
  candidates="$(grep "^pod/$2" <<<"$1")" || return 1
  if [[ "$(wc -l <<<"$candidates")" -gt 1 ]]; then
    echo "!! Several pods start with '$2', using the first:" $candidates >&2
  fi
  head -n1 <<<"$candidates"
}

pod_port() {
  kube "$1" get "$2" -o jsonpath='{.spec.containers[0].ports[0].containerPort}' 2>/dev/null
}

# Only previous port-forwards are killed; anything else on the port is left alone
free_local_port() {
  local port="$1" pid command
  pid="$(lsof -t -iTCP:"$port" -sTCP:LISTEN 2>/dev/null | head -n1)"
  [[ -z "$pid" ]] && return 0
  command="$(ps -o comm= -p "$pid")"
  if [[ "$command" == kubectl ]]; then kill "$pid"; echo "Stopped previous port-forward on $port"; return 0; fi
  echo "!! Port $port is in use by '$command' (pid $pid), skipping" >&2
  return 1
}

forward_once() {
  local kubeconfig="$1" target="$2" local_port="$3" remote_port="$4" pod port
  pod="$(find_pod "$kubeconfig" "$target")" || { echo "!! No Running pod for '$target'" >&2; return; }
  port="${remote_port:-$(pod_port "$kubeconfig" "$pod")}"
  echo "==> $pod  localhost:$local_port -> $port"
  # kubectl must be the background job itself so the TERM trap can kill it
  KUBECONFIG="$kubeconfig" kubectl "${NAMESPACE_ARGS[@]}" port-forward "$pod" "$local_port:$port" >/dev/null &
  wait $!
}

# Background jobs + wait keep the TERM trap responsive while kubectl or sleep run
forward_loop() {
  trap 'kill $(jobs -p) 2>/dev/null; exit' TERM HUP
  while true; do
    forward_once "$@"
    echo "!! Port-forward $2 stopped, retrying in 3s" >&2
    sleep 3 &
    wait $!
  done
}

start_forward() {
  local spec="$1" kubeconfig="$2" target local_port remote_port override
  IFS=: read -r target local_port remote_port override <<<"$spec"
  [[ -n "$target" && -n "$local_port" ]] || fail "Invalid forward '$spec'"$'\n\n'"$USAGE"
  if [[ -n "$override" ]]; then kubeconfig="$(resolve_kubeconfig "$override")" || return 0; fi
  free_local_port "$local_port" || return 0
  forward_loop "$kubeconfig" "$target" "$local_port" "$remote_port" &
}

show_context() {
  local namespace="$NAMESPACE"
  [[ -n "$namespace" ]] || namespace="$(kubectl config view --minify -o jsonpath='{..namespace}')"
  echo "KUBECONFIG: $KUBECONFIG"
  echo "Context:    $(kubectl config current-context)"
  echo "Namespace:  ${namespace:-default}"
  echo
}

main() {
  parse_args "$@"
  load_aliases
  KUBECONFIG="$(resolve_kubeconfig "${ARGS[0]}")" || exit 1
  export KUBECONFIG
  show_context
  trap 'kill $(jobs -p) 2>/dev/null' EXIT
  trap 'exit 0' INT TERM HUP
  for spec in "${ARGS[@]:1}"; do start_forward "$spec" "$KUBECONFIG"; done
  wait
}

main "$@"
