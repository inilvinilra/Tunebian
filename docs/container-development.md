# Container-Based Development On EndeavourOS

EndeavourOS uzerinde Debian tabanli ISO gelistirirken ana sistemi temiz tutmak icin build isini container icine aliyoruz. Ilk tercih Distrobox + Podman olabilir; Docker da ayni mantikla kullanilabilir.

## Onerilen Yaklasim

- Host: EndeavourOS
- Container runtime: Podman
- Developer UX: Distrobox
- Build tabani: Debian stable
- ISO sistemi: `live-build`
- Test: QEMU/KVM

Bu modelde host sadece editor, git, container runtime ve sanallastirma araci tasir. Debian build bagimliliklari container icinde kalir.

## Host Paketleri

EndeavourOS tarafinda gerekli olabilecek paketler:

```bash
sudo pacman -S podman distrobox qemu-full virt-manager edk2-ovmf git rsync
```

Docker tercih edilirse:

```bash
sudo pacman -S docker docker-compose qemu-full virt-manager edk2-ovmf git rsync
sudo systemctl enable --now docker
```

## Distrobox Akisi

Container olusturma:

```bash
distrobox create --name tunebian-build --image debian:stable
```

Container'a giris:

```bash
distrobox enter tunebian-build
```

Container icinde build paketleri:

```bash
sudo apt update
sudo apt install -y live-build debootstrap xorriso squashfs-tools isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin mtools dosfstools qemu-utils ca-certificates git
```

## Docker/Podman Akisi

Dockerfile veya Containerfile kullanarak daha tekrar edilebilir ortam kurulabilir. Bu yontem ileride CI icin daha saglamdir.

Temel hedefler:

- Build paketleri imaja gomulur.
- Workspace container icine volume olarak baglanir.
- ISO build komutu container icinde tek komutla calisir.
- Cache dizini hostta tutulur.

Podman rootless kullanirken host dosya izinlerinin dogru gorunmesi icin `--userns=keep-id` kullanilir. ISO build islemleri chroot ve filesystem adimlari yaptigi icin lokal build container'i `--privileged` ile calistirilir.

Container shell:

```bash
./scripts/shell.sh
```

Container icinde ISO build:

```bash
./scripts/build-iso.sh
```

## Dizinler

Onerilen workspace dizinleri:

```text
tunebian/
  branding/
  build/
  cache/
  config/
  docs/
  output/
  scripts/
```

`build/`, `cache/` ve `output/` git'e alinmaz. `config/`, `scripts/`, `branding/` ve `docs/` repo varligidir.

## Ilk Dogrulama

Container icinde su komutlar calismali:

```bash
lb --version
debootstrap --version
xorriso -version
```

Host tarafinda QEMU/KVM dogrulamasi:

```bash
qemu-system-x86_64 --version
```

## Riskler

- `live-build` bazi asamalarda root yetkisi ister; container yetkileri buna gore ayarlanmalidir.
- Distrobox kullanimi kolaydir ama CI icin Docker/Podman Containerfile daha tekrar edilebilir olabilir.
- ISO boot testleri host sanallastirma destegine baglidir.
- Debian `testing` kullanilirsa build kirilmalari daha sik olabilir.
