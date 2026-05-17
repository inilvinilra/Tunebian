# Project Decisions

Bu dosya distro tasarim kararlarini takip etmek icin tutulur. Karar degistikce tarih ve gerekce ekleyelim.

## Open Decisions

- Distro name: `Tunebian` gecici ad.
- Debian base: karar bekliyor.
- Desktop environment: karar bekliyor.
- Installer: karar bekliyor.
- Container workflow: Distrobox + Podman oneriliyor, karar bekliyor.
- Package policy: karar bekliyor.
- Branding direction: karar bekliyor.

## Proposed Defaults

- Debian base: `stable`
- Architecture: `amd64`
- Build tooling: `live-build`
- Container workflow: Distrobox + Podman locally, Containerfile later for CI
- Test target: QEMU/KVM first
- Installer: Calamares after first live ISO boots

