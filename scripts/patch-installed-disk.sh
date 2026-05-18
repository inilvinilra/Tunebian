#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISK_PATH="${1:-${TUNEBIAN_QEMU_DISK:-$PROJECT_ROOT/output/tunebian-test.qcow2}}"
NBD_DEV="${TUNEBIAN_NBD_DEV:-/dev/nbd0}"
INSTALL_USER="${TUNEBIAN_INSTALL_USER:-tunebian}"
INSTALL_PASSWORD="${TUNEBIAN_INSTALL_PASSWORD:-tunebian}"
ROOT_PASSWORD="${TUNEBIAN_ROOT_PASSWORD:-$INSTALL_PASSWORD}"

if [ "$(id -u)" -ne 0 ]; then
  exec sudo -E "$0" "$@"
fi

if [ ! -f "$DISK_PATH" ]; then
  printf 'No installed disk found at %s.\n' "$DISK_PATH" >&2
  exit 1
fi

if pgrep -af qemu-system-x86_64 >/dev/null 2>&1; then
  printf 'A QEMU process is running. Shut it down before patching %s.\n' "$DISK_PATH" >&2
  exit 1
fi

MOUNT_DIR="$(mktemp -d /tmp/tunebian-installed.XXXXXX)"
ROOT_PART=""
BOUND_MOUNTS=()
CONNECTED=0

cleanup() {
  set +e
  for mountpoint in "${BOUND_MOUNTS[@]}"; do
    umount -R "$mountpoint" 2>/dev/null || true
  done
  if mountpoint -q "$MOUNT_DIR"; then
    umount -R "$MOUNT_DIR" 2>/dev/null || true
  fi
  if [ "$CONNECTED" -eq 1 ]; then
    qemu-nbd --disconnect "$NBD_DEV" >/dev/null 2>&1 || true
  fi
  rmdir "$MOUNT_DIR" 2>/dev/null || true
}
trap cleanup EXIT

modprobe nbd max_part=16
qemu-nbd --disconnect "$NBD_DEV" >/dev/null 2>&1 || true
qemu-nbd --connect="$NBD_DEV" "$DISK_PATH"
CONNECTED=1
partprobe "$NBD_DEV" 2>/dev/null || true
sleep 1

ROOT_PART="$(lsblk -nrpo NAME,FSTYPE "$NBD_DEV" | awk '$2 ~ /^(ext2|ext3|ext4|btrfs|xfs)$/ { print $1; exit }')"
if [ -z "$ROOT_PART" ]; then
  printf 'Could not find a Linux root partition on %s.\n' "$NBD_DEV" >&2
  lsblk -f "$NBD_DEV" >&2 || true
  exit 1
fi

mount "$ROOT_PART" "$MOUNT_DIR"

install -Dm644 /dev/stdin "$MOUNT_DIR/usr/lib/os-release" <<'EOF'
PRETTY_NAME="Tunebian GNU/Linux 13 (trixie)"
NAME="Tunebian GNU/Linux"
VERSION_ID="13"
VERSION="13 (trixie)"
VERSION_CODENAME=trixie
ID=tunebian
ID_LIKE=debian
HOME_URL="https://tunebian.local/"
SUPPORT_URL="https://tunebian.local/support"
BUG_REPORT_URL="https://tunebian.local/bugs"
EOF

ln -sfn ../usr/lib/os-release "$MOUNT_DIR/etc/os-release"
printf 'DISTRIB_ID=Tunebian\nDISTRIB_RELEASE=13\nDISTRIB_CODENAME=trixie\nDISTRIB_DESCRIPTION="Tunebian GNU/Linux 13 (trixie)"\n' \
  > "$MOUNT_DIR/etc/lsb-release"
printf 'tunebian\n' > "$MOUNT_DIR/etc/hostname"
printf 'Tunebian GNU/Linux 13 \\n \\l\n\n' > "$MOUNT_DIR/etc/issue"
printf 'Tunebian GNU/Linux 13\n\n' > "$MOUNT_DIR/etc/issue.net"

mkdir -p "$MOUNT_DIR/etc/lightdm/lightdm.conf.d"
cat > "$MOUNT_DIR/etc/lightdm/lightdm.conf.d/50-tunebian-autologin.conf" <<EOF
[Seat:*]
autologin-user=$INSTALL_USER
autologin-user-timeout=0
EOF

if [ -f "$MOUNT_DIR/etc/default/grub" ]; then
  if grep -q '^GRUB_DISTRIBUTOR=' "$MOUNT_DIR/etc/default/grub"; then
    sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="Tunebian"/' "$MOUNT_DIR/etc/default/grub"
  else
    printf '\nGRUB_DISTRIBUTOR="Tunebian"\n' >> "$MOUNT_DIR/etc/default/grub"
  fi
fi

if [ -f "$MOUNT_DIR/boot/grub/grub.cfg" ]; then
  sed -i 's/Debian GNU\/Linux/Tunebian GNU\/Linux/g' "$MOUNT_DIR/boot/grub/grub.cfg"
fi

CURRENT_USER="$INSTALL_USER"
if ! grep -q "^$INSTALL_USER:" "$MOUNT_DIR/etc/passwd"; then
  CURRENT_USER="$(awk -F: '$3>=1000 && $3<65534 { print $1; exit }' "$MOUNT_DIR/etc/passwd")"
fi

if [ -n "$CURRENT_USER" ] && grep -q "^$CURRENT_USER:" "$MOUNT_DIR/etc/passwd"; then
  for path in dev proc sys run; do
    mount --bind "/$path" "$MOUNT_DIR/$path"
    BOUND_MOUNTS=("$MOUNT_DIR/$path" "${BOUND_MOUNTS[@]}")
  done

  if [ "$CURRENT_USER" != "$INSTALL_USER" ]; then
    if chroot "$MOUNT_DIR" /usr/bin/getent group "$CURRENT_USER" >/dev/null 2>&1 && ! chroot "$MOUNT_DIR" /usr/bin/getent group "$INSTALL_USER" >/dev/null 2>&1; then
      chroot "$MOUNT_DIR" /usr/sbin/groupmod -n "$INSTALL_USER" "$CURRENT_USER"
    fi
    chroot "$MOUNT_DIR" /usr/sbin/usermod -l "$INSTALL_USER" -d "/home/$INSTALL_USER" -m "$CURRENT_USER"
  fi

  {
    printf '%s:%s\n' "$INSTALL_USER" "$INSTALL_PASSWORD"
    printf 'root:%s\n' "$ROOT_PASSWORD"
  } | chroot "$MOUNT_DIR" /usr/sbin/chpasswd

  chroot "$MOUNT_DIR" /usr/sbin/groupadd -f autologin 2>/dev/null || true
  EXTRA_GROUPS="$(chroot "$MOUNT_DIR" /usr/bin/getent group sudo adm cdrom floppy audio dip video plugdev users netdev autologin 2>/dev/null | cut -d: -f1 | paste -sd, -)"
  if [ -n "$EXTRA_GROUPS" ]; then
    chroot "$MOUNT_DIR" /usr/sbin/usermod -aG "$EXTRA_GROUPS" "$INSTALL_USER" 2>/dev/null || true
  fi
  chroot "$MOUNT_DIR" /usr/sbin/update-grub >/dev/null 2>&1 || true

  if [ -f "$MOUNT_DIR/boot/grub/grub.cfg" ]; then
    sed -i 's/Debian GNU\/Linux/Tunebian GNU\/Linux/g' "$MOUNT_DIR/boot/grub/grub.cfg"
  fi
else
  printf 'User %s was not found in installed system; identity was patched, password was not changed.\n' "$INSTALL_USER" >&2
fi

sync
printf 'Patched %s on %s. Login user: %s\n' "$DISK_PATH" "$ROOT_PART" "$INSTALL_USER"
