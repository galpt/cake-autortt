#!/bin/bash

# cake-autortt Uninstallation Script for Ubuntu/Debian
# This script removes cake-autortt service from Ubuntu/Debian systems

set -e

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

stop_service() {
    log_step "Stopping cake-autortt service..."
    
    if systemctl is-active cake-autortt.service >/dev/null 2>&1; then
        log_info "Stopping running service..."
        systemctl stop cake-autortt.service
    else
        log_info "Service is not running"
    fi
    
    if systemctl is-enabled cake-autortt.service >/dev/null 2>&1; then
        log_info "Disabling service from auto-start..."
        systemctl disable cake-autortt.service
    else
        log_info "Service is not enabled"
    fi
}

remove_files() {
    log_step "Removing cake-autortt files..."
    
    local files_removed=0
    
    # Remove executable
    if [ -f "/usr/bin/cake-autortt" ]; then
        log_info "Removing executable: /usr/bin/cake-autortt"
        rm -f "/usr/bin/cake-autortt"
        files_removed=$((files_removed + 1))
    fi
    
    # Remove systemd service file
    if [ -f "/etc/systemd/system/cake-autortt.service" ]; then
        log_info "Removing systemd service: /etc/systemd/system/cake-autortt.service"
        rm -f "/etc/systemd/system/cake-autortt.service"
        files_removed=$((files_removed + 1))
    fi
    
    # Remove udev rule
    if [ -f "/etc/udev/rules.d/99-cake-autortt.rules" ]; then
        log_info "Removing udev rule: /etc/udev/rules.d/99-cake-autortt.rules"
        rm -f "/etc/udev/rules.d/99-cake-autortt.rules"
        files_removed=$((files_removed + 1))
    fi
    
    # Remove PID file if it exists
    if [ -f "/var/run/cake-autortt.pid" ]; then
        log_info "Removing PID file: /var/run/cake-autortt.pid"
        rm -f "/var/run/cake-autortt.pid"
    fi
    
    if [ $files_removed -eq 0 ]; then
        log_warn "No cake-autortt files found to remove"
    else
        log_info "Removed $files_removed file(s)"
    fi
}

handle_config() {
    log_step "Handling configuration files..."
    
    if [ -f "/etc/default/cake-autortt" ]; then
        echo
        echo "Configuration file found: /etc/default/cake-autortt"
        read -p "Remove configuration file? (y/N): " remove_config
        
        if [ "$remove_config" = "y" ] || [ "$remove_config" = "Y" ]; then
            log_info "Removing configuration file"
            rm -f "/etc/default/cake-autortt"
        else
            log_info "Keeping configuration file"
            log_warn "Configuration will remain at /etc/default/cake-autortt"
        fi
    else
        log_info "No configuration file found"
    fi
}

handle_backups() {
    log_step "Handling backup files..."
    
    local backup_files=""
    local backup_count=0
    
    # Check for backup files created during installation
    for file in "/usr/bin/cake-autortt.bak" "/etc/systemd/system/cake-autortt.service.bak" \
                "/etc/default/cake-autortt.bak" "/etc/udev/rules.d/99-cake-autortt.rules.bak"; do
        if [ -f "$file" ]; then
            backup_files="$backup_files\n  $file"
            backup_count=$((backup_count + 1))
        fi
    done
    
    if [ $backup_count -gt 0 ]; then
        echo
        echo "Backup files found:$backup_files"
        echo
        read -p "Remove backup files? (y/N): " remove_backups
        
        if [ "$remove_backups" = "y" ] || [ "$remove_backups" = "Y" ]; then
            log_info "Removing backup files..."
            rm -f "/usr/bin/cake-autortt.bak" \
                  "/etc/systemd/system/cake-autortt.service.bak" \
                  "/etc/default/cake-autortt.bak" \
                  "/etc/udev/rules.d/99-cake-autortt.rules.bak"
            log_info "Removed $backup_count backup file(s)"
        else
            log_info "Keeping backup files"
        fi
    else
        log_info "No backup files found"
    fi
}

reload_services() {
    log_step "Reloading system services..."
    
    log_info "Reloading systemd daemon..."
    systemctl daemon-reload
    
    log_info "Reloading udev rules..."
    udevadm control --reload-rules
    
    log_info "System services reloaded"
}

clean_temp_files() {
    log_step "Cleaning temporary files..."
    
    # Remove any temporary files that might have been left behind
    local temp_files_pattern="/tmp/cake-autortt-hosts.*"
    local removed_count=0
    
    for file in $temp_files_pattern; do
        if [ -f "$file" ]; then
            rm -f "$file"
            removed_count=$((removed_count + 1))
        fi
    done
    
    if [ $removed_count -gt 0 ]; then
        log_info "Removed $removed_count temporary file(s)"
    else
        log_info "No temporary files found"
    fi
}

show_completion() {
    log_info "Uninstallation completed successfully!"
    echo
    echo "Summary of actions performed:"
    echo "- Stopped and disabled cake-autortt service"
    echo "- Removed executable and service files"
    echo "- Reloaded systemd and udev"
    echo "- Cleaned up temporary files"
    echo
    
    if [ -f "/etc/default/cake-autortt" ]; then
        echo "Configuration file preserved at: /etc/default/cake-autortt"
    fi
    
    # Check for any remaining files
    local remaining_files=""
    for file in "/usr/bin/cake-autortt" "/etc/systemd/system/cake-autortt.service" \
                "/etc/default/cake-autortt" "/etc/udev/rules.d/99-cake-autortt.rules"; do
        if [ -f "$file" ]; then
            remaining_files="$remaining_files\n  $file"
        fi
    done
    
    if [ -n "$remaining_files" ]; then
        echo
        echo "Remaining files:$remaining_files"
    fi
    
    echo
    echo "cake-autortt has been removed from your system."
}

show_help() {
    cat << EOF
cake-autortt Uninstallation Script for Ubuntu/Debian

Usage: $0 [OPTIONS]

OPTIONS:
  --help           Show this help message
  --force          Remove all files without prompting

DESCRIPTION:
  This script removes cake-autortt from Ubuntu/Debian systems by:
  - Stopping and disabling the systemd service
  - Removing executable, service, and configuration files
  - Cleaning up temporary files and reloading system services

EXAMPLES:
  sudo $0          # Interactive uninstallation
  sudo $0 --force  # Non-interactive removal of all files

REQUIREMENTS:
  - Root privileges (use sudo)
  - systemd

For more information, see README.md
EOF
}

# Parse command line arguments
FORCE_REMOVE=0
while [ $# -gt 0 ]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --force)
            FORCE_REMOVE=1
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main uninstallation function
main() {
    echo "cake-autortt Uninstallation Script for Ubuntu/Debian"
    echo "===================================================="
    echo
    
    # Check if we're running as root
    check_root
    
    # Check if cake-autortt is installed
    if [ ! -f "/usr/bin/cake-autortt" ] && [ ! -f "/etc/systemd/system/cake-autortt.service" ]; then
        log_warn "cake-autortt does not appear to be installed"
        
        # Still check for orphaned files
        if [ -f "/etc/default/cake-autortt" ] || [ -f "/etc/udev/rules.d/99-cake-autortt.rules" ]; then
            log_info "Found some cake-autortt files, proceeding with cleanup"
        else
            log_info "No cake-autortt files found"
            exit 0
        fi
    fi
    
    # Confirm uninstallation
    if [ $FORCE_REMOVE -eq 0 ]; then
        echo "This will remove cake-autortt from your system."
        read -p "Continue with uninstallation? (y/N): " confirm
        
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log_info "Uninstallation cancelled"
            exit 0
        fi
        echo
    fi
    
    # Stop the service first
    stop_service
    
    # Remove main files
    remove_files
    
    # Handle configuration and backups based on force flag
    if [ $FORCE_REMOVE -eq 1 ]; then
        log_info "Force mode: removing all files..."
        rm -f "/etc/default/cake-autortt"
        rm -f "/usr/bin/cake-autortt.bak" \
              "/etc/systemd/system/cake-autortt.service.bak" \
              "/etc/default/cake-autortt.bak" \
              "/etc/udev/rules.d/99-cake-autortt.rules.bak"
    else
        handle_config
        handle_backups
    fi
    
    # Clean up temporary files
    clean_temp_files
    
    # Reload system services
    reload_services
    
    # Show completion message
    show_completion
}

# Run main function
main 