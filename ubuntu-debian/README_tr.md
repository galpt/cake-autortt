# Ubuntu/Debian için cake-autortt

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | [中文](README_zh.md) | [Bahasa Indonesia](README_id.md) | [Русский](README_ru.md) | [日本語](README_ja.md) | [Tiếng Việt](README_vi.md) | **Türkçe** | [العربية](README_ar.md)

---

**Ölçülen ağ koşullarına dayalı olarak CAKE qdisc RTT parametresini otomatik olarak ayarlar**

Bu, OpenWrt'nin UCI sistemi yerine systemd, apt paket yönetimi ve geleneksel yapılandırma dosyalarını kullanan standart Linux dağıtımları için ayarlanmış cake-autortt'nin **Ubuntu/Debian portu**dur.

## 🌍 Bu neden internet deneyiminiz için önemli

Çoğu kullanıcı YouTube, Netflix ve Google gibi büyük sitelerin hızlı yüklenmesine alışkındır - bunlar içerik dağıtım ağları (CDN'ler) kullanarak sunucuları kullanıcılara çok yakın yerleştirirler ve genellikle 50-100ms altında yanıt süreleri sağlarlar. Ancak internet bu büyük platformlardan çok daha geniştir.

**Ana CDN destekli siteler dışındaki web sitelerine göz attığınızda, çeşitli sunuculardan oluşan bir dünyayla karşılaşırsınız:**
- **Yerel/bölgesel hizmetler**: Küçük işletmeler, yerel haber siteleri, topluluk forumları ve bölgesel hizmetler genellikle ülkenizde veya bölgenizde sunuculara sahiptir (10-50ms RTT)
- **Uluslararası içerik**: Özel web siteleri, akademik kaynaklar, oyun sunucuları ve niş hizmetler diğer kıtalarda barındırılabilir (100-500ms RTT)
- **Uzak altyapı**: Özellikle gelişmekte olan bölgelerdeki veya özel uygulamalardaki bazı hizmetler önemli ölçüde daha yüksek gecikmeye sahip olabilir

**CAKE'nin RTT parametresi, kuyruk yönetimi algoritmasının tıkanıklığa ne kadar agresif tepki vereceğini kontrol eder.** Varsayılan olarak CAKE, genel internet trafiği için oldukça iyi çalışan 100ms RTT varsayımını kullanır. Ancak:

- **RTT ayarı çok düşük**: CAKE ağ RTT'sinin gerçekte olduğundan daha kısa olduğunu düşünürse, kuyruklar biriktiğinde paket düşürme konusunda çok agresif hale gelir ve uzak sunucular için bant genişliğini azaltabilir
- **RTT ayarı çok yüksek**: CAKE ağ RTT'sinin gerçekte olduğundan daha uzun olduğunu düşünürse, çok muhafazakar hale gelir ve büyük kuyrukların birikmesine izin vererek yakın sunucular için gereksiz gecikme yaratır

**Gerçek dünya etkisi örnekleri:**
- **Singapur kullanıcısı → Alman sunucusu**: RTT ayarlaması olmadan, Singapur'daki bir kullanıcının Alman web sitesine (≈180ms RTT) erişimi, CAKE'nin varsayılan 100ms ayarının erken paket düşürmeye neden olması nedeniyle azaltılmış bant genişliği yaşayabilir
- **Kırsal ABD → Bölgesel sunucu**: Kırsal ABD'deki bir kullanıcının bölgesel sunucuya (≈25ms RTT) erişimi, CAKE'nin varsayılan 100ms ayarının gerekenden daha fazla kuyruk gelişimine izin vermesi nedeniyle gerekenden daha yüksek gecikme yaşayabilir
- **Oyun/gerçek zamanlı uygulamalar**: Hem gecikme hem de bant genişliğine duyarlı uygulamalar, gerçek ağ koşullarına uygun RTT ayarlamasından önemli ölçüde faydalanır

**cake-autortt nasıl yardımcı olur:**
İletişim kurduğunuz sunuculara gerçek RTT'yi otomatik olarak ölçerek ve CAKE parametrelerini buna göre ayarlayarak şunları elde edersiniz:
- Yakın sunuculara erişirken **daha hızlı yanıt** (daha kısa RTT → daha agresif kuyruk yönetimi)
- Uzak sunuculara erişirken **daha iyi bant genişliği** (daha uzun RTT → daha sabırlı kuyruk yönetimi)
- Varsayımlar yerine gerçek ağ koşullarına uyum sağlayan **optimal bufferbloat kontrolü**

Bu özellikle çeşitli içerik kaynaklarına sık sık erişen, uluslararası hizmetlerle çalışan veya internet trafiğinin genellikle büyük mesafeler kat ettiği bölgelerde yaşayan kullanıcılar için değerlidir.

## 🚀 Özellikler

- **Otomatik RTT keşfi**: `/proc/net/nf_conntrack` üzerinden aktif bağlantıları izler ve dış hostlara RTT ölçer
- **Akıllı host filtreleme**: LAN adreslerini otomatik olarak filtreler ve dış hostlara odaklanır
- **Akıllı RTT algoritması**: Her host için ayrı RTT ölçmek üzere yerleşik ping komutunu kullanır (host başına 3 ping), ardından optimal performans için ortalama ve en kötü RTT arasında akıllıca seçim yapar
- **Otomatik arayüz keşfi**: CAKE etkin arayüzleri otomatik olarak algılar
- **systemd entegrasyonu**: Otomatik başlatma ve süreç yönetimi ile uygun bir systemd hizmeti olarak çalışır
- **Yapılandırılabilir parametreler**: Tüm zamanlama ve davranış parametreleri yapılandırma dosyası aracılığıyla yapılandırılabilir
- **Sağlam hata işleme**: Eksik bağımlılıkları, ağ sorunlarını ve arayüz değişikliklerini zarif bir şekilde işler
- **Minimal bağımlılıklar**: Sadece ping ve tc gerekir - ek paket gerekmez, tüm sistemlerde mevcut olan yerleşik yardımcı programları kullanır
- **Yüksek hassasiyetli RTT**: Hassas ağ zamanlaması için kesirli RTT değerlerini destekler (örn. 100.23ms)

## 🔧 Uyumluluk

**Test edildi ve çalışıyor:**
- **Ubuntu 20.04+ (Focal ve üzeri)**
- **Debian 10+ (Buster ve üzeri)**

**Beklenen uyumluluk:**
- CAKE qdisc desteği olan herhangi bir systemd tabanlı Linux dağıtımı
- Modern iproute2 paketine sahip dağıtımlar

**Uyumluluk gereksinimleri:**
- CAKE qdisc kernel modülü (Linux 4.19+'da mevcut)
- ping yardımcı programı (tüm standart Linux dağıtımlarında dahil)
- systemd hizmet yönetimi
- tc (trafik kontrolü) yardımcı programı ile iproute2
- /proc/net/nf_conntrack desteği (netfilter conntrack)

## 📋 Gereksinimler

### Bağımlılıklar
- **ping**: RTT ölçümü için standart ping yardımcı programı (tüm Linux dağıtımlarında dahil)
- **tc**: Trafik kontrolü yardımcı programı (iproute2'nin bir parçası)
- **CAKE qdisc**: Hedef arayüzlerde yapılandırılmış olmalı
- **systemd**: Hizmet yönetimi
- **netfilter conntrack**: Bağlantı izleme için (/proc/net/nf_conntrack)

### Bağımlılıkları yükleme

```bash
# Gerekli paketleri yükle
sudo apt update
sudo apt install iputils-ping iproute2

# tc'nin CAKE desteği olup olmadığını kontrol et:
tc qdisc help | grep cake

# conntrack kullanılabilirliğini kontrol et
ls /proc/net/nf_conntrack
```

## 🔧 Kurulum

> [!IMPORTANT]  
> Kurulum betiğini çalıştırmadan önce, ağ arayüzlerinizde CAKE qdisc'i yapılandırmanız ve sisteminiz için doğru arayüz adlarını ayarlamak üzere yapılandırma dosyasını düzenlemeniz GEREKİR.

### Ön koşul: CAKE qdisc yapılandırması

Önce ağ arayüzlerinizde CAKE qdisc'i yapılandırmanız gerekir. Bu genellikle internet'e bakan arayüzde yapılır:

```bash
# Örnek: Ana arayüzde CAKE yapılandırması
# 'eth0'ı gerçek arayüz adınızla değiştirin
# '100Mbit'i gerçek bant genişliğinizle değiştirin

# Basit yapılandırma için (eth0'ı arayüzünüzle değiştirin):
sudo tc qdisc add root dev eth0 cake bandwidth 100Mbit

# Ingress shaping ile gelişmiş yapılandırma için:
# İndirme shaping için ifb (intermediate functional block) arayüzü oluştur
sudo modprobe ifb
sudo ip link add name ifb0 type ifb
sudo ip link set dev ifb0 up

# Ingress trafik yönlendirme ve CAKE yapılandır
sudo tc qdisc add dev eth0 handle ffff: ingress
sudo tc filter add dev eth0 parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
sudo tc qdisc add root dev ifb0 cake bandwidth 500Mbit ingress

# Egress CAKE yapılandır
sudo tc qdisc add root dev eth0 cake bandwidth 50Mbit

# CAKE'nin yapılandırıldığını doğrula
tc qdisc show | grep cake
```

### Hızlı kurulum

1. **CAKE arayüzlerini yapılandır (yukarıdaki bölüme bakın)**

2. **Yapılandırma dosyasını düzenle:**

```bash
# Yapılandırma dosyasını arayüz adlarınıza uyacak şekilde düzenle
nano etc/default/cake-autortt
```

3. **Arayüz adlarınızı yapılandır:**

Ağ yapılandırmanıza uyacak şekilde `DL_INTERFACE` (indirme) ve `UL_INTERFACE` (yükleme) ayarlarını güncelleyin:

```bash
# Farklı kurulumlar için örnek yapılandırmalar:

# Basit kurulum için (her iki yön için tek arayüz):
DL_INTERFACE="eth0"
UL_INTERFACE="eth0"

# Ingress shaping için ifb arayüzü ile gelişmiş kurulum için:
DL_INTERFACE="ifb0"     # İndirme arayüzü (ingress trafik shaping için ifb)
UL_INTERFACE="eth0"     # Yükleme arayüzü (fiziksel arayüz)

# Özel arayüz adları için:
DL_INTERFACE="enp3s0"   # Özel indirme arayüzünüz
UL_INTERFACE="enp3s0"   # Özel yükleme arayüzünüz
```

**Arayüz adlarınızı nasıl bulacağınız:**
```bash
# CAKE qdisc'li arayüzleri listele
tc qdisc show | grep cake

# Tüm ağ arayüzlerini listele
ip link show

# Ana ağ arayüzünüzü kontrol edin
ip route | grep default
```

4. **Kurulum betiğini çalıştır:**

```bash
# Kurulum betiğini çalıştırılabilir yap ve çalıştır
chmod +x install.sh
sudo ./install.sh
```

### Manuel kurulum

1. **Hizmet dosyalarını sisteminize kopyala:**

```bash
# Ana çalıştırılabilir dosyayı kopyala
sudo cp usr/bin/cake-autortt /usr/bin/
sudo chmod +x /usr/bin/cake-autortt

# systemd hizmet dosyasını kopyala
sudo cp etc/systemd/system/cake-autortt.service /etc/systemd/system/

# Yapılandırma dosyasını kopyala
sudo cp etc/default/cake-autortt /etc/default/

# Arayüz izleme için udev kuralını kopyala
sudo cp etc/udev/rules.d/99-cake-autortt.rules /etc/udev/rules.d/

# systemd ve udev'i yeniden yükle
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```

2. **Hizmeti etkinleştir ve başlat:**

```bash
# Önyüklemede otomatik başlatma için hizmeti etkinleştir
sudo systemctl enable cake-autortt

# Hizmeti başlat
sudo systemctl start cake-autortt
```

## 🗑️ Kaldırma

cake-autortt'yi sisteminizden kaldırmak için:

```bash
# Kaldırma betiğini çalıştırılabilir yap ve çalıştır
chmod +x uninstall.sh
sudo ./uninstall.sh
```

Kaldırma betiği şunları yapacaktır:
- Hizmeti durdur ve devre dışı bırak
- Tüm yüklü dosyaları kaldır
- İsteğe bağlı olarak yapılandırma dosyalarını ve yedekleri kaldır
- Geçici dosyaları temizle

## ⚙️ Yapılandırma

### 🔧 Arayüz yapılandırması (GEREKLİ)

**En kritik yapılandırma adımı doğru arayüz adlarını ayarlamaktır.** Hizmet doğru arayüz adları olmadan düzgün çalışmayacaktır.

```bash
# Mevcut yapılandırmayı görüntüle
cat /etc/default/cake-autortt

# Yapılandırmayı düzenle
sudo nano /etc/default/cake-autortt

# Değişiklikleri uygulamak için hizmeti yeniden başlat
sudo systemctl restart cake-autortt
```

Hizmet `/etc/default/cake-autortt` aracılığıyla yapılandırılır. Tüm parametreler bu dosyayı düzenleyerek yapılandırılabilir.

### Yapılandırma parametreleri

| Parametre | Varsayılan | Açıklama |
|-----------|---------|-------------|
| `DL_INTERFACE` | auto | İndirme arayüz adı (örn. 'eth0', 'ifb0') |
| `UL_INTERFACE` | auto | Yükleme arayüz adı (örn. 'eth0', 'enp3s0') |
| `RTT_UPDATE_INTERVAL` | 5 | qdisc RTT parametresi güncellemeleri arasındaki saniye |
| `MIN_HOSTS` | 3 | RTT hesaplaması için gereken minimum host sayısı |
| `MAX_HOSTS` | 100 | Sırayla probe edilecek maksimum host sayısı |
| `RTT_MARGIN_PERCENT` | 10 | Ölçülen RTT'ye eklenen güvenlik marjı (yüzde) |
| `DEFAULT_RTT_MS` | 100 | Yeterli host mevcut olmadığında varsayılan RTT |
| `DEBUG` | 0 | Debug günlüğünü etkinleştir (0=kapalı, 1=açık) |

> [!NOTE]  
> Arayüz parametreleri "auto" varsayılanına sahip olsa da, otomatik algılama tüm yapılandırmalarda güvenilir şekilde çalışmayabilir. Bu değerleri açıkça ayarlamanız şiddetle tavsiye edilir.

> [!TIP]  
> Yüksek aktiviteli ağlar için (örn. kampüs, çok sayıda aktif kullanıcısı olan kamu ağları), ağ özelliklerinize göre `RTT_UPDATE_INTERVAL`'ı ayarlamayı düşünün. Varsayılan 5 saniye çoğu durum için iyi çalışır, ancak daha kararlı ağlar için 10-15 saniyeye çıkarabilir veya çok dinamik ortamlar için 3 saniyeye düşürebilirsiniz.

### Yapılandırma örneği

```bash
# /etc/default/cake-autortt

# Ağ arayüzleri (GEREKLİ - kurulumunuz için yapılandırın)
DL_INTERFACE="ifb0"      # İndirme arayüzü
UL_INTERFACE="eth0"      # Yükleme arayüzü

# Zamanlama parametreleri
RTT_UPDATE_INTERVAL=5    # Her 5 saniyede RTT güncelle
MIN_HOSTS=3              # Ölçüm için minimum 3 host gerekli
MAX_HOSTS=100            # Maksimum 100 host örnekle
RTT_MARGIN_PERCENT=10    # %10 güvenlik marjı ekle
DEFAULT_RTT_MS=100       # Yedek RTT değeri

# Debug
DEBUG=0                  # Ayrıntılı günlük için 1'e ayarla
```

## 🔍 Nasıl çalışır

1. **Bağlantı izleme**: Aktif ağ bağlantılarını belirlemek için `/proc/net/nf_conntrack`'i periyodik olarak analiz eder
2. **Host filtreleme**: Hedef IP adreslerini çıkarır ve özel/LAN adreslerini filtreler
3. **RTT ölçümü**: Her dış host için ayrı RTT ölçmek üzere `ping` kullanır (host başına 3 ping)
4. **Akıllı RTT seçimi**: Ağ tıkanıklığını önlemek için hostları sırayla pingleyerek ortalama ve en kötü RTT'yi hesaplar, ardından tüm bağlantılar için optimal performansı sağlamak üzere daha yüksek değeri kullanır
5. **Güvenlik marjı**: Yeterli tamponlama sağlamak için ölçülen RTT'ye yapılandırılabilir marj ekler
6. **qdisc güncelleme**: İndirme ve yükleme arayüzlerinde CAKE qdisc RTT parametresini günceller

### 🧠 Akıllı RTT algoritması

Sürüm 1.2.0'dan itibaren, cake-autortt Dave Täht'ın (CAKE ortak yazarı) önerisine dayalı akıllı RTT seçim algoritması uygular:

**Sorun**: Sadece ortalama RTT kullanmak, bazı hostların diğerlerinden önemli ölçüde daha yüksek gecikmeye sahip olduğu durumlarda sorunlu olabilir. Örneğin, ortalama RTT'si 40ms olan 100 hostunuz varsa, ancak 2 hostun RTT'si 234ms ve 240ms ise, ortalama 40ms kullanmak bu yüksek gecikmeli bağlantılar için performans sorunlarına neden olabilir.

**Çözüm**: Mevcut algoritma:
1. **Tüm yanıt veren hostlardan hem ortalama hem de en kötü RTT'yi hesaplar**
2. **İki değeri karşılaştırır** ve uygun olanı akıllıca seçer
3. **Ortalamadan önemli ölçüde yüksek olduğunda en kötü RTT'yi kullanır** tüm bağlantılar için iyi performans sağlamak üzere
4. **En kötü RTT ortalamaya yakın olduğunda ortalama RTT'yi kullanır** aşırı muhafazakar ayarları önlemek için

**Bu neden önemli**: [Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17)'a göre, "özellikle ingress shaping ile, tipik RTT'nizi tahmin olarak kullanmak, yenmeye çalıştığınız ISP shaper'ına ulaşmadan önce kuyruk kontrolü elde etmek için daha iyidir." Ancak, herhangi bir hosta gerçek RTT, CAKE arayüzünde ayarlanan RTT'den daha uzunsa, performans ciddi şekilde etkilenebilir.

**Gerçek dünya örneği**:
- 30-50ms RTT'li 98 host (ortalama: 42ms)
- 200ms+ RTT'li 2 host (en kötü: 234ms)
- **Eski algoritma**: Ortalama 45ms kullanırdı, 200ms+ hostlar için sorunlara neden olurdu
- **Yeni algoritma**: En kötü RTT 234ms kullanır, tüm bağlantılar için optimal performans sağlar

### Bağlantı akışı örneği

```
[Host/Uygulama] → [Arayüzde CAKE] → [İnternet]
                            ↑
                      cake-autortt aktif
                      bağlantıları izler ve
                      RTT parametresini ayarlar
```

## 📊 Beklenen davranış

Kurulum ve başlatmadan sonra şunları gözlemlemelisiniz:

### Anında etkiler
- Hizmet systemd aracılığıyla otomatik olarak başlar ve bağlantıları izlemeye başlar
- RTT ölçümleri sistem günlüklerine kaydedilir (debug etkinse)
- CAKE qdisc RTT parametresi ölçülen ağ koşullarına göre her 5 saniyede güncellenir
- Yüksek hassasiyetli RTT değerleri (örn. 44.89ms) CAKE qdisc'e uygulanır

### Uzun vadeli faydalar
- **Gelişmiş yanıt verme**: RTT parametresi gerçek ağ koşullarıyla sürekli güncel tutulur
- **Daha iyi Bufferbloat kontrolü**: CAKE kuyruk yönetimi hakkında daha bilinçli kararlar verebilir
- **Uyarlanabilir performans**: Değişen ağ koşullarına otomatik olarak uyum sağlar (uydu, mobil, tıkanık bağlantılar)
- **Daha yüksek hassasiyet**: Ağ koşullarının daha iyi temsili için maksimum 100 host (yapılandırılabilir) örnekler

### İzleme

```bash
# Hizmet durumunu kontrol et
sudo systemctl status cake-autortt

# Hizmet günlüklerini görüntüle
sudo journalctl -u cake-autortt -f

# CAKE qdisc parametrelerini izle
tc qdisc show | grep cake

# Ayrıntılı günlük için debug modu
sudo nano /etc/default/cake-autortt
# DEBUG=1 ayarla, ardından:
sudo systemctl restart cake-autortt
```

## 🔧 Sorun giderme

### Yaygın sorunlar

1. **Hizmet başlamıyor**
   ```bash
   # Bağımlılıkları kontrol et
   which ping tc
   
   # CAKE arayüzlerini kontrol et
   tc qdisc show | grep cake
   
   # Hizmet günlüklerini kontrol et
   sudo journalctl -u cake-autortt --no-pager
   ```

2. **RTT güncellemeleri yok**
   ```bash
   # Debug modunu etkinleştir
   sudo nano /etc/default/cake-autortt
   # DEBUG=1 ayarla
   
   sudo systemctl restart cake-autortt
   
   # Günlükleri kontrol et
   sudo journalctl -u cake-autortt -f
   ```

3. **Arayüz algılama başarısız**
   ```bash
   # Yapılandırmada arayüzleri manuel olarak belirt
   sudo nano /etc/default/cake-autortt
   # DL_INTERFACE ve UL_INTERFACE ayarla
   
   sudo systemctl restart cake-autortt
   ```

4. **CAKE qdisc bulunamadı**
   ```bash
   # CAKE desteğini kontrol et
   tc qdisc help | grep cake
   
   # CAKE'nin arayüzde yapılandırılıp yapılandırılmadığını kontrol et
   tc qdisc show
   
   # Gerekirse CAKE yapılandır (kurulum bölümüne bakın)
   ```

### Debug bilgileri

Debug etkin (`/etc/default/cake-autortt`'de `DEBUG=1`) ile hizmet ayrıntılı günlük sağlar:

**Örnek debug çıktısı:**
```bash
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Extracting hosts from conntrack
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Found 35 non-LAN hosts
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Measuring RTT using ping for 35 hosts (3 pings each)
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: ping summary: 28/35 hosts alive
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: Using average RTT: 45.2ms (avg: 45.2ms, worst: 89.1ms)
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: Using measured RTT: 45.2ms
Jan 09 18:34:35 hostname cake-autortt[1234]: INFO: Adjusting CAKE RTT to 49.72ms (49720us)
Jan 09 18:34:35 hostname cake-autortt[1234]: DEBUG: Updated RTT on download interface ifb0
Jan 09 18:34:35 hostname cake-autortt[1234]: DEBUG: Updated RTT on upload interface eth0
```

> [!NOTE]  
> **Bellek verimli günlük**: Debug günlüğü günlük taşmasını önlemek için optimize edilmiştir. Bireysel host RTT ölçümleri bellek kullanımını ve disk yazımını azaltmak için günlüğe kaydedilmez. Sadece özet bilgiler systemd journal'a kaydedilir, bu da aşırı günlük büyümesi olmadan sürekli işlem için uygun hale getirir.

## 🔄 OpenWrt sürümünden farklar

Bu Ubuntu/Debian portu OpenWrt sürümünden birkaç önemli açıdan farklıdır:

### Yapılandırma sistemi
- **OpenWrt**: UCI yapılandırma sistemi kullanır (`uci set`, `/etc/config/cake-autortt`)
- **Ubuntu/Debian**: Geleneksel yapılandırma dosyaları kullanır (`/etc/default/cake-autortt`)

### Hizmet yönetimi
- **OpenWrt**: procd ve OpenWrt init.d betikleri kullanır
- **Ubuntu/Debian**: systemd hizmet yönetimi kullanır

### Arayüz izleme
- **OpenWrt**: Arayüz olayları için hotplug.d betikleri kullanır
- **Ubuntu/Debian**: Arayüz izleme için udev kuralları kullanır

### Paket yönetimi
- **OpenWrt**: opkg paket yöneticisi kullanır
- **Ubuntu/Debian**: apt paket yöneticisi kullanır

### Dosya konumları
- **OpenWrt**: OpenWrt'ye özgü yollar kullanır (`/etc/config/`, `/etc/hotplug.d/`)
- **Ubuntu/Debian**: Standart Linux yolları kullanır (`/etc/default/`, `/etc/systemd/`, `/etc/udev/`)

## 📄 Lisans

Bu proje GNU General Public License v2.0 altında lisanslanmıştır - ayrıntılar için [LICENSE](../LICENSE) dosyasına bakın.

## 🤝 Katkıda bulunma

Katkılar memnuniyetle karşılanır! Lütfen Pull Request gönderin. Ubuntu/Debian portuna katkıda bulunurken, lütfen hem mevcut Ubuntu LTS hem de Debian kararlı sürümleriyle uyumluluğu sağlayın.