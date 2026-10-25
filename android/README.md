# GoodbyeDPI (Android) — Kurulum ve Ayar Rehberi

Bu klasördeki **`GoodbyeDPI-Android.apk`**, Türkiye'de Discord, Roblox ve engelli sitelere **VPN sunucusu olmadan** ve **hız kaybı yaşamadan** erişmek için geliştirilmiş açık kaynaklı Android DPI atlatma uygulamasıdır.

---

## 🇹🇷 Discord'u Sorunsuz Açma Ayarı (Kesin Çözüm)

Türkiye'deki operatörler (Türk Telekom, Superonline, Vodafone vb.) Discord'u hem **DNS engeli** hem de **DPI filtrelemesi** ile engellediği için, uygulamayı kurup ayar yapmadan doğrudan bastığınızda Discord açılmayabilir veya sonsuz yüklemede kalabilir.

Discord ve diğer servislerin anında açılması için **yalnızca 30 saniyelik** şu 2 adımı yapmanız gerekir:

### 1. Adım: Telefonun Özel DNS Ayarı (En Önemlisi)
Operatörlerin Discord adreslerini engellemesini aşmak için:
1. Telefonun **Ayarlar** menüsüne gidin.
2. **Bağlantılar (veya Ağ ve İnternet) > Özel DNS (Private DNS)** seçeneğine dokunun.
3. **Özel DNS sağlayıcı ana bilgisayar adı** seçeneğini işaretleyip şu adresi yazın ve kaydedin:
   ```text
   dns.google
   ```
   *(veya alternatif: `one.one.one.one`)*

### 2. Adım: Uygulama İçine Türkiye Discord Kodunu Girme
DPI duvarını atlatmak için:
1. **GoodbyeDPI (ByeDPI)** uygulamasını açın.
2. Sağ üstteki **Ayarlar (çark ⚙️)** simgesine dokunun.
3. **"Use command line settings"** *(Komut satırı ayarlarını kullan)* seçeneğini **AÇIK** yapın.
4. Açılan **Command line editor** kutusuna dokunun ve şu kodu eksiksiz yapıştırın:
   ```text
   -s1 -At -d2 -f-1 -r1+s -An
   ```
   *(Eğer Turkcell Superonline kullanıyorsanız alternatif olarak: `-s1 -At -d2 -At -f-1 -r1+s -An`)*
5. Ana ekrana dönüp **Connect (Bağlan)** butonuna dokunun.

🎉 **Discord, sesli kanallar ve engelli siteler anında açılacaktır!**

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
