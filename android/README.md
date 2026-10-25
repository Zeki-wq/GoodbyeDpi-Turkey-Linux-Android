# GoodbyeDPI (Android) — Kurulum ve Ayar Rehberi

Bu klasördeki **`GoodbyeDPI-Android.apk`**, [ByeByeDPI](https://github.com/romanvht/ByeByeDPI) **v1.8.2** (evrensel APK) dosyasıdır. Açık kaynaklı, VPN sunucusu kullanmayan, DPI atlatma uygulamasıdır.

> SHA-256: `3df9570313c9fb03de19fdde7dbf7e56b943fd0845b2d57b687c5859aff4e0001`
> (Resmi ByeByeDPI sürümüyle birebir aynıdır, değiştirilmemiştir.)

Önceki sürümde olmayan özellikler bu sürümde vardır:
- **Apps filter / Select apps** (uygulama seçme ekranı)
- **Proxy test** (operatörünüzde hangi komutun çalıştığını uygulamanın kendisi test eder)
- **Autostart service on device startup** (telefon açılınca otomatik başlama)

> [!NOTE]
> Uygulama Türkçe dil desteğine sahiptir. Telefonunuz Türkçe ise menüler Türkçe görünür; aşağıda İngilizce adları parantez içinde verilmiştir.

---

## 1. Kurulum

1. `GoodbyeDPI-Android.apk` dosyasını telefona indirip kurun (gerekirse "bilinmeyen kaynaklardan yüklemeye izin ver").
2. Eski ByeDPI sürümü kuruluysa **önce onu kaldırın**.
3. Uygulamayı açıp **bağlan** butonuna basın ve çıkan **VPN izni** penceresini onaylayın. (Bu yerel bir VPN arayüzüdür; verileriniz uzak bir sunucuya gitmez.)

---

## 2. Özel DNS (Private DNS)

Operatörler Discord'u DNS ile de engelleyebildiği için telefonun DNS'ini değiştirmek gerekir.

**Ayarlar → Bağlantılar (veya Ağ ve İnternet) → Özel DNS → "Özel DNS sağlayıcı ana bilgisayar adı"**

Sırayla şunlardan birini deneyin:

| Sıra | Ana bilgisayar adı |
|---|---|
| 1 | `dns.google` |
| 2 | `one.one.one.one` |
| 3 | `dns.adguard-dns.com` |

Biri çalışmazsa bir sonrakini deneyin. Uygulama da "Private DNS is set in the system" uyarısı gösterir; bu normaldir.

> [!IMPORTANT]
> DNS tek başına yetmez. DPI engelini aşmak için bir sonraki adımdaki komut da gerekir.

---

## 3. Operatörünüze Uygun Komutu Bulma (Proxy test)

Her operatörde (Türk Telekom, Turkcell Superonline, Vodafone, TurkNet) çalışan komut farklı olabilir. Tek bir sabit komut yazmak yerine uygulamanın kendi testini kullanın:

1. Uygulamada **Ayarlar → Proxy test (Proxy test)** bölümüne girin.
2. **Testi başlat (Start testing)** düğmesine basın ve bitmesini bekleyin.
3. Test, hazır komut setlerini sırayla dener ve hangilerinin çalıştığını gösterir.
4. Çalışan bir komutu seçip **Ayarlar → Komut satırı ayarlarını kullan (Use command line settings) → Komut satırı düzenleyici (Command line editor)** alanına yapıştırın.

> [!WARNING]
> Uygulamanın kendi uyarısı: test sonuçları ön değerlendirme içindir, başarılı bitmesi her sitede kusursuz çalışacağı anlamına gelmez. Test sırasında uygulama kapanırsa, test ayarlarından komutlar arası bekleme süresini 2'şer saniye artırın.

Test Discord'u açmazsa başka bir komut seçip tekrar deneyin. Topluluk forumlarında Türkiye için sık paylaşılan bir komut:

```text
-s1 -At -d2 -f-1 -r1+s -An
```

Bu komutu telefonda test edemedim; her operatörde çalışacağının garantisi yoktur.

---

## 4. Uygulama Seçme (Apps filter)

Yalnızca Discord gibi seçtiğiniz uygulamaların uygulamadan geçmesini istiyorsanız:

1. **Ayarlar → Uygulama filtresi (Apps filter)** bölümüne girin.
2. Modu **Whitelist** (yalnızca seçilenler) yapın.
3. **Uygulamaları seç (Select apps)** ile Discord'u (ve gerekirse tarayıcınızı) işaretleyin.

**Blacklist** seçerseniz tersi olur: seçtikleriniz hariç tüm uygulamalar geçer.

---

## 5. Telefon Açılınca Otomatik Başlasın

Uygulama ayarlarında şu iki seçeneği açın:

- **Autostart service on device startup** (cihaz açılışında servisi başlat)
- **Automatically connect when the ByeByeDPI start** (uygulama açılınca otomatik bağlan)

Ardından Android'in uygulamayı kapatmaması için:
**Ayarlar → Uygulamalar → ByeByeDPI → Pil → "Kısıtlama yok" (Unrestricted)**

Xiaomi / MIUI / HyperOS / Huawei gibi cihazlarda ayrıca güvenlik uygulamasından **Otomatik başlatma** iznini verin.

> [!NOTE]
> Android, uygulama VPN iznini bir kez onaylamadan açılışta otomatik bağlanmasına izin vermez. İlk kurulumda bağlanıp izni mutlaka onaylayın.

---

## 6. Pil Tüketimi

Uzak sunucuya bağlanmadığı ve trafiği şifrelemediği için normal VPN'lere göre çok daha az pil harcar. Kesin değer cihaza göre değişir; pil kullanım ekranından kendiniz kontrol edebilirsiniz. Apps filter ile yalnızca Discord'u seçmek tüketimi daha da azaltır.

---

## 7. Kaldırma

Uygulamayı normal şekilde kaldırmanız yeterlidir.

---

## 📄 Lisans ve Kaynak (Credits)

Bu klasörde yer alan uygulama, **[romanvht/ByeByeDPI](https://github.com/romanvht/ByeByeDPI)** projesine aittir ve **GNU General Public License v3.0 (GPL-3.0)** altında dağıtılmaktadır. Uygulama [dovecoteescapee](https://github.com/dovecoteescapee/ByeDPIAndroid) ve [hufrea/byedpi](https://github.com/hufrea/byedpi) tabanlıdır.

Klasördeki APK, resmi sürümden doğrudan alınmış orijinal ve değiştirilmemiş ikilidir.

