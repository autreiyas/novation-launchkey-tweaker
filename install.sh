#!/bin/bash
#
# Install Tweaker — Launchkey MK4 transport encoder patch for FL Studio
#
# This script:
#   1. Backs up the original Novation transport view files
#   2. Installs patched views with speed multipliers + custom knob mappings
#   3. Installs patched product_defs, surface_action_generator, and application
#   4. Installs the config loader and default config JSON
#   5. Installs the custom view modules for extra knob functions
#   6. Installs shifted button remapping support
#
# To restore originals: ./restore.sh
#

set -e

NOVATION_DIR="$HOME/Documents/Image-Line/FL Studio/Settings/Hardware/Novation"
VIEW_DIR="$NOVATION_DIR/script/device_independent/view"
LAYOUT_DIR="$NOVATION_DIR/script/device_dependent/LaunchkeyMk4Range"
APP_DIR="$NOVATION_DIR/script/device_dependent/LaunchkeyMk4"
PRODUCT_DEFS_DIR="$NOVATION_DIR/script/product_defs"
ACTION_GEN_DIR="$NOVATION_DIR/script/action_generators/surface_action_generator"
BACKUP_DIR="$HOME/Documents/Image-Line/FL Studio/Settings/Hardware/Novation_backup_originals"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Original files to back up and replace
VIEW_FILES=(
    "transport_song_position_view.py"
    "transport_zoom_view.py"
    "transport_marker_view.py"
    "transport_tempo_view.py"
)

# Custom view modules (new files, no backup needed)
CUSTOM_VIEWS=(
    "transport_vertical_zoom_view.py"
    "transport_track_volume_view.py"
    "transport_track_pan_view.py"
    "transport_channel_volume_view.py"
    "transport_channel_pan_view.py"
    "transport_swing_view.py"
    "tweaker_button_view.py"
    "keystroke_sender.py"
)

echo "=== Tweaker — Launchkey MK4 Patch ==="
echo ""

# Check that the Novation directory exists
if [ ! -d "$VIEW_DIR" ]; then
    echo "ERROR: Novation script directory not found at:"
    echo "  $VIEW_DIR"
    echo "Make sure FL Studio and the Novation scripts are installed."
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup original view files
echo "Backing up original files..."
for f in "${VIEW_FILES[@]}"; do
    if [ -f "$VIEW_DIR/$f" ] && [ ! -f "$BACKUP_DIR/$f" ]; then
        cp "$VIEW_DIR/$f" "$BACKUP_DIR/$f"
        echo "  Backed up: $f"
    elif [ -f "$BACKUP_DIR/$f" ]; then
        echo "  Already backed up: $f"
    fi
done

# Backup layout manager
if [ -f "$LAYOUT_DIR/transport_encoder_layout_manager.py" ] && [ ! -f "$BACKUP_DIR/transport_encoder_layout_manager.py" ]; then
    cp "$LAYOUT_DIR/transport_encoder_layout_manager.py" "$BACKUP_DIR/transport_encoder_layout_manager.py"
    echo "  Backed up: transport_encoder_layout_manager.py"
fi

# Backup product_defs
if [ -f "$PRODUCT_DEFS_DIR/launchkey_mk4_product_defs.py" ] && [ ! -f "$BACKUP_DIR/launchkey_mk4_product_defs.py" ]; then
    cp "$PRODUCT_DEFS_DIR/launchkey_mk4_product_defs.py" "$BACKUP_DIR/launchkey_mk4_product_defs.py"
    echo "  Backed up: launchkey_mk4_product_defs.py"
fi

# Backup surface_action_generator
if [ -f "$ACTION_GEN_DIR/launchkey_mk4_surface_action_generator.py" ] && [ ! -f "$BACKUP_DIR/launchkey_mk4_surface_action_generator.py" ]; then
    cp "$ACTION_GEN_DIR/launchkey_mk4_surface_action_generator.py" "$BACKUP_DIR/launchkey_mk4_surface_action_generator.py"
    echo "  Backed up: launchkey_mk4_surface_action_generator.py"
fi

# Backup application
if [ -f "$APP_DIR/application.py" ] && [ ! -f "$BACKUP_DIR/application.py" ]; then
    cp "$APP_DIR/application.py" "$BACKUP_DIR/application.py"
    echo "  Backed up: application.py"
fi

# Install patched view files
echo ""
echo "Installing patched views..."
for f in "${VIEW_FILES[@]}"; do
    cp "$SCRIPT_DIR/patched_views/$f" "$VIEW_DIR/$f"
    echo "  Installed: $f"
done

# Install custom view modules into a patched_views package inside Novation dir
echo ""
echo "Installing custom knob & button views..."
mkdir -p "$NOVATION_DIR/patched_views"
touch "$NOVATION_DIR/patched_views/__init__.py"
for f in "${CUSTOM_VIEWS[@]}"; do
    cp "$SCRIPT_DIR/patched_views/$f" "$NOVATION_DIR/patched_views/$f"
    echo "  Installed: patched_views/$f"
done

# Install layout manager
echo ""
echo "Installing transport encoder layout manager..."
cp "$SCRIPT_DIR/patched_views/transport_encoder_layout_manager.py" "$LAYOUT_DIR/transport_encoder_layout_manager.py"
echo "  Installed: transport_encoder_layout_manager.py"

# Check if shift buttons are enabled in config
SHIFT_ENABLED=$(python3 -c "import json; c=json.load(open('$SCRIPT_DIR/tweaker_config.json')); print(c.get('enable_shift_buttons', False))" 2>/dev/null || echo "False")

if [ "$SHIFT_ENABLED" = "True" ]; then
    echo ""
    echo "Installing shift button patches (enable_shift_buttons=true)..."
    cp "$SCRIPT_DIR/patched_views/launchkey_mk4_product_defs.py" "$PRODUCT_DEFS_DIR/launchkey_mk4_product_defs.py"
    echo "  Installed: launchkey_mk4_product_defs.py"
    cp "$SCRIPT_DIR/patched_views/launchkey_mk4_surface_action_generator.py" "$ACTION_GEN_DIR/launchkey_mk4_surface_action_generator.py"
    echo "  Installed: launchkey_mk4_surface_action_generator.py"
    cp "$SCRIPT_DIR/patched_views/application.py" "$APP_DIR/application.py"
    echo "  Installed: application.py"
else
    echo ""
    echo "Shift button patches DISABLED (set enable_shift_buttons=true to enable)."
    # Restore originals if they were previously patched
    if [ -f "$BACKUP_DIR/launchkey_mk4_product_defs.py" ]; then
        cp "$BACKUP_DIR/launchkey_mk4_product_defs.py" "$PRODUCT_DEFS_DIR/launchkey_mk4_product_defs.py"
    fi
    if [ -f "$BACKUP_DIR/launchkey_mk4_surface_action_generator.py" ]; then
        cp "$BACKUP_DIR/launchkey_mk4_surface_action_generator.py" "$ACTION_GEN_DIR/launchkey_mk4_surface_action_generator.py"
    fi
    if [ -f "$BACKUP_DIR/application.py" ]; then
        cp "$BACKUP_DIR/application.py" "$APP_DIR/application.py"
    fi
fi

# Clear pycache to avoid stale bytecode
find "$NOVATION_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null

# Install config loader + default config
echo ""
echo "Installing config..."
cp "$SCRIPT_DIR/transport_speed_config.py" "$NOVATION_DIR/transport_speed_config.py"
echo "  Installed: transport_speed_config.py"

if [ ! -f "$NOVATION_DIR/tweaker_config.json" ]; then
    cp "$SCRIPT_DIR/tweaker_config.json" "$NOVATION_DIR/tweaker_config.json"
    echo "  Installed: tweaker_config.json (default)"
else
    echo "  Kept existing: tweaker_config.json"
fi

echo ""
echo "=== Installation complete! ==="
echo ""
echo "1. Restart FL Studio for changes to take effect."
echo "2. Use Tweaker to adjust settings live:"
echo "   $SCRIPT_DIR/Tweaker.app"
echo ""
echo "To restore originals: ./restore.sh"
