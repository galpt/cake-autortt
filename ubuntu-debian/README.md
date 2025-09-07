# cake-autortt for Ubuntu/Debian

**Automatically adjust CAKE qdisc RTT parameter based on measured network conditions**

This is the **Ubuntu/Debian port** of cake-autortt, adapted for standard Linux distributions that use systemd, apt package management, and traditional configuration files instead of OpenWrt's UCI system.

## 🌍 Why This Matters for Your Internet Experience

Most users are familiar with the fast loading times of major websites like YouTube, Netflix, and Google - these sites use Content Delivery Networks (CDNs) that place servers very close to users, typically resulting in response times under 50-100ms. However, the internet is much larger than these big platforms.

**When you browse beyond the major CDN-backed sites, you encounter a diverse world of servers:**
- **Local/Regional Services**: Small businesses, local news sites, community forums, and regional services often have servers within your country or region (10-50ms RTT)
- **International Content**: Specialized websites, academic resources, gaming servers, and niche services may be hosted continents away (100-500ms RTT)  
- **Remote Infrastructure**: Some services, particularly in developing regions or specialized applications, may have significantly higher latencies

**The CAKE RTT parameter controls how aggressively the queue management algorithm responds to congestion.** By default, CAKE uses a 100ms RTT assumption that works reasonably well for general internet traffic. However:

- **Too Low RTT Setting**: If CAKE thinks the network RTT is shorter than reality, it becomes too aggressive in dropping packets when queues build up, potentially reducing throughput for distant servers
- **Too High RTT Setting**: If CAKE thinks the network RTT is longer than reality, it becomes too conservative and allows larger queues to build up, creating unnecessary latency for nearby servers

**Real-World Impact Examples:**
- **Singapore User → German Server**: Without RTT adjustment, a user in Singapore accessing a German website (≈180ms RTT) might experience reduced throughput because CAKE's default 100ms setting causes premature packet drops
- **Rural US → Regional Server**: A user in rural US accessing a regional server (≈25ms RTT) might experience higher latency than necessary because CAKE's default 100ms setting allows queues to grow larger than needed
- **Gaming/Real-time Applications**: Applications sensitive to both latency and throughput benefit significantly from RTT tuning that matches actual network conditions

**How cake-autortt Helps:**
By automatically measuring the actual RTT to the servers you're communicating with and adjusting CAKE's parameters accordingly, you get:
- **Snappier response** when accessing nearby servers (shorter RTT → more aggressive queue management)
- **Better throughput** when accessing distant servers (longer RTT → more patient queue management)  
- **Optimal bufferbloat control** that adapts to real network conditions rather than assumptions

This is particularly valuable for users who regularly access diverse content sources, work with international services, or live in areas where internet traffic frequently traverses long distances.

## 🚀 Features

- **Automatic RTT Detection**: Monitors active connections via `/proc/net/nf_conntrack` and measures RTT to external hosts
- **Smart Host Filtering**: Automatically filters out LAN addresses and focuses on external hosts  
- **Sequential Ping Measurement**: Uses built-in ping command to measure RTT to each host individually (3 pings per host) for reliable measurements
- **Interface Auto-Detection**: Automatically detects CAKE-enabled interfaces
- **systemd Integration**: Runs as a proper systemd service with automatic startup and process management
- **Configurable Parameters**: All timing and behavior parameters can be customized via configuration file
- **Robust Error Handling**: Gracefully handles missing dependencies, network issues, and interface changes
- **Minimal Dependencies**: Only requires ping and tc - no additional packages needed, uses built-in utilities available on all systems
- **High Precision RTT**: Supports fractional RTT values (e.g., 100.23ms) for precise network timing adjustments

## 🔧 Compatibility

**Tested and Working:**
- **Ubuntu 20.04+ (Focal and later)**
- **Debian 10+ (Buster and later)**

**Expected Compatibility:**
- Any systemd-based Linux distribution with CAKE qdisc support
- Distributions with modern iproute2 package

**Requirements for Compatibility:**
- CAKE qdisc kernel module (available in Linux 4.19+)
- ping utility (included in all standard Linux distributions)
- systemd service management
- iproute2 with tc (traffic control) utilities
- /proc/net/nf_conntrack support (netfilter conntrack)

## 📋 Requirements

### Dependencies
- **ping**: Standard ping utility for measuring RTT (included in all Linux distributions)
- **tc**: Traffic control utility (part of iproute2)
- **CAKE qdisc**: Must be configured on target interfaces
- **systemd**: Service management
- **netfilter conntrack**: For connection tracking (/proc/net/nf_conntrack)

### Installation of Dependencies

```bash
# Install required packages
sudo apt update
sudo apt install iputils-ping iproute2

# Check if tc supports CAKE:
tc qdisc help | grep cake

# Verify conntrack is available
ls /proc/net/nf_conntrack
```

## 🔧 Installation

> [!IMPORTANT]  
> Before running the installation script, you MUST configure CAKE qdisc on your network interfaces and edit the configuration file to set the correct interface names for your system.

### Prerequisites: Configure CAKE qdisc

First, you need to set up CAKE qdisc on your network interfaces. This is typically done on your internet-facing interface:

```bash
# Example: Configure CAKE on your main interface
# Replace 'eth0' with your actual interface name
# Replace '100Mbit' with your actual bandwidth

# For simple setup (replace eth0 with your interface):
sudo tc qdisc add root dev eth0 cake bandwidth 100Mbit

# For more advanced setup with ingress shaping:
# Create ifb (intermediate functional block) interface for download shaping
sudo modprobe ifb
sudo ip link add name ifb0 type ifb
sudo ip link set dev ifb0 up

# Configure ingress redirection and CAKE
sudo tc qdisc add dev eth0 handle ffff: ingress
sudo tc filter add dev eth0 parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
sudo tc qdisc add root dev ifb0 cake bandwidth 500Mbit ingress

# Configure egress CAKE  
sudo tc qdisc add root dev eth0 cake bandwidth 50Mbit

# Verify CAKE is configured
tc qdisc show | grep cake
```

### Quick Installation

1. **Configure CAKE interfaces (see above section)**

2. **Edit the configuration file:**

```bash
# Edit the config file to match your interface names
nano etc/default/cake-autortt
```

3. **Configure your interface names:**

Update the `DL_INTERFACE` (download) and `UL_INTERFACE` (upload) settings to match your network setup:

```bash
# Example configurations for different setups:

# For simple setup (same interface for both directions):
DL_INTERFACE="eth0"
UL_INTERFACE="eth0"

# For advanced setup with ifb interface for download shaping:
DL_INTERFACE="ifb0"     # Download interface (ifb for ingress shaping)
UL_INTERFACE="eth0"     # Upload interface (physical interface)

# For custom interface names:
DL_INTERFACE="enp3s0"   # Your specific download interface
UL_INTERFACE="enp3s0"   # Your specific upload interface
```

**How to find your interface names:**
```bash
# List interfaces with CAKE qdisc
tc qdisc show | grep cake

# List all network interfaces
ip link show

# Check your main network interface
ip route | grep default
```

4. **Run the installation script:**

```bash
# Make install script executable and run
chmod +x install.sh
sudo ./install.sh
```

### Manual Installation

1. **Copy the service files to your system:**

```bash
# Copy the main executable
sudo cp usr/bin/cake-autortt /usr/bin/
sudo chmod +x /usr/bin/cake-autortt

# Copy the systemd service file
sudo cp etc/systemd/system/cake-autortt.service /etc/systemd/system/

# Copy the configuration file
sudo cp etc/default/cake-autortt /etc/default/

# Copy the udev rule for interface monitoring
sudo cp etc/udev/rules.d/99-cake-autortt.rules /etc/udev/rules.d/

# Reload systemd and udev
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```

2. **Enable and start the service:**

```bash
# Enable the service to start automatically on boot
sudo systemctl enable cake-autortt

# Start the service
sudo systemctl start cake-autortt
```

## 🗑️ Uninstallation

To remove cake-autortt from your system:

```bash
# Make uninstall script executable and run
chmod +x uninstall.sh
sudo ./uninstall.sh
```

The uninstall script will:
- Stop and disable the service
- Remove all installed files
- Optionally remove configuration and backup files
- Clean up temporary files

## ⚙️ Configuration

### 🔧 Interface Configuration (REQUIRED)

**The most critical configuration step is setting the correct interface names.** The service will not work properly without the correct interface names.

```bash
# View current configuration
cat /etc/default/cake-autortt

# Edit configuration
sudo nano /etc/default/cake-autortt

# Restart service to apply changes
sudo systemctl restart cake-autortt
```

The service is configured through `/etc/default/cake-autortt`. All parameters can be customized by editing this file.

### Configuration Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `DL_INTERFACE` | auto | Download interface name (e.g., 'eth0', 'ifb0') |
| `UL_INTERFACE` | auto | Upload interface name (e.g., 'eth0', 'enp3s0') |
| `RTT_UPDATE_INTERVAL` | 30 | Seconds between qdisc RTT parameter updates |
| `MIN_HOSTS` | 3 | Minimum number of hosts required for RTT calculation |
| `MAX_HOSTS` | 100 | Maximum number of hosts to probe simultaneously |
| `RTT_MARGIN_PERCENT` | 10 | Safety margin added to measured RTT (percentage) |
| `DEFAULT_RTT_MS` | 100 | Default RTT when insufficient hosts available |
| `DEBUG` | 0 | Enable debug logging (0=disabled, 1=enabled) |

> [!NOTE]  
> While the interface parameters have "auto" as default, auto-detection may not work reliably in all configurations. It is strongly recommended to explicitly set these values.

### Example Configuration

```bash
# /etc/default/cake-autortt

# Network interfaces (REQUIRED - adjust for your setup)
DL_INTERFACE="ifb0"      # Download interface
UL_INTERFACE="eth0"      # Upload interface

# Timing parameters
RTT_UPDATE_INTERVAL=30   # Update RTT every 30 seconds
MIN_HOSTS=3              # Need at least 3 hosts for measurement
MAX_HOSTS=100            # Sample up to 100 hosts
RTT_MARGIN_PERCENT=10    # Add 10% safety margin
DEFAULT_RTT_MS=100       # Fallback RTT value

# Debugging
DEBUG=0                  # Set to 1 for verbose logging
```

## 🔍 How It Works

1. **Connection Monitoring**: Periodically parses `/proc/net/nf_conntrack` to identify active network connections
2. **Host Filtering**: Extracts destination IP addresses and filters out private/LAN addresses
3. **RTT Measurement**: Uses `ping` to measure RTT to each external host individually (3 pings per host)
4. **Sequential Processing**: Pings hosts one by one to prevent network overload, then calculates average RTT across all responsive hosts
5. **Safety Margin**: Adds a configurable margin to the measured RTT to ensure adequate buffering
6. **qdisc Update**: Updates the CAKE qdisc RTT parameter on both download and upload interfaces

### Example Connection Flow

```
[Host/Application] → [CAKE on Interface] → [Internet]
                            ↑
                      cake-autortt monitors
                      active connections and
                      adjusts RTT parameter
```

## 📊 Expected Behavior

After installation and startup, you should observe:

### Immediate Effects
- Service starts automatically via systemd and begins monitoring connections
- RTT measurements logged to system journal (if debug enabled)
- CAKE qdisc RTT parameter updated every 30 seconds based on measured network conditions
- High precision RTT values (e.g., 44.89ms) applied to CAKE qdisc

### Long-term Benefits
- **Improved Responsiveness**: RTT parameter stays current with actual network conditions
- **Better Bufferbloat Control**: CAKE can make more informed decisions about queue management
- **Adaptive Performance**: Automatically adjusts to changing network conditions (satellite, cellular, congested links)
- **Higher Accuracy**: Samples up to 20 hosts for better representation of network conditions

### Monitoring

```bash
# Check service status
sudo systemctl status cake-autortt

# View service logs
sudo journalctl -u cake-autortt -f

# Monitor CAKE qdisc parameters
tc qdisc show | grep cake

# Debug mode for detailed logging
sudo nano /etc/default/cake-autortt
# Set DEBUG=1, then:
sudo systemctl restart cake-autortt
```

## 🔧 Troubleshooting

### Common Issues

1. **Service won't start**
   ```bash
   # Check dependencies
   which ping tc
   
   # Check for CAKE interfaces
   tc qdisc show | grep cake
   
   # Check service logs
   sudo journalctl -u cake-autortt --no-pager
   ```

2. **No RTT updates**
   ```bash
   # Enable debug mode
   sudo nano /etc/default/cake-autortt
   # Set DEBUG=1
   
   sudo systemctl restart cake-autortt
   
   # Check logs
   sudo journalctl -u cake-autortt -f
   ```

3. **Interface detection fails**
   ```bash
   # Manually specify interfaces in configuration
   sudo nano /etc/default/cake-autortt
   # Set DL_INTERFACE and UL_INTERFACE
   
   sudo systemctl restart cake-autortt
   ```

4. **CAKE qdisc not found**
   ```bash
   # Verify CAKE support
   tc qdisc help | grep cake
   
   # Check if CAKE is configured on interfaces
   tc qdisc show
   
   # Configure CAKE if needed (see installation section)
   ```

### Debug Information

With debug enabled (`DEBUG=1` in `/etc/default/cake-autortt`), the service provides detailed logging:

**Example debug output:**
```bash
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Extracting hosts from conntrack
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Found 35 non-LAN hosts
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Measuring RTT using ping for 35 hosts (3 pings each)
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: ping summary: 28/35 hosts alive
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: Average RTT from 28 hosts: 45.2ms
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: Using measured RTT: 45.2ms
Jan 09 18:34:35 hostname cake-autortt[1234]: INFO: Adjusting CAKE RTT to 49.72ms (49720us)
Jan 09 18:34:35 hostname cake-autortt[1234]: DEBUG: Updated RTT on download interface ifb0
Jan 09 18:34:35 hostname cake-autortt[1234]: DEBUG: Updated RTT on upload interface eth0
```

## 🔄 Differences from OpenWrt Version

This Ubuntu/Debian port differs from the OpenWrt version in several key ways:

### Configuration System
- **OpenWrt**: Uses UCI configuration system (`uci set`, `/etc/config/cake-autortt`)
- **Ubuntu/Debian**: Uses traditional config file (`/etc/default/cake-autortt`)

### Service Management
- **OpenWrt**: Uses procd and OpenWrt init.d scripts
- **Ubuntu/Debian**: Uses systemd service management

### Interface Monitoring
- **OpenWrt**: Uses hotplug.d scripts for interface events
- **Ubuntu/Debian**: Uses udev rules for interface monitoring

### Package Management
- **OpenWrt**: Uses opkg package manager
- **Ubuntu/Debian**: Uses apt package manager

### File Locations
- **OpenWrt**: Uses OpenWrt-specific paths (`/etc/config/`, `/etc/hotplug.d/`)
- **Ubuntu/Debian**: Uses standard Linux paths (`/etc/default/`, `/etc/systemd/`, `/etc/udev/`)

## 📄 License

This project is licensed under the GNU General Public License v2.0 - see the [LICENSE](../LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. When contributing to the Ubuntu/Debian port, please ensure compatibility with both Ubuntu LTS versions and current Debian stable.