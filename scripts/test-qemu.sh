#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_PATH="${1:-}"

if [ -z "$ISO_PATH" ]; then
  ISO_PATH="$(find "$PROJECT_ROOT/output" -maxdepth 1 -type f -name '*.iso' | sort | tail -n 1)"
fi

if [ -z "$ISO_PATH" ] || [ ! -f "$ISO_PATH" ]; then
  printf 'No ISO found. Pass an ISO path or build one first.\n' >&2
  exit 1
fi

exec qemu-system-x86_64 \
  -m 4096 \
  -smp 2 \
  -enable-kvm \
  -cdrom "$ISO_PATH" \
  -boot d \
  -nic user,model=virtio-net-pci \
  -device virtio-vga \
  -display gtk
