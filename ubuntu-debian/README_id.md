# cake-autortt (Ubuntu/Debian)

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | [中文](README_zh.md) | **Bahasa Indonesia** | [Русский](README_ru.md) | [日本語](README_ja.md) | [Tiếng Việt](README_vi.md) | [Türkçe](README_tr.md) | [العربية](README_ar.md)

---

**Secara otomatis menyesuaikan parameter RTT CAKE qdisc berdasarkan kondisi jaringan yang diukur**

Ini adalah **port Ubuntu/Debian** dari cake-autortt, diadaptasi untuk distribusi Linux standar yang menggunakan systemd, manajemen paket apt, dan file konfigurasi tradisional alih-alih sistem UCI OpenWrt.

## 🌍 Mengapa Ini Penting untuk Pengalaman Internet Anda

Sebagian besar pengguna familiar dengan waktu loading yang cepat dari situs web utama seperti YouTube, Netflix, dan Google - situs-situs ini menggunakan Content Delivery Networks (CDN) yang menempatkan server sangat dekat dengan pengguna, biasanya menghasilkan waktu respons di bawah 50-100ms. Namun, internet jauh lebih luas dari platform besar ini.

**Ketika Anda menjelajah di luar situs yang didukung CDN utama, Anda menemukan dunia server yang beragam:**
- **Layanan Lokal/Regional**: Bisnis kecil, situs berita lokal, forum komunitas, dan layanan regional sering memiliki server di dalam negara atau wilayah Anda (10-50ms RTT)
- **Konten Internasional**: Situs web khusus, sumber daya akademik, server gaming, dan layanan niche mungkin dihosting di benua yang jauh (100-500ms RTT)
- **Infrastruktur Remote**: Beberapa layanan, terutama di wilayah berkembang atau aplikasi khusus, mungkin memiliki latensi yang jauh lebih tinggi

**Parameter RTT CAKE mengontrol seberapa agresif algoritma manajemen antrian merespons kemacetan.** Secara default, CAKE menggunakan asumsi RTT 100ms yang bekerja cukup baik untuk lalu lintas internet umum. Namun:

- **Pengaturan RTT Terlalu Rendah**: Jika CAKE menganggap RTT jaringan lebih pendek dari kenyataan, ia menjadi terlalu agresif dalam membuang paket ketika antrian menumpuk, berpotensi mengurangi throughput untuk server yang jauh
- **Pengaturan RTT Terlalu Tinggi**: Jika CAKE menganggap RTT jaringan lebih panjang dari kenyataan, ia menjadi terlalu konservatif dan memungkinkan antrian yang lebih besar menumpuk, menciptakan latensi yang tidak perlu untuk server terdekat

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
- **Algoritma RTT Cerdas**: Menggunakan perintah ping bawaan untuk mengukur RTT ke setiap host secara individual (3 ping per host), kemudian secara cerdas memilih antara RTT rata-rata dan kasus terburuk untuk performa optimal
- **Deteksi Interface Otomatis**: Secara otomatis mendeteksi interface yang diaktifkan CAKE
- **Integrasi systemd**: Berjalan sebagai layanan systemd yang tepat dengan startup otomatis dan manajemen proses
- **Parameter yang Dapat Dikonfigurasi**: Semua parameter timing dan perilaku dapat disesuaikan melalui file konfigurasi
- **Penanganan Error yang Kuat**: Menangani dengan baik dependensi yang hilang, masalah jaringan, dan perubahan interface
- **Dependensi Minimal**: Hanya memerlukan ping dan tc - tidak perlu paket tambahan, menggunakan utilitas bawaan yang tersedia di semua sistem
- **RTT Presisi Tinggi**: Mendukung nilai RTT pecahan (misalnya 100.23ms) untuk penyesuaian timing jaringan yang presisi

## 🔧 Kompatibilitas

**Diuji dan Bekerja:**
- **Ubuntu 20.04+ (Focal dan yang lebih baru)**
- **Debian 10+ (Buster dan yang lebih baru)**

**Kompatibilitas yang Diharapkan:**
- Distribusi Linux berbasis systemd apa pun dengan dukungan CAKE qdisc
- Distribusi dengan paket iproute2 modern

**Persyaratan untuk Kompatibilitas:**
- Modul kernel CAKE qdisc (tersedia di Linux 4.19+)
- Utilitas ping (termasuk dalam semua distribusi Linux standar)
- Manajemen layanan systemd
- iproute2 dengan utilitas tc (traffic control)
- Dukungan /proc/net/nf_conntrack (netfilter conntrack)

## 📋 Persyaratan

### Dependensi
- **ping**: Utilitas ping standar untuk mengukur RTT (termasuk dalam semua distribusi Linux)
- **tc**: Utilitas traffic control (bagian dari iproute2)
- **CAKE qdisc**: Harus dikonfigurasi pada interface target
- **systemd**: Manajemen layanan
- **netfilter conntrack**: Untuk pelacakan koneksi (/proc/net/nf_conntrack)

### Instalasi Dependensi

```bash
# Install paket yang diperlukan
sudo apt update
sudo apt install iputils-ping iproute2

# Periksa apakah tc mendukung CAKE:
tc qdisc help | grep cake

# Verifikasi conntrack tersedia
ls /proc/net/nf_conntrack
```

## 🔧 Instalasi

> [!IMPORTANT]  
> Sebelum menjalankan skrip instalasi, Anda HARUS mengkonfigurasi CAKE qdisc pada interface jaringan Anda dan mengedit file konfigurasi untuk mengatur nama interface yang benar untuk sistem Anda.

### Prasyarat: Konfigurasi CAKE qdisc

Pertama, Anda perlu mengatur CAKE qdisc pada interface jaringan Anda. Ini biasanya dilakukan pada interface yang menghadap internet:

```bash
# Contoh: Konfigurasi CAKE pada interface utama
# Ganti 'eth0' dengan nama interface aktual Anda
# Ganti '100Mbit' dengan bandwidth aktual Anda

# Untuk setup sederhana (ganti eth0 dengan interface Anda):
sudo tc qdisc add root dev eth0 cake bandwidth 100Mbit

# Untuk setup yang lebih canggih dengan shaping ingress:
# Buat interface ifb (intermediate functional block) untuk shaping download
sudo modprobe ifb
sudo ip link add name ifb0 type ifb
sudo ip link set dev ifb0 up

# Konfigurasi pengalihan ingress dan CAKE
sudo tc qdisc add dev eth0 handle ffff: ingress
sudo tc filter add dev eth0 parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
sudo tc qdisc add root dev ifb0 cake bandwidth 500Mbit ingress

# Konfigurasi CAKE egress
sudo tc qdisc add root dev eth0 cake bandwidth 50Mbit

# Verifikasi CAKE dikonfigurasi
tc qdisc show | grep cake
```

### Instalasi Cepat

1. **Konfigurasi interface CAKE (lihat bagian di atas)**

2. **Edit file konfigurasi:**

```bash
# Edit file config untuk mencocokkan nama interface Anda
nano etc/default/cake-autortt
```

3. **Konfigurasi nama interface Anda:**

Perbarui pengaturan `DL_INTERFACE` (download) dan `UL_INTERFACE` (upload) untuk mencocokkan setup jaringan Anda:

```bash
# Contoh konfigurasi untuk setup yang berbeda:

# Untuk setup sederhana (interface yang sama untuk kedua arah):
DL_INTERFACE="eth0"
UL_INTERFACE="eth0"

# Untuk setup canggih dengan interface ifb untuk shaping download:
DL_INTERFACE="ifb0"     # Interface download (ifb untuk shaping ingress)
UL_INTERFACE="eth0"     # Interface upload (interface fisik)

# Untuk nama interface kustom:
DL_INTERFACE="enp3s0"   # Interface download spesifik Anda
UL_INTERFACE="enp3s0"   # Interface upload spesifik Anda
```

**Cara menemukan nama interface Anda:**
```bash
# Daftar interface dengan CAKE qdisc
tc qdisc show | grep cake

# Daftar semua interface jaringan
ip link show

# Periksa interface jaringan utama Anda
ip route | grep default
```

4. **Jalankan skrip instalasi:**

```bash
# Buat skrip install dapat dieksekusi dan jalankan
chmod +x install.sh
sudo ./install.sh
```

### Instalasi Manual

1. **Salin file layanan ke sistem Anda:**

```bash
# Salin file executable utama
sudo cp usr/bin/cake-autortt /usr/bin/
sudo chmod +x /usr/bin/cake-autortt

# Salin file layanan systemd
sudo cp etc/systemd/system/cake-autortt.service /etc/systemd/system/

# Salin file konfigurasi
sudo cp etc/default/cake-autortt /etc/default/

# Salin aturan udev untuk pemantauan interface
sudo cp etc/udev/rules.d/99-cake-autortt.rules /etc/udev/rules.d/

# Reload systemd dan udev
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```

2. **Aktifkan dan mulai layanan:**

```bash
# Aktifkan layanan untuk memulai secara otomatis saat boot
sudo systemctl enable cake-autortt

# Mulai layanan
sudo systemctl start cake-autortt
```

## 🗑️ Uninstalasi

Untuk menghapus cake-autortt dari sistem Anda:

```bash
# Buat skrip uninstall dapat dieksekusi dan jalankan
chmod +x uninstall.sh
sudo ./uninstall.sh
```

Skrip uninstall akan:
- Menghentikan dan menonaktifkan layanan
- Menghapus semua file yang terinstal
- Secara opsional menghapus file konfigurasi dan backup
- Membersihkan file sementara

## ⚙️ Konfigurasi

### 🔧 Konfigurasi Interface (DIPERLUKAN)

**Langkah konfigurasi paling kritis adalah mengatur nama interface yang benar.** Layanan tidak akan bekerja dengan baik tanpa nama interface yang benar.

```bash
# Lihat konfigurasi saat ini
cat /etc/default/cake-autortt

# Edit konfigurasi
sudo nano /etc/default/cake-autortt

# Restart layanan untuk menerapkan perubahan
sudo systemctl restart cake-autortt
```

Layanan dikonfigurasi melalui `/etc/default/cake-autortt`. Semua parameter dapat disesuaikan dengan mengedit file ini.

### Parameter Konfigurasi

| Parameter | Default | Deskripsi |
|-----------|---------|-------------|
| `DL_INTERFACE` | auto | Nama interface download (misalnya 'eth0', 'ifb0') |
| `UL_INTERFACE` | auto | Nama interface upload (misalnya 'eth0', 'enp3s0') |
| `RTT_UPDATE_INTERVAL` | 5 | Detik antara pembaruan parameter RTT qdisc |
| `MIN_HOSTS` | 3 | Jumlah minimum host yang diperlukan untuk kalkulasi RTT |
| `MAX_HOSTS` | 100 | Jumlah maksimum host untuk probe berurutan |
| `RTT_MARGIN_PERCENT` | 10 | Margin keamanan yang ditambahkan ke RTT yang diukur (persentase) |
| `DEFAULT_RTT_MS` | 100 | RTT default ketika host yang tersedia tidak mencukupi |
| `DEBUG` | 0 | Aktifkan logging debug (0=nonaktif, 1=aktif) |

> [!NOTE]  
> Meskipun parameter interface memiliki "auto" sebagai default, deteksi otomatis mungkin tidak bekerja dengan andal di semua konfigurasi. Sangat disarankan untuk secara eksplisit mengatur nilai-nilai ini.

> [!TIP]  
> Untuk jaringan dengan aktivitas tinggi (misalnya kampus universitas, jaringan publik dengan banyak pengguna aktif), pertimbangkan untuk menyesuaikan `RTT_UPDATE_INTERVAL` berdasarkan karakteristik jaringan Anda. Default 5 detik bekerja dengan baik untuk sebagian besar skenario, tetapi Anda dapat meningkatkannya menjadi 10-15 detik untuk jaringan yang lebih stabil atau menguranginya menjadi 3 detik untuk lingkungan yang sangat dinamis.

### Contoh Konfigurasi

```bash
# /etc/default/cake-autortt

# Interface jaringan (DIPERLUKAN - sesuaikan untuk setup Anda)
DL_INTERFACE="ifb0"      # Interface download
UL_INTERFACE="eth0"      # Interface upload

# Parameter timing
RTT_UPDATE_INTERVAL=5    # Update RTT setiap 5 detik
MIN_HOSTS=3              # Perlu setidaknya 3 host untuk pengukuran
MAX_HOSTS=100            # Sample hingga 100 host
RTT_MARGIN_PERCENT=10    # Tambahkan margin keamanan 10%
DEFAULT_RTT_MS=100       # Nilai RTT fallback

# Debugging
DEBUG=0                  # Set ke 1 untuk logging verbose
```

## 🔍 Cara Kerja

1. **Pemantauan Koneksi**: Secara berkala mem-parse `/proc/net/nf_conntrack` untuk mengidentifikasi koneksi jaringan aktif
2. **Penyaringan Host**: Mengekstrak alamat IP tujuan dan menyaring alamat privat/LAN
3. **Pengukuran RTT**: Menggunakan `ping` untuk mengukur RTT ke setiap host eksternal secara individual (3 ping per host)
4. **Pemilihan RTT Cerdas**: Ping host satu per satu untuk mencegah overload jaringan, menghitung RTT rata-rata dan kasus terburuk, kemudian menggunakan nilai yang lebih tinggi untuk memastikan performa optimal untuk semua koneksi
5. **Margin Keamanan**: Menambahkan margin yang dapat dikonfigurasi ke RTT yang diukur untuk memastikan buffering yang memadai
6. **Update qdisc**: Memperbarui parameter RTT CAKE qdisc pada interface download dan upload

### 🧠 Algoritma RTT Cerdas

Mulai dari versi 1.2.0, cake-autortt mengimplementasikan algoritma pemilihan RTT cerdas berdasarkan rekomendasi dari Dave Täht (co-author CAKE):

**Masalah**: Menggunakan hanya RTT rata-rata bisa bermasalah ketika beberapa host memiliki latensi yang jauh lebih tinggi dari yang lain. Misalnya, jika Anda memiliki 100 host dengan RTT rata-rata 40ms, tetapi 2 host memiliki RTT 234ms dan 240ms, menggunakan rata-rata 40ms bisa menyebabkan masalah performa untuk koneksi latensi tinggi tersebut.

**Solusi**: Algoritma sekarang:
1. **Menghitung RTT rata-rata dan kasus terburuk** dari semua host yang responsif
2. **Membandingkan kedua nilai** dan secara cerdas memilih yang sesuai
3. **Menggunakan RTT terburuk ketika secara signifikan lebih tinggi** dari rata-rata untuk memastikan semua koneksi berkinerja baik
4. **Menggunakan RTT rata-rata ketika RTT terburuk mendekati** rata-rata untuk menghindari pengaturan yang terlalu konservatif

**Mengapa Ini Penting**: Menurut [Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17), "lebih baik, terutama ketika shaping inbound, menggunakan RTT tipikal Anda sebagai estimasi untuk mendapatkan kontrol antrian sebelum mengalir ke shaper ISP yang Anda kalahkan." Namun, jika RTT aktual ke host mana pun lebih panjang dari RTT yang diatur pada interface CAKE, performa bisa sangat terganggu.

**Contoh Dunia Nyata**:
- 98 host dengan RTT 30-50ms (rata-rata: 42ms)
- 2 host dengan RTT 200ms+ (terburuk: 234ms)
- **Algoritma lama**: Akan menggunakan rata-rata 45ms, menyebabkan masalah untuk host 200ms+
- **Algoritma baru**: Menggunakan RTT terburuk 234ms, memastikan performa optimal untuk semua koneksi

### Contoh Alur Koneksi

```
[Host/Aplikasi] → [CAKE pada Interface] → [Internet]
                            ↑
                      cake-autortt memantau
                      koneksi aktif dan
                      menyesuaikan parameter RTT
```

## 📊 Perilaku yang Diharapkan

Setelah instalasi dan startup, Anda harus mengamati:

### Efek Langsung
- Layanan mulai secara otomatis melalui systemd dan mulai memantau koneksi
- Pengukuran RTT dicatat ke journal sistem (jika debug diaktifkan)
- Parameter RTT CAKE qdisc diperbarui setiap 5 detik berdasarkan kondisi jaringan yang diukur
- Nilai RTT presisi tinggi (misalnya 44.89ms) diterapkan ke CAKE qdisc

### Manfaat Jangka Panjang
- **Responsivitas yang Ditingkatkan**: Parameter RTT tetap terkini dengan kondisi jaringan aktual
- **Kontrol Bufferbloat yang Lebih Baik**: CAKE dapat membuat keputusan yang lebih terinformasi tentang manajemen antrian
- **Performa Adaptif**: Secara otomatis menyesuaikan dengan kondisi jaringan yang berubah (satelit, seluler, link yang macet)
- **Akurasi yang Lebih Tinggi**: Sampling hingga 100 host (dapat dikonfigurasi) untuk representasi kondisi jaringan yang lebih baik

### Pemantauan

```bash
# Periksa status layanan
sudo systemctl status cake-autortt

# Lihat log layanan
sudo journalctl -u cake-autortt -f

# Pantau parameter CAKE qdisc
tc qdisc show | grep cake

# Mode debug untuk logging detail
sudo nano /etc/default/cake-autortt
# Set DEBUG=1, kemudian:
sudo systemctl restart cake-autortt
```

## 🔧 Pemecahan Masalah

### Masalah Umum

1. **Layanan tidak mau mulai**
   ```bash
   # Periksa dependensi
   which ping tc
   
   # Periksa interface CAKE
   tc qdisc show | grep cake
   
   # Periksa log layanan
   sudo journalctl -u cake-autortt --no-pager
   ```

2. **Tidak ada update RTT**
   ```bash
   # Aktifkan mode debug
   sudo nano /etc/default/cake-autortt
   # Set DEBUG=1
   
   sudo systemctl restart cake-autortt
   
   # Periksa log
   sudo journalctl -u cake-autortt -f
   ```

3. **Deteksi interface gagal**
   ```bash
   # Tentukan interface secara manual dalam konfigurasi
   sudo nano /etc/default/cake-autortt
   # Set DL_INTERFACE dan UL_INTERFACE
   
   sudo systemctl restart cake-autortt
   ```

4. **CAKE qdisc tidak ditemukan**
   ```bash
   # Verifikasi dukungan CAKE
   tc qdisc help | grep cake
   
   # Periksa apakah CAKE dikonfigurasi pada interface
   tc qdisc show
   
   # Konfigurasi CAKE jika diperlukan (lihat bagian instalasi)
   ```

### Informasi Debug

Dengan debug diaktifkan (`DEBUG=1` di `/etc/default/cake-autortt`), layanan menyediakan logging detail:

**Contoh output debug:**
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
> **Logging Efisien Memori**: Logging debug dioptimalkan untuk mencegah banjir log. Pengukuran RTT host individual tidak dicatat untuk mengurangi penggunaan memori dan penulisan disk. Hanya informasi ringkasan yang dicatat ke journal systemd, membuatnya cocok untuk operasi berkelanjutan tanpa pertumbuhan log yang berlebihan.

## 🔄 Perbedaan dari Versi OpenWrt

Port Ubuntu/Debian ini berbeda dari versi OpenWrt dalam beberapa cara kunci:

### Sistem Konfigurasi
- **OpenWrt**: Menggunakan sistem konfigurasi UCI (`uci set`, `/etc/config/cake-autortt`)
- **Ubuntu/Debian**: Menggunakan file konfigurasi tradisional (`/etc/default/cake-autortt`)

### Manajemen Layanan
- **OpenWrt**: Menggunakan procd dan skrip init.d OpenWrt
- **Ubuntu/Debian**: Menggunakan manajemen layanan systemd

### Pemantauan Interface
- **OpenWrt**: Menggunakan skrip hotplug.d untuk event interface
- **Ubuntu/Debian**: Menggunakan aturan udev untuk pemantauan interface

### Manajemen Paket
- **OpenWrt**: Menggunakan manajer paket opkg
- **Ubuntu/Debian**: Menggunakan manajer paket apt

### Lokasi File
- **OpenWrt**: Menggunakan path spesifik OpenWrt (`/etc/config/`, `/etc/hotplug.d/`)
- **Ubuntu/Debian**: Menggunakan path Linux standar (`/etc/default/`, `/etc/systemd/`, `/etc/udev/`)

## 📄 Lisensi

Proyek ini dilisensikan di bawah GNU General Public License v2.0 - lihat file [LICENSE](../LICENSE) untuk detail.

## 🤝 Berkontribusi

Kontribusi sangat diterima! Silakan kirim Pull Request. Ketika berkontribusi ke port Ubuntu/Debian, pastikan kompatibilitas dengan versi Ubuntu LTS dan Debian stable saat ini.