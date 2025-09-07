# cake-autortt

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | [中文](README_zh.md) | [Bahasa Indonesia](README_id.md) | [Русский](README_ru.md) | [日本語](README_ja.md) | **Tiếng Việt** | [Türkçe](README_tr.md) | [العربية](README_ar.md)

---

**Tự động điều chỉnh tham số RTT của CAKE qdisc dựa trên điều kiện mạng đo được**

> [!NOTE]  
> Nếu bạn đang tìm kiếm **phiên bản Ubuntu/Debian**, hãy kiểm tra thư mục `ubuntu-debian/`. Tuy nhiên, lưu ý rằng chỉ có phiên bản OpenWrt được kiểm tra cá nhân hàng ngày - bản port Ubuntu/Debian được cung cấp như hiện tại cho cộng đồng.

`cake-autortt` là một dịch vụ OpenWrt thông minh giám sát các kết nối mạng hoạt động và tự động điều chỉnh tham số RTT (Round Trip Time) của CAKE qdisc trên các giao diện đến và đi để có hiệu suất mạng tối ưu.

## 🌍 Tại sao điều này quan trọng đối với trải nghiệm Internet của bạn

Hầu hết người dùng đã quen với thời gian tải nhanh của các trang web chính như YouTube, Netflix và Google - những trang này sử dụng mạng phân phối nội dung (CDN) đặt máy chủ rất gần người dùng, thường cung cấp thời gian phản hồi dưới 50-100ms. Tuy nhiên, Internet lớn hơn nhiều so với những nền tảng lớn này.

**Khi bạn duyệt các trang web ngoài những trang chính được hỗ trợ bởi CDN, bạn gặp phải một thế giới đa dạng của các máy chủ:**
- **Dịch vụ Địa phương/Khu vực**: Doanh nghiệp nhỏ, trang tin tức địa phương, diễn đàn cộng đồng và dịch vụ khu vực thường có máy chủ trong quốc gia hoặc khu vực của bạn (10-50ms RTT)
- **Nội dung Quốc tế**: Các trang web chuyên biệt, tài nguyên học thuật, máy chủ game và dịch vụ ngách có thể được lưu trữ trên các lục địa khác (100-500ms RTT)
- **Cơ sở hạ tầng Từ xa**: Một số dịch vụ, đặc biệt là ở các khu vực đang phát triển hoặc ứng dụng chuyên biệt, có thể có độ trễ cao đáng kể

**Tham số CAKE RTT kiểm soát mức độ tích cực của thuật toán xếp hàng phản ứng với tắc nghẽn.** Theo mặc định, CAKE sử dụng giả định RTT 100ms, hoạt động khá tốt cho lưu lượng Internet chung. Tuy nhiên:

- **Cài đặt RTT quá thấp**: Nếu CAKE nghĩ RTT mạng ngắn hơn thực tế, nó trở nên quá tích cực trong việc loại bỏ gói tin khi định hình hàng đợi, có thể làm giảm băng thông cho các máy chủ từ xa
- **Cài đặt RTT quá cao**: Nếu CAKE nghĩ RTT mạng dài hơn thực tế, nó trở nên quá bảo thủ và cho phép hình thành hàng đợi lớn, tạo ra độ trễ không cần thiết cho các máy chủ gần

**Ví dụ tác động thực tế:**
- **Người dùng Singapore → Máy chủ Đức**: Không có điều chỉnh RTT, người dùng ở Singapore truy cập trang web Đức (≈180ms RTT) có thể gặp băng thông giảm do cài đặt mặc định 100ms của CAKE gây ra việc loại bỏ gói tin sớm
- **Nông thôn Mỹ → Máy chủ Khu vực**: Người dùng ở nông thôn Mỹ truy cập máy chủ khu vực (≈25ms RTT) có thể gặp độ trễ cao hơn cần thiết do cài đặt mặc định 100ms của CAKE cho phép hàng đợi phát triển lớn hơn cần thiết
- **Ứng dụng Game/Thời gian thực**: Các ứng dụng nhạy cảm với cả độ trễ và băng thông đều được hưởng lợi đáng kể từ việc điều chỉnh RTT phù hợp với điều kiện mạng thực tế

**Cách cake-autortt giúp đỡ:**
Bằng cách tự động đo RTT thực tế đến các máy chủ bạn đang giao tiếp và điều chỉnh tham số CAKE tương ứng, bạn nhận được:
- **Phản hồi nhanh hơn** khi truy cập máy chủ gần (RTT ngắn hơn → quản lý hàng đợi tích cực hơn)
- **Băng thông tốt hơn** khi truy cập máy chủ từ xa (RTT dài hơn → quản lý hàng đợi kiên nhẫn hơn)
- **Kiểm soát bufferbloat tối ưu** thích ứng với điều kiện mạng thực tế thay vì giả định

Điều này đặc biệt có giá trị cho người dùng thường xuyên truy cập các nguồn nội dung đa dạng, làm việc với dịch vụ quốc tế, hoặc sống ở những khu vực mà lưu lượng Internet thường đi qua khoảng cách lớn.

## 🚀 Tính năng

- **Phát hiện RTT Tự động**: Giám sát các kết nối hoạt động thông qua `/proc/net/nf_conntrack` và đo RTT đến các host bên ngoài
- **Lọc Host Thông minh**: Tự động lọc địa chỉ LAN và tập trung vào các host bên ngoài
- **Thuật toán RTT Thông minh**: Sử dụng lệnh ping tích hợp để đo RTT của từng host riêng lẻ (3 ping mỗi host), sau đó thông minh lựa chọn giữa RTT trung bình và tệ nhất để có hiệu suất tối ưu
- **Phát hiện Giao diện Tự động**: Tự động phát hiện các giao diện có CAKE (ưu tiên `ifb-*` cho download, giao diện vật lý cho upload)
- **Tích hợp Dịch vụ OpenWrt**: Hoạt động như một dịch vụ OpenWrt thích hợp với khởi động tự động và quản lý tiến trình
- **Tham số Có thể Cấu hình**: Tất cả tham số thời gian và hành vi có thể cấu hình thông qua cấu hình UCI
- **Xử lý Lỗi Mạnh mẽ**: Xử lý một cách duyên dáng các phụ thuộc bị thiếu, vấn đề mạng và thay đổi giao diện
- **Phụ thuộc Tối thiểu**: Chỉ yêu cầu ping và tc - không cần gói bổ sung, sử dụng tiện ích tích hợp có sẵn trên tất cả hệ thống
- **RTT Độ chính xác Cao**: Hỗ trợ giá trị RTT phân số (ví dụ: 100.23ms) để điều chỉnh thời gian mạng chính xác

## 🔧 Tương thích

**Đã kiểm tra và hoạt động:**
- **OpenWrt 24.10.1, r28597-0425664679, Target Platform x86/64**

**Tương thích dự kiến:**
- Các phiên bản OpenWrt trước đó (21.02+) với hỗ trợ CAKE qdisc
- Các bản phát hành OpenWrt tương lai miễn là các phụ thuộc cần thiết có sẵn
- Tất cả kiến trúc đích được hỗ trợ bởi OpenWrt (ARM, MIPS, x86, v.v.)

**Yêu cầu tương thích:**
- Mô-đun kernel CAKE qdisc
- Tiện ích ping (bao gồm trong tất cả bản phân phối Linux tiêu chuẩn)
- Tiện ích tc tiêu chuẩn (kiểm soát lưu lượng)
- Hỗ trợ /proc/net/nf_conntrack (netfilter conntrack)

## 📋 Yêu cầu

### Phụ thuộc
- **ping**: Tiện ích ping tiêu chuẩn để đo RTT (bao gồm trong tất cả bản phân phối Linux)
- **tc**: Tiện ích kiểm soát lưu lượng (một phần của iproute2)
- **CAKE qdisc**: Phải được cấu hình trên các giao diện đích

### Cài đặt Phụ thuộc

```bash
# ping được bao gồm theo mặc định trong OpenWrt
# Không cần gói bổ sung cho chức năng ping

# CAKE qdisc thường có sẵn trong các phiên bản OpenWrt hiện đại
# Kiểm tra xem tc có hỗ trợ CAKE không:
tc qdisc help | grep cake
```

## 🔧 Cài đặt

> [!IMPORTANT]  
> Trước khi chạy script cài đặt, bạn PHẢI chỉnh sửa tệp cấu hình để đặt tên giao diện chính xác cho hệ thống của bạn.

1. **Chỉnh sửa tệp cấu hình:**

```bash
# Chỉnh sửa tệp cấu hình để phù hợp với tên giao diện của bạn
nano etc/config/cake-autortt
```

2. **Cấu hình tên giao diện của bạn:**

Cập nhật cài đặt `dl_interface` (download) và `ul_interface` (upload) để phù hợp với thiết lập mạng của bạn:

```bash
# Ví dụ cấu hình cho các thiết lập khác nhau:

# Cho thiết lập OpenWrt SQM điển hình sử dụng giao diện ifb:
option dl_interface 'ifb-wan'      # Giao diện download (thường là ifb-*)
option ul_interface 'wan'          # Giao diện upload (thường là wan, eth0, v.v.)

# Cho thiết lập giao diện trực tiếp:
option dl_interface 'eth0'         # Giao diện WAN của bạn
option ul_interface 'eth0'         # Cùng giao diện cho cả hai hướng

# Cho tên giao diện tùy chỉnh:
option dl_interface 'ifb4eth1'     # Giao diện download cụ thể của bạn
option ul_interface 'eth1'         # Giao diện upload cụ thể của bạn
```

**Cách tìm tên giao diện của bạn:**
```bash
# Liệt kê các giao diện với CAKE qdisc
tc qdisc show | grep cake

# Liệt kê tất cả giao diện mạng
ip link show

# Kiểm tra cấu hình giao diện SQM (nếu sử dụng SQM)
uci show sqm
```

### Cài đặt Nhanh

1. **Cấu hình giao diện (xem phần trên)**

2. **Chạy script cài đặt:**

```bash
# Làm cho script cài đặt có thể thực thi và chạy
chmod +x install.sh
./install.sh
```

### Cài đặt Thủ công

1. **Sao chép tệp dịch vụ vào router OpenWrt của bạn:**

```bash
# Sao chép tệp thực thi chính
cp usr/bin/cake-autortt /usr/bin/
chmod +x /usr/bin/cake-autortt

# Sao chép script khởi tạo
cp etc/init.d/cake-autortt /etc/init.d/
chmod +x /etc/init.d/cake-autortt

# Sao chép tệp cấu hình
cp etc/config/cake-autortt /etc/config/

# Sao chép script hotplug
cp etc/hotplug.d/iface/99-cake-autortt /etc/hotplug.d/iface/
chmod +x /etc/hotplug.d/iface/99-cake-autortt
```

2. **Kích hoạt và khởi động dịch vụ:**

```bash
# Kích hoạt dịch vụ để khởi động tự động khi boot
/etc/init.d/cake-autortt enable

# Khởi động dịch vụ
/etc/init.d/cake-autortt start
```

## 🗑️ Gỡ cài đặt

Để gỡ cake-autortt khỏi hệ thống của bạn:

```bash
# Làm cho script gỡ cài đặt có thể thực thi và chạy
chmod +x uninstall.sh
./uninstall.sh
```

Script gỡ cài đặt sẽ:
- Dừng và vô hiệu hóa dịch vụ
- Xóa tất cả tệp đã cài đặt
- Tùy chọn xóa tệp cấu hình và sao lưu
- Dọn dẹp tệp tạm thời

## ⚙️ Cấu hình

### 🔧 Cấu hình Giao diện (BẮT BUỘC)

**Bước cấu hình quan trọng nhất là đặt tên giao diện chính xác.** Dịch vụ sẽ không hoạt động đúng cách mà không có tên giao diện chính xác.

```bash
# Xem cấu hình hiện tại
uci show cake-autortt

# BẮT BUỘC: Đặt tên giao diện của bạn
uci set cake-autortt.global.dl_interface='your-download-interface'
uci set cake-autortt.global.ul_interface='your-upload-interface'
uci commit cake-autortt

# Các thay đổi cấu hình tùy chọn khác
uci set cake-autortt.global.rtt_update_interval='30'
uci set cake-autortt.global.debug='1'
uci commit cake-autortt

# Khởi động lại dịch vụ để áp dụng thay đổi
/etc/init.d/cake-autortt restart
```

Dịch vụ được cấu hình thông qua UCI. Chỉnh sửa `/etc/config/cake-autortt` hoặc sử dụng lệnh `uci`.

### Tham số Cấu hình

| Tham số | Mặc định | Mô tả |
|-----------|---------|-------------|
| `dl_interface` | auto | Tên giao diện download (ví dụ: 'ifb-wan', 'ifb4eth1') |
| `ul_interface` | auto | Tên giao diện upload (ví dụ: 'wan', 'eth1') |
| `rtt_update_interval` | 5 | Giây giữa các lần cập nhật tham số qdisc RTT |
| `min_hosts` | 3 | Số lượng host tối thiểu cần thiết để tính toán RTT |
| `max_hosts` | 100 | Số lượng host tối đa để thăm dò tuần tự |
| `rtt_margin_percent` | 10 | Lề an toàn được thêm vào RTT đo được (phần trăm) |
| `default_rtt_ms` | 100 | RTT mặc định khi không có đủ host khả dụng |
| `debug` | 0 | Kích hoạt ghi log debug (0=tắt, 1=bật) |

> [!NOTE]  
> Mặc dù các tham số giao diện có mặc định "auto", phát hiện tự động có thể không hoạt động đáng tin cậy trong tất cả cấu hình. Khuyến khích mạnh mẽ đặt các giá trị này một cách rõ ràng.

> [!TIP]  
> Đối với mạng hoạt động cao (ví dụ: khuôn viên đại học, mạng công cộng với nhiều người dùng hoạt động), hãy xem xét điều chỉnh `rtt_update_interval` dựa trên đặc điểm mạng của bạn. Mặc định 5 giây hoạt động tốt cho hầu hết các tình huống, nhưng bạn có thể tăng lên 10-15 giây cho mạng ổn định hơn hoặc giảm xuống 3 giây cho môi trường rất động.

## 🔍 Cách hoạt động

1. **Giám sát Kết nối**: Định kỳ phân tích `/proc/net/nf_conntrack` để xác định các kết nối mạng hoạt động
2. **Lọc Host**: Trích xuất địa chỉ IP đích và lọc địa chỉ riêng tư/LAN
3. **Đo RTT**: Sử dụng `ping` để đo RTT của từng host bên ngoài riêng lẻ (3 ping mỗi host)
4. **Lựa chọn RTT Thông minh**: Ping các host tuần tự để ngăn tắc nghẽn mạng, tính toán RTT trung bình và tệ nhất, sau đó sử dụng giá trị cao hơn để đảm bảo hiệu suất tối ưu cho tất cả kết nối
5. **Lề An toàn**: Thêm lề có thể cấu hình vào RTT đo được để đảm bảo đệm đầy đủ
6. **Cập nhật qdisc**: Cập nhật tham số CAKE qdisc RTT trên giao diện download và upload

### 🧠 Thuật toán RTT Thông minh

Kể từ phiên bản 1.2.0, cake-autortt triển khai thuật toán lựa chọn RTT thông minh dựa trên khuyến nghị của Dave Täht (đồng tác giả CAKE):

**Vấn đề**: Chỉ sử dụng RTT trung bình có thể có vấn đề khi một số host có độ trễ cao hơn đáng kể so với những host khác. Ví dụ, nếu bạn có 100 host với RTT trung bình 40ms, nhưng 2 host có RTT 234ms và 240ms, việc sử dụng trung bình 40ms có thể gây ra vấn đề hiệu suất cho những kết nối độ trễ cao này.

**Giải pháp**: Thuật toán hiện tại:
1. **Tính toán cả RTT trung bình và tệ nhất** từ tất cả host phản hồi
2. **So sánh hai giá trị** và thông minh lựa chọn giá trị phù hợp
3. **Sử dụng RTT tệ nhất khi nó cao hơn đáng kể** so với trung bình để đảm bảo tất cả kết nối hoạt động tốt
4. **Sử dụng RTT trung bình khi RTT tệ nhất gần** với trung bình để tránh cài đặt quá bảo thủ

**Tại sao điều này quan trọng**: Theo [Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17), "tốt hơn, đặc biệt với shaping đến, là sử dụng RTT điển hình của bạn như một ước tính để có được kiểm soát hàng đợi trước khi nó đến shaper ISP mà bạn đang đánh bại." Tuy nhiên, nếu RTT thực tế đến bất kỳ host nào dài hơn RTT được đặt trên giao diện CAKE, hiệu suất có thể bị ảnh hưởng đáng kể.

**Ví dụ thực tế**:
- 98 host với RTT 30-50ms (trung bình: 42ms)
- 2 host với RTT 200ms+ (tệ nhất: 234ms)
- **Thuật toán cũ**: Sẽ sử dụng trung bình 45ms, gây ra vấn đề cho host 200ms+
- **Thuật toán mới**: Sử dụng RTT tệ nhất 234ms, đảm bảo hiệu suất tối ưu cho tất cả kết nối

### Ví dụ Luồng Kết nối

```
[Thiết bị LAN] → [Router CAKE] → [Internet]
                       ↑
                 cake-autortt giám sát
                 kết nối hoạt động và
                 điều chỉnh tham số RTT
```

## 📊 Hành vi Dự kiến

Sau khi cài đặt và khởi động, bạn nên quan sát:

### Hiệu ứng Ngay lập tức
- Dịch vụ khởi động tự động và bắt đầu giám sát kết nối
- Các phép đo RTT được ghi vào log hệ thống (nếu debug được bật)
- Tham số CAKE qdisc RTT được cập nhật mỗi 30 giây dựa trên điều kiện mạng đo được
- Giá trị RTT độ chính xác cao (ví dụ: 44.89ms) được áp dụng cho CAKE qdisc

### Lợi ích Dài hạn
- **Cải thiện Phản hồi**: Tham số RTT luôn cập nhật với điều kiện mạng thực tế
- **Kiểm soát Bufferbloat Tốt hơn**: CAKE có thể đưa ra quyết định quản lý hàng đợi có thông tin hơn
- **Hiệu suất Thích ứng**: Tự động thích ứng với điều kiện mạng thay đổi (vệ tinh, di động, liên kết tắc nghẽn)
- **Độ chính xác Cao hơn**: Lấy mẫu lên đến 20 host để đại diện tốt hơn cho điều kiện mạng

### Giám sát

```bash
# Kiểm tra trạng thái dịch vụ
/etc/init.d/cake-autortt status

# Xem log dịch vụ
logread | grep cake-autortt

# Giám sát tham số CAKE qdisc
tc qdisc show | grep cake

# Chế độ debug cho log chi tiết
uci set cake-autortt.global.debug='1'
uci commit cake-autortt
/etc/init.d/cake-autortt restart
```

## 🔧 Khắc phục sự cố

### Vấn đề Thường gặp

1. **Dịch vụ không khởi động**
   ```bash
   # Kiểm tra phụ thuộc
   which ping tc
   
   # Kiểm tra giao diện CAKE
   tc qdisc show | grep cake
   ```

2. **Không có cập nhật RTT**
   ```bash
   # Bật chế độ debug
   uci set cake-autortt.global.debug='1'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   
   # Kiểm tra log
   logread | grep cake-autortt
   ```

3. **Phát hiện giao diện thất bại**
   ```bash
   # Chỉ định giao diện thủ công
   uci set cake-autortt.global.dl_interface='ifb-wan'
   uci set cake-autortt.global.ul_interface='wan'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   ```

### Thông tin Debug

Với debug được bật (`uci set cake-autortt.global.debug='1'`), dịch vụ cung cấp log chi tiết:

**Ví dụ đầu ra debug:**
```bash
[2025-01-09 18:34:22] cake-autortt DEBUG: Trích xuất host từ conntrack
[2025-01-09 18:34:22] cake-autortt DEBUG: Tìm thấy 35 host không phải LAN
[2025-01-09 18:34:22] cake-autortt DEBUG: Đo RTT bằng ping cho 35 host (3 ping mỗi host)
[2025-01-09 18:34:25] cake-autortt DEBUG: tóm tắt ping: 28/35 host sống
[2025-01-09 18:34:25] cake-autortt DEBUG: Sử dụng RTT trung bình: 45.2ms (trung bình: 45.2ms, tệ nhất: 89.1ms)
[2025-01-09 18:34:25] cake-autortt DEBUG: Sử dụng RTT đo được: 45.2ms
[2025-01-09 18:34:35] cake-autortt INFO: Đặt CAKE RTT thành 49.72ms (49720us)
[2025-01-09 18:34:35] cake-autortt DEBUG: RTT được cập nhật trên giao diện download ifb-wan
[2025-01-09 18:34:35] cake-autortt DEBUG: RTT được cập nhật trên giao diện upload wan
```

> [!NOTE]  
> **Log Hiệu quả Bộ nhớ**: Log debug được tối ưu hóa để ngăn tràn log. Các phép đo RTT host riêng lẻ không được ghi để giảm sử dụng bộ nhớ và ghi đĩa. Chỉ thông tin tóm tắt được ghi, làm cho nó phù hợp cho hoạt động liên tục mà không tăng trưởng log quá mức.

## 📄 Giấy phép

Dự án này được cấp phép theo GNU General Public License v2.0 - xem tệp [LICENSE](LICENSE) để biết chi tiết.

## 🤝 Đóng góp

Chào mừng đóng góp! Vui lòng gửi Pull Request.