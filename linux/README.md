# GoodbyeDPI-Turkey — Linux Sürümü

Bu klasör, [GoodbyeDPI-Turkey](../README.md) projesinin Linux karşılığını içerir. `windows/`, `macos/` ve `src/` klasörleri olduğu gibi durur; bu port onları değiştirmez.

## Nasıl çalışır?

Windows sürümü paketleri **WinDivert** ile yakalar. Linux'taki karşılığı **NFQUEUE**'dur. Bu sürüm, [zapret](https://github.com/bol-van/zapret) projesinin `nfqws` aracını kullanır (hazır, statik ikili; derleme gerekmez). Sonuç:

- Sistem genelinde çalışır; **uygulama başına proxy ayarı gerekmez** (Discord dahil).
- Windows'taki `--dns-addr 77.88.8.8 --dns-port 1253` karşılığı nftables DNAT ile yapılır: UDP 53 sorguları Yandex DNS'e yönlenir.
- Tüm kurallar kendi tablosundadır (`inet goodbyedpi_turkey`); diğer güvenlik duvarı kurallarına dokunulmaz. Kuralların hepsinde `bypass` vardır: `nfqws` çökerse internetiniz kesilmez.

## Gereksinimler

- Linux, root yetkisi (sudo), `nftables` (`nft` komutu), çekirdekte `nfnetlink_queue`.
- `curl` veya `wget`, `tar`, `sha256sum` (ilk çalıştırmada `nfqws` indirilirken).
- Hizmet kurulumu için systemd. Tek seferlik kullanım her sistemde çalışır.
- Fedora, Debian/Ubuntu ve Arch tabanlı dağıtımlarda çalışması beklenir (aynı yaklaşım Fedora'da, SELinux açıkken denendi).

## Hızlı başlangıç

Proje klasöründe (içinde `linux/` klasörünün göründüğü yerde):

```bash
# Tek seferlik: Ctrl-C veya terminali kapatınca durur, ayarlar geri alınır
sudo ./linux/goodbyedpi-turkey.sh

# Kalıcı: açılışta otomatik başlar, siz kaldırana kadar açık kalır
sudo ./linux/goodbyedpi-turkey.sh install

# Kaldırmak için
sudo ./linux/goodbyedpi-turkey.sh remove
```

İlk çalıştırmada `nfqws` otomatik indirilir (zapret v72.13, SHA256 doğrulanır) ve `linux/bin/nfqws` altına konur. `install` komutu betiği ve `nfqws`'i **root sahipli** `/opt/goodbyedpi-turkey/` altına kopyalar; bu yüzden proje klasörünü sonradan silseniz ya da taşısanız da hizmet çalışmaya devam eder.

## Komutlar

| Komut | Ne yapar |
|---|---|
| `start [yöntem]` | Tek seferlik çalıştırır (`turkey_dnsredir.cmd` karşılığı). Komutsuz çalıştırmak da bunu yapar. |
| `install [yöntem]` | systemd hizmeti kurar ve başlatır (`service_install_*.cmd` karşılığı). |
| `remove` | Hizmeti, `/opt` kopyasını ve nft tablosunu kaldırır (`service_remove.cmd` karşılığı). |
| `stop` | Çalışan her şeyi durdurur ve nft tablosunu siler. Hizmet açılışta yine başlar. |
| `status` | Hizmet, nft tablosu ve `nfqws` durumunu gösterir; bayat tablo varsa uyarır. |
| `methods` | Yöntem tablosunu gösterir. |
| `setup` | `nfqws`'i indirir ve SHA256 ile doğrular. |
| `build` | `nfqws`'i kaynak koddan derler (hazır ikilinin olmadığı mimariler için). |

## Yöntemler

Windows'taki `.cmd` dosyalarıyla birebir eşleşir. Hepsinde sahte paket ve/veya bölme teknikleri kullanılır.

| Yöntem | Windows karşılığı | `nfqws` argümanları | DNS yönlendirme |
|---|---|---|---|
| `default` | `-5 --set-ttl 5` | `--dpi-desync=fake,multidisorder --dpi-desync-split-pos=2 --dpi-desync-ttl=5` | evet |
| `alt` | `--set-ttl 3` | `--dpi-desync=fake --dpi-desync-ttl=3` | hayır |
| `alt2` | `-5` | `--dpi-desync=fake,multidisorder --dpi-desync-split-pos=2 --dpi-desync-autottl --dpi-desync-ttl=5` | hayır |
| `alt3` | `--set-ttl 3` + DNS | `alt` ile aynı | evet |
| `alt4` | `-5` + DNS | `alt2` ile aynı | evet |
| `alt5` | `-9` + DNS | `--dpi-desync=fake,multidisorder --dpi-desync-split-pos=2 --dpi-desync-fooling=badsum,badseq` | evet |
| `alt6` | `-9` | `alt5` ile aynı | hayır |

Yöntem seçmek için: `sudo ./linux/goodbyedpi-turkey.sh start alt4` veya `sudo ./linux/goodbyedpi-turkey.sh install alt4`. Yöntemi değiştirmek için `install` komutunu yeni yöntemle tekrar çalıştırmanız yeterlidir.

> **Fark:** Windows'taki `-9` ön ayarı ayrıca QUIC'i (UDP 443) engeller. Linux sürümünde bunun karşılığı yoktur.

## Sorun giderme

- **"komut bulunamadı":** Komutu proje klasörünün dışında çalıştırıyorsunuzdur. Önce `cd` ile proje klasörüne girin (içinde `linux/` klasörü görünmeli).
- **Bazı siteler yavaş açılıyor veya hiç açılmıyor:** TTL'e dayalı yöntemlerde olabilir. Önce `alt4`, olmazsa `alt5` yöntemini deneyin.
- **Yavaşlık DNS'ten mi geliyor?** `curl -o /dev/null -sS -w 'dns=%{time_namelookup} baglanti=%{time_connect} tls=%{time_appconnect} toplam=%{time_total}\n' https://SITE` ile ölçün. `dns` değeri yüksekse Yandex yönlendirmesi gecikme ekliyordur.
- **`discord.com` açılmıyor, sertifika hatası (`localhost.localdomain`):** ISS'in DNS'i engel sayfasına yönlendiriyordur. DNS yönlendirmeli bir yöntem (`default`, `alt3`, `alt4`, `alt5`) kullanın.
- **LAN içi adlar (`router.lan` gibi) çözülmüyor:** DNS yönlendirmeli yöntemlerde tüm UDP 53 sorguları Yandex'e gider (Windows sürümüyle aynı). DNS'siz bir yöntem kullanın.
- **Sanal makine (VirtualBox/VMware NAT):** Hipervizör TTL'i değiştirdiği için TTL hileleri çalışmaz. Köprü (bridge) ağ kullanın.
- **VPN açıkken:** DPI atlatmaya gerek yoktur.
- **Tarayıcıda "Güvenli DNS" (DoH) açık:** Tarayıcı sistem DNS'ini atlar, DNS yönlendirmesi o tarayıcı için etkisiz kalır.
- **`ps`/`systemctl status` çıktısında `fake multidisorder` (virgülsüz) görünüyor:** Normaldir. `nfqws` argümanlarını ayrıştırırken kendi argüman belleğini değiştirir. Gerçek unit dosyasında virgül yerindedir.
- **Tablo silinmedi / bayat tablo:** `sudo ./linux/goodbyedpi-turkey.sh stop` her şeyi temizler. Elle: `sudo nft delete table inet goodbyedpi_turkey`.
- **Hizmet başlamıyor:** `journalctl -u goodbyedpi-turkey -b` çıktısına bakın. SELinux şüphesinde `sudo ausearch -m avc -ts recent`.
- **`nfqws` indirilemiyor / mimari desteklenmiyor:** `sudo ./linux/goodbyedpi-turkey.sh build` ile kaynaktan derleyin.

## Güvenlik notları

- İndirilen arşivin SHA256 değeri betiğe sabitlenmiştir; uyuşmazsa ikili kurulmaz.
- `nfqws` başladıktan sonra root yetkisini bırakır (nobody'ye düşer).
- Hizmet, kullanıcı klasöründeki dosyayı değil, root sahipli `/opt/goodbyedpi-turkey/` kopyasını çalıştırır.
- `sysctl` ayarlarına veya `/etc/resolv.conf` dosyasına dokunulmaz.

## Yasal uyarı

Ana [README](../README.md) dosyasındaki yasal uyarı bu sürüm için de geçerlidir. Uygulamanın kullanımından doğan her türlü sorumluluk kullanan kişiye aittir.
