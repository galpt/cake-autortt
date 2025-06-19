#!/bin/sh

# cake-autortt Installation Script for OpenWrt
# This script installs cake-autortt service on OpenWrt routers

set -e

SCRIPT_DIR="$(dirname "$0")"
INSTALL_ROOT="${INSTALL_ROOT:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check for required commands
    local missing_deps=""
    
    if ! command -v fping >/dev/null 2>&1; then
        missing_deps="$missing_deps fping"
    fi
    
    if ! command -v bc >/dev/null 2>&1; then
        missing_deps="$missing_deps bc"
    fi
    
    if ! command -v tc >/dev/null 2>&1; then
        missing_deps="$missing_deps tc"
    fi
    
    if [ -n "$missing_deps" ]; then
        log_warn "Missing dependencies:$missing_deps"
        log_info "Install with: opkg update && opkg install$missing_deps"
        
        read -p "Would you like to install missing dependencies now? (y/N): " install_deps
        if [ "$install_deps" = "y" ] || [ "$install_deps" = "Y" ]; then
            log_info "Installing dependencies..."
            opkg update
            for dep in $missing_deps; do
                case "$dep" in
                    bc) opkg install bc-gpl ;;
                    *) opkg install "$dep" ;;
                esac
            done
        else
            log_error "Cannot proceed without required dependencies"
            exit 1
        fi
    fi
    
    # Check for CAKE support
    if ! tc qdisc help 2>/dev/null | grep -q cake; then
        log_warn "CAKE qdisc support not detected in tc"
        log_warn "Ensure your OpenWrt version supports CAKE"
    fi
    
    log_info "Dependencies check completed"
}

backup_existing() {
    local file="$1"
    if [ -f "$file" ]; then
        log_warn "Backing up existing file: $file -> $file.bak"
        cp "$file" "$file.bak"
    fi
}

install_files() {
    log_info "Installing cake-autortt files..."
    
    # Create directories if they don't exist
    mkdir -p "${INSTALL_ROOT}/usr/bin"
    mkdir -p "${INSTALL_ROOT}/etc/init.d"
    mkdir -p "${INSTALL_ROOT}/etc/config"
    mkdir -p "${INSTALL_ROOT}/etc/hotplug.d/iface"
    
    # Backup existing files
    backup_existing "${INSTALL_ROOT}/usr/bin/cake-autortt"
    backup_existing "${INSTALL_ROOT}/etc/init.d/cake-autortt"
    backup_existing "${INSTALL_ROOT}/etc/config/cake-autortt"
    backup_existing "${INSTALL_ROOT}/etc/hotplug.d/iface/99-cake-autortt"
    
    # Copy files
    log_info "Copying executable..."
    cp "$SCRIPT_DIR/usr/bin/cake-autortt" "${INSTALL_ROOT}/usr/bin/"
    chmod +x "${INSTALL_ROOT}/usr/bin/cake-autortt"
    
    log_info "Copying init script..."
    cp "$SCRIPT_DIR/etc/init.d/cake-autortt" "${INSTALL_ROOT}/etc/init.d/"
    chmod +x "${INSTALL_ROOT}/etc/init.d/cake-autortt"
    
    log_info "Copying configuration..."
    if [ ! -f "${INSTALL_ROOT}/etc/config/cake-autortt" ]; then
        cp "$SCRIPT_DIR/etc/config/cake-autortt" "${INSTALL_ROOT}/etc/config/"
    else
        log_warn "Configuration file already exists, skipping (backup created)"
    fi
    
    log_info "Copying hotplug script..."
    cp "$SCRIPT_DIR/etc/hotplug.d/iface/99-cake-autortt" "${INSTALL_ROOT}/etc/hotplug.d/iface/"
    chmod +x "${INSTALL_ROOT}/etc/hotplug.d/iface/99-cake-autortt"
    
    log_info "Files installed successfully"
}

check_cake_interfaces() {
    log_info "Checking for CAKE interfaces..."
    
    local cake_interfaces
    cake_interfaces=$(tc qdisc show 2>/dev/null | grep "qdisc cake" | awk '{print $5}' || true)
    
    if [ -z "$cake_interfaces" ]; then
        log_warn "No CAKE interfaces found"
        log_warn "Please configure CAKE qdisc on your interfaces before starting the service"
        log_warn "Example: tc qdisc add root dev wan cake bandwidth 50Mbit"
        return 1
    else
        log_info "Found CAKE interfaces: $(echo $cake_interfaces | tr '\n' ' ')"
        return 0
    fi
}

enable_service() {
    log_info "Enabling cake-autortt service..."
    
    if [ -z "$INSTALL_ROOT" ]; then
        # Real system installation
        /etc/init.d/cake-autortt enable
        log_info "Service enabled for automatic startup"
        
        read -p "Would you like to start the service now? (Y/n): " start_now
        if [ "$start_now" != "n" ] && [ "$start_now" != "N" ]; then
            log_info "Starting cake-autortt service..."
            /etc/init.d/cake-autortt start
            
            # Wait a moment and check status
            sleep 2
            if /etc/init.d/cake-autortt status >/dev/null 2>&1; then
                log_info "Service started successfully!"
                log_info "Monitor with: logread | grep cake-autortt"
            else
                log_warn "Service may have failed to start, check logs with: logread | grep cake-autortt"
            fi
        fi
    else
        log_info "Installation root specified, skipping service operations"
    fi
}

show_post_install_info() {
    log_info "Installation completed!"
    echo
    echo "Next steps:"
    echo "1. Review configuration: uci show cake-autortt"
    echo "2. Enable debug if needed: uci set cake-autortt.global.debug='1'"
    echo "3. Restart service: /etc/init.d/cake-autortt restart"
    echo "4. Monitor logs: logread | grep cake-autortt"
    echo
    echo "For more information, see README.md"
}

uninstall() {
    log_info "Uninstalling cake-autortt..."
    
    # Stop and disable service
    if [ -f "${INSTALL_ROOT}/etc/init.d/cake-autortt" ]; then
        if [ -z "$INSTALL_ROOT" ]; then
            /etc/init.d/cake-autortt stop 2>/dev/null || true
            /etc/init.d/cake-autortt disable 2>/dev/null || true
        fi
    fi
    
    # Remove files
    rm -f "${INSTALL_ROOT}/usr/bin/cake-autortt"
    rm -f "${INSTALL_ROOT}/etc/init.d/cake-autortt"
    rm -f "${INSTALL_ROOT}/etc/hotplug.d/iface/99-cake-autortt"
    
    # Ask about configuration removal
    if [ -f "${INSTALL_ROOT}/etc/config/cake-autortt" ]; then
        read -p "Remove configuration file? (y/N): " remove_config
        if [ "$remove_config" = "y" ] || [ "$remove_config" = "Y" ]; then
            rm -f "${INSTALL_ROOT}/etc/config/cake-autortt"
        fi
    fi
    
    log_info "Uninstallation completed"
}

show_help() {
    cat << EOF
cake-autortt Installation Script

Usage: $0 [OPTIONS]

OPTIONS:
    install       Install cake-autortt (default action)
    uninstall     Remove cake-autortt
    --help        Show this help message

ENVIRONMENT VARIABLES:
    INSTALL_ROOT  Root directory for installation (for testing/packaging)

EXAMPLES:
    $0                    # Install cake-autortt
    $0 install            # Install cake-autortt (explicit)
    $0 uninstall          # Remove cake-autortt
    INSTALL_ROOT=/tmp $0  # Install to /tmp (for testing)

EOF
}

# Main execution
case "${1:-install}" in
    install)
        log_info "Starting cake-autortt installation..."
        check_dependencies
        install_files
        if [ -z "$INSTALL_ROOT" ]; then
            check_cake_interfaces || log_warn "Configure CAKE interfaces before starting service"
            enable_service
        fi
        show_post_install_info
        ;;
    uninstall)
        uninstall
        ;;
    --help|-h|help)
        show_help
        ;;
    *)
        log_error "Unknown action: $1"
        show_help
        exit 1
        ;;
esac 