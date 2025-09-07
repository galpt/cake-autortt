# cake-autortt

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | [中文](README_zh.md) | [Bahasa Indonesia](README_id.md) | [Русский](README_ru.md) | [日本語](README_ja.md) | [Tiếng Việt](README_vi.md) | **Türkçe** | [العربية](README_ar.md)

---

> [!NOTE]  
> **Ubuntu/Debian sürümünü** arıyorsanız, `ubuntu-debian/` klasörünü kontrol edin. Ancak, yalnızca OpenWrt sürümünün günlük olarak kişisel olarak test edildiğini unutmayın - Ubuntu/Debian portu topluluk için olduğu gibi sağlanmaktadır.

**Ölçülen ağ koşullarına dayalı olarak CAKE qdisc RTT parametresini otomatik olarak ayarlar**

`cake-autortt`, aktif ağ bağlantılarını izleyen ve optimal ağ performansı için gelen ve giden arayüzlerde CAKE qdisc'in RTT (Round Trip Time) parametresini otomatik olarak ayarlayan akıllı bir OpenWrt hizmetidir.

## 🌍 Bu neden İnternet deneyiminiz için önemli

Çoğu kullanıcı YouTube, Netflix ve Google gibi büyük sitelerin hızlı yükleme sürelerine alışkındır - bunlar kullanıcılara çok yakın sunucular yerleştiren içerik dağıtım ağları (CDN'ler) kullanır ve genellikle 50-100ms altında yanıt süreleri sağlar. Ancak, İnternet bu büyük platformlardan çok daha geniştir.

**CDN destekli büyük siteler dışında web'de gezindiğinizde, çeşitli sunuculardan oluşan bir dünyayla karşılaşırsınız:**
- **Yerel/Bölgesel Hizmetler**: Küçük işletmeler, yerel haber siteleri, topluluk forumları ve bölgesel hizmetler genellikle ülkenizde veya bölgenizde sunuculara sahiptir (10-50ms RTT)
- **Uluslararası İçerik**: Özel web siteleri, akademik kaynaklar, oyun sunucuları ve niş hizmetler diğer kıtalarda barındırılabilir (100-500ms RTT)
- **Uzak Altyapı**: Bazı hizmetler, özellikle gelişmekte olan bölgelerde veya özel uygulamalarda, önemli ölçüde yüksek gecikmeye sahip olabilir

**CAKE RTT parametresi, kuyruk algoritmasının tıkanıklığa ne kadar agresif tepki vereceğini kontrol eder.** Varsayılan olarak, CAKE 100ms RTT varsayımı kullanır, bu genel İnternet trafiği için oldukça iyi çalışır. Ancak:

- **RTT ayarı çok düşük**: CAKE ağ RTT'sinin gerçekte olduğundan daha kısa olduğunu düşünürse, kuyruk şekillendirmesi yaparken paket düşürme konusunda çok agresif hale gelir ve uzak sunucular için bant genişliğini azaltabilir
- **RTT ayarı çok yüksek**: CAKE ağ RTT'sinin gerçekte olduğundan daha uzun olduğunu düşünürse, çok muhafazakar hale gelir ve büyük kuyrukların oluşmasına izin verir, yakın sunucular için gereksiz gecikme yaratır

**Gerçek dünya etkisi örnekleri:**
- **Singapur kullanıcısı → Alman sunucusu**: RTT ayarlaması olmadan, Singapur'daki bir kullanıcı Alman web sitesine (≈180ms RTT) erişirken, CAKE'nin varsayılan 100ms ayarının erken paket düşürmeye neden olması nedeniyle azaltılmış bant genişliği yaşayabilir
- **Kırsal ABD → Bölgesel sunucu**: Kırsal ABD'deki bir kullanıcı bölgesel sunucuya (≈25ms RTT) erişirken, CAKE'nin varsayılan 100ms ayarının kuyrukların gerekenden daha büyük gelişmesine izin vermesi nedeniyle gerekenden daha yüksek gecikme yaşayabilir
- **Oyun/Gerçek zamanlı uygulamalar**: Hem gecikme hem de bant genişliğine duyarlı uygulamalar, gerçek ağ koşullarına uygun RTT ayarlamasından önemli ölçüde faydalanır

**cake-autortt nasıl yardımcı olur:**
İletişim kurduğunuz sunuculara gerçek RTT'yi otomatik olarak ölçerek ve CAKE parametresini buna göre ayarlayarak şunları elde edersiniz:
- Yakın sunuculara erişirken **daha hızlı yanıt** (daha kısa RTT → daha agresif kuyruk yönetimi)
- Uzak sunuculara erişirken **daha iyi bant genişliği** (daha uzun RTT → daha sabırlı kuyruk yönetimi)
- Varsayımlar yerine gerçek ağ koşullarına uyum sağlayan **optimal bufferbloat kontrolü**

Bu, özellikle çeşitli içerik kaynaklarına düzenli olarak erişen, uluslararası hizmetlerle çalışan veya İnternet trafiğinin genellikle büyük mesafeler kat ettiği bölgelerde yaşayan kullanıcılar için değerlidir.

## 🚀 Özellikler

- **Otomatik RTT Algılama**: `/proc/net/nf_conntrack` aracılığıyla aktif bağlantıları izler ve dış hostlara RTT ölçer
- **Akıllı Host Filtreleme**: LAN adreslerini otomatik olarak filtreler ve dış hostlara odaklanır
- **Akıllı RTT Algoritması**: Her bir hostu ayrı ayrı ölçmek için yerleşik ping kullanır (host başına 3 ping), ardından optimal performans için ortalama ve en kötü durum RTT arasında akıllıca seçim yapar
- **Otomatik Arayüz Algılama**: CAKE ile arayüzleri otomatik olarak algılar (indirme için `ifb-*` tercih edilir, yükleme için fiziksel arayüzler)
- **OpenWrt Hizmet Entegrasyonu**: Otomatik başlatma ve süreç yönetimi ile uygun bir OpenWrt hizmeti olarak çalışır
- **Yapılandırılabilir Parametreler**: Tüm zamanlama ve davranış parametreleri UCI yapılandırması aracılığıyla yapılandırılabilir
- **Sağlam Hata İşleme**: Eksik bağımlılıkları, ağ sorunlarını ve arayüz değişikliklerini zarif bir şekilde işler
- **Minimal Bağımlılıklar**: Yalnızca ping ve tc gerektirir - ek paket gerekmez, tüm sistemlerde mevcut olan yerleşik yardımcı programları kullanır
- **Yüksek Hassasiyetli RTT**: Hassas ağ zamanlaması için kesirli RTT değerlerini destekler (örn. 100.23ms)

## 🔧 Uyumluluk

**Test edildi ve çalışıyor:**
- **OpenWrt 24.10.1, r28597-0425664679, Hedef Platform x86/64**

**Beklenen uyumluluk:**
- CAKE qdisc desteği olan önceki OpenWrt sürümleri (21.02+)
- Gerekli bağımlılıklar mevcut olduğu sürece gelecekteki OpenWrt sürümleri
- OpenWrt tarafından desteklenen tüm hedef mimariler (ARM, MIPS, x86, vb.)

**Uyumluluk gereksinimleri:**
- CAKE qdisc kernel modülü
- ping yardımcı programı (tüm standart Linux dağıtımlarında dahil)
- Standart tc yardımcı programı (trafik kontrolü)
- /proc/net/nf_conntrack desteği (netfilter conntrack)

## 📋 Gereksinimler

### Bağımlılıklar
- **ping**: RTT ölçümü için standart ping yardımcı programı (tüm Linux dağıtımlarında dahil)
- **tc**: Trafik kontrol yardımcı programı (iproute2'nin bir parçası)
- **CAKE qdisc**: Hedef arayüzlerde yapılandırılmış olmalıdır

### Bağımlılık Kurulumu

```bash
# ping varsayılan olarak OpenWrt'de dahildir
# ping işlevselliği için ek paket gerekmez

# CAKE qdisc genellikle modern OpenWrt sürümlerinde mevcuttur
# tc'nin CAKE'i destekleyip desteklemediğini kontrol edin:
tc qdisc help | grep cake
```

## 🔧 Kurulum

> [!IMPORTANT]  
> Kurulum betiğini çalıştırmadan önce, sisteminiz için doğru arayüz adlarını ayarlamak üzere yapılandırma dosyasını düzenlemeniz GEREKİR.

1. **Yapılandırma dosyasını düzenleyin:**

```bash
# Yapılandırma dosyasını arayüz adlarınızla eşleşecek şekilde düzenleyin
nano etc/config/cake-autortt
```

2. **Arayüz adlarınızı yapılandırın:**

Ağ kurulumunuzla eşleşecek şekilde `dl_interface` (indirme) ve `ul_interface` (yükleme) ayarlarını güncelleyin:

```bash
# Farklı kurulumlar için örnek yapılandırmalar:

# ifb arayüzleri kullanan tipik OpenWrt SQM kurulumu için:
option dl_interface 'ifb-wan'      # İndirme arayüzü (genellikle ifb-*)
option ul_interface 'wan'          # Yükleme arayüzü (genellikle wan, eth0, vb.)

# Doğrudan arayüz kurulumu için:
option dl_interface 'eth0'         # WAN arayüzünüz
option ul_interface 'eth0'         # Her iki yön için aynı arayüz

# Özel arayüz adları için:
option dl_interface 'ifb4eth1'     # Özel indirme arayüzünüz
option ul_interface 'eth1'         # Özel yükleme arayüzünüz
```

**Arayüz adlarınızı nasıl bulursunuz:**
```bash
# CAKE qdisc ile arayüzleri listeleyin
tc qdisc show | grep cake

# Tüm ağ arayüzlerini listeleyin
ip link show

# SQM arayüz yapılandırmasını kontrol edin (SQM kullanıyorsanız)
uci show sqm
```

### Hızlı Kurulum

1. **Arayüzleri yapılandırın (yukarıdaki bölüme bakın)**

2. **Kurulum betiğini çalıştırın:**

```bash
# Kurulum betiğini çalıştırılabilir yapın ve çalıştırın
chmod +x install.sh
./install.sh
```

### Manuel Kurulum

1. **Hizmet dosyalarını OpenWrt yönlendiricinize kopyalayın:**

```bash
# Ana çalıştırılabilir dosyayı kopyalayın
cp usr/bin/cake-autortt /usr/bin/
chmod +x /usr/bin/cake-autortt

# Init betiğini kopyalayın
cp etc/init.d/cake-autortt /etc/init.d/
chmod +x /etc/init.d/cake-autortt

# Yapılandırma dosyasını kopyalayın
cp etc/config/cake-autortt /etc/config/

# Hotplug betiğini kopyalayın
cp etc/hotplug.d/iface/99-cake-autortt /etc/hotplug.d/iface/
chmod +x /etc/hotplug.d/iface/99-cake-autortt
```

2. **Hizmeti etkinleştirin ve başlatın:**

```bash
# Önyüklemede otomatik başlatma için hizmeti etkinleştirin
/etc/init.d/cake-autortt enable

# Hizmeti başlatın
/etc/init.d/cake-autortt start
```

## 🗑️ Kaldırma

cake-autortt'yi sisteminizden kaldırmak için:

```bash
# Kaldırma betiğini çalıştırılabilir yapın ve çalıştırın
chmod +x uninstall.sh
./uninstall.sh
```

Kaldırma betiği şunları yapacaktır:
- Hizmeti durdur ve devre dışı bırak
- Tüm kurulu dosyaları kaldır
- İsteğe bağlı olarak yapılandırma dosyalarını ve yedekleri kaldır
- Geçici dosyaları temizle

## ⚙️ Yapılandırma

### 🔧 Arayüz Yapılandırması (GEREKLİ)

**En kritik yapılandırma adımı doğru arayüz adlarını ayarlamaktır.** Hizmet, doğru arayüz adları olmadan düzgün çalışmayacaktır.

```bash
# Mevcut yapılandırmayı görüntüleyin
uci show cake-autortt

# GEREKLİ: Arayüz adlarınızı ayarlayın
uci set cake-autortt.global.dl_interface='your-download-interface'
uci set cake-autortt.global.ul_interface='your-upload-interface'
uci commit cake-autortt

# Diğer isteğe bağlı yapılandırma değişiklikleri
uci set cake-autortt.global.rtt_update_interval='30'
uci set cake-autortt.global.debug='1'
uci commit cake-autortt

# Değişiklikleri uygulamak için hizmeti yeniden başlatın
/etc/init.d/cake-autortt restart
```

Hizmet UCI aracılığıyla yapılandırılır. `/etc/config/cake-autortt` dosyasını düzenleyin veya `uci` komutlarını kullanın.

### Yapılandırma Parametreleri

| Parametre | Varsayılan | Açıklama |
|-----------|---------|-------------|
| `dl_interface` | auto | İndirme arayüz adı (örn. 'ifb-wan', 'ifb4eth1') |
| `ul_interface` | auto | Yükleme arayüz adı (örn. 'wan', 'eth1') |
| `rtt_update_interval` | 5 | qdisc RTT parametresi güncellemeleri arasındaki saniye |
| `min_hosts` | 3 | RTT hesaplaması için gereken minimum host sayısı |
| `max_hosts` | 100 | Sıralı olarak araştırılacak maksimum host sayısı |
| `rtt_margin_percent` | 10 | Ölçülen RTT'ye eklenen güvenlik marjı (yüzde) |
| `default_rtt_ms` | 100 | Yeterli host mevcut olmadığında varsayılan RTT |
| `debug` | 0 | Hata ayıklama günlüğünü etkinleştir (0=kapalı, 1=açık) |

> [!NOTE]  
> Arayüz parametreleri "auto" varsayılanına sahip olsa da, otomatik algılama tüm yapılandırmalarda güvenilir şekilde çalışmayabilir. Bu değerleri açıkça ayarlamanız şiddetle önerilir.

> [!TIP]  
> Yüksek aktiviteli ağlar için (örn. üniversite kampüsleri, birçok aktif kullanıcısı olan kamu ağları), ağ özelliklerinize göre `rtt_update_interval`'ı ayarlamayı düşünün. Varsayılan 5 saniye çoğu durum için iyi çalışır, ancak daha kararlı ağlar için 10-15 saniyeye çıkarabilir veya çok dinamik ortamlar için 3 saniyeye düşürebilirsiniz.

## 🔍 Nasıl Çalışır

1. **Bağlantı İzleme**: Aktif ağ bağlantılarını belirlemek için `/proc/net/nf_conntrack`'i periyodik olarak analiz eder
2. **Host Filtreleme**: Hedef IP adreslerini çıkarır ve özel/LAN adreslerini filtreler
3. **RTT Ölçümü**: Her bir dış hostu ayrı ayrı ölçmek için `ping` kullanır (host başına 3 ping)
4. **Akıllı RTT Seçimi**: Ağ tıkanıklığını önlemek için hostları sıralı olarak pingleyerek ortalama ve en kötü durum RTT'sini hesaplar, ardından tüm bağlantılar için optimal performansı sağlamak üzere daha yüksek değeri kullanır
5. **Güvenlik Marjı**: Yeterli tamponlama sağlamak için ölçülen RTT'ye yapılandırılabilir marj ekler
6. **qdisc Güncellemesi**: İndirme ve yükleme arayüzlerinde CAKE qdisc RTT parametresini günceller

### 🧠 Akıllı RTT Algoritması

Sürüm 1.2.0'dan itibaren, cake-autortt Dave Täht'ın (CAKE ortak yazarı) önerisine dayalı akıllı RTT seçim algoritması uygular:

**Sorun**: Yalnızca ortalama RTT kullanmak, bazı hostların diğerlerinden önemli ölçüde daha yüksek gecikmeye sahip olduğu durumlarda sorunlu olabilir. Örneğin, ortalama RTT'si 40ms olan 100 hostunuz varsa, ancak 2 host 234ms ve 240ms RTT'ye sahipse, ortalama 40ms kullanmak bu yüksek gecikmeli bağlantılar için performans sorunlarına neden olabilir.

**Çözüm**: Mevcut algoritma:
1. **Tüm yanıt veren hostlardan hem ortalama hem de en kötü durum RTT'sini hesaplar**
2. **İki değeri karşılaştırır** ve uygun değeri akıllıca seçer
3. **En kötü durum RTT ortalamadan önemli ölçüde yüksek olduğunda** tüm bağlantıların iyi performans göstermesini sağlamak için en kötü durum RTT'sini kullanır
4. **En kötü durum RTT ortalamaya yakın olduğunda** aşırı muhafazakar ayarları önlemek için ortalama RTT'yi kullanır

**Bu neden önemli**: [Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17)'a göre, "özellikle gelen şekillendirme ile, tipik RTT'nizi, yenmeye çalıştığınız ISP şekillendiricisine ulaşmadan önce kuyruk kontrolü elde etmek için bir tahmin olarak kullanmak daha iyidir." Ancak, herhangi bir hosta gerçek RTT, CAKE arayüzünde ayarlanan RTT'den daha uzunsa, performans önemli ölçüde etkilenebilir.

**Gerçek dünya örneği**:
- 30-50ms RTT'li 98 host (ortalama: 42ms)
- 200ms+ RTT'li 2 host (en kötü: 234ms)
- **Eski algoritma**: Ortalama 45ms kullanırdı, 200ms+ hostlar için sorunlara neden olurdu
- **Yeni algoritma**: En kötü durum RTT 234ms kullanır, tüm bağlantılar için optimal performans sağlar

### Örnek Bağlantı Akışı

```
[LAN Cihazı] → [CAKE Router] → [İnternet]
                       ↑
                 cake-autortt aktif
                 bağlantıları izler ve
                 RTT parametresini ayarlar
```

## 📊 Beklenen Davranış

Kurulum ve başlatmadan sonra şunları gözlemlemelisiniz:

### Anında Etkiler
- Hizmet otomatik olarak başlar ve bağlantıları izlemeye başlar
- RTT ölçümleri sistem günlüğüne kaydedilir (hata ayıklama etkinse)
- CAKE qdisc RTT parametresi ölçülen ağ koşullarına göre her 30 saniyede bir güncellenir
- Yüksek hassasiyetli RTT değerleri (örn. 44.89ms) CAKE qdisc'e uygulanır

### Uzun Vadeli Faydalar
- **Gelişmiş Yanıt Verme**: RTT parametresi gerçek ağ koşullarıyla güncel tutulur
- **Daha İyi Bufferbloat Kontrolü**: CAKE daha bilgili kuyruk yönetimi kararları verebilir
- **Uyarlanabilir Performans**: Değişen ağ koşullarına otomatik olarak uyum sağlar (uydu, mobil, tıkanık bağlantılar)
- **Daha Yüksek Doğruluk**: Ağ koşullarının daha iyi temsili için 20'ye kadar host örnekler

### İzleme

```bash
# Hizmet durumunu kontrol edin
/etc/init.d/cake-autortt status

# Hizmet günlüklerini görüntüleyin
logread | grep cake-autortt

# CAKE qdisc parametrelerini izleyin
tc qdisc show | grep cake

# Ayrıntılı günlükler için hata ayıklama modu
uci set cake-autortt.global.debug='1'
uci commit cake-autortt
/etc/init.d/cake-autortt restart
```

## 🔧 Sorun Giderme

### Yaygın Sorunlar

1. **Hizmet başlamıyor**
   ```bash
   # Bağımlılıkları kontrol edin
   which ping tc
   
   # CAKE arayüzlerini kontrol edin
   tc qdisc show | grep cake
   ```

2. **RTT güncellemesi yok**
   ```bash
   # Hata ayıklama modunu etkinleştirin
   uci set cake-autortt.global.debug='1'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   
   # Günlükleri kontrol edin
   logread | grep cake-autortt
   ```

3. **Arayüz algılama başarısız**
   ```bash
   # Arayüzleri manuel olarak belirtin
   uci set cake-autortt.global.dl_interface='ifb-wan'
   uci set cake-autortt.global.ul_interface='wan'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   ```

### Hata Ayıklama Bilgileri

Hata ayıklama etkinken (`uci set cake-autortt.global.debug='1'`), hizmet ayrıntılı günlükler sağlar:

**Örnek hata ayıklama çıktısı:**
```bash
[2025-01-09 18:34:22] cake-autortt DEBUG: conntrack'ten host çıkarılıyor
[2025-01-09 18:34:22] cake-autortt DEBUG: 35 LAN olmayan host bulundu
[2025-01-09 18:34:22] cake-autortt DEBUG: 35 host için ping ile RTT ölçülüyor (host başına 3 ping)
[2025-01-09 18:34:25] cake-autortt DEBUG: ping özeti: 28/35 host canlı
[2025-01-09 18:34:25] cake-autortt DEBUG: Ortalama RTT kullanılıyor: 45.2ms (ortalama: 45.2ms, en kötü: 89.1ms)
[2025-01-09 18:34:25] cake-autortt DEBUG: Ölçülen RTT kullanılıyor: 45.2ms
[2025-01-09 18:34:35] cake-autortt INFO: CAKE RTT 49.72ms (49720us) olarak ayarlandı
[2025-01-09 18:34:35] cake-autortt DEBUG: RTT indirme arayüzü ifb-wan'da güncellendi
[2025-01-09 18:34:35] cake-autortt DEBUG: RTT yükleme arayüzü wan'da güncellendi
```

> [!NOTE]  
> **Bellek Verimli Günlükleme**: Hata ayıklama günlükleri günlük taşmasını önlemek için optimize edilmiştir. Bireysel host RTT ölçümleri bellek kullanımını ve disk yazımını azaltmak için günlüğe kaydedilmez. Yalnızca özet bilgiler günlüğe kaydedilir, bu da aşırı günlük büyümesi olmadan sürekli işlem için uygun hale getirir.

## 📄 Lisans

Bu proje GNU General Public License v2.0 altında lisanslanmıştır - ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.

## 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır! Lütfen Pull Request gönderin.