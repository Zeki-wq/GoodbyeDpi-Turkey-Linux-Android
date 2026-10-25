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

## 📱 Android Kurulumu ve Discord Ayarı (Kesin Çözüm)

Android cihazlarda Discord ve engelli sitelere girmek için kök yetkisi (root) gerektirmeyen **GoodbyeDPI Android** kullanılır:

### 1. Kurulum:
1. **[GoodbyeDPI-Android.apk](https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android/releases/latest/download/GoodbyeDPI-Android.apk)** dosyasını indirin ve kurun. *(Veya repo içindeki `android/GoodbyeDPI-Android.apk`)*

### 2. 🇹🇷 Discord'u Açmak İçin Gerekli Ayarlar (30 Saniye):
Türkiye'deki operatörlerin (Türk Telekom, Superonline vb.) uyguladığı DNS ve DPI filtrelerini aşmak için şu 2 basit ayarı yapın:

1. **Telefonun Özel DNS Ayarı:** Telefonunuzun **Ayarlar > Bağlantılar > Özel DNS (Private DNS)** bölümüne gidin. "Özel DNS sağlayıcı ana bilgisayar adı" seçeneğine **`dns.google`** *(veya `one.one.one.one`)* yazıp kaydedin.
2. **Uygulama İçi Kod Ayarı:** ByeDPI uygulamasını açın, sağ üstteki **Ayarlar (⚙️)** simgesine dokunun. **"Use command line settings"** seçeneğini açın ve Command line editor kutusuna şu kodu yapıştırın:
   ```text
   -s1 -At -d2 -f-1 -r1+s -An
   ```
   *(Superonline için alternatif: `-s1 -At -d2 -At -f-1 -r1+s -An`)*
3. Ana ekrandan **Connect (Bağlan)** butonuna basın. Discord anında açılacaktır!

### 3. Telefon Kapanıp Açıldığında Otomatik Başlaması İçin:
1. Uygulama içinde sağ üstteki **Ayarlar (çark ⚙️)** simgesine dokunun.
2. **"Automatically start the service when the device boots"** *(Cihaz açıldığında servisi otomatik başlat)* seçeneğini **AÇIN**.
3. Telefonunuzun **Ayarlar > Uygulamalar > ByeDPI (veya GoodbyeDPI)** sayfasına gidin.
4. **Pil (Battery) / Pil Tasarrufu** seçeneğini **"Kısıtlama Yok" (Unrestricted / Don't optimize)** olarak ayarlayın.

> **Tebrikler:** Artık telefonunuz kapansa, şarjı bitse veya yeniden başlasa bile uygulama arka planda kendiliğinden açılacak ve Discord/engelli sitelere kesintisiz girmeye devam edeceksiniz.

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
