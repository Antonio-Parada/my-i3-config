#!/usr/bin/env python3
"""
Test script to verify the alternating layout script functionality.
This can be run when i3 is active to test if the script works.
"""

import sys
import subprocess
import time
from i3ipc import Connection

def test_i3_connection():
    """Test if we can connect to i3"""
    try:
        i3 = Connection()
        tree = i3.get_tree()
        print("✓ Successfully connected to i3")
        print(f"  Current workspace: {tree.find_focused().workspace().name}")
        return True
    except Exception as e:
        print(f"✗ Failed to connect to i3: {e}")
        return False

def test_script_running():
    """Check if the alternating layout script is already running"""
    try:
        result = subprocess.run(['pgrep', '-f', 'alternating_layouts.py'], 
                              capture_output=True, text=True)
        if result.stdout.strip():
            print("✓ Alternating layout script is running")
            print(f"  PID: {result.stdout.strip()}")
            return True
        else:
            print("✗ Alternating layout script is not running")
            return False
    except Exception as e:
        print(f"✗ Error checking script status: {e}")
        return False

def main():
    print("Testing i3 alternating layout setup...")
    print("=" * 40)
    
    # Test i3 connection
    if not test_i3_connection():
        print("\nℹ️  i3 is not currently running. To test:")
        print("   1. Log out of your current session")
        print("   2. At the login screen, select 'i3' as your session")
        print("   3. Log back in and run this test script")
        sys.exit(1)
    
    # Test if script is running
    script_running = test_script_running()
    
    print("\n" + "=" * 40)
    if script_running:
        print("✓ Setup appears to be working correctly!")
        print("\nTo test the functionality:")
        print("  1. Open a terminal (Super+Return)")
        print("  2. Open more terminals and observe the layout")
        print("  3. Windows should alternate between horizontal and vertical splits")
        print("     based on their dimensions")
    else:
        print("⚠️  Setup is ready but script is not running yet.")
        print("\nThe script will start automatically when i3 starts.")
        print("If you're currently in i3 and it's not running, try:")
        print("  Super+Shift+R (restart i3)")
    
    print(f"\nConfiguration file: ~/.config/i3/config")
    print(f"Script location: /home/super/Documents/i3-alternating-layout/alternating_layouts.py")

if __name__ == "__main__":
    main()
