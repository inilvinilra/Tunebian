# Tunebian Debian-Based Distro Roadmap

Bu belge EndeavourOS ana sisteminde, izole container ortamlarında Debian tabanli distro gelistirmek icin ana gorev listesidir. Hedefimiz once tekrar edilebilir ISO build hatti kurmak, sonra paketler, ayarlar, branding ve installer tarafini parca parca oturtmak.

## 0. Kararlar

- [ ] Distro adi kesinlestirilecek.
- [ ] Hedef kullanici profili belirlenecek: genel masaustu, gelistirici, minimal, gaming, privacy veya egitim.
- [ ] Debian tabani secilecek: `stable`, `testing` veya belirli release codename.
- [ ] Varsayilan mimari secilecek: baslangic icin `amd64`.
- [ ] Masaustu ortami secilecek: XFCE, KDE Plasma, GNOME, Cinnamon, LXQt veya WM tabanli kurulum.
- [ ] Installer yaklasimi secilecek: Debian Installer, Calamares veya sadece live ISO.
- [ ] Paket politikasi belirlenecek: Debian resmi repo agirlikli mi, ek repo/Flatpak var mi?
- [ ] Non-free firmware politikasi belirlenecek.
- [ ] Secure Boot hedefleniyor mu karar verilecek.

## 1. Gelistirme Ortami

- [ ] EndeavourOS uzerinde gerekli host araclari kurulacak.
- [ ] Distrobox mi Docker/Podman mi kullanilacak karar verilecek.
- [ ] Debian build container imaji hazirlanacak.
- [ ] Container icinde `live-build`, `debootstrap`, `xorriso`, `squashfs-tools`, `isolinux/syslinux`, `grub-pc-bin`, `grub-efi-amd64-bin` kurulacak.
- [ ] Build icin kalici volume dizinleri olusturulacak: `build/`, `cache/`, `output/`.
- [ ] Host ile container arasinda UID/GID ve dosya izinleri test edilecek.
- [ ] Build komutlari icin tek giris noktasi yazilacak: `scripts/build-iso.sh`.
- [ ] Temizleme komutu yazilacak: `scripts/clean.sh`.
- [ ] Container shell komutu yazilacak: `scripts/shell.sh`.

## 2. Repo Yapisi

- [ ] `config/` dizini `live-build` formatina gore olusturulacak.
- [ ] `config/package-lists/` paket listeleri icin ayrilacak.
- [ ] `config/includes.chroot/` hedef sistem dosyalari icin ayrilacak.
- [ ] `config/includes.binary/` ISO seviyesindeki dosyalar icin ayrilacak.
- [ ] `config/hooks/normal/` build hooklari icin ayrilacak.
- [ ] `branding/` logo, wallpaper, GRUB, Plymouth ve tema varliklari icin ayrilacak.
- [ ] `docs/` kararlar, test notlari ve release checklist icin ayrilacak.
- [ ] `scripts/` host/container yardimci scriptleri icin ayrilacak.
- [ ] `.gitignore` build ciktilarini dislayacak sekilde eklenecek.

## 3. Ilk Boot Eden ISO

- [ ] Minimal `live-build` konfigrasyonu olusturulacak.
- [ ] Debian repo mirror ayarlari yapilacak.
- [ ] `amd64` live ISO build alinacak.
- [ ] QEMU/Boxes/VirtualBox ile ISO boot testi yapilacak.
- [ ] UEFI boot testi yapilacak.
- [ ] BIOS/legacy boot testi yapilacak.
- [ ] Live session aciliyor mu dogrulanacak.
- [ ] Network otomatik geliyor mu kontrol edilecek.
- [ ] Terminal ve temel shell araclari kontrol edilecek.
- [ ] Build tekrar edilebilir mi test edilecek.

## 4. Paket Setleri

- [ ] `base.list.chroot` temel paket listesi yazilacak.
- [ ] `desktop.list.chroot` masaustu paket listesi yazilacak.
- [ ] `hardware.list.chroot` firmware ve donanim paketleri yazilacak.
- [ ] `devtools.list.chroot` gelistirici araclari yazilacak.
- [ ] `multimedia.list.chroot` ses/video paketleri yazilacak.
- [ ] Browser secilecek ve eklenecek.
- [ ] Terminal emulator secilecek.
- [ ] Dosya yoneticisi secilecek.
- [ ] Metin editoru secilecek.
- [ ] Archive, screenshot, clipboard, bluetooth, printer gibi gunluk paketler eklenecek.
- [ ] Paket setleri minimal tutulup ISO boyutu takip edilecek.

## 5. Sistem Ayarlari

- [ ] Locale varsayilani belirlenecek.
- [ ] Klavye varsayilani belirlenecek.
- [ ] Timezone stratejisi belirlenecek.
- [ ] Default user/live user ayarlari yapilacak.
- [ ] `sudo` yetkileri ayarlanacak.
- [ ] NetworkManager varsayilan yapilacak.
- [ ] PipeWire ses altyapisi ayarlanacak.
- [ ] Bluetooth servisleri gerekiyorsa aktif edilecek.
- [ ] Printer desteği gerekiyorsa CUPS ayarlanacak.
- [ ] Flatpak kullanilacaksa Flathub ekleme stratejisi belirlenecek.
- [ ] APT pinning veya preferences gerekiyorsa yazilacak.
- [ ] Sistem servisleri audit edilecek.

## 6. Masaustu Deneyimi

- [ ] Tema yonu belirlenecek: sade, karanlik, acik, renk paleti.
- [ ] GTK/Qt tema paketleri secilecek.
- [ ] Icon tema secilecek.
- [ ] Cursor tema secilecek.
- [ ] Varsayilan panel/dock ayarlari yapilacak.
- [ ] Varsayilan uygulama favorileri ayarlanacak.
- [ ] Wallpaper eklenecek.
- [ ] Login manager secilecek ve temalandirilacak.
- [ ] Kullanici ilk acilis ayarlari hook ile yazilacak.
- [ ] Desktop ayarlari tekrar edilebilir dosyalara alinacak.

## 7. Branding

- [ ] Distro adi ve surum semasi kesinlestirilecek.
- [ ] Logo hazirlanacak.
- [ ] Wallpaper seti hazirlanacak.
- [ ] GRUB arka plani ve tema dosyalari hazirlanacak.
- [ ] Plymouth splash temasi hazirlanacak.
- [ ] `/etc/os-release` markalanacak.
- [ ] Hostname varsayilani ayarlanacak.
- [ ] Installer branding dosyalari hazirlanacak.
- [ ] About/system info alanlarinda distro adi gorunmesi saglanacak.

## 8. Installer

- [ ] Installer hedefi netlestirilecek: Calamares onerilir, Debian Installer daha klasik kalir.
- [ ] Calamares paketleri ve modulleri eklenecek.
- [ ] Partitioning akisi test edilecek.
- [ ] User creation akisi test edilecek.
- [ ] Bootloader kurulumu test edilecek.
- [ ] Installed system ilk boot testi yapilacak.
- [ ] Live ortamdan kurulu sisteme tasinan ayarlar kontrol edilecek.
- [ ] Kurulum loglari ve hata durumlari incelenecek.

## 9. Build Otomasyonu

- [ ] `make iso` veya script tabanli tek komut build saglanacak.
- [ ] Build loglari `logs/` altina alinacak.
- [ ] ISO ciktilari `output/` altina standart isimle yazilacak.
- [ ] SHA256 checksum uretilacak.
- [ ] Build metadata dosyasi uretilerek tarih, git commit ve Debian codename yazilacak.
- [ ] Temiz build ve incremental build ayrilacak.
- [ ] Container yeniden olusturma komutu yazilacak.
- [ ] CI icin ileride GitHub Actions/GitLab CI taslagi hazirlanacak.

## 10. Test Matrisi

- [ ] QEMU UEFI live boot.
- [ ] QEMU BIOS live boot.
- [ ] VirtualBox live boot.
- [ ] GNOME Boxes live boot.
- [ ] Network/wifi testi.
- [ ] Ses testi.
- [ ] Ekran cozunurlugu ve Wayland/X11 testi.
- [ ] Installer full disk testi.
- [ ] Kurulum sonrasi update testi.
- [ ] Reboot/shutdown testi.
- [ ] Paket yoneticisi testi.
- [ ] Locale/klavye testi.
- [ ] ISO checksum dogrulama.

## 11. Guvenlik ve Bakim

- [ ] APT kaynaklari ve keyring dosyalari audit edilecek.
- [ ] Gereksiz servisler kapatilacak.
- [ ] Varsayilan parolalar olmayacak.
- [ ] Live user yetkileri sinirlandirma acisindan incelenecek.
- [ ] Firewall varsayilan politikasi belirlenecek.
- [ ] Otomatik update politikasi belirlenecek.
- [ ] Release sonrasi security update sorumlulugu netlestirilecek.

## 12. Release Hazirligi

- [ ] Surum numarasi ve codename belirlenecek.
- [ ] Release notes yazilacak.
- [ ] Bilinen sorunlar listelenecek.
- [ ] Minimum sistem gereksinimleri yazilacak.
- [ ] ISO dosyasi ve SHA256 yayinlanacak.
- [ ] Test edilen VM/hardware listesi yazilacak.
- [ ] Geri bildirim kanali belirlenecek.

## Ilk Sprint

1. Repo iskeleti olustur.
2. Distrobox/Docker gelistirme ortamini sec.
3. Debian container icinde `live-build` kurulumunu dogrula.
4. Minimal Debian live ISO build al.
5. QEMU ile live boot test et.
6. Paket listelerini katmanlara ayir.
7. Masaustu ortamini secip ikinci ISO build al.

