#!/bin/bash
#
# Install Tweaker — Launchkey MK4 transport encoder patch for FL Studio
#
# This script:
#   1. Backs up the original Novation transport view files
#   2. Installs patched views with speed multipliers + custom knob mappings
#   3. Installs the config loader and default config JSON
#   4. Installs the custom view modules for extra knob functions
#
# To restore originals: ./restore.sh
#

set -e

NOVATION_DIR="$HOME/Documents/Image-Line/FL Studio/Settings/Hardware/Novation"
VIEW_DIR="$NOVATION_DIR/script/device_independent/view"
LAYOUT_DIR="$NOVATION_DIR/script/device_dependent/LaunchkeyMk4Range"
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
)

echo "=== Tweaker — Launchkey MK4 Transport Encoder Patch ==="
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

# Install patched view files
echo ""
echo "Installing patched views..."
for f in "${VIEW_FILES[@]}"; do
    cp "$SCRIPT_DIR/patched_views/$f" "$VIEW_DIR/$f"
    echo "  Installed: $f"
done

# Install custom view modules into a patched_views package inside Novation dir
echo ""
echo "Installing custom knob views..."
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
echo "1. Restart FL Studio for the initial setup."
echo "2. After that, use Tweaker to adjust settings live:"
echo "   $SCRIPT_DIR/Tweaker.app"
echo ""
echo "To restore originals: ./restore.sh"
