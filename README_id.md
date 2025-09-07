# cake-autortt

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | [中文](README_zh.md) | **Bahasa Indonesia** | [Русский](README_ru.md) | [日本語](README_ja.md) | [Tiếng Việt](README_vi.md) | [Türkçe](README_tr.md) | [العربية](README_ar.md)

---

**Secara otomatis menyesuaikan parameter RTT CAKE qdisc berdasarkan kondisi jaringan yang diukur**

> [!NOTE]  
> Jika Anda mencari **versi Ubuntu/Debian**, periksa folder `ubuntu-debian/`. Namun, harap dicatat bahwa hanya versi OpenWrt yang diuji secara pribadi setiap hari - port Ubuntu/Debian disediakan apa adanya untuk komunitas.

`cake-autortt` adalah layanan OpenWrt yang secara cerdas memantau koneksi jaringan aktif dan secara otomatis menyesuaikan parameter RTT (Round Trip Time) dari CAKE qdisc pada antarmuka ingress dan egress untuk kinerja jaringan yang optimal.

## 🌍 Mengapa Ini Penting untuk Pengalaman Internet Anda

Sebagian besar pengguna familiar dengan waktu loading yang cepat dari situs web utama seperti YouTube, Netflix, dan Google - situs-situs ini menggunakan Content Delivery Networks (CDN) yang menempatkan server sangat dekat dengan pengguna, biasanya menghasilkan waktu respons di bawah 50-100ms. Namun, internet jauh lebih besar dari platform-platform besar ini.

**Ketika Anda menjelajah di luar situs-situs yang didukung CDN utama, Anda menemukan dunia server yang beragam:**
- **Layanan Lokal/Regional**: Bisnis kecil, situs berita lokal, forum komunitas, dan layanan regional sering memiliki server dalam negara atau wilayah Anda (10-50ms RTT)
- **Konten Internasional**: Situs web khusus, sumber daya akademik, server gaming, dan layanan niche mungkin dihosting di benua yang jauh (100-500ms RTT)
- **Infrastruktur Terpencil**: Beberapa layanan, terutama di wilayah berkembang atau aplikasi khusus, mungkin memiliki latensi yang jauh lebih tinggi

**Parameter RTT CAKE mengontrol seberapa agresif algoritma manajemen antrian merespons kemacetan.** Secara default, CAKE menggunakan asumsi RTT 100ms yang bekerja cukup baik untuk lalu lintas internet umum. Namun:

- **Pengaturan RTT Terlalu Rendah**: Jika CAKE menganggap RTT jaringan lebih pendek dari kenyataan, ia menjadi terlalu agresif dalam membuang paket ketika antrian terbentuk, berpotensi mengurangi throughput untuk server yang jauh
- **Pengaturan RTT Terlalu Tinggi**: Jika CAKE menganggap RTT jaringan lebih panjang dari kenyataan, ia menjadi terlalu konservatif dan memungkinkan antrian yang lebih besar terbentuk, menciptakan latensi yang tidak perlu untuk server terdekat

**Contoh Dampak Dunia Nyata:**
- **Pengguna Singapura → Server Jerman**: Tanpa penyesuaian RTT, pengguna di Singapura yang mengakses situs web Jerman (≈180ms RTT) mungkin mengalami throughput yang berkurang karena pengaturan default 100ms CAKE menyebabkan pembuangan paket prematur
- **AS Pedesaan → Server Regional**: Pengguna di AS pedesaan yang mengakses server regional (≈25ms RTT) mungkin mengalami latensi yang lebih tinggi dari yang diperlukan karena pengaturan default 100ms CAKE memungkinkan antrian tumbuh lebih besar dari yang dibutuhkan
- **Aplikasi Gaming/Real-time**: Aplikasi yang sensitif terhadap latensi dan throughput mendapat manfaat signifikan dari tuning RTT yang sesuai dengan kondisi jaringan aktual

**Bagaimana cake-autortt Membantu:**
Dengan secara otomatis mengukur RTT aktual ke server yang Anda komunikasikan dan menyesuaikan parameter CAKE sesuai, Anda mendapatkan:
- **Respons yang lebih cepat** saat mengakses server terdekat (RTT lebih pendek → manajemen antrian lebih agresif)
- **Throughput yang lebih baik** saat mengakses server yang jauh (RTT lebih panjang → manajemen antrian lebih sabar)
- **Kontrol bufferbloat optimal** yang beradaptasi dengan kondisi jaringan nyata daripada asumsi

Ini sangat berharga untuk pengguna yang secara teratur mengakses sumber konten yang beragam, bekerja dengan layanan internasional, atau tinggal di daerah di mana lalu lintas internet sering melintasi jarak jauh.

## 🚀 Fitur

- **Deteksi RTT Otomatis**: Memantau koneksi aktif melalui `/proc/net/nf_conntrack` dan mengukur RTT ke host eksternal
- **Penyaringan Host Cerdas**: Secara otomatis menyaring alamat LAN dan fokus pada host eksternal
- **Algoritma RTT Cerdas**: Menggunakan perintah ping bawaan untuk mengukur RTT ke setiap host secara individual (3 ping per host), kemudian secara cerdas memilih antara RTT rata-rata dan kasus terburuk untuk kinerja optimal
- **Deteksi Antarmuka Otomatis**: Secara otomatis mendeteksi antarmuka yang diaktifkan CAKE (lebih memilih `ifb-*` untuk download, antarmuka fisik untuk upload)
- **Integrasi Layanan OpenWrt**: Berjalan sebagai layanan OpenWrt yang tepat dengan startup otomatis dan manajemen proses
- **Parameter yang Dapat Dikonfigurasi**: Semua parameter waktu dan perilaku dapat disesuaikan melalui konfigurasi UCI
- **Penanganan Error yang Kuat**: Menangani dengan baik dependensi yang hilang, masalah jaringan, dan perubahan antarmuka
- **Dependensi Minimal**: Hanya memerlukan ping dan tc - tidak perlu paket tambahan, menggunakan utilitas bawaan yang tersedia di semua sistem
- **RTT Presisi Tinggi**: Mendukung nilai RTT pecahan (misalnya, 100.23ms) untuk penyesuaian waktu jaringan yang presisi

## 🔧 Kompatibilitas

**Diuji dan Bekerja:**
- **OpenWrt 24.10.1, r28597-0425664679, Platform Target x86/64**

**Kompatibilitas yang Diharapkan:**
- Versi OpenWrt sebelumnya (21.02+) dengan dukungan CAKE qdisc
- Rilis OpenWrt masa depan selama dependensi yang diperlukan tersedia
- Semua arsitektur target yang didukung oleh OpenWrt (ARM, MIPS, x86, dll.)

**Persyaratan untuk Kompatibilitas:**
- Modul kernel CAKE qdisc
- Utilitas ping (termasuk dalam semua distribusi Linux standar)
- Utilitas tc (traffic control) standar
- Dukungan /proc/net/nf_conntrack (netfilter conntrack)

## 📋 Persyaratan

### Dependensi
- **ping**: Utilitas ping standar untuk mengukur RTT (termasuk dalam semua distribusi Linux)
- **tc**: Utilitas traffic control (bagian dari iproute2)
- **CAKE qdisc**: Harus dikonfigurasi pada antarmuka target

### Instalasi Dependensi

```bash
# ping sudah termasuk secara default di OpenWrt
# Tidak perlu paket tambahan untuk fungsionalitas ping

# CAKE qdisc biasanya tersedia di versi OpenWrt modern
# Periksa apakah tc mendukung CAKE:
tc qdisc help | grep cake
```

## 🔧 Instalasi

> [!IMPORTANT]  
> Sebelum menjalankan skrip instalasi, Anda HARUS mengedit file konfigurasi untuk mengatur nama antarmuka yang benar untuk sistem Anda.

1. **Edit file konfigurasi:**

```bash
# Edit file config untuk mencocokkan nama antarmuka Anda
nano etc/config/cake-autortt
```

2. **Konfigurasi nama antarmuka Anda:**

Perbarui pengaturan `dl_interface` (download) dan `ul_interface` (upload) untuk mencocokkan setup jaringan Anda:

```bash
# Contoh konfigurasi untuk setup yang berbeda:

# Untuk setup OpenWrt tipikal dengan SQM menggunakan antarmuka ifb:
option dl_interface 'ifb-wan'      # Antarmuka download (biasanya ifb-*)
option ul_interface 'wan'          # Antarmuka upload (biasanya wan, eth0, dll.)

# Untuk setup antarmuka langsung:
option dl_interface 'eth0'         # Antarmuka WAN Anda
option ul_interface 'eth0'         # Antarmuka yang sama untuk kedua arah

# Untuk nama antarmuka kustom:
option dl_interface 'ifb4eth1'     # Antarmuka download spesifik Anda
option ul_interface 'eth1'         # Antarmuka upload spesifik Anda
```

**Cara menemukan nama antarmuka Anda:**
```bash
# Daftar antarmuka dengan CAKE qdisc
tc qdisc show | grep cake

# Daftar semua antarmuka jaringan
ip link show

# Periksa konfigurasi antarmuka SQM (jika menggunakan SQM)
uci show sqm
```

### Instalasi Cepat

1. **Konfigurasi antarmuka (lihat bagian di atas)**

2. **Jalankan skrip instalasi:**

```bash
# Buat skrip instalasi dapat dieksekusi dan jalankan
chmod +x install.sh
./install.sh
```

### Instalasi Manual

1. **Salin file layanan ke router OpenWrt Anda:**

```bash
# Salin file executable utama
cp usr/bin/cake-autortt /usr/bin/
chmod +x /usr/bin/cake-autortt

# Salin skrip init
cp etc/init.d/cake-autortt /etc/init.d/
chmod +x /etc/init.d/cake-autortt

# Salin file konfigurasi
cp etc/config/cake-autortt /etc/config/

# Salin skrip hotplug
cp etc/hotplug.d/iface/99-cake-autortt /etc/hotplug.d/iface/
chmod +x /etc/hotplug.d/iface/99-cake-autortt
```

2. **Aktifkan dan mulai layanan:**

```bash
# Aktifkan layanan untuk memulai secara otomatis saat boot
/etc/init.d/cake-autortt enable

# Mulai layanan
/etc/init.d/cake-autortt start
```

## 🗑️ Uninstalasi

Untuk menghapus cake-autortt dari sistem Anda:

```bash
# Buat skrip uninstall dapat dieksekusi dan jalankan
chmod +x uninstall.sh
./uninstall.sh
```

Skrip uninstall akan:
- Menghentikan dan menonaktifkan layanan
- Menghapus semua file yang terinstal
- Secara opsional menghapus file konfigurasi dan backup
- Membersihkan file sementara

## ⚙️ Konfigurasi

### 🔧 Konfigurasi Antarmuka (DIPERLUKAN)

**Langkah konfigurasi paling kritis adalah mengatur nama antarmuka yang benar.** Layanan tidak akan bekerja dengan baik tanpa nama antarmuka yang benar.

```bash
# Lihat konfigurasi saat ini
uci show cake-autortt

# DIPERLUKAN: Atur nama antarmuka Anda
uci set cake-autortt.global.dl_interface='your-download-interface'
uci set cake-autortt.global.ul_interface='your-upload-interface'
uci commit cake-autortt

# Perubahan konfigurasi opsional lainnya
uci set cake-autortt.global.rtt_update_interval='5'
uci set cake-autortt.global.debug='1'
uci commit cake-autortt

# Restart layanan untuk menerapkan perubahan
/etc/init.d/cake-autortt restart
```

Layanan dikonfigurasi melalui UCI. Edit `/etc/config/cake-autortt` atau gunakan perintah `uci`.

### Parameter Konfigurasi

| Parameter | Default | Deskripsi |
|-----------|---------|-------------|
| `dl_interface` | auto | Nama antarmuka download (misalnya, 'ifb-wan', 'ifb4eth1') |
| `ul_interface` | auto | Nama antarmuka upload (misalnya, 'wan', 'eth1') |
| `rtt_update_interval` | 5 | Detik antara pembaruan parameter RTT qdisc |
| `min_hosts` | 3 | Jumlah minimum host yang diperlukan untuk kalkulasi RTT |
| `max_hosts` | 100 | Jumlah maksimum host untuk probe berurutan |
| `rtt_margin_percent` | 10 | Margin keamanan yang ditambahkan ke RTT yang diukur (persentase) |
| `default_rtt_ms` | 100 | RTT default ketika host yang tersedia tidak mencukupi |
| `debug` | 0 | Aktifkan logging debug (0=nonaktif, 1=aktif) |

> [!NOTE]  
> Meskipun parameter antarmuka memiliki "auto" sebagai default, deteksi otomatis mungkin tidak bekerja dengan andal di semua konfigurasi. Sangat disarankan untuk secara eksplisit mengatur nilai-nilai ini.

> [!TIP]  
> Untuk jaringan dengan aktivitas tinggi (misalnya, kampus universitas, jaringan publik dengan banyak pengguna aktif), pertimbangkan untuk menyesuaikan `rtt_update_interval` berdasarkan karakteristik jaringan Anda. Default 5 detik bekerja dengan baik untuk sebagian besar skenario, tetapi Anda dapat meningkatkannya menjadi 10-15 detik untuk jaringan yang lebih stabil atau menguranginya menjadi 3 detik untuk lingkungan yang sangat dinamis.

## 🔍 Cara Kerja

1. **Pemantauan Koneksi**: Secara berkala mem-parse `/proc/net/nf_conntrack` untuk mengidentifikasi koneksi jaringan aktif
2. **Penyaringan Host**: Mengekstrak alamat IP tujuan dan menyaring alamat privat/LAN
3. **Pengukuran RTT**: Menggunakan `ping` untuk mengukur RTT ke setiap host eksternal secara individual (3 ping per host)
4. **Pemilihan RTT Cerdas**: Ping host satu per satu untuk mencegah kelebihan beban jaringan, menghitung RTT rata-rata dan kasus terburuk, kemudian menggunakan nilai yang lebih tinggi untuk memastikan kinerja optimal untuk semua koneksi
5. **Margin Keamanan**: Menambahkan margin yang dapat dikonfigurasi ke RTT yang diukur untuk memastikan buffering yang memadai
6. **Pembaruan qdisc**: Memperbarui parameter RTT CAKE qdisc pada antarmuka download dan upload

### 🧠 Algoritma RTT Cerdas

Mulai dari versi 1.2.0, cake-autortt mengimplementasikan algoritma pemilihan RTT cerdas berdasarkan rekomendasi dari Dave Täht (co-author CAKE):

**Masalah**: Menggunakan hanya RTT rata-rata bisa bermasalah ketika beberapa host memiliki latensi yang jauh lebih tinggi dari yang lain. Misalnya, jika Anda memiliki 100 host dengan RTT rata-rata 40ms, tetapi 2 host memiliki RTT 234ms dan 240ms, menggunakan rata-rata 40ms bisa menyebabkan masalah kinerja untuk koneksi latensi tinggi tersebut.

**Solusi**: Algoritma sekarang:
1. **Menghitung RTT rata-rata dan kasus terburuk** dari semua host yang responsif
2. **Membandingkan kedua nilai** dan secara cerdas memilih yang tepat
3. **Menggunakan RTT terburuk ketika secara signifikan lebih tinggi** dari rata-rata untuk memastikan semua koneksi berkinerja baik
4. **Menggunakan RTT rata-rata ketika RTT terburuk mendekati** rata-rata untuk menghindari pengaturan yang terlalu konservatif

**Mengapa Ini Penting**: Menurut [Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17), "lebih baik, terutama ketika shaping inbound, menggunakan RTT tipikal Anda sebagai estimasi untuk mendapatkan kontrol antrian sebelum mengalir ke shaper ISP yang Anda kalahkan." Namun, jika RTT aktual ke host mana pun lebih panjang dari RTT yang diatur pada antarmuka CAKE, kinerja bisa sangat terganggu.

**Contoh Dunia Nyata**:
- 98 host dengan RTT 30-50ms (rata-rata: 42ms)
- 2 host dengan RTT 200ms+ (terburuk: 234ms)
- **Algoritma lama**: Akan menggunakan rata-rata 45ms, menyebabkan masalah untuk host 200ms+
- **Algoritma baru**: Menggunakan RTT terburuk 234ms, memastikan kinerja optimal untuk semua koneksi

### Contoh Alur Koneksi

```
[Perangkat LAN] → [Router dengan CAKE] → [Internet]
                       ↑
                 cake-autortt memantau
                 koneksi aktif dan
                 menyesuaikan parameter RTT
```

## 📊 Perilaku yang Diharapkan

Setelah instalasi dan startup, Anda harus mengamati:

### Efek Langsung
- Layanan mulai secara otomatis dan mulai memantau koneksi
- Pengukuran RTT dicatat ke log sistem (jika debug diaktifkan)
- Parameter RTT CAKE qdisc diperbarui setiap 5 detik berdasarkan kondisi jaringan yang diukur
- Nilai RTT presisi tinggi (misalnya, 44.89ms) diterapkan ke CAKE qdisc

### Manfaat Jangka Panjang
- **Responsivitas yang Ditingkatkan**: Parameter RTT tetap terkini dengan kondisi jaringan aktual
- **Kontrol Bufferbloat yang Lebih Baik**: CAKE dapat membuat keputusan yang lebih terinformasi tentang manajemen antrian
- **Kinerja Adaptif**: Secara otomatis menyesuaikan dengan kondisi jaringan yang berubah (satelit, seluler, link yang macet)
- **Akurasi yang Lebih Tinggi**: Sampel hingga 100 host (dapat dikonfigurasi) untuk representasi kondisi jaringan yang lebih baik

### Pemantauan

```bash
# Periksa status layanan
/etc/init.d/cake-autortt status

# Lihat log layanan
logread | grep cake-autortt

# Pantau parameter CAKE qdisc
tc qdisc show | grep cake

# Mode debug untuk logging detail
uci set cake-autortt.global.debug='1'
uci commit cake-autortt
/etc/init.d/cake-autortt restart
```

## 🔧 Pemecahan Masalah

### Masalah Umum

1. **Layanan tidak mau mulai**
   ```bash
   # Periksa dependensi
   which ping tc
   
   # Periksa antarmuka CAKE
   tc qdisc show | grep cake
   ```

2. **Tidak ada pembaruan RTT**
   ```bash
   # Aktifkan mode debug
   uci set cake-autortt.global.debug='1'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   
   # Periksa log
   logread | grep cake-autortt
   ```

3. **Deteksi antarmuka gagal**
   ```bash
   # Tentukan antarmuka secara manual
   uci set cake-autortt.global.dl_interface='ifb-wan'
   uci set cake-autortt.global.ul_interface='wan'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   ```

### Informasi Debug

Dengan debug diaktifkan (`uci set cake-autortt.global.debug='1'`), layanan menyediakan logging detail:

**Contoh output debug:**
```bash
[2025-01-09 18:34:22] cake-autortt DEBUG: Mengekstrak host dari conntrack
[2025-01-09 18:34:22] cake-autortt DEBUG: Ditemukan 35 host non-LAN
[2025-01-09 18:34:22] cake-autortt DEBUG: Mengukur RTT menggunakan ping untuk 35 host (3 ping masing-masing)
[2025-01-09 18:34:25] cake-autortt DEBUG: ringkasan ping: 28/35 host hidup
[2025-01-09 18:34:25] cake-autortt DEBUG: Menggunakan RTT rata-rata: 45.2ms (rata-rata: 45.2ms, terburuk: 89.1ms)
[2025-01-09 18:34:25] cake-autortt DEBUG: Menggunakan RTT yang diukur: 45.2ms
[2025-01-09 18:34:35] cake-autortt INFO: Menyesuaikan CAKE RTT ke 49.72ms (49720us)
[2025-01-09 18:34:35] cake-autortt DEBUG: RTT diperbarui pada antarmuka download ifb-wan
[2025-01-09 18:34:35] cake-autortt DEBUG: RTT diperbarui pada antarmuka upload wan
```

> [!NOTE]  
> **Logging Efisien Memori**: Logging debug dioptimalkan untuk mencegah banjir log. Pengukuran RTT host individual tidak dicatat untuk mengurangi penggunaan memori dan penulisan disk. Hanya informasi ringkasan yang dicatat, membuatnya cocok untuk operasi berkelanjutan tanpa pertumbuhan log yang berlebihan.

## 📄 Lisensi

Proyek ini dilisensikan di bawah GNU General Public License v2.0 - lihat file [LICENSE](LICENSE) untuk detail.

## 🤝 Berkontribusi

Kontribusi sangat diterima! Silakan kirim Pull Request.