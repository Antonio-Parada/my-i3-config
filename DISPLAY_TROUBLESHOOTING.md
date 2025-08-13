# Display Troubleshooting Guide

This guide helps you fix display issues in i3, particularly when applications open on secondary displays (like trackpad screens).

## Quick Fixes

### 1. Immediate Fix (when already in i3)
```bash
# Run the display setup script manually
~/.local/bin/display_setup.sh

# Or restart i3 to reload display configuration
i3-msg restart
```

### 2. Check Current Display Setup
```bash
# See all connected displays
xrandr --query

# See which display is set as primary
xrandr --query | grep primary
```

### 3. Manual Display Configuration
```bash
# Set main laptop screen as primary (replace eDP-1 with your display name)
xrandr --output eDP-1 --primary --auto

# Disable secondary display (replace DP-2 with the problematic display)
xrandr --output DP-2 --off

# If you have external monitors, position them correctly
xrandr --output HDMI-1 --auto --right-of eDP-1
```

## Common Display Names

Different laptops use different naming conventions:

### Laptop Internal Displays
- `eDP-1` or `eDP1` (modern laptops)
- `LVDS-1` or `LVDS1` (older laptops)
- `LCD-1` or `LCD1` 

### External/Secondary Displays
- `HDMI-1`, `HDMI-2` (HDMI ports)
- `DP-1`, `DP-2`, `DP-3` (DisplayPort)
- `VGA-1` (VGA port)

### Trackpad/Touch Screen Displays
These often have names like:
- `DP-2`, `DP-3` (small resolution, e.g., 1024x600)
- `HDMI-2` (if it's a secondary built-in display)

## Automated Solution

The i3 configuration includes an automatic display setup script that runs on startup. This script:

1. **Identifies the main laptop display** (eDP, LVDS, LCD patterns)
2. **Sets it as primary** and enables it
3. **Disables small secondary displays** (like trackpad screens)
4. **Positions external monitors** appropriately

## Manual Configuration

### Step 1: Identify Your Displays
```bash
# List all displays with details
xrandr --verbose

# Find the problematic display (usually has small resolution)
xrandr --query | grep -E "(connected|[0-9]+x[0-9]+)"
```

### Step 2: Create Custom Display Script
If the automatic script doesn't work, create a custom one:

```bash
# Create custom script
cat > ~/.config/i3/my_display_setup.sh << 'EOF'
#!/bin/bash

# Replace these with your actual display names
MAIN_DISPLAY="eDP-1"      # Your main laptop screen
TRACKPAD_DISPLAY="DP-2"   # The problematic trackpad/secondary display

# Set main display as primary
xrandr --output "$MAIN_DISPLAY" --primary --auto

# Disable trackpad display
xrandr --output "$TRACKPAD_DISPLAY" --off

# If you have external monitors, configure them here
# xrandr --output HDMI-1 --auto --right-of "$MAIN_DISPLAY"

EOF

chmod +x ~/.config/i3/my_display_setup.sh
```

### Step 3: Update i3 Config
Add this line to your `~/.config/i3/config`:

```bash
exec --no-startup-id ~/.config/i3/my_display_setup.sh
```

## Keyboard Shortcuts

Add these to your i3 config for quick display management:

```bash
# Add to ~/.config/i3/config

# Toggle external monitor
bindsym $mod+Shift+m exec --no-startup-id ~/.local/bin/display_setup.sh

# Manual display configuration
bindsym $mod+Shift+d exec --no-startup-id arandr  # GUI display manager (if installed)
```

## Common Issues & Solutions

### Issue: Applications Still Open on Wrong Display
**Solution:**
```bash
# Force applications to open on primary display
export DISPLAY=:0.0

# Add to your shell profile (.bashrc/.zshrc)
echo 'export DISPLAY=:0.0' >> ~/.bashrc
```

### Issue: Display Setup Doesn't Persist
**Solution:**
```bash
# Make sure the script runs on i3 startup
grep "display_autostart" ~/.config/i3/config

# If not found, add this line:
echo "exec --no-startup-id ~/.config/i3/display_autostart.sh" >> ~/.config/i3/config
```

### Issue: Can't Identify Display Names
**Solution:**
```bash
# Get detailed display information
xrandr --listproviders
xrandr --listmonitors

# Check what's currently active
xrandr --current
```

### Issue: External Monitor Not Detected
**Solution:**
```bash
# Force detection
xrandr --auto

# Check if it's detected but disabled
xrandr --query | grep disconnected
```

## Testing Your Setup

After making changes:

1. **Restart i3**: `i3-msg restart`
2. **Open a test application**: `Super + Return` (terminal)
3. **Check if it opens on main display**
4. **Test with GUI apps**: `Super + d` then type `firefox`

## Advanced Configuration

### Save Display Profile
```bash
# Save current setup
xrandr > ~/.config/i3/display_profile.txt

# Create script from current setup
xrandr | grep " connected" | while read line; do
    display=$(echo $line | cut -d' ' -f1)
    echo "xrandr --output $display --auto"
done > ~/.config/i3/restore_displays.sh
```

### Multiple Monitor Profiles
```bash
# Create different profiles for different setups
mkdir ~/.config/i3/display_profiles/

# Single laptop profile
echo "xrandr --output eDP-1 --primary --auto --output DP-2 --off" > ~/.config/i3/display_profiles/laptop_only.sh

# Dual monitor profile  
echo "xrandr --output eDP-1 --primary --auto --output HDMI-1 --auto --right-of eDP-1 --output DP-2 --off" > ~/.config/i3/display_profiles/dual_monitor.sh

chmod +x ~/.config/i3/display_profiles/*.sh
```

## Getting Help

If you're still having issues:

1. **Check logs**: `journalctl -b | grep -i display`
2. **Test manually**: Run commands step by step
3. **Share output**: `xrandr --query` and `ls ~/.config/i3/`

The display setup should now work automatically when you start i3! 🖥️
