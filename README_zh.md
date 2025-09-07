# cake-autortt

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | **中文** | [Bahasa Indonesia](README_id.md) | [Русский](README_ru.md) | [日本語](README_ja.md) | [Tiếng Việt](README_vi.md) | [Türkçe](README_tr.md) | [العربية](README_ar.md)

---

> [!NOTE]  
> 如果您正在寻找 **Ubuntu/Debian 版本**，请查看 `ubuntu-debian/` 文件夹。但是，请注意只有 OpenWrt 版本经过了日常个人测试 - Ubuntu/Debian 移植版本是为社区提供的现状版本。

**根据测量的网络条件自动调整 CAKE qdisc RTT 参数**

`cake-autortt` 是一个 OpenWrt 服务，它智能地监控活跃的网络连接，并自动调整入站和出站接口上 CAKE qdisc 的 RTT（往返时间）参数，以获得最佳网络性能。

## 🌍 为什么这对您的互联网体验很重要

大多数用户都熟悉 YouTube、Netflix 和 Google 等主要网站的快速加载时间 - 这些网站使用内容分发网络（CDN），将服务器放置在非常接近用户的位置，通常响应时间在 50-100ms 以下。然而，互联网远比这些大平台更广阔。

**当您浏览超出主要 CDN 支持的网站时，您会遇到多样化的服务器世界：**
- **本地/区域服务**：小企业、本地新闻网站、社区论坛和区域服务通常在您的国家或地区内有服务器（10-50ms RTT）
- **国际内容**：专业网站、学术资源、游戏服务器和小众服务可能托管在大洲之外（100-500ms RTT）
- **远程基础设施**：一些服务，特别是在发展中地区或专业应用中，可能有显著更高的延迟

**CAKE RTT 参数控制队列管理算法对拥塞的响应积极程度。** 默认情况下，CAKE 使用 100ms RTT 假设，这对一般互联网流量工作得相当好。然而：

- **RTT 设置过低**：如果 CAKE 认为网络 RTT 比实际更短，它在队列建立时会过于积极地丢弃数据包，可能会降低远程服务器的吞吐量
- **RTT 设置过高**：如果 CAKE 认为网络 RTT 比实际更长，它会过于保守，允许更大的队列建立，为附近的服务器创造不必要的延迟

**实际影响示例：**
- **新加坡用户 → 德国服务器**：没有 RTT 调整，新加坡用户访问德国网站（≈180ms RTT）可能会遇到吞吐量降低，因为 CAKE 的默认 100ms 设置导致过早的数据包丢弃
- **美国农村 → 区域服务器**：美国农村用户访问区域服务器（≈25ms RTT）可能会遇到比必要更高的延迟，因为 CAKE 的默认 100ms 设置允许队列增长得比需要的更大
- **游戏/实时应用**：对延迟和吞吐量都敏感的应用从匹配实际网络条件的 RTT 调优中显著受益

**cake-autortt 如何帮助：**
通过自动测量您正在通信的服务器的实际 RTT 并相应调整 CAKE 的参数，您可以获得：
- **更快的响应**当访问附近服务器时（更短的 RTT → 更积极的队列管理）
- **更好的吞吐量**当访问远程服务器时（更长的 RTT → 更耐心的队列管理）
- **最佳的缓冲膨胀控制**适应真实网络条件而不是假设

这对于经常访问多样化内容源、与国际服务合作或生活在互联网流量经常穿越长距离的地区的用户特别有价值。

## 🚀 功能特性

- **自动 RTT 检测**：通过 `/proc/net/nf_conntrack` 监控活跃连接并测量到外部主机的 RTT
- **智能主机过滤**：自动过滤掉 LAN 地址并专注于外部主机
- **智能 RTT 算法**：使用内置 ping 命令单独测量每个主机的 RTT（每个主机 3 次 ping），然后智能地在平均和最坏情况 RTT 之间选择以获得最佳性能
- **接口自动检测**：自动检测启用 CAKE 的接口（下载优先选择 `ifb-*`，上传选择物理接口）
- **OpenWrt 服务集成**：作为适当的 OpenWrt 服务运行，具有自动启动和进程管理
- **可配置参数**：所有时间和行为参数都可以通过 UCI 配置自定义
- **强大的错误处理**：优雅地处理缺失的依赖项、网络问题和接口更改
- **最小依赖**：只需要 ping 和 tc - 不需要额外的包，使用所有系统上可用的内置实用程序
- **高精度 RTT**：支持分数 RTT 值（例如，100.23ms）以进行精确的网络时间调整

## 🔧 兼容性

**已测试和工作：**
- **OpenWrt 24.10.1, r28597-0425664679, 目标平台 x86/64**

**预期兼容性：**
- 支持 CAKE qdisc 的以前的 OpenWrt 版本（21.02+）
- 只要所需依赖项可用的未来 OpenWrt 版本
- OpenWrt 支持的所有目标架构（ARM、MIPS、x86 等）

**兼容性要求：**
- CAKE qdisc 内核模块
- ping 实用程序（包含在所有标准 Linux 发行版中）
- 标准 tc（流量控制）实用程序
- /proc/net/nf_conntrack 支持（netfilter conntrack）

## 📋 要求

### 依赖项
- **ping**：用于测量 RTT 的标准 ping 实用程序（包含在所有 Linux 发行版中）
- **tc**：流量控制实用程序（iproute2 的一部分）
- **CAKE qdisc**：必须在目标接口上配置

### 依赖项安装

```bash
# ping 默认包含在 OpenWrt 中
# ping 功能不需要额外的包

# CAKE qdisc 通常在现代 OpenWrt 版本中可用
# 检查 tc 是否支持 CAKE：
tc qdisc help | grep cake
```

## 🔧 安装

> [!IMPORTANT]  
> 在运行安装脚本之前，您必须编辑配置文件以为您的系统设置正确的接口名称。

1. **编辑配置文件：**

```bash
# 编辑配置文件以匹配您的接口名称
nano etc/config/cake-autortt
```

2. **配置您的接口名称：**

更新 `dl_interface`（下载）和 `ul_interface`（上传）设置以匹配您的网络设置：

```bash
# 不同设置的示例配置：

# 对于使用 ifb 接口的典型 OpenWrt SQM 设置：
option dl_interface 'ifb-wan'      # 下载接口（通常是 ifb-*）
option ul_interface 'wan'          # 上传接口（通常是 wan、eth0 等）

# 对于直接接口设置：
option dl_interface 'eth0'         # 您的 WAN 接口
option ul_interface 'eth0'         # 两个方向使用相同接口

# 对于自定义接口名称：
option dl_interface 'ifb4eth1'     # 您的特定下载接口
option ul_interface 'eth1'         # 您的特定上传接口
```

**如何找到您的接口名称：**
```bash
# 列出带有 CAKE qdisc 的接口
tc qdisc show | grep cake

# 列出所有网络接口
ip link show

# 检查 SQM 接口配置（如果使用 SQM）
uci show sqm
```

### 快速安装

1. **配置接口（见上面部分）**

2. **运行安装脚本：**

```bash
# 使安装脚本可执行并运行
chmod +x install.sh
./install.sh
```

### 手动安装

1. **将服务文件复制到您的 OpenWrt 路由器：**

```bash
# 复制主要可执行文件
cp usr/bin/cake-autortt /usr/bin/
chmod +x /usr/bin/cake-autortt

# 复制初始化脚本
cp etc/init.d/cake-autortt /etc/init.d/
chmod +x /etc/init.d/cake-autortt

# 复制配置文件
cp etc/config/cake-autortt /etc/config/

# 复制热插拔脚本
cp etc/hotplug.d/iface/99-cake-autortt /etc/hotplug.d/iface/
chmod +x /etc/hotplug.d/iface/99-cake-autortt
```

2. **启用并启动服务：**

```bash
# 启用服务以在启动时自动启动
/etc/init.d/cake-autortt enable

# 启动服务
/etc/init.d/cake-autortt start
```

## 🗑️ 卸载

要从您的系统中删除 cake-autortt：

```bash
# 使卸载脚本可执行并运行
chmod +x uninstall.sh
./uninstall.sh
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
uci show cake-autortt

# 必需：设置您的接口名称
uci set cake-autortt.global.dl_interface='your-download-interface'
uci set cake-autortt.global.ul_interface='your-upload-interface'
uci commit cake-autortt

# 其他可选配置更改
uci set cake-autortt.global.rtt_update_interval='5'
uci set cake-autortt.global.debug='1'
uci commit cake-autortt

# 重启服务以应用更改
/etc/init.d/cake-autortt restart
```

服务通过 UCI 配置。编辑 `/etc/config/cake-autortt` 或使用 `uci` 命令。

### 配置参数

| 参数 | 默认值 | 描述 |
|-----------|---------|-------------|
| `dl_interface` | auto | 下载接口名称（例如，'ifb-wan'、'ifb4eth1'）|
| `ul_interface` | auto | 上传接口名称（例如，'wan'、'eth1'）|
| `rtt_update_interval` | 5 | qdisc RTT 参数更新之间的秒数 |
| `min_hosts` | 3 | RTT 计算所需的最少主机数 |
| `max_hosts` | 100 | 顺序探测的最大主机数 |
| `rtt_margin_percent` | 10 | 添加到测量 RTT 的安全边际（百分比）|
| `default_rtt_ms` | 100 | 可用主机不足时的默认 RTT |
| `debug` | 0 | 启用调试日志记录（0=禁用，1=启用）|

> [!NOTE]  
> 虽然接口参数的默认值为"auto"，但自动检测在所有配置中可能无法可靠工作。强烈建议明确设置这些值。

> [!TIP]  
> 对于高活动网络（例如，大学校园、有许多活跃用户的公共网络），考虑根据您网络的特性调整 `rtt_update_interval`。默认的 5 秒适用于大多数场景，但您可以将其增加到 10-15 秒用于更稳定的网络，或减少到 3 秒用于非常动态的环境。

## 🔍 工作原理

1. **连接监控**：定期解析 `/proc/net/nf_conntrack` 以识别活跃的网络连接
2. **主机过滤**：提取目标 IP 地址并过滤掉私有/LAN 地址
3. **RTT 测量**：使用 `ping` 单独测量每个外部主机的 RTT（每个主机 3 次 ping）
4. **智能 RTT 选择**：逐个 ping 主机以防止网络过载，计算平均和最坏情况 RTT，然后使用较高的值以确保所有连接的最佳性能
5. **安全边际**：为测量的 RTT 添加可配置的边际以确保足够的缓冲
6. **qdisc 更新**：更新下载和上传接口上的 CAKE qdisc RTT 参数

### 🧠 智能 RTT 算法

从版本 1.2.0 开始，cake-autortt 基于 Dave Täht（CAKE 的共同作者）的建议实现了智能 RTT 选择算法：

**问题**：当某些主机的延迟明显高于其他主机时，仅使用平均 RTT 可能会有问题。例如，如果您有 100 个主机，平均 RTT 为 40ms，但有 2 个主机的 RTT 为 234ms 和 240ms，使用 40ms 平均值可能会导致这些高延迟连接的性能问题。

**解决方案**：算法现在：
1. **计算所有响应主机的平均和最坏情况 RTT**
2. **比较两个值**并智能地选择适当的一个
3. **当最坏 RTT 明显高于平均值时使用最坏 RTT**以确保所有连接都表现良好
4. **当最坏 RTT 接近平均值时使用平均 RTT**以避免过于保守的设置

**为什么这很重要**：根据 [Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17) 的说法，"特别是在入站整形时，最好使用您的典型 RTT 作为估计，以便在队列流入您正在击败的 ISP 整形器之前获得队列控制。"然而，如果到任何主机的实际 RTT 比在 CAKE 接口上设置的 RTT 更长，性能可能会显著受损。

**实际示例**：
- 98 个主机，RTT 30-50ms（平均：42ms）
- 2 个主机，RTT 200ms+（最坏：234ms）
- **旧算法**：会使用 45ms 平均值，导致 200ms+ 主机出现问题
- **新算法**：使用 234ms 最坏 RTT，确保所有连接的最佳性能

### 示例连接流程

```
[LAN 设备] → [带 CAKE 的路由器] → [互联网]
                       ↑
                 cake-autortt 监控
                 活跃连接并
                 调整 RTT 参数
```

## 📊 预期行为

安装和启动后，您应该观察到：

### 立即效果
- 服务自动启动并开始监控连接
- RTT 测量记录到系统日志（如果启用调试）
- 基于测量的网络条件每 5 秒更新一次 CAKE qdisc RTT 参数
- 高精度 RTT 值（例如，44.89ms）应用于 CAKE qdisc

### 长期好处
- **改善的响应性**：RTT 参数与实际网络条件保持同步
- **更好的缓冲膨胀控制**：CAKE 可以对队列管理做出更明智的决策
- **自适应性能**：自动适应变化的网络条件（卫星、蜂窝、拥塞链路）
- **更高的准确性**：采样多达 100 个主机（可配置）以更好地代表网络条件

### 监控

```bash
# 检查服务状态
/etc/init.d/cake-autortt status

# 查看服务日志
logread | grep cake-autortt

# 监控 CAKE qdisc 参数
tc qdisc show | grep cake

# 详细日志记录的调试模式
uci set cake-autortt.global.debug='1'
uci commit cake-autortt
/etc/init.d/cake-autortt restart
```

## 🔧 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查依赖项
   which ping tc
   
   # 检查 CAKE 接口
   tc qdisc show | grep cake
   ```

2. **没有 RTT 更新**
   ```bash
   # 启用调试模式
   uci set cake-autortt.global.debug='1'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   
   # 检查日志
   logread | grep cake-autortt
   ```

3. **接口检测失败**
   ```bash
   # 手动指定接口
   uci set cake-autortt.global.dl_interface='ifb-wan'
   uci set cake-autortt.global.ul_interface='wan'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   ```

### 调试信息

启用调试（`uci set cake-autortt.global.debug='1'`）后，服务提供详细的日志记录：

**示例调试输出：**
```bash
[2025-01-09 18:34:22] cake-autortt DEBUG: 从 conntrack 提取主机
[2025-01-09 18:34:22] cake-autortt DEBUG: 找到 35 个非 LAN 主机
[2025-01-09 18:34:22] cake-autortt DEBUG: 使用 ping 测量 35 个主机的 RTT（每个 3 次 ping）
[2025-01-09 18:34:25] cake-autortt DEBUG: ping 摘要：28/35 个主机存活
[2025-01-09 18:34:25] cake-autortt DEBUG: 使用平均 RTT：45.2ms（平均：45.2ms，最坏：89.1ms）
[2025-01-09 18:34:25] cake-autortt DEBUG: 使用测量的 RTT：45.2ms
[2025-01-09 18:34:35] cake-autortt INFO: 将 CAKE RTT 调整为 49.72ms（49720us）
[2025-01-09 18:34:35] cake-autortt DEBUG: 在下载接口 ifb-wan 上更新了 RTT
[2025-01-09 18:34:35] cake-autortt DEBUG: 在上传接口 wan 上更新了 RTT
```

> [!NOTE]  
> **内存高效日志记录**：调试日志记录经过优化以防止日志泛滥。不记录单个主机 RTT 测量以减少内存使用和磁盘写入。只记录摘要信息，使其适合连续操作而不会过度增长日志。

## 📄 许可证

此项目根据 GNU 通用公共许可证 v2.0 许可 - 有关详细信息，请参阅 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎贡献！请随时提交拉取请求。