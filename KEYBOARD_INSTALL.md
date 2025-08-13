# Keyboard-Only Installation Guide

This guide helps you install i3 on a system where you only have keyboard access (no mouse/GUI).

## Quick Install (One Command)

If you have internet access via command line:

```bash
curl -sSL https://raw.githubusercontent.com/Antonio-Parada/my-i3-config/main/install.sh | bash
```

## Manual Installation Steps

### Step 1: Get the Repository
```bash
# Clone the repository
git clone https://github.com/Antonio-Parada/my-i3-config.git
cd my-i3-config

# Make installer executable and run
chmod +x install.sh
./install.sh
```

### Step 2: After Installation
The installer will complete and show you next steps. You need to:

1. **Log out** of current session:
   ```bash
   # If in a desktop environment
   logout
   
   # Or if in TTY/console
   exit
   ```

2. **At login screen** (this is keyboard navigable):
   - Look for session selection (usually gear icon or dropdown)
   - Use `Tab` to navigate between fields
   - Use `Enter` to select options
   - Choose **"i3"** from session menu
   - Enter your password and login

### Step 3: First i3 Session

When i3 starts for the first time, it will ask about the config file and modifier key:

1. **Config file prompt**: Press `Enter` to generate default config
2. **Modifier key prompt**: 
   - Press `Enter` for **Super/Windows key** (recommended)
   - Or press arrow keys to select Alt, then `Enter`

## Essential i3 Keyboard Commands

Once in i3, you only need these commands to get started:

### Immediate Survival Commands
- `Super + Enter` = Open terminal
- `Super + d` = Application launcher (dmenu)
- `Super + Shift + q` = Close current window
- `Super + Shift + e` = Exit i3 (logout)

### Navigation
- `Super + j/k/l/;` = Move focus between windows
- `Super + 1-0` = Switch to workspace 1-10
- `Super + Shift + 1-0` = Move window to workspace 1-10

### Window Management
- `Super + h` = Split horizontally
- `Super + v` = Split vertically  
- `Super + f` = Fullscreen current window
- `Super + Shift + Space` = Toggle floating window

### System
- `Super + Shift + r` = Restart i3 (reload config)
- `Super + Shift + c` = Reload i3 config file

## Testing Your Setup

After logging into i3, open a terminal and run:
```bash
~/.local/bin/test_script.py
```

This will verify that:
- i3 is running correctly
- The alternating layout script is active
- Python dependencies are working

## Troubleshooting Without Mouse

### Can't See Desktop/Nothing Happens
- Press `Super + Enter` to open terminal
- If nothing happens, try `Alt + F2` (fallback launcher)
- If still stuck, press `Ctrl + Alt + F1` to get to TTY console

### Need to Get Back to Console
- `Ctrl + Alt + F1` through `F6` = Switch to TTY consoles
- `Ctrl + Alt + F7` = Usually returns to X session

### i3 Won't Start
```bash
# Check if i3 is installed
which i3

# Test i3 config
i3 -C -c ~/.config/i3/config

# View logs
journalctl -u display-manager
# or
cat ~/.xsession-errors
```

### Script Not Working
```bash
# Check if script is running
pgrep -f alternating_layouts.py

# Test script manually
python3 ~/.local/bin/alternating_layouts.py

# Restart i3 to reload everything
i3-msg restart
```

## Network Setup (if needed)

If you need to set up networking first:

```bash
# Check network interfaces
ip link show

# Connect to WiFi (if using NetworkManager)
nmcli device wifi list
nmcli device wifi connect "SSID" password "password"

# Or use basic tools
sudo dhclient eth0  # for ethernet
```

## Applications You Can Launch

Once in i3, use `Super + d` to launch:
- `firefox` or `chromium` - Web browser
- `thunar` or `nautilus` - File manager  
- `code` or `nano` - Text editors
- `htop` - System monitor

## Remember

- **Everything in i3 is keyboard-driven**
- **Super key** is your main modifier (Windows key)
- **Start with terminal** (`Super + Enter`) - it's your gateway to everything
- **dmenu** (`Super + d`) can launch any application by name

You're all set! i3 works perfectly without a mouse. 🎯
