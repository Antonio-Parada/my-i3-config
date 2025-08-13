# My i3 Window Manager Configuration

A complete i3 window manager setup with automatic alternating layout functionality for Debian-based systems.

## Features

- **i3 Window Manager**: Complete configuration with sensible defaults
- **Automatic Layout Management**: Windows automatically alternate between horizontal and vertical splits based on their dimensions
- **Easy Installation**: One-command setup script for Debian/Ubuntu systems
- **Git Sync Ready**: Keep your configuration synchronized across multiple machines

## Quick Install

Run this command on your Debian-based system:

```bash
curl -sSL https://raw.githubusercontent.com/Antonio-Parada/my-i3-config/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/Antonio-Parada/my-i3-config.git
cd my-i3-config
chmod +x install.sh
./install.sh
```

## What Gets Installed

1. **i3 window manager** and related packages
2. **i3status** for the status bar
3. **Python dependencies** (i3ipc library)
4. **Configuration files** copied to appropriate locations
5. **Alternating layout script** that runs automatically

## How to Use

### After Installation

1. **Log out** of your current desktop session
2. At the **login screen**, select **"i3"** from the session menu
3. Log back in to start using i3

### Key Bindings

- `Super + Return`: Open terminal
- `Super + d`: Application launcher (dmenu)
- `Super + Shift + q`: Close focused window
- `Super + 1-0`: Switch to workspace 1-10
- `Super + Shift + 1-0`: Move window to workspace 1-10
- `Super + Shift + r`: Restart i3 (reload configuration)
- `Super + Shift + e`: Exit i3

### Automatic Layout Feature

The alternating layout script automatically manages window splits:

- **Wide windows** (width > height): Next window opens with vertical split
- **Tall windows** (height > width): Next window opens with horizontal split
- Creates balanced, natural layouts without manual split management

## File Structure

```
├── config/               # i3 configuration
│   └── i3/
│       └── config       # Main i3 configuration file
├── scripts/             # Window management scripts
│   ├── alternating_layouts.py
│   └── test_script.py
├── install.sh          # Installation script
└── README.md           # This file
```

## Customization

### Modifying i3 Configuration

Edit `config/i3/config` and then run:

```bash
git add -A
git commit -m "Update i3 configuration"
git push
```

### Syncing to Another Machine

On your other machine:

```bash
git pull origin main
./install.sh  # This will backup existing configs before overwriting
```

## Troubleshooting

### Script Not Running

Check if the script is active:
```bash
pgrep -f alternating_layouts.py
```

If not running, restart i3:
```bash
i3-msg restart
```

### Configuration Issues

Test your i3 config syntax:
```bash
i3 -C -c ~/.config/i3/config
```

### Manual Script Testing

Test the script manually (when i3 is running):
```bash
python3 ~/.local/bin/alternating_layouts.py
```

## Dependencies

- **OS**: Debian/Ubuntu/Kali Linux
- **Python**: 3.6+ (with pip)
- **i3**: Latest stable version
- **Python Package**: i3ipc

## Contributing

Feel free to fork this repository and customize it for your needs. Submit pull requests for improvements!

## License

This configuration is free to use and modify. The alternating layout script is adapted from [olemartinorg/i3-alternating-layout](https://github.com/olemartinorg/i3-alternating-layout).

---

**Happy tiling!** 🪟✨
