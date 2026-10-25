# GoodbyeDPI-Turkey (Linux & Android)

Discord, Roblox ve Türkiye'de internet servis sağlayıcıları tarafından engellenen web siteleri ve servislere **VPN kullanmadan** ve **internet hızında yavaşlama olmadan** erişmek için geliştirilmiş DPI atlatma aracı.

---

## ⚡ Özellikler

- **Sıfır Hız Kaybı & Orijinal Ping:** Bu bir VPN değildir. Trafiğinizi yabancı bir sunucuya yönlendirmez. Yalnızca engellemenin yapıldığı ilk el sıkışma paketlerini düzenler. İndirme/yükleme hızınız ve oyunlardaki pinginiz asla etkilenmez.
- **Kalıcı Kurulum (Otomatik Başlangıç):** 
  - **Linux'ta:** Tek bir komutla kurulur (`sudo ./install.sh`). Bilgisayarınızı yeniden başlatsanız bile systemd servisi olarak arka planda otomatik çalışmaya devam eder.
  - **Android'de:** Uygulama içi ayar ve pil kısıtlamasını kaldırarak telefonunuz her açıldığında VPN otomatik olarak kendiliğinden bağlanır.
- **Tüm Dağıtımlarla Uyumlu:** Ubuntu, Debian, Linux Mint, Fedora, Arch Linux, Manjaro, Pop!_OS, openSUSE ve systemd kullanan tüm modern Linux dağıtımlarında sorunsuz çalışır.
- **Tüm Operatörlerde Geçerli:** Türk Telekom, Turkcell Superonline, TurkNet, Vodafone ve diğer tüm ISS'lerde ek ayar gerektirmeden çalışır.
- **Temiz Kaldırma:** Tek bir komutla (`sudo ./remove.sh`) servis, dosyalar ve güvenlik duvarı kuralları sistemden tamamen silinir; geride hiçbir çöp veya artık bırakmaz.

---

## 📥 İndirme (Releases)

En son sürümleri doğrudan indirmek için:
- **[Tüm Dosyaları İndir (Releases Sayfası)](https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android/releases/latest)**
- **[Android APK Doğrudan İndir (GoodbyeDPI-Android.apk)](https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android/releases/latest/download/GoodbyeDPI-Android.apk)** *(Veya repo içindeki `android/GoodbyeDPI-Android.apk`)*
- **[Linux Arşivi Doğrudan İndir (.tar.gz)](https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android/releases/latest/download/goodbyedpi-turkey-linux.tar.gz)**

---

## 🐧 Linux Kurulumu ve Kullanımı

### 1. Kurulum (Tek Komutla Kalıcı Kurulum)

Terminali açın ve şu komutları girin:

```bash
git clone https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android.git
cd GoodbyeDpi-Turkey-Linux-Android
sudo ./install.sh
```

*(Veya yukarıdaki Releases bağlantısından arşivi indirip ayıkladıktan sonra klasör içinde `sudo ./install.sh` çalıştırmanız yeterlidir.)*

> **Bilgisayar açılışında otomatik başlar:** `install.sh` betiği gerekli bileşenleri otomatik indirir, doğrular, systemd servisi olarak `/opt/goodbyedpi-turkey` altına kurar ve etkinleştirir. Artık terminali kapatabilir veya bilgisayarı yeniden başlatabilirsiniz; servis her zaman arka planda devrede kalacaktır.

### 2. Kaldırma (Tek Komutla Temiz Kaldırma)

Uygulamayı ve arkasındaki tüm kuralları tamamen silmek istediğinizde:

```bash
sudo ./remove.sh
```

Bu komut:
- Çalışan arka plan servisini durdurur.
- Açılışta otomatik başlama kaydını siler.
- Eklenen `nftables` güvenlik duvarı tablosunu temizler.
- `/opt` altındaki kurulum dosyalarını tamamen kaldırır.

### 3. Durum Kontrolü (İsteğe Bağlı)

Çalışıp çalışmadığını kontrol etmek için:

```bash
sudo ./status.sh
```

---

## 📱 Android Kurulumu

Android için [ByeByeDPI](https://github.com/romanvht/ByeByeDPI) v1.8.2 kullanılır (root gerekmez). Bu sürümde **uygulama seçme (Apps filter)**, **operatörünüze uygun komutu bulan Proxy test** ve **cihaz açılışında otomatik başlama** vardır.

1. **[GoodbyeDPI-Android.apk](https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android/releases/latest/download/GoodbyeDPI-Android.apk)** dosyasını indirip kurun. *(Veya repo içindeki `android/GoodbyeDPI-Android.apk`)*
2. Telefon **Özel DNS** ayarına `dns.google` yazın (olmazsa `one.one.one.one`).
3. Uygulamada **Proxy test** ile operatörünüzde çalışan komutu bulup uygulayın.
4. **Autostart service on device startup** seçeneğini açın.

Adım adım ayrıntılı rehber: **[android/README.md](android/README.md)**

> [!WARNING]
> Hiçbir DPI atlatma ayarı her operatörde garanti çalışmaz. Çalışmazsa Proxy test ile farklı komut deneyin.

---

## ❓ Sıkça Sorulan Sorular (SSS)

### 1. Hangi Linux dağıtımlarında çalışır?
Linux çekirdeği (4.18+) ve `systemd` kullanan tüm dağıtımlarda çalışır:
- **Ubuntu / Linux Mint / Pop!_OS / Elementary OS**
- **Debian / Pardus**
- **Fedora / Red Hat / CentOS Stream**
- **Arch Linux / Manjaro / EndeavourOS**
- **openSUSE / Tumbleweed**

### 2. Bilgisayarı kapatıp açtığımda tekrar çalıştırmam gerekir mi?
**Hayır.** `sudo ./install.sh` komutunu bir kez çalıştırmanız yeterlidir. Systemd servisi olarak kaydedildiği için bilgisayarınız her açıldığında otomatik olarak devreye girer.

### 3. İnternet hızım düşer mi ya da oyunlarda pingim artar mı?
**Hayır.** Bu araç bir VPN tüneli kurmaz. Yalnızca web sitelerine veya Discord'a bağlanırken ilk el sıkışma aşamasındaki TCP/TLS paketlerini sansür cihazlarını atlatacak şekilde böler. Bağlantı kurulduktan sonraki veri akışı, dosya indirmeleri veya sesli konuşmalar doğrudan kendi internet hızınızla akar.

### 4. Tarayıcımda Discord açılmıyor, ne yapmalıyım?
Tarayıcınızın (Chrome, Brave, Edge vb.) Ayarlar bölümünde **"Güvenli DNS (DNS-over-HTTPS / DoH)"** seçeneği açıksa, tarayıcı sistem DNS yönlendirmesini atlar. Bu ayarı kapatmanız veya işletim sistemi varsayılanını kullanacak şekilde ayarlamanız önerilir.

---

## 📄 Lisans

Bu proje [Apache License 2.0](LICENSE) altında dağıtılmaktadır.
DPI atlatma motoru için bol-van'ın açık kaynaklı [zapret](https://github.com/bol-van/zapret) ve [ByeDPI](https://github.com/dovecoteescapee/ByeDPIAndroid) projeleri kullanılmaktadır.
