# Tunebian

Tunebian is a Debian-based live ISO project. The host development machine is EndeavourOS, so the default workflow is intentionally container-first: build the ISO in Podman or Docker, then test it in QEMU.

The current image boots into an XFCE live desktop, identifies itself as Tunebian, and ships a Calamares installer launcher on the desktop.

## Current Status

- Base: Debian stable/trixie via `live-build`
- Desktop: XFCE with LightDM
- Installer: Calamares
- Live user: `tunebian`
- Live hostname: `tunebian`
- ISO output: `output/tunebian-YYYYMMDD-stable-amd64.iso`
- Build log: `logs/build.log`

## Repository Layout

- `auto/config`: `live-build` configuration wrapper.
- `Containerfile`: build image used by Podman or Docker.
- `config/package-lists/*.list.chroot`: packages installed into the live system.
- `config/includes.chroot/`: files copied into the live filesystem after packages install.
- `config/hooks/normal/`: build hooks, including boot menu branding.
- `scripts/check-host.sh`: validates host-side tools.
- `scripts/container-build.sh`: builds the container image if needed and runs the ISO build.
- `scripts/shell.sh`: opens an interactive build container shell.
- `scripts/build-iso.sh`: runs `lb clean`, `auto/config`, `lb build`, then moves/checksums the ISO.
- `scripts/test-qemu.sh`: boots an ISO with a writable qcow2 disk attached.
- `scripts/boot-installed.sh`: boots an installed qcow2 disk without the ISO attached.
- `scripts/patch-installed-disk.sh`: emergency helper for patching an installed qcow2 disk offline.

## Host Requirements

Required on the EndeavourOS host:

- `podman` or `docker`
- `git`
- `qemu-system-x86_64`

Useful optional tools:

- `distrobox`
- `lb` / `live-build` if you want to build outside the container

Check the host:

```bash
./scripts/check-host.sh
```

## Build Workflow

The recommended build command is:

```bash
./scripts/container-build.sh
```

This command:

1. Chooses Podman if available, otherwise Docker.
2. Builds `tunebian-build:debian-stable` from `Containerfile` if it does not exist.
3. Mounts the repository at `/workspace`.
4. Runs `./scripts/build-iso.sh` inside the container.
5. Writes the ISO and SHA256 file to `output/`.

Expected output files look like:

```text
output/tunebian-20260518-stable-amd64.iso
output/tunebian-20260518-stable-amd64.iso.sha256
```

Verify the ISO checksum:

```bash
sha256sum -c output/tunebian-20260518-stable-amd64.iso.sha256
```

## Interactive Container Shell

Use this when you want to inspect or debug the live-build environment manually:

```bash
./scripts/shell.sh
```

Inside the shell, run:

```bash
./scripts/build-iso.sh
```

## QEMU Live ISO Test

Boot the newest ISO in `output/`:

```bash
./scripts/test-qemu.sh
```

Boot a specific ISO:

```bash
./scripts/test-qemu.sh output/tunebian-20260518-stable-amd64.iso
```

Use a fresh test disk:

```bash
rm -f output/tunebian-live-test.qcow2
TUNEBIAN_QEMU_DISK="$PWD/output/tunebian-live-test.qcow2" \
  ./scripts/test-qemu.sh output/tunebian-20260518-stable-amd64.iso
```

Important: `scripts/test-qemu.sh` always attaches the ISO and uses `-boot d`. That means a reboot from this VM will boot the live ISO again. This is expected and does not mean Calamares failed.

## Calamares Install Test

1. Boot the ISO with `scripts/test-qemu.sh`.
2. Wait for the XFCE live desktop.
3. Open `Install Tunebian` from the desktop.
4. Install to the attached QEMU disk.
5. Shut down or reboot after Calamares finishes.

The live session includes a temporary passwordless sudo rule for the `tunebian` user so the desktop installer launcher can start Calamares cleanly. Calamares runs a cleanup module near the end of installation to remove live-only installer files from the installed system.

## Boot Installed System

After installing with Calamares, do not use `scripts/test-qemu.sh` for the installed-system check because it will boot the ISO again.

Use:

```bash
./scripts/boot-installed.sh output/tunebian-live-test.qcow2
```

This boots the qcow2 disk directly with no ISO attached and uses `-boot c`.

If the installed system appears here, Calamares installed successfully. If the live desktop appears here, the wrong disk was booted or the install target was not the qcow2 disk.

## Useful Environment Variables

- `TUNEBIAN_RUNTIME`: force `podman` or `docker`.
- `TUNEBIAN_IMAGE`: override the build container image name.
- `TUNEBIAN_ARCH`: default `amd64`.
- `TUNEBIAN_DEBIAN_SUITE`: default `stable`.
- `TUNEBIAN_ARCHIVE_AREAS`: default `main contrib non-free-firmware non-free`.
- `TUNEBIAN_BOOTAPPEND`: override live boot parameters.
- `TUNEBIAN_QEMU_DISK`: qcow2 path used by QEMU scripts.
- `TUNEBIAN_QEMU_DISK_SIZE`: default `32G`.
- `TUNEBIAN_QEMU_NET_MODEL`: default `rtl8139`.
- `TUNEBIAN_NBD_DEV`: default `/dev/nbd0`, used by `patch-installed-disk.sh`.
- `TUNEBIAN_INSTALL_USER`: default `tunebian`, used by `patch-installed-disk.sh`.
- `TUNEBIAN_INSTALL_PASSWORD`: default `tunebian`, used by `patch-installed-disk.sh`.
- `TUNEBIAN_ROOT_PASSWORD`: defaults to `TUNEBIAN_INSTALL_PASSWORD`, used by `patch-installed-disk.sh`.

Example:

```bash
TUNEBIAN_RUNTIME=podman \
TUNEBIAN_DEBIAN_SUITE=stable \
./scripts/container-build.sh
```

## Branding And Identity

Tunebian identity is currently set in:

- `config/includes.chroot/etc/os-release`
- `config/includes.chroot/usr/lib/os-release`
- `config/includes.chroot/etc/lsb-release`
- `config/includes.chroot/etc/hostname`
- `config/includes.chroot/etc/issue`
- `auto/config` boot parameters
- `config/hooks/normal/010-tunebian-binary-branding.binary`
- `config/includes.chroot/etc/calamares/branding/tunebian/`

Quick verification after a build:

```bash
podman run --rm -v "$PWD:/workspace:Z" -w /workspace tunebian-build:debian-stable bash -lc '
  rm -rf /tmp/tunebian-verify
  unsquashfs -q -d /tmp/tunebian-verify binary/live/filesystem.squashfs \
    etc/os-release usr/lib/os-release etc/lsb-release etc/hostname >/dev/null
  cat /tmp/tunebian-verify/etc/os-release
  cat /tmp/tunebian-verify/etc/lsb-release
  cat /tmp/tunebian-verify/etc/hostname
'
```

Boot menu string check:

```bash
podman run --rm -v "$PWD:/workspace:Z" -w /workspace tunebian-build:debian-stable bash -lc '
  rm -rf /tmp/tunebian-iso
  mkdir -p /tmp/tunebian-iso
  xorriso -indev output/tunebian-20260518-stable-amd64.iso -osirrox on \
    -extract /isolinux /tmp/tunebian-iso/isolinux \
    -extract /boot/grub /tmp/tunebian-iso/grub >/dev/null 2>&1
  grep -RIna "Debian GNU/Linux\\|Debian Live\\|Debian" /tmp/tunebian-iso \
    --include="*.cfg" --include="*.txt" --include="*.theme" --include="*.conf" || true
'
```

## Troubleshooting

If QEMU reboots into `Tunebian Live` after installation, check how it was started. `scripts/test-qemu.sh` boots the ISO by design. Use `scripts/boot-installed.sh <disk.qcow2>` to boot the installed disk.

If Calamares does not open from the desktop icon, run this inside the live terminal:

```bash
calamares-install-tunebian
```

If networking behaves oddly in the text Debian installer, make sure you are using the Calamares desktop installer. The Debian Installer is disabled in `auto/config`.

If a stale disk causes confusing results, create a new qcow2:

```bash
rm -f output/tunebian-live-test.qcow2
TUNEBIAN_QEMU_DISK="$PWD/output/tunebian-live-test.qcow2" \
  ./scripts/test-qemu.sh output/tunebian-20260518-stable-amd64.iso
```

If the installed system still says Debian, rebuild the ISO and verify both `/etc/os-release` and `/usr/lib/os-release` in the squashfs before testing.

## Emergency Installed Disk Patch

`scripts/patch-installed-disk.sh` can patch a qcow2 installation offline. It mounts the root partition through NBD, updates Tunebian identity files, sets LightDM autologin, adjusts GRUB labels, and can reset the install/root passwords.

Do not run it while QEMU is using the disk.

Example:

```bash
TUNEBIAN_INSTALL_USER=tunebian \
TUNEBIAN_INSTALL_PASSWORD=tunebian \
sudo -E ./scripts/patch-installed-disk.sh output/tunebian-live-test.qcow2
```

This script is a repair/debug helper, not the normal installation path.

## Development Notes

- Prefer container builds on non-Debian hosts.
- Use fresh qcow2 disks when validating installer behavior.
- Keep live-only conveniences out of installed systems; Calamares cleanup should remove installer launchers and temporary sudo rules.
- Do not assume live boot success means install success; always boot the installed disk without the ISO attached.

## Reference Docs

- [Roadmap](docs/distro-roadmap.md)
- [Container development](docs/container-development.md)
- [Decisions](docs/decisions.md)
