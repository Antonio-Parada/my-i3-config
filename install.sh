#!/bin/bash

# i3 Configuration Installation Script
# For Debian-based systems (Ubuntu, Kali, etc.)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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
    echo -e "${BLUE}  i3 Window Manager Setup${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

print_header

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Script directory: $SCRIPT_DIR"
print_status "Installing i3 window manager configuration..."

# Update package index
print_status "Updating package index..."
sudo apt update

# Install required packages
print_status "Installing i3 and dependencies..."
sudo apt install -y \
    i3 \
    i3status \
    dmenu \
    i3lock \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    feh

# Install Python i3ipc library
print_status "Installing Python i3ipc library..."
pip3 install --user i3ipc

# Create necessary directories
print_status "Creating configuration directories..."
mkdir -p ~/.config/i3
mkdir -p ~/.local/bin

# Backup existing configuration if it exists
if [ -f ~/.config/i3/config ]; then
    print_warning "Backing up existing i3 configuration..."
    cp ~/.config/i3/config ~/.config/i3/config.backup.$(date +%Y%m%d_%H%M%S)
fi

# Copy configuration files
print_status "Installing i3 configuration..."
cp "$SCRIPT_DIR/config/i3/config" ~/.config/i3/config

# Install scripts
print_status "Installing window management scripts..."
cp "$SCRIPT_DIR/scripts/alternating_layouts.py" ~/.local/bin/
cp "$SCRIPT_DIR/scripts/test_script.py" ~/.local/bin/
cp "$SCRIPT_DIR/scripts/display_setup.sh" ~/.local/bin/

# Make scripts executable
chmod +x ~/.local/bin/alternating_layouts.py
chmod +x ~/.local/bin/test_script.py
chmod +x ~/.local/bin/display_setup.sh

# Ensure ~/.local/bin is in PATH
if ! echo $PATH | grep -q "$HOME/.local/bin"; then
    print_status "Adding ~/.local/bin to PATH..."
    
    # Add to .bashrc if it exists
    if [ -f ~/.bashrc ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    
    # Add to .zshrc if it exists
    if [ -f ~/.zshrc ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    fi
    
    # Export for current session
    export PATH="$HOME/.local/bin:$PATH"
fi

# Create desktop entry for i3 if it doesn't exist
if [ ! -f /usr/share/xsessions/i3.desktop ]; then
    print_status "Creating i3 desktop session entry..."
    sudo tee /usr/share/xsessions/i3.desktop > /dev/null <<EOF
[Desktop Entry]
Name=i3
Comment=improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
Keywords=tiling;wm;windowmanager;window;manager;
EOF
fi

# Test the i3 configuration
print_status "Testing i3 configuration..."
if i3 -C -c ~/.config/i3/config > /dev/null 2>&1; then
    print_status "✓ i3 configuration is valid"
else
    print_error "✗ i3 configuration has syntax errors"
    print_error "Please check the configuration file: ~/.config/i3/config"
    exit 1
fi

# Test Python script
print_status "Testing alternating layout script..."
if python3 -m py_compile ~/.local/bin/alternating_layouts.py; then
    print_status "✓ Python script is valid"
else
    print_error "✗ Python script has syntax errors"
    exit 1
fi

print_status "Installation completed successfully!"
echo
print_warning "NEXT STEPS:"
echo -e "  1. ${YELLOW}Log out${NC} of your current desktop session"
echo -e "  2. At the login screen, select ${YELLOW}'i3'${NC} as your session type"
echo -e "  3. Log back in to start using i3"
echo
print_status "KEY BINDINGS:"
echo "  Super + Return       = Open terminal"
echo "  Super + d            = Application launcher"
echo "  Super + Shift + q    = Close window"
echo "  Super + 1-0          = Switch workspaces"
echo "  Super + Shift + r    = Restart i3"
echo "  Super + Shift + e    = Exit i3"
echo
print_status "TEST YOUR SETUP:"
echo "  After logging into i3, run: ~/.local/bin/test_script.py"
echo
print_status "CONFIGURATION FILES:"
echo "  i3 config: ~/.config/i3/config"
echo "  Scripts:   ~/.local/bin/alternating_layouts.py"
echo
print_status "For troubleshooting, see the README.md file."

# Offer to test now if in X session (but not in i3)
if [ ! -z "$DISPLAY" ] && ! pgrep -x "i3" > /dev/null 2>&1; then
    echo
    read -p "Would you like to test the Python i3ipc connection now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Testing i3ipc installation..."
        if python3 -c "import i3ipc; print('✓ i3ipc imported successfully')" 2>/dev/null; then
            print_status "✓ i3ipc library is working correctly"
        else
            print_warning "i3ipc test inconclusive (normal if not in i3 session)"
        fi
    fi
fi

print_status "Setup complete! Enjoy your new i3 configuration! 🪟✨"
