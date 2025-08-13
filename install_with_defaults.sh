#!/bin/bash

# Enhanced i3 Configuration Installation Script
# Handles setting i3 as default session for keyboard-only systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  i3 Window Manager Setup (Enhanced)${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Function to set i3 as default session
set_default_session() {
    print_status "Setting i3 as default session..."
    
    # Method 1: Create .dmrc file (works with most display managers)
    cat > ~/.dmrc << EOF
[Desktop]
Session=i3
EOF
    
    print_status "Created ~/.dmrc to set i3 as default session"
    
    # Method 2: Set alternatives (if available)
    if command -v update-alternatives &> /dev/null; then
        print_status "Updating x-session-manager alternatives..."
        sudo update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/i3 50 || true
    fi
    
    # Method 3: Create desktop file with higher priority (for some DMs)
    if [ -d /usr/share/xsessions ]; then
        sudo tee /usr/share/xsessions/i3-priority.desktop > /dev/null <<EOF
[Desktop Entry]
Name=i3 (Default)
Comment=improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
Keywords=tiling;wm;windowmanager;window;manager;
X-Ubuntu-Gettext-Domain=i3
EOF
    fi
    
    # Method 4: Configure LightDM if present
    if [ -f /etc/lightdm/lightdm.conf ]; then
        print_status "Configuring LightDM for i3..."
        if ! grep -q "user-session=i3" /etc/lightdm/lightdm.conf; then
            sudo sed -i '/^\[Seat:\*\]/a user-session=i3' /etc/lightdm/lightdm.conf || true
        fi
    fi
    
    # Method 5: Configure GDM if present  
    if command -v gdm3 &> /dev/null || command -v gdm &> /dev/null; then
        print_status "Note: GDM detected. You may need to select i3 manually at login."
    fi
}

# Function to create session switching helper
create_session_helper() {
    print_status "Creating session management helper..."
    
    cat > ~/.local/bin/switch_to_i3.sh << 'EOF'
#!/bin/bash

# Session Switching Helper Script
# Run this to force switch to i3 session

echo "=== i3 Session Switcher ==="

# Check if i3 is installed
if ! command -v i3 &> /dev/null; then
    echo "Error: i3 is not installed!"
    exit 1
fi

# Set i3 as default session
echo "Setting i3 as default session..."
echo 'i3' > ~/.dmrc

# Try to restart display manager
echo "Attempting to restart display manager..."
if systemctl is-active --quiet lightdm; then
    echo "Restarting LightDM..."
    sudo systemctl restart lightdm
elif systemctl is-active --quiet gdm3; then
    echo "Restarting GDM3..."
    sudo systemctl restart gdm3
elif systemctl is-active --quiet gdm; then
    echo "Restarting GDM..."
    sudo systemctl restart gdm
elif systemctl is-active --quiet sddm; then
    echo "Restarting SDDM..."
    sudo systemctl restart sddm
else
    echo "Could not identify display manager."
    echo "Please log out and select i3 from the session menu."
fi

echo "Done! i3 should now be the default session."
EOF

    chmod +x ~/.local/bin/switch_to_i3.sh
    print_status "Created session switching helper at ~/.local/bin/switch_to_i3.sh"
}

# Function to create TTY launcher (fallback)
create_tty_launcher() {
    print_status "Creating TTY i3 launcher (fallback method)..."
    
    cat > ~/.local/bin/start_i3_from_tty.sh << 'EOF'
#!/bin/bash

# TTY i3 Launcher - run this from a TTY if you can't get to i3 via display manager

echo "=== Starting i3 from TTY ==="

# Check if X is already running
if pgrep -x "X" > /dev/null || pgrep -x "Xorg" > /dev/null; then
    echo "X server is already running. Trying to switch to it..."
    # Try to switch to existing X session
    for display in 0 1 2; do
        if DISPLAY=:$display xdpyinfo >/dev/null 2>&1; then
            echo "Found X session on display :$display"
            export DISPLAY=:$display
            exec i3
            exit 0
        fi
    done
fi

# Start new X session with i3
echo "Starting new X session with i3..."
exec startx /usr/bin/i3

EOF

    chmod +x ~/.local/bin/start_i3_from_tty.sh
    print_status "Created TTY launcher at ~/.local/bin/start_i3_from_tty.sh"
}

# Main installation function
main() {
    print_header
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
       print_error "This script should not be run as root (don't use sudo)"
       exit 1
    fi
    
    # Run the main installer first
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ -f "$SCRIPT_DIR/install.sh" ]; then
        print_status "Running main installer..."
        bash "$SCRIPT_DIR/install.sh"
    else
        print_error "Main install.sh not found. Make sure you're in the correct directory."
        exit 1
    fi
    
    echo
    print_status "=== Enhanced Setup for Keyboard-Only Systems ==="
    
    # Set default session
    set_default_session
    
    # Create helper scripts
    create_session_helper
    create_tty_launcher
    
    print_status "Enhanced setup complete!"
    echo
    print_warning "KEYBOARD-ONLY INSTRUCTIONS:"
    echo -e "  ${YELLOW}Option 1 (Recommended):${NC} Log out normally - i3 should now be default"
    echo -e "  ${YELLOW}Option 2:${NC} Run ~/.local/bin/switch_to_i3.sh to force session switch"
    echo -e "  ${YELLOW}Option 3 (TTY Fallback):${NC} Press Ctrl+Alt+F2, login, run ~/.local/bin/start_i3_from_tty.sh"
    echo
    print_status "LOGIN SCREEN NAVIGATION:"
    echo "  - Tab/Shift+Tab: Navigate fields"
    echo "  - Enter: Activate buttons/dropdowns" 
    echo "  - Arrow keys: Navigate menus"
    echo "  - F10/Alt+F10: Often opens session menu"
    echo
    print_status "If you get stuck, press Ctrl+Alt+F1 to get to TTY console."
    echo
    
    # Offer to set session now
    read -p "Would you like to switch to i3 session now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ~/.local/bin/switch_to_i3.sh
    else
        print_status "You can switch later by running: ~/.local/bin/switch_to_i3.sh"
        print_status "Or just log out and i3 should be the default session."
    fi
}

# Run main function
main "$@"
