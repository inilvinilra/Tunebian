#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${TUNEBIAN_IMAGE:-tunebian-build:debian-stable}"
RUNTIME="${TUNEBIAN_RUNTIME:-}"

if [ -z "$RUNTIME" ]; then
  if command -v podman >/dev/null 2>&1; then
    RUNTIME="podman"
  elif command -v docker >/dev/null 2>&1; then
    RUNTIME="docker"
  else
    printf 'Neither podman nor docker is installed.\n' >&2
    exit 1
  fi
fi

if ! "$RUNTIME" image exists "$IMAGE" >/dev/null 2>&1; then
  "$RUNTIME" build \
    --build-arg "USER_ID=$(id -u)" \
    --build-arg "GROUP_ID=$(id -g)" \
    -f "$PROJECT_ROOT/Containerfile" \
    -t "$IMAGE" \
    "$PROJECT_ROOT"
fi

volume_arg="$PROJECT_ROOT:/workspace"
run_args=(run --rm)

if [ "$RUNTIME" = "podman" ]; then
  volume_arg="$volume_arg:Z"
  run_args+=(--userns=keep-id --privileged)
fi

exec "$RUNTIME" "${run_args[@]}" \
  -v "$volume_arg" \
  -w /workspace \
  "$IMAGE" \
  ./scripts/build-iso.sh "$@"
