# cake-autortt (Ubuntu/Debian)

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | [中文](README_zh.md) | [Bahasa Indonesia](README_id.md) | [Русский](README_ru.md) | [日本語](README_ja.md) | **Tiếng Việt** | [Türkçe](README_tr.md) | [العربية](README_ar.md)

---

**Tự động điều chỉnh tham số RTT của CAKE qdisc dựa trên điều kiện mạng đo được**

Đây là **bản port Ubuntu/Debian** của cake-autortt, được điều chỉnh cho các bản phân phối Linux tiêu chuẩn sử dụng systemd, quản lý gói apt và tệp cấu hình truyền thống thay vì hệ thống UCI của OpenWrt.

## 🌍 Tại sao điều này quan trọng cho trải nghiệm internet của bạn

Hầu hết người dùng đã quen với việc tải nhanh các trang web chính như YouTube, Netflix và Google - những trang này sử dụng mạng phân phối nội dung (CDN) đặt máy chủ rất gần người dùng, thường cung cấp thời gian phản hồi dưới 50-100ms. Tuy nhiên, internet rộng lớn hơn nhiều so với những nền tảng lớn này.

**Khi bạn duyệt các trang web ngoài những trang được hỗ trợ CDN chính, bạn gặp phải một thế giới đa dạng của các máy chủ:**
- **Dịch vụ địa phương/khu vực**: Doanh nghiệp nhỏ, trang tin tức địa phương, diễn đàn cộng đồng và dịch vụ khu vực thường có máy chủ trong quốc gia hoặc khu vực của bạn (10-50ms RTT)
- **Nội dung quốc tế**: Các trang web chuyên biệt, tài nguyên học thuật, máy chủ game và dịch vụ ngách có thể được lưu trữ trên các lục địa khác (100-500ms RTT)
- **Cơ sở hạ tầng từ xa**: Một số dịch vụ, đặc biệt ở các khu vực đang phát triển hoặc ứng dụng chuyên biệt, có thể có độ trễ cao hơn đáng kể

**Tham số RTT của CAKE kiểm soát mức độ tích cực của thuật toán quản lý hàng đợi phản ứng với tắc nghẽn.** Theo mặc định, CAKE sử dụng giả định RTT 100ms, hoạt động khá tốt cho lưu lượng internet chung. Tuy nhiên:

- **Cài đặt RTT quá thấp**: Nếu CAKE nghĩ RTT mạng ngắn hơn thực tế, nó trở nên quá tích cực trong việc loại bỏ gói khi hàng đợi tích tụ, có thể giảm băng thông cho các máy chủ từ xa
- **Cài đặt RTT quá cao**: Nếu CAKE nghĩ RTT mạng dài hơn thực tế, nó trở nên quá bảo thủ và cho phép hàng đợi lớn tích tụ, tạo ra độ trễ không cần thiết cho các máy chủ gần

**Ví dụ tác động thực tế:**
- **Người dùng Singapore → Máy chủ Đức**: Không có điều chỉnh RTT, người dùng ở Singapore truy cập trang web Đức (≈180ms RTT) có thể gặp băng thông giảm do cài đặt mặc định 100ms của CAKE gây ra việc loại bỏ gói sớm
- **Vùng nông thôn Mỹ → Máy chủ khu vực**: Người dùng ở vùng nông thôn Mỹ truy cập máy chủ khu vực (≈25ms RTT) có thể gặp độ trễ cao hơn cần thiết vì cài đặt mặc định 100ms của CAKE cho phép hàng đợi phát triển nhiều hơn cần thiết
- **Ứng dụng game/thời gian thực**: Các ứng dụng nhạy cảm với cả độ trễ và băng thông được hưởng lợi đáng kể từ việc điều chỉnh RTT phù hợp với điều kiện mạng thực tế

**Cách cake-autortt giúp đỡ:**
Bằng cách tự động đo RTT thực tế đến các máy chủ bạn đang giao tiếp và điều chỉnh tham số CAKE tương ứng, bạn nhận được:
- **Phản hồi nhanh hơn** khi truy cập máy chủ gần (RTT ngắn hơn → quản lý hàng đợi tích cực hơn)
- **Băng thông tốt hơn** khi truy cập máy chủ từ xa (RTT dài hơn → quản lý hàng đợi kiên nhẫn hơn)
- **Kiểm soát bufferbloat tối ưu** thích ứng với điều kiện mạng thực tế thay vì giả định

Điều này đặc biệt có giá trị cho người dùng thường xuyên truy cập các nguồn nội dung đa dạng, làm việc với dịch vụ quốc tế, hoặc sống ở những khu vực mà lưu lượng internet thường đi qua khoảng cách lớn.

## 🚀 Tính năng

- **Khám phá RTT tự động**: Giám sát kết nối hoạt động qua `/proc/net/nf_conntrack` và đo RTT đến các host bên ngoài
- **Lọc host thông minh**: Tự động lọc địa chỉ LAN và tập trung vào các host bên ngoài
- **Thuật toán RTT thông minh**: Sử dụng lệnh ping tích hợp để đo RTT riêng lẻ cho từng host (3 ping mỗi host), sau đó chọn thông minh giữa RTT trung bình và tệ nhất để có hiệu suất tối ưu
- **Khám phá giao diện tự động**: Tự động phát hiện các giao diện có CAKE được kích hoạt
- **Tích hợp systemd**: Chạy như một dịch vụ systemd thích hợp với khởi động tự động và quản lý tiến trình
- **Tham số có thể cấu hình**: Tất cả tham số thời gian và hành vi có thể cấu hình qua tệp cấu hình
- **Xử lý lỗi mạnh mẽ**: Xử lý một cách duyên dáng các phụ thuộc bị thiếu, vấn đề mạng và thay đổi giao diện
- **Phụ thuộc tối thiểu**: Chỉ cần ping và tc - không cần gói bổ sung, sử dụng tiện ích tích hợp có sẵn trên tất cả hệ thống
- **RTT độ chính xác cao**: Hỗ trợ giá trị RTT phân số (ví dụ: 100.23ms) để điều chỉnh thời gian mạng chính xác

## 🔧 Tương thích

**Đã kiểm tra và hoạt động:**
- **Ubuntu 20.04+ (Focal trở lên)**
- **Debian 10+ (Buster trở lên)**

**Tương thích dự kiến:**
- Bất kỳ bản phân phối Linux dựa trên systemd nào có hỗ trợ CAKE qdisc
- Các bản phân phối với gói iproute2 hiện đại

**Yêu cầu tương thích:**
- Mô-đun kernel CAKE qdisc (có sẵn trong Linux 4.19+)
- Tiện ích ping (bao gồm trong tất cả bản phân phối Linux tiêu chuẩn)
- Quản lý dịch vụ systemd
- iproute2 với tiện ích tc (kiểm soát lưu lượng)
- Hỗ trợ /proc/net/nf_conntrack (netfilter conntrack)

## 📋 Yêu cầu

### Phụ thuộc
- **ping**: Tiện ích ping tiêu chuẩn để đo RTT (bao gồm trong tất cả bản phân phối Linux)
- **tc**: Tiện ích kiểm soát lưu lượng (một phần của iproute2)
- **CAKE qdisc**: Phải được cấu hình trên các giao diện đích
- **systemd**: Quản lý dịch vụ
- **netfilter conntrack**: Để theo dõi kết nối (/proc/net/nf_conntrack)

### Cài đặt phụ thuộc

```bash
# Cài đặt các gói cần thiết
sudo apt update
sudo apt install iputils-ping iproute2

# Kiểm tra xem tc có hỗ trợ CAKE không:
tc qdisc help | grep cake

# Kiểm tra tính khả dụng của conntrack
ls /proc/net/nf_conntrack
```

## 🔧 Cài đặt

> [!IMPORTANT]  
> Trước khi chạy script cài đặt, bạn PHẢI cấu hình CAKE qdisc trên các giao diện mạng của mình và chỉnh sửa tệp cấu hình để đặt tên giao diện chính xác cho hệ thống của bạn.

### Điều kiện tiên quyết: Cấu hình CAKE qdisc

Trước tiên, bạn cần cấu hình CAKE qdisc trên các giao diện mạng của mình. Điều này thường được thực hiện trên giao diện hướng internet:

```bash
# Ví dụ: Cấu hình CAKE trên giao diện chính
# Thay thế 'eth0' bằng tên giao diện thực tế của bạn
# Thay thế '100Mbit' bằng băng thông thực tế của bạn

# Cho cấu hình đơn giản (thay thế eth0 bằng giao diện của bạn):
sudo tc qdisc add root dev eth0 cake bandwidth 100Mbit

# Cho cấu hình nâng cao với shaping ingress:
# Tạo giao diện ifb (intermediate functional block) cho shaping download
sudo modprobe ifb
sudo ip link add name ifb0 type ifb
sudo ip link set dev ifb0 up

# Cấu hình chuyển hướng lưu lượng ingress và CAKE
sudo tc qdisc add dev eth0 handle ffff: ingress
sudo tc filter add dev eth0 parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
sudo tc qdisc add root dev ifb0 cake bandwidth 500Mbit ingress

# Cấu hình CAKE egress
sudo tc qdisc add root dev eth0 cake bandwidth 50Mbit

# Xác minh CAKE được cấu hình
tc qdisc show | grep cake
```

### Cài đặt nhanh

1. **Cấu hình giao diện CAKE (xem phần trên)**

2. **Chỉnh sửa tệp cấu hình:**

```bash
# Chỉnh sửa tệp cấu hình để phù hợp với tên giao diện của bạn
nano etc/default/cake-autortt
```

3. **Cấu hình tên giao diện của bạn:**

Cập nhật cài đặt `DL_INTERFACE` (download) và `UL_INTERFACE` (upload) để phù hợp với cấu hình mạng của bạn:

```bash
# Ví dụ cấu hình cho các thiết lập khác nhau:

# Cho thiết lập đơn giản (một giao diện cho cả hai hướng):
DL_INTERFACE="eth0"
UL_INTERFACE="eth0"

# Cho thiết lập nâng cao với giao diện ifb cho shaping ingress:
DL_INTERFACE="ifb0"     # Giao diện download (ifb cho shaping lưu lượng ingress)
UL_INTERFACE="eth0"     # Giao diện upload (giao diện vật lý)

# Cho tên giao diện tùy chỉnh:
DL_INTERFACE="enp3s0"   # Giao diện download cụ thể của bạn
UL_INTERFACE="enp3s0"   # Giao diện upload cụ thể của bạn
```

**Cách tìm tên giao diện của bạn:**
```bash
# Liệt kê các giao diện có CAKE qdisc
tc qdisc show | grep cake

# Liệt kê tất cả giao diện mạng
ip link show

# Kiểm tra giao diện mạng chính của bạn
ip route | grep default
```

4. **Chạy script cài đặt:**

```bash
# Làm cho script cài đặt có thể thực thi và chạy
chmod +x install.sh
sudo ./install.sh
```

### Cài đặt thủ công

1. **Sao chép tệp dịch vụ vào hệ thống của bạn:**

```bash
# Sao chép tệp thực thi chính
sudo cp usr/bin/cake-autortt /usr/bin/
sudo chmod +x /usr/bin/cake-autortt

# Sao chép tệp dịch vụ systemd
sudo cp etc/systemd/system/cake-autortt.service /etc/systemd/system/

# Sao chép tệp cấu hình
sudo cp etc/default/cake-autortt /etc/default/

# Sao chép quy tắc udev để giám sát giao diện
sudo cp etc/udev/rules.d/99-cake-autortt.rules /etc/udev/rules.d/

# Tải lại systemd và udev
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```

2. **Kích hoạt và khởi động dịch vụ:**

```bash
# Kích hoạt dịch vụ để khởi động tự động khi boot
sudo systemctl enable cake-autortt

# Khởi động dịch vụ
sudo systemctl start cake-autortt
```

## 🗑️ Gỡ cài đặt

Để gỡ cake-autortt khỏi hệ thống của bạn:

```bash
# Làm cho script gỡ cài đặt có thể thực thi và chạy
chmod +x uninstall.sh
sudo ./uninstall.sh
```

Script gỡ cài đặt sẽ:
- Dừng và vô hiệu hóa dịch vụ
- Xóa tất cả tệp đã cài đặt
- Tùy chọn xóa tệp cấu hình và sao lưu
- Dọn dẹp tệp tạm thời

## ⚙️ Cấu hình

### 🔧 Cấu hình giao diện (BẮT BUỘC)

**Bước cấu hình quan trọng nhất là đặt tên giao diện chính xác.** Dịch vụ sẽ không hoạt động đúng cách mà không có tên giao diện chính xác.

```bash
# Xem cấu hình hiện tại
cat /etc/default/cake-autortt

# Chỉnh sửa cấu hình
sudo nano /etc/default/cake-autortt

# Khởi động lại dịch vụ để áp dụng thay đổi
sudo systemctl restart cake-autortt
```

Dịch vụ được cấu hình qua `/etc/default/cake-autortt`. Tất cả tham số có thể được cấu hình bằng cách chỉnh sửa tệp này.

### Tham số cấu hình

| Tham số | Mặc định | Mô tả |
|-----------|---------|-------------|
| `DL_INTERFACE` | auto | Tên giao diện download (ví dụ: 'eth0', 'ifb0') |
| `UL_INTERFACE` | auto | Tên giao diện upload (ví dụ: 'eth0', 'enp3s0') |
| `RTT_UPDATE_INTERVAL` | 5 | Giây giữa các lần cập nhật tham số RTT qdisc |
| `MIN_HOSTS` | 3 | Số lượng host tối thiểu cần thiết để tính toán RTT |
| `MAX_HOSTS` | 100 | Số lượng host tối đa để probe tuần tự |
| `RTT_MARGIN_PERCENT` | 10 | Lề an toàn được thêm vào RTT đo được (phần trăm) |
| `DEFAULT_RTT_MS` | 100 | RTT mặc định khi không đủ host có sẵn |
| `DEBUG` | 0 | Kích hoạt ghi log debug (0=tắt, 1=bật) |

> [!NOTE]  
> Mặc dù các tham số giao diện có mặc định "auto", tự động phát hiện có thể không hoạt động đáng tin cậy trong tất cả cấu hình. Rất khuyến khích đặt các giá trị này một cách rõ ràng.

> [!TIP]  
> Đối với mạng hoạt động cao (ví dụ: khuôn viên đại học, mạng công cộng với nhiều người dùng hoạt động), hãy xem xét điều chỉnh `RTT_UPDATE_INTERVAL` dựa trên đặc điểm mạng của bạn. Mặc định 5 giây hoạt động tốt cho hầu hết các tình huống, nhưng bạn có thể tăng lên 10-15 giây cho mạng ổn định hơn hoặc giảm xuống 3 giây cho môi trường rất động.

### Ví dụ cấu hình

```bash
# /etc/default/cake-autortt

# Giao diện mạng (BẮT BUỘC - cấu hình cho cài đặt của bạn)
DL_INTERFACE="ifb0"      # Giao diện download
UL_INTERFACE="eth0"      # Giao diện upload

# Tham số thời gian
RTT_UPDATE_INTERVAL=5    # Cập nhật RTT mỗi 5 giây
MIN_HOSTS=3              # Cần tối thiểu 3 host để đo
MAX_HOSTS=100            # Lấy mẫu tối đa 100 host
RTT_MARGIN_PERCENT=10    # Thêm 10% lề an toàn
DEFAULT_RTT_MS=100       # Giá trị RTT dự phòng

# Debug
DEBUG=0                  # Đặt thành 1 cho ghi log chi tiết
```

## 🔍 Cách hoạt động

1. **Giám sát kết nối**: Định kỳ phân tích `/proc/net/nf_conntrack` để xác định kết nối mạng hoạt động
2. **Lọc host**: Trích xuất địa chỉ IP đích và lọc địa chỉ riêng tư/LAN
3. **Đo RTT**: Sử dụng `ping` để đo RTT riêng lẻ cho từng host bên ngoài (3 ping mỗi host)
4. **Lựa chọn RTT thông minh**: Ping các host tuần tự để tránh tắc nghẽn mạng, tính toán RTT trung bình và tệ nhất, sau đó sử dụng giá trị cao hơn để đảm bảo hiệu suất tối ưu cho tất cả kết nối
5. **Lề an toàn**: Thêm lề có thể cấu hình vào RTT đo được để đảm bảo đệm đầy đủ
6. **Cập nhật qdisc**: Cập nhật tham số RTT CAKE qdisc trên giao diện download và upload

### 🧠 Thuật toán RTT thông minh

Kể từ phiên bản 1.2.0, cake-autortt triển khai thuật toán lựa chọn RTT thông minh dựa trên khuyến nghị của Dave Täht (đồng tác giả CAKE):

**Vấn đề**: Chỉ sử dụng RTT trung bình có thể có vấn đề khi một số host có độ trễ cao hơn đáng kể so với những host khác. Ví dụ, nếu bạn có 100 host với RTT trung bình 40ms, nhưng 2 host có RTT 234ms và 240ms, việc sử dụng trung bình 40ms có thể gây ra vấn đề hiệu suất cho những kết nối độ trễ cao này.

**Giải pháp**: Thuật toán hiện tại:
1. **Tính toán cả RTT trung bình và tệ nhất** từ tất cả host phản hồi
2. **So sánh hai giá trị** và chọn thông minh cái phù hợp
3. **Sử dụng RTT tệ nhất khi nó cao hơn đáng kể** so với trung bình để đảm bảo hiệu suất tốt cho tất cả kết nối
4. **Sử dụng RTT trung bình khi RTT tệ nhất gần** với trung bình để tránh cài đặt quá bảo thủ

**Tại sao điều này quan trọng**: Theo [Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17), "tốt hơn, đặc biệt với shaping ingress, là sử dụng RTT điển hình của bạn làm ước tính để có được kiểm soát hàng đợi trước khi nó đến shaper ISP mà bạn đang đánh bại." Tuy nhiên, nếu RTT thực tế đến bất kỳ host nào dài hơn RTT được đặt trên giao diện CAKE, hiệu suất có thể bị ảnh hưởng nghiêm trọng.

**Ví dụ thực tế**:
- 98 host với RTT 30-50ms (trung bình: 42ms)
- 2 host với RTT 200ms+ (tệ nhất: 234ms)
- **Thuật toán cũ**: Sẽ sử dụng trung bình 45ms, gây ra vấn đề cho host 200ms+
- **Thuật toán mới**: Sử dụng RTT tệ nhất 234ms, đảm bảo hiệu suất tối ưu cho tất cả kết nối

### Ví dụ luồng kết nối

```
[Host/Ứng dụng] → [CAKE trên giao diện] → [Internet]
                            ↑
                      cake-autortt giám sát
                      kết nối hoạt động và
                      điều chỉnh tham số RTT
```

## 📊 Hành vi mong đợi

Sau khi cài đặt và khởi động, bạn nên quan sát:

### Hiệu ứng tức thì
- Dịch vụ tự động khởi động qua systemd và bắt đầu giám sát kết nối
- Các phép đo RTT được ghi vào log hệ thống (nếu debug được kích hoạt)
- Tham số RTT CAKE qdisc được cập nhật mỗi 30 giây dựa trên điều kiện mạng đo được
- Giá trị RTT độ chính xác cao (ví dụ: 44.89ms) được áp dụng cho CAKE qdisc

### Lợi ích dài hạn
- **Cải thiện khả năng phản hồi**: Tham số RTT luôn cập nhật với điều kiện mạng thực tế
- **Kiểm soát Bufferbloat tốt hơn**: CAKE có thể đưa ra quyết định thông tin hơn về quản lý hàng đợi
- **Hiệu suất thích ứng**: Tự động thích ứng với điều kiện mạng thay đổi (vệ tinh, di động, liên kết tắc nghẽn)
- **Độ chính xác cao hơn**: Lấy mẫu tối đa 20 host để đại diện tốt hơn cho điều kiện mạng

### Giám sát

```bash
# Kiểm tra trạng thái dịch vụ
sudo systemctl status cake-autortt

# Xem log dịch vụ
sudo journalctl -u cake-autortt -f

# Giám sát tham số CAKE qdisc
tc qdisc show | grep cake

# Chế độ debug cho ghi log chi tiết
sudo nano /etc/default/cake-autortt
# Đặt DEBUG=1, sau đó:
sudo systemctl restart cake-autortt
```

## 🔧 Khắc phục sự cố

### Vấn đề thường gặp

1. **Dịch vụ không khởi động**
   ```bash
   # Kiểm tra phụ thuộc
   which ping tc
   
   # Kiểm tra giao diện CAKE
   tc qdisc show | grep cake
   
   # Kiểm tra log dịch vụ
   sudo journalctl -u cake-autortt --no-pager
   ```

2. **Không có cập nhật RTT**
   ```bash
   # Kích hoạt chế độ debug
   sudo nano /etc/default/cake-autortt
   # Đặt DEBUG=1
   
   sudo systemctl restart cake-autortt
   
   # Kiểm tra log
   sudo journalctl -u cake-autortt -f
   ```

3. **Phát hiện giao diện thất bại**
   ```bash
   # Chỉ định giao diện thủ công trong cấu hình
   sudo nano /etc/default/cake-autortt
   # Đặt DL_INTERFACE và UL_INTERFACE
   
   sudo systemctl restart cake-autortt
   ```

4. **Không tìm thấy CAKE qdisc**
   ```bash
   # Kiểm tra hỗ trợ CAKE
   tc qdisc help | grep cake
   
   # Kiểm tra xem CAKE có được cấu hình trên giao diện không
   tc qdisc show
   
   # Cấu hình CAKE nếu cần (xem phần cài đặt)
   ```

### Thông tin debug

Với debug được kích hoạt (`DEBUG=1` trong `/etc/default/cake-autortt`), dịch vụ cung cấp ghi log chi tiết:

**Ví dụ đầu ra debug:**
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
> **Ghi log hiệu quả bộ nhớ**: Ghi log debug được tối ưu hóa để ngăn chặn tràn log. Các phép đo RTT host riêng lẻ không được ghi log để giảm sử dụng bộ nhớ và ghi đĩa. Chỉ thông tin tóm tắt được ghi vào journal systemd, làm cho nó phù hợp cho hoạt động liên tục mà không tăng trưởng log quá mức.

## 🔄 Khác biệt với phiên bản OpenWrt

Bản port Ubuntu/Debian này khác với phiên bản OpenWrt ở một số khía cạnh chính:

### Hệ thống cấu hình
- **OpenWrt**: Sử dụng hệ thống cấu hình UCI (`uci set`, `/etc/config/cake-autortt`)
- **Ubuntu/Debian**: Sử dụng tệp cấu hình truyền thống (`/etc/default/cake-autortt`)

### Quản lý dịch vụ
- **OpenWrt**: Sử dụng procd và script init.d OpenWrt
- **Ubuntu/Debian**: Sử dụng quản lý dịch vụ systemd

### Giám sát giao diện
- **OpenWrt**: Sử dụng script hotplug.d cho sự kiện giao diện
- **Ubuntu/Debian**: Sử dụng quy tắc udev cho giám sát giao diện

### Quản lý gói
- **OpenWrt**: Sử dụng trình quản lý gói opkg
- **Ubuntu/Debian**: Sử dụng trình quản lý gói apt

### Vị trí tệp
- **OpenWrt**: Sử dụng đường dẫn cụ thể OpenWrt (`/etc/config/`, `/etc/hotplug.d/`)
- **Ubuntu/Debian**: Sử dụng đường dẫn Linux tiêu chuẩn (`/etc/default/`, `/etc/systemd/`, `/etc/udev/`)

## 📄 Giấy phép

Dự án này được cấp phép theo GNU General Public License v2.0 - xem tệp [LICENSE](../LICENSE) để biết chi tiết.

## 🤝 Đóng góp

Đóng góp được hoan nghênh! Vui lòng gửi Pull Request. Khi đóng góp cho bản port Ubuntu/Debian, vui lòng đảm bảo tương thích với cả phiên bản Ubuntu LTS và Debian stable hiện tại.