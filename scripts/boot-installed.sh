#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISK_PATH="${1:-${TUNEBIAN_QEMU_DISK:-$PROJECT_ROOT/output/tunebian-test.qcow2}}"
NET_MODEL="${TUNEBIAN_QEMU_NET_MODEL:-rtl8139}"

if [ ! -f "$DISK_PATH" ]; then
  printf 'No installed disk found at %s.\n' "$DISK_PATH" >&2
  printf 'Run scripts/test-qemu.sh first and install Tunebian to the test disk.\n' >&2
  exit 1
fi

exec qemu-system-x86_64 \
  -m 4096 \
  -smp 2 \
  -enable-kvm \
  -drive "file=${DISK_PATH},format=qcow2,if=virtio" \
  -boot c \
  -nic "user,model=${NET_MODEL}" \
  -device virtio-vga \
  -display gtk
