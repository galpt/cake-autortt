#!/bin/bash

# cake-autortt Installation Script for Ubuntu/Debian
# This script installs cake-autortt service on Ubuntu/Debian systems

set -e

SCRIPT_DIR="$(dirname "$0")"
INSTALL_ROOT="${INSTALL_ROOT:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_os() {
    if [ ! -f /etc/os-release ]; then
        log_error "Cannot determine OS. This script is for Ubuntu/Debian systems."
        exit 1
    fi
    
    # Source the os-release file
    . /etc/os-release
    
    case "$ID" in
        ubuntu|debian)
            log_info "Detected $PRETTY_NAME"
            ;;
        *)
            log_warn "Unsupported OS: $PRETTY_NAME"
            log_warn "This script is designed for Ubuntu/Debian. Proceeding anyway..."
            ;;
    esac
}

check_systemd() {
    if ! command -v systemctl >/dev/null 2>&1; then
        log_error "systemd is required but not found"
        log_error "This script is designed for systemd-based distributions"
        exit 1
    fi
    
    if ! systemctl --version >/dev/null 2>&1; then
        log_error "systemd is not running or not properly configured"
        exit 1
    fi
}

check_dependencies() {
    log_step "Checking dependencies..."
    
    # Check for required commands
    local missing_deps=""
    local missing_packages=""
    
    if ! command -v fping >/dev/null 2>&1; then
        missing_deps="$missing_deps fping"
        missing_packages="$missing_packages fping"
    fi
    
    if ! command -v tc >/dev/null 2>&1; then
        missing_deps="$missing_deps tc"
        missing_packages="$missing_packages iproute2"
    fi
    
    if [ -n "$missing_deps" ]; then
        log_warn "Missing dependencies:$missing_deps"
        log_info "Required packages:$missing_packages"
        
        read -p "Would you like to install missing dependencies now? (Y/n): " install_deps
        if [ "$install_deps" != "n" ] && [ "$install_deps" != "N" ]; then
            log_info "Updating package list..."
            apt update
            
            log_info "Installing dependencies..."
            # shellcheck disable=SC2086
            apt install -y $missing_packages
        else
            log_error "Cannot proceed without required dependencies"
            exit 1
        fi
    fi
    
    # Check for CAKE support
    if ! tc qdisc help 2>/dev/null | grep -q cake; then
        log_warn "CAKE qdisc support not detected in tc"
        log_warn "Your kernel may not support CAKE or iproute2 is too old"
        log_warn "Ubuntu 20.04+ and Debian 10+ should have CAKE support"
    fi
    
    # Check for conntrack
    if [ ! -f "/proc/net/nf_conntrack" ]; then
        log_warn "Connection tracking not available at /proc/net/nf_conntrack"
        log_warn "You may need to load the nf_conntrack module: modprobe nf_conntrack"
    fi
    
    log_info "Dependencies check completed"
}

check_cake_interfaces() {
    log_step "Checking for CAKE interfaces..."
    
    local cake_interfaces
    cake_interfaces=$(tc qdisc show 2>/dev/null | grep "qdisc cake" | awk '{print $5}' || true)
    
    if [ -z "$cake_interfaces" ]; then
        log_warn "No CAKE interfaces found"
        log_warn "You need to configure CAKE qdisc on your interfaces before starting the service"
        echo
        log_info "Example CAKE configuration:"
        echo "  # Simple setup:"
        echo "  sudo tc qdisc add root dev eth0 cake bandwidth 100Mbit"
        echo
        echo "  # Advanced setup with ingress shaping:"
        echo "  sudo modprobe ifb"
        echo "  sudo ip link add name ifb0 type ifb"
        echo "  sudo ip link set dev ifb0 up"
        echo "  sudo tc qdisc add dev eth0 handle ffff: ingress"
        echo "  sudo tc filter add dev eth0 parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0"
        echo "  sudo tc qdisc add root dev ifb0 cake bandwidth 500Mbit ingress"
        echo "  sudo tc qdisc add root dev eth0 cake bandwidth 50Mbit"
        echo
        return 1
    else
        log_info "Found CAKE interfaces: $(echo $cake_interfaces | tr '\n' ' ')"
        return 0
    fi
}

backup_existing() {
    local file="$1"
    if [ -f "$file" ]; then
        log_warn "Backing up existing file: $file -> $file.bak"
        cp "$file" "$file.bak"
    fi
}

install_files() {
    log_step "Installing cake-autortt files..."
    
    # Create directories if they don't exist
    mkdir -p "${INSTALL_ROOT}/usr/bin"
    mkdir -p "${INSTALL_ROOT}/etc/systemd/system"
    mkdir -p "${INSTALL_ROOT}/etc/default"
    mkdir -p "${INSTALL_ROOT}/etc/udev/rules.d"
    
    # Backup existing files
    backup_existing "${INSTALL_ROOT}/usr/bin/cake-autortt"
    backup_existing "${INSTALL_ROOT}/etc/systemd/system/cake-autortt.service"
    backup_existing "${INSTALL_ROOT}/etc/default/cake-autortt"
    backup_existing "${INSTALL_ROOT}/etc/udev/rules.d/99-cake-autortt.rules"
    
    # Copy files
    log_info "Copying executable..."
    cp "$SCRIPT_DIR/usr/bin/cake-autortt" "${INSTALL_ROOT}/usr/bin/"
    chmod +x "${INSTALL_ROOT}/usr/bin/cake-autortt"
    
    log_info "Copying systemd service..."
    cp "$SCRIPT_DIR/etc/systemd/system/cake-autortt.service" "${INSTALL_ROOT}/etc/systemd/system/"
    
    log_info "Copying configuration..."
    if [ ! -f "${INSTALL_ROOT}/etc/default/cake-autortt" ]; then
        cp "$SCRIPT_DIR/etc/default/cake-autortt" "${INSTALL_ROOT}/etc/default/"
    else
        log_warn "Configuration file already exists, skipping (backup created)"
    fi
    
    log_info "Copying udev rule..."
    cp "$SCRIPT_DIR/etc/udev/rules.d/99-cake-autortt.rules" "${INSTALL_ROOT}/etc/udev/rules.d/"
    
    # Reload systemd and udev
    if [ -z "$INSTALL_ROOT" ]; then
        log_info "Reloading systemd daemon..."
        systemctl daemon-reload
        
        log_info "Reloading udev rules..."
        udevadm control --reload-rules
    fi
    
    log_info "Files installed successfully"
}

configure_interfaces() {
    log_step "Configuring interfaces..."
    
    local config_file="${INSTALL_ROOT}/etc/default/cake-autortt"
    
    # Try to auto-detect CAKE interfaces
    local cake_interfaces
    cake_interfaces=$(tc qdisc show 2>/dev/null | grep "qdisc cake" | awk '{print $5}' | head -2 || true)
    
    if [ -n "$cake_interfaces" ]; then
        local dl_interface ul_interface
        
        # Try to detect download interface (typically ifb-* or similar)
        dl_interface=$(echo "$cake_interfaces" | grep "ifb" | head -1 || true)
        [ -z "$dl_interface" ] && dl_interface=$(echo "$cake_interfaces" | head -1)
        
        # Try to detect upload interface (typically physical interface)
        ul_interface=$(echo "$cake_interfaces" | grep -v "ifb" | head -1 || true)
        [ -z "$ul_interface" ] && ul_interface=$(echo "$cake_interfaces" | tail -1)
        
        log_info "Auto-detected interfaces: DL=$dl_interface UL=$ul_interface"
        
        # Ask user if they want to use auto-detected interfaces
        echo
        echo "Auto-detected interface configuration:"
        echo "  Download interface: $dl_interface"
        echo "  Upload interface: $ul_interface"
        echo
        read -p "Use these interfaces? (Y/n): " use_auto
        
        if [ "$use_auto" != "n" ] && [ "$use_auto" != "N" ]; then
            # Update configuration file
            sed -i "s/^DL_INTERFACE=.*/DL_INTERFACE=\"$dl_interface\"/" "$config_file"
            sed -i "s/^UL_INTERFACE=.*/UL_INTERFACE=\"$ul_interface\"/" "$config_file"
            log_info "Configuration updated with auto-detected interfaces"
        else
            log_warn "Please manually edit $config_file to set your interfaces"
        fi
    else
        log_warn "No CAKE interfaces found for auto-detection"
        log_warn "Please configure CAKE qdisc first, then edit $config_file"
    fi
}

enable_service() {
    log_step "Enabling cake-autortt service..."
    
    if [ -z "$INSTALL_ROOT" ]; then
        # Real system installation
        systemctl enable cake-autortt.service
        log_info "Service enabled for automatic startup"
        
        echo
        read -p "Would you like to start the service now? (Y/n): " start_now
        if [ "$start_now" != "n" ] && [ "$start_now" != "N" ]; then
            log_info "Starting cake-autortt service..."
            systemctl start cake-autortt.service
            
            # Wait a moment and check status
            sleep 2
            if systemctl is-active cake-autortt.service >/dev/null 2>&1; then
                log_info "Service started successfully!"
                log_info "Monitor with: sudo journalctl -u cake-autortt -f"
            else
                log_warn "Service may have failed to start"
                log_warn "Check status with: sudo systemctl status cake-autortt"
                log_warn "Check logs with: sudo journalctl -u cake-autortt --no-pager"
            fi
        fi
    else
        log_info "Installation root specified, skipping service operations"
    fi
}

show_post_install_info() {
    log_info "Installation completed!"
    echo
    echo "Configuration file: /etc/default/cake-autortt"
    echo "Service management:"
    echo "  Status:  sudo systemctl status cake-autortt"
    echo "  Start:   sudo systemctl start cake-autortt"
    echo "  Stop:    sudo systemctl stop cake-autortt"
    echo "  Restart: sudo systemctl restart cake-autortt"
    echo "  Logs:    sudo journalctl -u cake-autortt -f"
    echo
    echo "To configure interfaces:"
    echo "  sudo nano /etc/default/cake-autortt"
    echo "  sudo systemctl restart cake-autortt"
    echo
    echo "To enable debug logging:"
    echo "  Set DEBUG=1 in /etc/default/cake-autortt"
    echo "  sudo systemctl restart cake-autortt"
    echo
    echo "For more information, see README.md"
}

uninstall() {
    log_step "Uninstalling cake-autortt..."
    
    # Stop and disable service
    if [ -f "${INSTALL_ROOT}/etc/systemd/system/cake-autortt.service" ]; then
        if [ -z "$INSTALL_ROOT" ]; then
            systemctl stop cake-autortt.service 2>/dev/null || true
            systemctl disable cake-autortt.service 2>/dev/null || true
        fi
    fi
    
    # Remove files
    rm -f "${INSTALL_ROOT}/usr/bin/cake-autortt"
    rm -f "${INSTALL_ROOT}/etc/systemd/system/cake-autortt.service"
    rm -f "${INSTALL_ROOT}/etc/udev/rules.d/99-cake-autortt.rules"
    
    # Ask about configuration removal
    if [ -f "${INSTALL_ROOT}/etc/default/cake-autortt" ]; then
        read -p "Remove configuration file? (y/N): " remove_config
        if [ "$remove_config" = "y" ] || [ "$remove_config" = "Y" ]; then
            rm -f "${INSTALL_ROOT}/etc/default/cake-autortt"
        fi
    fi
    
    # Reload systemd and udev
    if [ -z "$INSTALL_ROOT" ]; then
        systemctl daemon-reload
        udevadm control --reload-rules
    fi
    
    log_info "Uninstallation completed"
}

show_help() {
    cat << EOF
cake-autortt Installation Script for Ubuntu/Debian

Usage: $0 [OPTIONS]

OPTIONS:
  --help                Show this help message
  --uninstall          Uninstall cake-autortt
  --install-root PATH  Install to alternative root (for packaging)

EXAMPLES:
  sudo $0                    # Install cake-autortt
  sudo $0 --uninstall       # Remove cake-autortt
  $0 --install-root /tmp/pkg # Install to /tmp/pkg for packaging

REQUIREMENTS:
  - Ubuntu 20.04+ or Debian 10+
  - systemd
  - Root privileges (use sudo)
  - CAKE qdisc support in kernel

BEFORE INSTALLATION:
  1. Ensure CAKE qdisc is configured on your interfaces
  2. Install required packages: sudo apt install fping iproute2

For more information, see README.md
EOF
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --uninstall)
            check_root
            uninstall
            exit 0
            ;;
        --install-root)
            INSTALL_ROOT="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main installation flow
main() {
    echo "cake-autortt Installation Script for Ubuntu/Debian"
    echo "================================================="
    echo
    
    # Preliminary checks
    check_root
    check_os
    check_systemd
    
    # Install process
    check_dependencies
    install_files
    
    # Only configure if CAKE interfaces exist or user proceeds anyway
    if check_cake_interfaces; then
        configure_interfaces
        enable_service
    else
        echo
        read -p "No CAKE interfaces found. Continue installation anyway? (y/N): " continue_install
        if [ "$continue_install" = "y" ] || [ "$continue_install" = "Y" ]; then
            log_warn "Proceeding without CAKE interface configuration"
            log_warn "Configure CAKE qdisc and edit /etc/default/cake-autortt before starting service"
            enable_service
        else
            log_info "Installation cancelled. Please configure CAKE qdisc first."
            exit 1
        fi
    fi
    
    show_post_install_info
}

# Run main function
main 