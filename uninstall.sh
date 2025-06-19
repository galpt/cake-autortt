#!/bin/sh

# cake-autortt Uninstallation Script for OpenWrt
# This script removes cake-autortt service from OpenWrt routers

set -e

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

stop_and_disable_service() {
    log_info "Stopping and disabling cake-autortt service..."
    
    if [ -f "${INSTALL_ROOT}/etc/init.d/cake-autortt" ] && [ -z "$INSTALL_ROOT" ]; then
        # Stop the service
        if /etc/init.d/cake-autortt status >/dev/null 2>&1; then
            log_info "Stopping cake-autortt service..."
            /etc/init.d/cake-autortt stop 2>/dev/null || true
        fi
        
        # Disable the service
        log_info "Disabling cake-autortt service..."
        /etc/init.d/cake-autortt disable 2>/dev/null || true
    fi
}

remove_files() {
    log_info "Removing cake-autortt files..."
    
    # Remove executable
    if [ -f "${INSTALL_ROOT}/usr/bin/cake-autortt" ]; then
        log_info "Removing executable: /usr/bin/cake-autortt"
        rm -f "${INSTALL_ROOT}/usr/bin/cake-autortt"
    fi
    
    # Remove init script
    if [ -f "${INSTALL_ROOT}/etc/init.d/cake-autortt" ]; then
        log_info "Removing init script: /etc/init.d/cake-autortt"
        rm -f "${INSTALL_ROOT}/etc/init.d/cake-autortt"
    fi
    
    # Remove hotplug script
    if [ -f "${INSTALL_ROOT}/etc/hotplug.d/iface/99-cake-autortt" ]; then
        log_info "Removing hotplug script: /etc/hotplug.d/iface/99-cake-autortt"
        rm -f "${INSTALL_ROOT}/etc/hotplug.d/iface/99-cake-autortt"
    fi
    
    # Remove runtime files
    if [ -f "${INSTALL_ROOT}/var/run/cake-autortt.pid" ]; then
        log_info "Removing PID file: /var/run/cake-autortt.pid"
        rm -f "${INSTALL_ROOT}/var/run/cake-autortt.pid"
    fi
    
    if [ -f "${INSTALL_ROOT}/tmp/cake-autortt-hosts" ]; then
        log_info "Removing temporary hosts file: /tmp/cake-autortt-hosts"
        rm -f "${INSTALL_ROOT}/tmp/cake-autortt-hosts"
    fi
}

handle_config_file() {
    if [ -f "${INSTALL_ROOT}/etc/config/cake-autortt" ]; then
        echo
        read -p "Remove configuration file /etc/config/cake-autortt? (y/N): " remove_config
        if [ "$remove_config" = "y" ] || [ "$remove_config" = "Y" ]; then
            log_info "Removing configuration file: /etc/config/cake-autortt"
            rm -f "${INSTALL_ROOT}/etc/config/cake-autortt"
        else
            log_info "Keeping configuration file for potential future use"
        fi
    fi
}

handle_backup_files() {
    local backup_files=""
    
    # Check for backup files
    for file in \
        "${INSTALL_ROOT}/usr/bin/cake-autortt.bak" \
        "${INSTALL_ROOT}/etc/init.d/cake-autortt.bak" \
        "${INSTALL_ROOT}/etc/config/cake-autortt.bak" \
        "${INSTALL_ROOT}/etc/hotplug.d/iface/99-cake-autortt.bak"; do
        if [ -f "$file" ]; then
            backup_files="$backup_files $file"
        fi
    done
    
    if [ -n "$backup_files" ]; then
        echo
        log_info "Found backup files from previous installation:"
        for file in $backup_files; do
            echo "  - $file"
        done
        
        read -p "Remove backup files? (y/N): " remove_backups
        if [ "$remove_backups" = "y" ] || [ "$remove_backups" = "Y" ]; then
            for file in $backup_files; do
                log_info "Removing backup file: $file"
                rm -f "$file"
            done
        else
            log_info "Keeping backup files"
        fi
    fi
}

show_completion_message() {
    echo
    log_info "cake-autortt has been uninstalled successfully!"
    echo
    echo "The following may still be present on your system:"
    echo "- CAKE qdisc configuration (not modified by this script)"
    echo "- Log entries in system logs"
    if [ -f "${INSTALL_ROOT}/etc/config/cake-autortt" ]; then
        echo "- Configuration file (kept at your request)"
    fi
    echo
    echo "If you want to completely remove all traces:"
    echo "- Clean system logs: logread | grep -v cake-autortt"
    echo "- Review CAKE qdisc settings: tc qdisc show"
}

main() {
    echo "cake-autortt Uninstaller"
    echo "========================"
    echo
    
    # Check if cake-autortt is installed
    if [ ! -f "${INSTALL_ROOT}/usr/bin/cake-autortt" ] && \
       [ ! -f "${INSTALL_ROOT}/etc/init.d/cake-autortt" ]; then
        log_warn "cake-autortt does not appear to be installed"
        exit 0
    fi
    
    echo "This will remove cake-autortt from your system."
    read -p "Are you sure you want to continue? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_info "Uninstallation cancelled"
        exit 0
    fi
    
    echo
    
    # Stop and disable service
    stop_and_disable_service
    
    # Remove files
    remove_files
    
    # Handle configuration file
    handle_config_file
    
    # Handle backup files
    handle_backup_files
    
    # Show completion message
    show_completion_message
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Uninstalls cake-autortt service from OpenWrt"
        echo
        echo "OPTIONS:"
        echo "  --help, -h          Show this help message"
        echo "  --force             Skip confirmation prompts"
        echo
        echo "Environment Variables:"
        echo "  INSTALL_ROOT        Override installation root (for testing)"
        exit 0
        ;;
    --force)
        # Set non-interactive mode
        export DEBIAN_FRONTEND=noninteractive
        # Override read prompts
        confirm="y"
        remove_config="y"
        remove_backups="y"
        ;;
esac

# Run main function
main 