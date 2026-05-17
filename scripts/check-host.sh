#!/usr/bin/env bash
set -euo pipefail

required_any=("podman docker")
required=("git" "qemu-system-x86_64")
optional=("distrobox" "lb")

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

printf 'Tunebian host check\n'
printf '===================\n'

missing=0
for group in "${required_any[@]}"; do
  found=0
  for cmd in $group; do
    if has_cmd "$cmd"; then
      printf '[ok] runtime: %s (%s)\n' "$cmd" "$(command -v "$cmd")"
      found=1
      break
    fi
  done
  if [ "$found" -eq 0 ]; then
    printf '[missing] one of: %s\n' "$group"
    missing=1
  fi
done

for cmd in "${required[@]}"; do
  if has_cmd "$cmd"; then
    printf '[ok] %s: %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '[missing] %s\n' "$cmd"
    missing=1
  fi
done

for cmd in "${optional[@]}"; do
  if has_cmd "$cmd"; then
    printf '[ok] optional %s: %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '[info] optional %s: missing\n' "$cmd"
  fi
done

if [ "$missing" -ne 0 ]; then
  printf '\nInstall missing host tools before building.\n'
  exit 1
fi

printf '\nHost looks ready for the container workflow.\n'

