# cake-autortt

**Automatically adjust CAKE qdisc RTT parameter based on measured network conditions**

`cake-autortt` is an OpenWrt service that intelligently monitors active network connections and automatically adjusts the RTT (Round Trip Time) parameter of CAKE qdisc on both ingress and egress interfaces for optimal network performance.

## 🚀 Features

- **Automatic RTT Detection**: Monitors active connections via `/proc/net/nf_conntrack` and measures RTT to external hosts
- **Smart Host Filtering**: Automatically filters out LAN addresses and focuses on external hosts  
- **Efficient fping Integration**: Leverages fping's built-in averaging across multiple hosts for reliable RTT measurements
- **Interface Auto-Detection**: Automatically detects CAKE-enabled interfaces (prefers `ifb-*` for download, physical interfaces for upload)
- **OpenWrt Service Integration**: Runs as a proper OpenWrt service with automatic startup and process management
- **Configurable Parameters**: All timing and behavior parameters can be customized via UCI configuration
- **Robust Error Handling**: Gracefully handles missing dependencies, network issues, and interface changes
- **Simplified Dependencies**: Only requires fping and tc - no complex calculations or additional utilities needed
- **High Precision RTT**: Supports fractional RTT values (e.g., 100.23ms) for precise network timing adjustments

## 🔧 Compatibility

**Tested and Working:**
- **OpenWrt 24.10.1, r28597-0425664679, Target Platform x86/64**

**Expected Compatibility:**
- Previous OpenWrt versions (21.02+) with CAKE qdisc support
- Future OpenWrt releases as long as required dependencies are available
- All target architectures supported by OpenWrt (ARM, MIPS, x86, etc.)

**Requirements for Compatibility:**
- CAKE qdisc kernel module
- fping package availability in OpenWrt repositories
- Standard tc (traffic control) utilities
- /proc/net/nf_conntrack support (netfilter conntrack)

## 📋 Requirements

### Dependencies
- **fping**: Fast ping utility for measuring RTT to multiple hosts (provides built-in averaging)
- **tc**: Traffic control utility (part of iproute2)
- **CAKE qdisc**: Must be configured on target interfaces

### Installation of Dependencies

```bash
# Install required packages
opkg update
opkg install fping

# CAKE qdisc is typically available in modern OpenWrt versions
# Check if tc supports CAKE:
tc qdisc help | grep cake
```

## 🔧 Installation

### Quick Installation

1. **Run the installation script:**

```bash
# Make install script executable and run
chmod +x install.sh
./install.sh
```

### Manual Installation

1. **Copy the service files to your OpenWrt router:**

```bash
# Copy the main executable
cp usr/bin/cake-autortt /usr/bin/
chmod +x /usr/bin/cake-autortt

# Copy the init script
cp etc/init.d/cake-autortt /etc/init.d/
chmod +x /etc/init.d/cake-autortt

# Copy the configuration file
cp etc/config/cake-autortt /etc/config/

# Copy the hotplug script
cp etc/hotplug.d/iface/99-cake-autortt /etc/hotplug.d/iface/
chmod +x /etc/hotplug.d/iface/99-cake-autortt
```

2. **Enable and start the service:**

```bash
# Enable the service to start automatically on boot
/etc/init.d/cake-autortt enable

# Start the service
/etc/init.d/cake-autortt start
```

## 🗑️ Uninstallation

To remove cake-autortt from your system:

```bash
# Make uninstall script executable and run
chmod +x uninstall.sh
./uninstall.sh
```

The uninstall script will:
- Stop and disable the service
- Remove all installed files
- Optionally remove configuration and backup files
- Clean up temporary files

## ⚙️ Configuration

The service is configured through UCI. Edit `/etc/config/cake-autortt` or use the `uci` command:

```bash
# View current configuration
uci show cake-autortt

# Example configuration changes
uci set cake-autortt.global.rtt_update_interval='8'
uci set cake-autortt.global.debug='1'
uci set cake-autortt.global.dl_interface='ifb-wan'
uci set cake-autortt.global.ul_interface='wan'
uci commit cake-autortt

# Restart service to apply changes
/etc/init.d/cake-autortt restart
```

### Configuration Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `rtt_update_interval` | 5 | Seconds between qdisc RTT parameter updates |
| `min_hosts` | 3 | Minimum number of hosts required for RTT calculation |
| `max_hosts` | 100 | Maximum number of hosts to probe simultaneously |
| `rtt_margin_percent` | 10 | Safety margin added to measured RTT (percentage) |
| `default_rtt_ms` | 100 | Default RTT when insufficient hosts available |
| `dl_interface` | auto | Download interface (leave empty for auto-detection) |
| `ul_interface` | auto | Upload interface (leave empty for auto-detection) |
| `debug` | 0 | Enable debug logging (0=disabled, 1=enabled) |



## 🔍 How It Works

1. **Connection Monitoring**: Periodically parses `/proc/net/nf_conntrack` to identify active network connections
2. **Host Filtering**: Extracts destination IP addresses and filters out private/LAN addresses
3. **RTT Measurement**: Uses `fping -s` to measure RTT to a representative sample of external hosts
4. **Automatic Averaging**: fping automatically calculates average RTT across all responsive hosts
5. **Safety Margin**: Adds a configurable margin to the measured RTT to ensure adequate buffering
6. **qdisc Update**: Updates the CAKE qdisc RTT parameter on both download and upload interfaces



### Example Connection Flow

```
[LAN Device] → [Router with CAKE] → [Internet]
                       ↑
                 cake-autortt monitors
                 active connections and
                 adjusts RTT parameter
```

## 📊 Expected Behavior

After installation and startup, you should observe:

### Immediate Effects
- Service starts automatically and begins monitoring connections
- RTT measurements logged to system log (if debug enabled)
- CAKE qdisc RTT parameter updated every 5 seconds based on measured network conditions
- High precision RTT values (e.g., 44.89ms) applied to CAKE qdisc

### Long-term Benefits
- **Improved Responsiveness**: RTT parameter stays current with actual network conditions
- **Better Bufferbloat Control**: CAKE can make more informed decisions about queue management
- **Adaptive Performance**: Automatically adjusts to changing network conditions (satellite, cellular, congested links)
- **Higher Accuracy**: Samples up to 100 hosts for better representation of network conditions

### Monitoring

```bash
# Check service status
/etc/init.d/cake-autortt status

# View service logs
logread | grep cake-autortt

# Monitor CAKE qdisc parameters
tc qdisc show | grep cake

# Debug mode for detailed logging
uci set cake-autortt.global.debug='1'
uci commit cake-autortt
/etc/init.d/cake-autortt restart
```

## 🔧 Troubleshooting

### Common Issues

1. **Service won't start**
   ```bash
   # Check dependencies
   which fping tc
   
   # Check for CAKE interfaces
   tc qdisc show | grep cake
   ```

2. **No RTT updates**
   ```bash
   # Enable debug mode
   uci set cake-autortt.global.debug='1'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   
   # Check logs
   logread | grep cake-autortt
   ```

3. **Interface detection fails**
   ```bash
   # Manually specify interfaces
   uci set cake-autortt.global.dl_interface='ifb-wan'
   uci set cake-autortt.global.ul_interface='wan'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   ```

### Debug Information

With debug enabled (`uci set cake-autortt.global.debug='1'`), the service provides detailed logging:

**Example debug output:**
```bash
[2025-01-09 18:34:22] cake-autortt DEBUG: Extracting hosts from conntrack
[2025-01-09 18:34:22] cake-autortt DEBUG: Found 35 non-LAN hosts
[2025-01-09 18:34:22] cake-autortt DEBUG: Measuring RTT using fping for 35 hosts
[2025-01-09 18:34:25] cake-autortt DEBUG: fping summary: 28/35 hosts alive, avg RTT: 45.2ms
[2025-01-09 18:34:25] cake-autortt DEBUG: Average RTT from 28 hosts: 45.2ms
[2025-01-09 18:34:25] cake-autortt DEBUG: Using measured RTT: 45.2ms
[2025-01-09 18:34:35] cake-autortt INFO: Adjusting CAKE RTT to 49.72ms (49720us)
[2025-01-09 18:34:35] cake-autortt DEBUG: Updated RTT on download interface ifb-wan
[2025-01-09 18:34:35] cake-autortt DEBUG: Updated RTT on upload interface wan
```


## 📄 License

This project is licensed under the GNU General Public License v2.0 - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
