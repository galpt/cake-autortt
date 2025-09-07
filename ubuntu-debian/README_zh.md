# Ubuntu/Debian 版 cake-autortt

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | **中文** | [Bahasa Indonesia](README_id.md) | [Русский](README_ru.md) | [日本語](README_ja.md) | [Tiếng Việt](README_vi.md) | [Türkçe](README_tr.md) | [العربية](README_ar.md)

---

**根据测量的网络条件自动调整 CAKE qdisc RTT 参数**

这是 cake-autortt 的 **Ubuntu/Debian 移植版**，适配了使用 systemd、apt 包管理和传统配置文件的标准 Linux 发行版，而不是 OpenWrt 的 UCI 系统。

## 🌍 为什么这对您的互联网体验很重要

大多数用户都熟悉 YouTube、Netflix 和 Google 等主要网站的快速加载时间 - 这些网站使用内容分发网络 (CDN)，将服务器放置在非常接近用户的位置，通常响应时间低于 50-100ms。然而，互联网远比这些大平台更广阔。

**当您浏览超出主要 CDN 支持的网站时，您会遇到多样化的服务器世界：**
- **本地/区域服务**：小企业、本地新闻网站、社区论坛和区域服务通常在您的国家或地区内有服务器（10-50ms RTT）
- **国际内容**：专业网站、学术资源、游戏服务器和小众服务可能托管在大洲之外（100-500ms RTT）
- **远程基础设施**：一些服务，特别是在发展中地区或专业应用中，可能有显著更高的延迟

**CAKE RTT 参数控制队列管理算法对拥塞的响应积极程度。** 默认情况下，CAKE 使用 100ms RTT 假设，这对一般互联网流量效果相当好。然而：

- **RTT 设置过低**：如果 CAKE 认为网络 RTT 比实际情况短，它在队列堆积时会过于激进地丢弃数据包，可能降低远程服务器的吞吐量
- **RTT 设置过高**：如果 CAKE 认为网络 RTT 比实际情况长，它会过于保守，允许更大的队列堆积，为附近服务器创造不必要的延迟

**实际影响示例：**
- **新加坡用户 → 德国服务器**：没有 RTT 调整，新加坡用户访问德国网站（≈180ms RTT）可能会遇到吞吐量降低，因为 CAKE 的默认 100ms 设置导致过早的数据包丢弃
- **美国农村 → 区域服务器**：美国农村用户访问区域服务器（≈25ms RTT）可能会遇到比必要更高的延迟，因为 CAKE 的默认 100ms 设置允许队列增长得比需要的更大
- **游戏/实时应用**：对延迟和吞吐量都敏感的应用从匹配实际网络条件的 RTT 调优中受益显著

**cake-autortt 如何帮助：**
通过自动测量您正在通信的服务器的实际 RTT 并相应调整 CAKE 的参数，您可以获得：
- **更快的响应**当访问附近服务器时（更短的 RTT → 更积极的队列管理）
- **更好的吞吐量**当访问远程服务器时（更长的 RTT → 更耐心的队列管理）
- **最佳的缓冲膨胀控制**适应真实网络条件而不是假设

这对经常访问多样化内容源、与国际服务合作或生活在互联网流量经常跨越长距离的地区的用户特别有价值。

## 🚀 功能特性

- **自动 RTT 检测**：通过 `/proc/net/nf_conntrack` 监控活动连接并测量到外部主机的 RTT
- **智能主机过滤**：自动过滤掉 LAN 地址并专注于外部主机
- **智能 RTT 算法**：使用内置 ping 命令单独测量每个主机的 RTT（每个主机 3 次 ping），然后智能地在平均和最坏情况 RTT 之间选择以获得最佳性能
- **接口自动检测**：自动检测启用 CAKE 的接口
- **systemd 集成**：作为适当的 systemd 服务运行，具有自动启动和进程管理
- **可配置参数**：所有时序和行为参数都可以通过配置文件自定义
- **强大的错误处理**：优雅地处理缺失的依赖项、网络问题和接口更改
- **最小依赖**：只需要 ping 和 tc - 不需要额外的包，使用所有系统上可用的内置实用程序
- **高精度 RTT**：支持分数 RTT 值（例如 100.23ms）以进行精确的网络时序调整

## 🔧 兼容性

**已测试并工作：**
- **Ubuntu 20.04+（Focal 及更高版本）**
- **Debian 10+（Buster 及更高版本）**

**预期兼容性：**
- 任何支持 CAKE qdisc 的基于 systemd 的 Linux 发行版
- 具有现代 iproute2 包的发行版

**兼容性要求：**
- CAKE qdisc 内核模块（在 Linux 4.19+ 中可用）
- ping 实用程序（包含在所有标准 Linux 发行版中）
- systemd 服务管理
- 带有 tc（流量控制）实用程序的 iproute2
- /proc/net/nf_conntrack 支持（netfilter conntrack）

## 📋 要求

### 依赖项
- **ping**：用于测量 RTT 的标准 ping 实用程序（包含在所有 Linux 发行版中）
- **tc**：流量控制实用程序（iproute2 的一部分）
- **CAKE qdisc**：必须在目标接口上配置
- **systemd**：服务管理
- **netfilter conntrack**：用于连接跟踪（/proc/net/nf_conntrack）

### 依赖项安装

```bash
# 安装所需包
sudo apt update
sudo apt install iputils-ping iproute2

# 检查 tc 是否支持 CAKE：
tc qdisc help | grep cake

# 验证 conntrack 是否可用
ls /proc/net/nf_conntrack
```

## 🔧 安装

> [!IMPORTANT]  
> 在运行安装脚本之前，您必须在网络接口上配置 CAKE qdisc 并编辑配置文件以为您的系统设置正确的接口名称。

### 先决条件：配置 CAKE qdisc

首先，您需要在网络接口上设置 CAKE qdisc。这通常在您的面向互联网的接口上完成：

```bash
# 示例：在主接口上配置 CAKE
# 将 'eth0' 替换为您的实际接口名称
# 将 '100Mbit' 替换为您的实际带宽

# 简单设置（将 eth0 替换为您的接口）：
sudo tc qdisc add root dev eth0 cake bandwidth 100Mbit

# 更高级的入口整形设置：
# 为下载整形创建 ifb（中间功能块）接口
sudo modprobe ifb
sudo ip link add name ifb0 type ifb
sudo ip link set dev ifb0 up

# 配置入口重定向和 CAKE
sudo tc qdisc add dev eth0 handle ffff: ingress
sudo tc filter add dev eth0 parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
sudo tc qdisc add root dev ifb0 cake bandwidth 500Mbit ingress

# 配置出口 CAKE
sudo tc qdisc add root dev eth0 cake bandwidth 50Mbit

# 验证 CAKE 已配置
tc qdisc show | grep cake
```

### 快速安装

1. **配置 CAKE 接口（见上节）**

2. **编辑配置文件：**

```bash
# 编辑配置文件以匹配您的接口名称
nano etc/default/cake-autortt
```

3. **配置您的接口名称：**

更新 `DL_INTERFACE`（下载）和 `UL_INTERFACE`（上传）设置以匹配您的网络设置：

```bash
# 不同设置的示例配置：

# 简单设置（两个方向使用相同接口）：
DL_INTERFACE="eth0"
UL_INTERFACE="eth0"

# 使用 ifb 接口进行下载整形的高级设置：
DL_INTERFACE="ifb0"     # 下载接口（用于入口整形的 ifb）
UL_INTERFACE="eth0"     # 上传接口（物理接口）

# 自定义接口名称：
DL_INTERFACE="enp3s0"   # 您的特定下载接口
UL_INTERFACE="enp3s0"   # 您的特定上传接口
```

**如何找到您的接口名称：**
```bash
# 列出带有 CAKE qdisc 的接口
tc qdisc show | grep cake

# 列出所有网络接口
ip link show

# 检查您的主网络接口
ip route | grep default
```

4. **运行安装脚本：**

```bash
# 使安装脚本可执行并运行
chmod +x install.sh
sudo ./install.sh
```

### 手动安装

1. **将服务文件复制到您的系统：**

```bash
# 复制主可执行文件
sudo cp usr/bin/cake-autortt /usr/bin/
sudo chmod +x /usr/bin/cake-autortt

# 复制 systemd 服务文件
sudo cp etc/systemd/system/cake-autortt.service /etc/systemd/system/

# 复制配置文件
sudo cp etc/default/cake-autortt /etc/default/

# 复制用于接口监控的 udev 规则
sudo cp etc/udev/rules.d/99-cake-autortt.rules /etc/udev/rules.d/

# 重新加载 systemd 和 udev
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```

2. **启用并启动服务：**

```bash
# 启用服务以在启动时自动启动
sudo systemctl enable cake-autortt

# 启动服务
sudo systemctl start cake-autortt
```

## 🗑️ 卸载

要从系统中删除 cake-autortt：

```bash
# 使卸载脚本可执行并运行
chmod +x uninstall.sh
sudo ./uninstall.sh
```

卸载脚本将：
- 停止并禁用服务
- 删除所有已安装的文件
- 可选择删除配置和备份文件
- 清理临时文件

## ⚙️ 配置

### 🔧 接口配置（必需）

**最关键的配置步骤是设置正确的接口名称。** 没有正确的接口名称，服务将无法正常工作。

```bash
# 查看当前配置
cat /etc/default/cake-autortt

# 编辑配置
sudo nano /etc/default/cake-autortt

# 重启服务以应用更改
sudo systemctl restart cake-autortt
```

服务通过 `/etc/default/cake-autortt` 配置。所有参数都可以通过编辑此文件进行自定义。

### 配置参数

| 参数 | 默认值 | 描述 |
|-----------|---------|-------------|
| `DL_INTERFACE` | auto | 下载接口名称（例如 'eth0'、'ifb0'）|
| `UL_INTERFACE` | auto | 上传接口名称（例如 'eth0'、'enp3s0'）|
| `RTT_UPDATE_INTERVAL` | 5 | qdisc RTT 参数更新之间的秒数 |
| `MIN_HOSTS` | 3 | RTT 计算所需的最少主机数 |
| `MAX_HOSTS` | 100 | 顺序探测的最大主机数 |
| `RTT_MARGIN_PERCENT` | 10 | 添加到测量 RTT 的安全边际（百分比）|
| `DEFAULT_RTT_MS` | 100 | 可用主机不足时的默认 RTT |
| `DEBUG` | 0 | 启用调试日志记录（0=禁用，1=启用）|

> [!NOTE]  
> 虽然接口参数的默认值为 "auto"，但自动检测在所有配置中可能无法可靠工作。强烈建议明确设置这些值。

> [!TIP]  
> 对于高活动网络（例如大学校园、有许多活跃用户的公共网络），考虑根据您网络的特性调整 `RTT_UPDATE_INTERVAL`。默认的 5 秒适用于大多数场景，但您可以将其增加到 10-15 秒以适应更稳定的网络，或将其减少到 3 秒以适应非常动态的环境。

### 配置示例

```bash
# /etc/default/cake-autortt

# 网络接口（必需 - 根据您的设置调整）
DL_INTERFACE="ifb0"      # 下载接口
UL_INTERFACE="eth0"      # 上传接口

# 时序参数
RTT_UPDATE_INTERVAL=5    # 每 5 秒更新 RTT
MIN_HOSTS=3              # 测量至少需要 3 个主机
MAX_HOSTS=100            # 采样最多 100 个主机
RTT_MARGIN_PERCENT=10    # 添加 10% 安全边际
DEFAULT_RTT_MS=100       # 回退 RTT 值

# 调试
DEBUG=0                  # 设置为 1 以启用详细日志记录
```

## 🔍 工作原理

1. **连接监控**：定期解析 `/proc/net/nf_conntrack` 以识别活动网络连接
2. **主机过滤**：提取目标 IP 地址并过滤掉私有/LAN 地址
3. **RTT 测量**：使用 `ping` 单独测量每个外部主机的 RTT（每个主机 3 次 ping）
4. **智能 RTT 选择**：逐个 ping 主机以防止网络过载，计算平均和最坏情况 RTT，然后使用较高的值以确保所有连接的最佳性能
5. **安全边际**：为测量的 RTT 添加可配置的边际以确保足够的缓冲
6. **qdisc 更新**：在下载和上传接口上更新 CAKE qdisc RTT 参数

### 🧠 智能 RTT 算法

从版本 1.2.0 开始，cake-autortt 实现了基于 Dave Täht（CAKE 的共同作者）建议的智能 RTT 选择算法：

**问题**：当某些主机的延迟明显高于其他主机时，仅使用平均 RTT 可能会有问题。例如，如果您有 100 个主机，平均 RTT 为 40ms，但有 2 个主机的 RTT 为 234ms 和 240ms，使用 40ms 平均值可能会导致这些高延迟连接的性能问题。

**解决方案**：算法现在：
1. **计算所有响应主机的平均和最坏情况 RTT**
2. **比较两个值**并智能地选择适当的值
3. **当最坏 RTT 明显高于平均值时使用最坏 RTT**以确保所有连接都表现良好
4. **当最坏 RTT 接近平均值时使用平均 RTT**以避免过于保守的设置

**为什么这很重要**：根据 [Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17) 的说法，"特别是在入站整形时，最好使用您的典型 RTT 作为估计，以便在队列流入您正在击败的 ISP 整形器之前获得队列控制。" 然而，如果到任何主机的实际 RTT 比在 CAKE 接口上设置的 RTT 更长，性能可能会显著受损。

**实际示例**：
- 98 个主机，RTT 30-50ms（平均：42ms）
- 2 个主机，RTT 200ms+（最坏：234ms）
- **旧算法**：会使用 45ms 平均值，导致 200ms+ 主机出现问题
- **新算法**：使用 234ms 最坏 RTT，确保所有连接的最佳性能

### 连接流程示例

```
[主机/应用程序] → [接口上的 CAKE] → [互联网]
                            ↑
                      cake-autortt 监控
                      活动连接并
                      调整 RTT 参数
```

## 📊 预期行为

安装和启动后，您应该观察到：

### 即时效果
- 服务通过 systemd 自动启动并开始监控连接
- RTT 测量记录到系统日志（如果启用调试）
- CAKE qdisc RTT 参数每 30 秒根据测量的网络条件更新
- 高精度 RTT 值（例如 44.89ms）应用于 CAKE qdisc

### 长期好处
- **改善响应性**：RTT 参数与实际网络条件保持同步
- **更好的缓冲膨胀控制**：CAKE 可以对队列管理做出更明智的决策
- **自适应性能**：自动适应变化的网络条件（卫星、蜂窝、拥塞链路）
- **更高精度**：采样多达 20 个主机以更好地代表网络条件

### 监控

```bash
# 检查服务状态
sudo systemctl status cake-autortt

# 查看服务日志
sudo journalctl -u cake-autortt -f

# 监控 CAKE qdisc 参数
tc qdisc show | grep cake

# 详细日志记录的调试模式
sudo nano /etc/default/cake-autortt
# 设置 DEBUG=1，然后：
sudo systemctl restart cake-autortt
```

## 🔧 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查依赖项
   which ping tc
   
   # 检查 CAKE 接口
   tc qdisc show | grep cake
   
   # 检查服务日志
   sudo journalctl -u cake-autortt --no-pager
   ```

2. **没有 RTT 更新**
   ```bash
   # 启用调试模式
   sudo nano /etc/default/cake-autortt
   # 设置 DEBUG=1
   
   sudo systemctl restart cake-autortt
   
   # 检查日志
   sudo journalctl -u cake-autortt -f
   ```

3. **接口检测失败**
   ```bash
   # 在配置中手动指定接口
   sudo nano /etc/default/cake-autortt
   # 设置 DL_INTERFACE 和 UL_INTERFACE
   
   sudo systemctl restart cake-autortt
   ```

4. **找不到 CAKE qdisc**
   ```bash
   # 验证 CAKE 支持
   tc qdisc help | grep cake
   
   # 检查接口上是否配置了 CAKE
   tc qdisc show
   
   # 如果需要，配置 CAKE（见安装部分）
   ```

### 调试信息

启用调试（在 `/etc/default/cake-autortt` 中设置 `DEBUG=1`）后，服务提供详细的日志记录：

**调试输出示例：**
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
> **内存高效日志记录**：调试日志记录经过优化以防止日志泛滥。不记录单个主机 RTT 测量以减少内存使用和磁盘写入。只有摘要信息记录到 systemd 日志，使其适合连续操作而不会过度增长日志。

## 🔄 与 OpenWrt 版本的差异

这个 Ubuntu/Debian 移植版在几个关键方面与 OpenWrt 版本不同：

### 配置系统
- **OpenWrt**：使用 UCI 配置系统（`uci set`、`/etc/config/cake-autortt`）
- **Ubuntu/Debian**：使用传统配置文件（`/etc/default/cake-autortt`）

### 服务管理
- **OpenWrt**：使用 procd 和 OpenWrt init.d 脚本
- **Ubuntu/Debian**：使用 systemd 服务管理

### 接口监控
- **OpenWrt**：使用 hotplug.d 脚本处理接口事件
- **Ubuntu/Debian**：使用 udev 规则进行接口监控

### 包管理
- **OpenWrt**：使用 opkg 包管理器
- **Ubuntu/Debian**：使用 apt 包管理器

### 文件位置
- **OpenWrt**：使用 OpenWrt 特定路径（`/etc/config/`、`/etc/hotplug.d/`）
- **Ubuntu/Debian**：使用标准 Linux 路径（`/etc/default/`、`/etc/systemd/`、`/etc/udev/`）

## 📄 许可证

本项目根据 GNU 通用公共许可证 v2.0 许可 - 有关详细信息，请参阅 [LICENSE](../LICENSE) 文件。

## 🤝 贡献

欢迎贡献！请随时提交拉取请求。在为 Ubuntu/Debian 移植版贡献时，请确保与 Ubuntu LTS 版本和当前 Debian 稳定版的兼容性。