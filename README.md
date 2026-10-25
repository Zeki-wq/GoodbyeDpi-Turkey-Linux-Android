# GoodbyeDPI-Turkey (Linux & Android)

Discord, Roblox ve Türkiye'de internet servis sağlayıcıları tarafından engellenen web siteleri ve servislere **VPN kullanmadan** ve **internet hızında yavaşlama olmadan** erişmek için geliştirilmiş DPI atlatma aracı.

---

## ⚡ Özellikler

- **Sıfır Hız Kaybı & Orijinal Ping:** Bu bir VPN değildir. Trafiğinizi yabancı bir sunucuya yönlendirmez. Yalnızca engellemenin yapıldığı ilk el sıkışma paketlerini düzenler. İndirme/yükleme hızınız ve oyunlardaki pinginiz asla etkilenmez.
- **Kalıcı Kurulum (Otomatik Başlangıç):** Tek bir komutla kurulur. Bilgisayarınızı yeniden başlatsanız bile systemd servisi olarak arka planda otomatik çalışmaya devam eder.
- **Tüm Dağıtımlarla Uyumlu:** Ubuntu, Debian, Linux Mint, Fedora, Arch Linux, Manjaro, Pop!_OS, openSUSE ve systemd kullanan tüm modern Linux dağıtımlarında sorunsuz çalışır.
- **Tüm Operatörlerde Geçerli:** Türk Telekom, Turkcell Superonline, TurkNet, Vodafone ve diğer tüm ISS'lerde ek ayar gerektirmeden çalışır.
- **Temiz Kaldırma:** Tek bir komutla servis, dosyalar ve güvenlik duvarı kuralları sistemden tamamen silinir; geride hiçbir çöp veya artık bırakmaz.

---

## 📥 İndirme (Releases)

En son sürümü doğrudan ZIP olarak indirmek için:
- **[Linux Sürümünü İndir (Releases)](https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android/releases/latest)**
- **[Android Sürümünü İndir (ByeDPI Android APK)](https://github.com/dovecoteescapee/ByeDPIAndroid/releases/latest)**

---

## 🐧 Linux Kurulumu ve Kullanımı

### 1. Kurulum (Tek Komutla Kalıcı Kurulum)

Terminali açın ve şu komutları girin:

```bash
git clone https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android.git
cd GoodbyeDpi-Turkey-Linux-Android
chmod +x install.sh remove.sh
sudo ./install.sh
```

*(Veya yukarıdaki Releases bağlantısından ZIP indirip ayıkladıktan sonra klasör içinde `sudo ./install.sh` çalıştırmanız yeterlidir.)*

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

## 📱 Android Kullanımı

Android cihazlarda DPI engellerini aşmak için sistemin yerel VPN arayüzünü kullanan (ancak harici bir sunucuya bağlanmadan paketleri yerel olarak bölen) açık kaynaklı **ByeDPI Android** aracı kullanılır:

1. **[Releases](https://github.com/dovecoteescapee/ByeDPIAndroid/releases/latest)** sayfasından son `.apk` dosyasını indirin ve kurun.
2. Uygulamayı açın.
3. Mod ayarlarından **VPN Modu** seçin ve **Bağlan (Connect)** butonuna dokunun.
4. Root (kök yetkisi) gerekmez; Discord ve engelli sitelere Android cihazınızdan hız kaybı olmadan erişebilirsiniz.

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
DPI atlatma motoru için bol-van'ın açık kaynaklı [zapret](https://github.com/bol-van/zapret) projesi kullanılmaktadır.
