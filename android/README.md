# GoodbyeDPI (Android) — Kurulum ve Ayar Rehberi

Bu klasördeki **`GoodbyeDPI-Android.apk`**, Türkiye'de Discord, Roblox ve engelli sitelere **VPN sunucusu olmadan** ve **hız kaybı yaşamadan** erişmek için geliştirilmiş açık kaynaklı Android DPI atlatma uygulamasıdır.

---

## 🚀 Hızlı Kurulum

1. Klasördeki **`GoodbyeDPI-Android.apk`** dosyasını Android telefonunuza aktarın veya [GitHub Releases](https://github.com/Zeki-wq/GoodbyeDpi-Turkey-Linux-Android/releases/latest) sayfasından doğrudan telefonunuza indirin.
2. APK dosyasını açıp kurun *(gerekirse "Bilinmeyen kaynaklardan yüklemeye izin ver" seçeneğini onaylayın)*.
3. Uygulamayı açın ve ortadaki **Bağlan (Connect)** butonuna dokunun. Android sisteminin sorduğu "VPN Bağlantı Talebi"ni **Tamam** diyerek onaylayın.
4. Discord ve engelli sitelere doğrudan telefonunuzdan girmeyi deneyin.

---

## 🔄 Telefon Kapanıp Açıldığında Otomatik Başlaması İçin

Uygulamanın tıpkı Linux sürümündeki gibi **telefon her yeniden başladığında kendiliğinden devreye girmesi** için şu iki basit ayarı yapın:

### 1. Uygulama İçi Otomatik Başlatma Ayarı:
1. Uygulamayı açın.
2. Sağ üstteki **Ayarlar (çark ⚙️)** simgesine dokunun.
3. **"Automatically start the service when the device boots"** *(Cihaz açıldığında servisi otomatik başlat)* seçeneğini **AÇIK (ON)** duruma getirin.

### 2. Android Pil Kısıtlamasını Kaldırma (Önemli):
Android işletim sistemi arka planda çalışan uygulamaları pil tasarrufu için kapatabilir. Bunun önüne geçmek için:
1. Telefonunuzun **Ayarlar > Uygulamalar > ByeDPI (veya GoodbyeDPI)** bölümüne gidin.
2. **Pil (Battery)** veya **Pil Tasarrufu** seçeneğine dokunun.
3. **"Kısıtlama Yok" (Unrestricted / Arka planda çalışmaya izin ver)** olarak ayarlayın.

*(Xiaomi / MIUI / HyperOS kullanıyorsanız ayrıca Güvenlik uygulamasından "Otomatik Başlatma" iznini açın).*

Artık telefonunuzu kapatsanız, şarjı bitse veya yeniden başlatsanız bile servis arka planda otomatik olarak açılacak ve Discord/engelli sitelere kesintisiz girmeye devam edeceksiniz.

---

## 🗑️ Kaldırma

Uygulamayı telefonunuzdan normal bir uygulama siler gibi ekranından basılı tutup **Kaldır** demeniz yeterlidir; sistemde hiçbir kalıntı bırakmaz.
