# Tunebian

Debian tabanli distro denemesi. Ana sistem EndeavourOS oldugu icin build ve test akisi container odakli ilerler.

## Baslangic Belgeleri

- [Roadmap](docs/distro-roadmap.md)
- [Container development](docs/container-development.md)
- [Decisions](docs/decisions.md)

## Ilk Hedef

Ilk milestone, Distrobox veya Docker/Podman icinde `live-build` ile minimal boot eden Debian live ISO uretmek.

## Komutlar

Host kontrolu:

```bash
./scripts/check-host.sh
```

Build container shell:

```bash
./scripts/shell.sh
```

Container icinde ISO build:

```bash
./scripts/build-iso.sh
```

Hosttan direkt container build:

```bash
./scripts/container-build.sh
```

ISO test:

```bash
./scripts/test-qemu.sh
```
