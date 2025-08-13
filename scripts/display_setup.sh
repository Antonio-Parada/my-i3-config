#!/bin/bash

# Display Setup Script for i3
# Handles multiple monitors and sets primary display correctly

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Function to detect displays
detect_displays() {
    print_status "Detecting connected displays..."
    xrandr --query | grep " connected" | while read line; do
        display=$(echo $line | cut -d' ' -f1)
        status=$(echo $line | cut -d' ' -f2)
        resolution=$(echo $line | cut -d' ' -f3 | cut -d'+' -f1)
        echo "  $display: $status ($resolution)"
    done
}

# Function to set primary display (main laptop screen)
set_primary_display() {
    print_status "Configuring display setup..."
    
    # Get all connected displays
    DISPLAYS=($(xrandr --query | grep " connected" | cut -d' ' -f1))
    
    if [ ${#DISPLAYS[@]} -eq 0 ]; then
        print_error "No displays detected!"
        return 1
    fi
    
    # Common laptop screen names (usually the main display)
    MAIN_DISPLAY_PATTERNS=("eDP" "LVDS" "LCD" "VGA" "HDMI1" "DP1")
    MAIN_DISPLAY=""
    
    # Find the main display
    for display in "${DISPLAYS[@]}"; do
        for pattern in "${MAIN_DISPLAY_PATTERNS[@]}"; do
            if [[ $display == *"$pattern"* ]]; then
                MAIN_DISPLAY=$display
                break 2
            fi
        done
    done
    
    # If no main display found, use the first one
    if [ -z "$MAIN_DISPLAY" ]; then
        MAIN_DISPLAY=${DISPLAYS[0]}
        print_warning "Could not identify main display, using: $MAIN_DISPLAY"
    else
        print_status "Main display identified: $MAIN_DISPLAY"
    fi
    
    # Configure displays
    print_status "Setting up display configuration..."
    
    # Set the main display as primary and enable it
    xrandr --output "$MAIN_DISPLAY" --primary --auto
    
    # Disable or position secondary displays appropriately
    for display in "${DISPLAYS[@]}"; do
        if [ "$display" != "$MAIN_DISPLAY" ]; then
            # Check if this looks like a touchscreen/trackpad display
            if [[ $display == *"HDMI"* ]] || [[ $display == *"DP"* ]] || [[ $display == *"VGA"* ]]; then
                # External monitor - position to the right
                print_status "Setting up external monitor: $display"
                xrandr --output "$display" --auto --right-of "$MAIN_DISPLAY"
            else
                # Likely a touchscreen/trackpad display - disable it
                print_status "Disabling secondary display: $display"
                xrandr --output "$display" --off
            fi
        fi
    done
    
    print_status "Display configuration complete!"
}

# Function to create a more robust display setup
setup_display_autostart() {
    print_status "Creating display autostart configuration..."
    
    # Create autostart script
    cat > ~/.config/i3/display_autostart.sh << 'EOF'
#!/bin/bash

# Wait for X to be ready
sleep 2

# Get primary display (usually eDP-1, LVDS-1, or similar for laptops)
PRIMARY_DISPLAY=$(xrandr --query | grep " connected primary" | cut -d' ' -f1)

# If no primary set, find main laptop display
if [ -z "$PRIMARY_DISPLAY" ]; then
    PRIMARY_DISPLAY=$(xrandr --query | grep -E "(eDP|LVDS|LCD)" | grep " connected" | head -1 | cut -d' ' -f1)
fi

# If still not found, use first connected display
if [ -z "$PRIMARY_DISPLAY" ]; then
    PRIMARY_DISPLAY=$(xrandr --query | grep " connected" | head -1 | cut -d' ' -f1)
fi

# Set as primary and enable
if [ -n "$PRIMARY_DISPLAY" ]; then
    xrandr --output "$PRIMARY_DISPLAY" --primary --auto
    
    # Disable secondary displays that might interfere
    xrandr --query | grep " connected" | cut -d' ' -f1 | while read display; do
        if [ "$display" != "$PRIMARY_DISPLAY" ]; then
            # Check if it's likely a touchscreen/trackpad display (small resolution)
            resolution=$(xrandr --query | grep -A1 "^$display" | tail -1 | awk '{print $1}' | cut -d'x' -f1)
            if [ -n "$resolution" ] && [ "$resolution" -lt 800 ]; then
                xrandr --output "$display" --off
            fi
        fi
    done
fi
EOF

    chmod +x ~/.config/i3/display_autostart.sh
    print_status "Display autostart script created at ~/.config/i3/display_autostart.sh"
}

# Main execution
main() {
    echo "=== i3 Display Configuration Tool ==="
    
    case "${1:-auto}" in
        "detect")
            detect_displays
            ;;
        "setup"|"auto")
            detect_displays
            echo ""
            set_primary_display
            setup_display_autostart
            ;;
        "help")
            echo "Usage: $0 [detect|setup|help]"
            echo "  detect - Show connected displays"
            echo "  setup  - Configure displays (default)"
            echo "  help   - Show this help"
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
