# cake-autortt

**Automatically adjust CAKE qdisc RTT parameter based on measured network conditions**

`cake-autortt` is an OpenWrt service that intelligently monitors active network connections and automatically adjusts the RTT (Round Trip Time) parameter of CAKE qdisc on both ingress and egress interfaces for optimal network performance.

## 🚀 Features

- **Automatic RTT Detection**: Monitors active connections via `/proc/net/nf_conntrack` and measures RTT to external hosts
- **Smart Host Filtering**: Automatically filters out LAN addresses and focuses on external hosts
- **EWMA Smoothing**: Uses Exponential Weighted Moving Average to smooth RTT measurements and avoid unnecessary adjustments
- **Interface Auto-Detection**: Automatically detects CAKE-enabled interfaces (prefers `ifb-*` for download, physical interfaces for upload)
- **OpenWrt Service Integration**: Runs as a proper OpenWrt service with automatic startup and process management
- **Configurable Parameters**: All timing and behavior parameters can be customized via UCI configuration
- **Robust Error Handling**: Gracefully handles missing dependencies, network issues, and interface changes

## 📋 Requirements

### Dependencies
- **fping**: Fast ping utility for measuring RTT to multiple hosts
- **bc**: Calculator utility for floating-point arithmetic
- **tc**: Traffic control utility (part of iproute2)
- **CAKE qdisc**: Must be configured on target interfaces

### Installation of Dependencies

```bash
# Install required packages
opkg update
opkg install fping bc

# CAKE qdisc is typically available in modern OpenWrt versions
# Check if tc supports CAKE:
tc qdisc help | grep cake
```

## 🔧 Installation

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

## ⚙️ Configuration

The service is configured through UCI. Edit `/etc/config/cake-autortt` or use the `uci` command:

```bash
# View current configuration
uci show cake-autortt

# Example configuration changes
uci set cake-autortt.global.probe_interval='10'
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
| `probe_interval` | 5 | Seconds between RTT probe cycles |
| `rtt_update_interval` | 30 | Seconds between qdisc RTT parameter updates |
| `ewma_alpha` | 0.1 | EWMA smoothing factor (0.01-0.9) |
| `min_hosts` | 3 | Minimum number of hosts required for RTT calculation |
| `max_hosts` | 20 | Maximum number of hosts to probe simultaneously |
| `rtt_margin_percent` | 10 | Safety margin added to measured RTT (percentage) |
| `default_rtt_ms` | 100 | Default RTT when insufficient hosts available |
| `dl_interface` | auto | Download interface (leave empty for auto-detection) |
| `ul_interface` | auto | Upload interface (leave empty for auto-detection) |
| `debug` | 0 | Enable debug logging (0=disabled, 1=enabled) |

## 🔍 How It Works

1. **Connection Monitoring**: Periodically parses `/proc/net/nf_conntrack` to identify active network connections
2. **Host Filtering**: Extracts destination IP addresses and filters out private/LAN addresses
3. **RTT Measurement**: Uses `fping` to measure RTT to a representative sample of external hosts
4. **EWMA Smoothing**: Applies exponential weighted moving average to smooth RTT measurements
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
- CAKE qdisc RTT parameter updated based on measured network conditions

### Long-term Benefits
- **Improved Responsiveness**: RTT parameter stays current with actual network conditions
- **Better Bufferbloat Control**: CAKE can make more informed decisions about queue management
- **Adaptive Performance**: Automatically adjusts to changing network conditions (satellite, cellular, congested links)

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
   which fping bc tc
   
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
[2025-06-19 18:34:22] cake-autortt DEBUG: Extracting hosts from conntrack
[2025-06-19 18:34:22] cake-autortt DEBUG: Found 20 non-LAN hosts
[2025-06-19 18:34:22] cake-autortt DEBUG: Measuring RTT using fping for 20 hosts
[2025-06-19 18:34:25] cake-autortt DEBUG: fping summary: 15/20 hosts alive, avg RTT: 45.2ms
[2025-06-19 18:34:25] cake-autortt DEBUG: Average RTT from 15 hosts: 45.2ms
[2025-06-19 18:34:25] cake-autortt DEBUG: RTT EWMA updated: 47.8ms
[2025-06-19 18:34:55] cake-autortt INFO: Adjusting CAKE RTT to 53ms (53000us)
[2025-06-19 18:34:55] cake-autortt DEBUG: Updated RTT on download interface ifb-wan
[2025-06-19 18:34:55] cake-autortt DEBUG: Updated RTT on upload interface wan
```

**Debug information includes:**
- **Connection monitoring**: Number of active external connections found
- **Host discovery**: Count of non-LAN hosts extracted from conntrack
- **RTT measurements**: Summary from fping including alive/total hosts and average RTT
- **EWMA smoothing**: Updated exponential weighted moving average values
- **Interface operations**: Success/failure of qdisc RTT parameter updates
- **Timing information**: When measurements and updates occur

**Fallback scenarios:**
```bash
# When insufficient hosts respond
[2025-06-19 18:35:22] cake-autortt DEBUG: Not enough responding hosts (2 < 3)
[2025-06-19 18:35:22] cake-autortt DEBUG: RTT measurement failed, using default RTT
[2025-06-19 18:35:52] cake-autortt INFO: Adjusting CAKE RTT to 100ms (100000us)

# When no external connections found
[2025-06-19 18:36:22] cake-autortt DEBUG: Found 0 non-LAN hosts
[2025-06-19 18:36:22] cake-autortt DEBUG: No hosts to probe
```

## 🤝 Integration with Other Systems

### SQM Integration
`cake-autortt` works alongside SQM (Smart Queue Management) scripts. Ensure CAKE is configured on your interfaces.

### Compatible with cake-autorate
Can be used alongside `cake-autorate` for comprehensive CAKE optimization:
- `cake-autorate`: Adjusts bandwidth based on load and latency
- `cake-autortt`: Adjusts RTT parameter based on measured network conditions

## 📝 Advanced Usage

### Custom Probe Intervals
For high-latency links (satellite):
```bash
uci set cake-autortt.global.probe_interval='15'
uci set cake-autortt.global.rtt_update_interval='60'
uci set cake-autortt.global.rtt_margin_percent='20'
```

### Conservative Settings
For stable connections:
```bash
uci set cake-autortt.global.ewma_alpha='0.05'
uci set cake-autortt.global.min_hosts='5'
```

### Aggressive Tracking
For rapidly changing conditions:
```bash
uci set cake-autortt.global.ewma_alpha='0.3'
uci set cake-autortt.global.probe_interval='3'
```

## 🤝 Contributing

We welcome contributions to improve cake-autortt! Here's how you can help:

### How to Contribute

1. **Fork the Repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/yourusername/cake-autortt.git
   cd cake-autortt
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-improvement
   ```

3. **Make Your Changes**
   - Fix bugs or add new features
   - Test thoroughly on OpenWrt hardware
   - Follow the existing code style
   - Add appropriate logging/debug messages

4. **Test Your Changes**
   ```bash
   # Test installation
   ./install.sh
   
   # Enable debug mode and monitor
   uci set cake-autortt.global.debug='1'
   uci commit cake-autortt
   /etc/init.d/cake-autortt restart
   logread | grep cake-autortt
   ```

5. **Submit a Pull Request**
   - Describe your changes clearly
   - Include testing details
   - Reference any related issues

### Areas for Improvement

We're particularly interested in contributions for:

- **IPv6 Support**: Extending conntrack parsing and fping usage for IPv6
- **Alternative RTT Sources**: Support for other ping utilities or measurement methods  
- **Enhanced Filtering**: Better logic for selecting optimal hosts to probe
- **Performance Optimization**: Reducing CPU usage and memory footprint
- **Configuration UI**: Web interface integration for easier configuration
- **Documentation**: Better examples, troubleshooting guides, and use cases
- **Testing**: Automated tests and validation on different OpenWrt versions

### Bug Reports

If you encounter issues:

1. Enable debug mode: `uci set cake-autortt.global.debug='1'`
2. Collect logs: `logread | grep cake-autortt > cake-autortt.log`
3. Include your configuration: `uci show cake-autortt`
4. Describe your network setup and OpenWrt version
5. Open an issue with all relevant information

### Code Style

- Use POSIX shell scripting (no bashisms)
- Follow existing indentation and naming conventions
- Add comments for complex logic
- Use descriptive variable names
- Include error handling and logging

## 📄 License

This project is released under the same license terms as the reference projects it's based on. See individual source files for specific license information.

## 🙏 Acknowledgments

This project was inspired by and learned from:
- [cake-autorate](https://github.com/lynxthecat/cake-autorate) - For RTT measurement techniques and service patterns
- [dscpclassify](https://github.com/jeverley/dscpclassify) - For OpenWrt service integration patterns
