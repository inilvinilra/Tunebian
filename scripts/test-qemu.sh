#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_PATH="${1:-}"
NET_MODEL="${TUNEBIAN_QEMU_NET_MODEL:-rtl8139}"
DISK_PATH="${TUNEBIAN_QEMU_DISK:-$PROJECT_ROOT/output/tunebian-test.qcow2}"
DISK_SIZE="${TUNEBIAN_QEMU_DISK_SIZE:-32G}"

if [ -z "$ISO_PATH" ]; then
  ISO_PATH="$(find "$PROJECT_ROOT/output" -maxdepth 1 -type f -name '*.iso' | sort | tail -n 1)"
fi

if [ -z "$ISO_PATH" ] || [ ! -f "$ISO_PATH" ]; then
  printf 'No ISO found. Pass an ISO path or build one first.\n' >&2
  exit 1
fi

mkdir -p "$(dirname "$DISK_PATH")"

if [ ! -f "$DISK_PATH" ]; then
  qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"
fi

exec qemu-system-x86_64 \
  -m 4096 \
  -smp 2 \
  -enable-kvm \
  -cdrom "$ISO_PATH" \
  -drive "file=${DISK_PATH},format=qcow2,if=virtio" \
  -boot d \
  -nic "user,model=${NET_MODEL}" \
  -device virtio-vga \
  -display gtk
