#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/output"
LOG_DIR="$PROJECT_ROOT/logs"

fix_ownership() {
  if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_UID:-}" ] && [ -n "${SUDO_GID:-}" ]; then
    chown -R "$SUDO_UID:$SUDO_GID" \
      "$PROJECT_ROOT/.build" \
      "$PROJECT_ROOT/auto" \
      "$PROJECT_ROOT/binary" \
      "$PROJECT_ROOT/branding" \
      "$PROJECT_ROOT/chroot" \
      "$PROJECT_ROOT/config" \
      "$PROJECT_ROOT/docs" \
      "$PROJECT_ROOT/local" \
      "$PROJECT_ROOT/logs" \
      "$PROJECT_ROOT/output" \
      "$PROJECT_ROOT/scripts" \
      "$PROJECT_ROOT/source" \
      2>/dev/null || true
  fi
}

trap fix_ownership EXIT

if ! command -v lb >/dev/null 2>&1; then
  printf 'live-build is not available. Run this inside scripts/shell.sh.\n' >&2
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  exec sudo -E "$0" "$@"
fi

mkdir -p "$OUTPUT_DIR" "$LOG_DIR"
cd "$PROJECT_ROOT"

lb clean --purge || true
"$PROJECT_ROOT/auto/config" "$@"
lb build 2>&1 | tee "$LOG_DIR/build.log"

iso_path="$(find "$PROJECT_ROOT" -maxdepth 1 -type f -name '*.iso' | sort | tail -n 1)"
if [ -z "$iso_path" ]; then
  printf 'Build finished, but no ISO was found in %s.\n' "$PROJECT_ROOT" >&2
  exit 1
fi

iso_name="tunebian-$(date -u +%Y%m%d)-${TUNEBIAN_DEBIAN_SUITE:-stable}-${TUNEBIAN_ARCH:-amd64}.iso"
mv "$iso_path" "$OUTPUT_DIR/$iso_name"

(
  cd "$PROJECT_ROOT"
  sha256sum "output/$iso_name" > "output/$iso_name.sha256"
)

printf 'ISO: %s\n' "$OUTPUT_DIR/$iso_name"
printf 'SHA256: %s.sha256\n' "$OUTPUT_DIR/$iso_name"
