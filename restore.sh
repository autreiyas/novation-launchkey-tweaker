#!/bin/bash
#
# Restore original Novation scripts for Launchkey MK4
#

set -e

NOVATION_DIR="$HOME/Documents/Image-Line/FL Studio/Settings/Hardware/Novation"
VIEW_DIR="$NOVATION_DIR/script/device_independent/view"
LAYOUT_DIR="$NOVATION_DIR/script/device_dependent/LaunchkeyMk4Range"
APP_DIR="$NOVATION_DIR/script/device_dependent/LaunchkeyMk4"
PRODUCT_DEFS_DIR="$NOVATION_DIR/script/product_defs"
ACTION_GEN_DIR="$NOVATION_DIR/script/action_generators/surface_action_generator"
BACKUP_DIR="$HOME/Documents/Image-Line/FL Studio/Settings/Hardware/Novation_backup_originals"

FILES=(
    "transport_song_position_view.py"
    "transport_zoom_view.py"
    "transport_marker_view.py"
    "transport_tempo_view.py"
)

echo "=== Restoring Original Novation Scripts ==="
echo ""

if [ ! -d "$BACKUP_DIR" ]; then
    echo "ERROR: No backup directory found at:"
    echo "  $BACKUP_DIR"
    echo "Cannot restore — backups were never created."
    exit 1
fi

# Restore view files
for f in "${FILES[@]}"; do
    if [ -f "$BACKUP_DIR/$f" ]; then
        cp "$BACKUP_DIR/$f" "$VIEW_DIR/$f"
        echo "  Restored: $f"
    else
        echo "  WARNING: No backup found for $f"
    fi
done

# Restore layout manager
if [ -f "$BACKUP_DIR/transport_encoder_layout_manager.py" ]; then
    cp "$BACKUP_DIR/transport_encoder_layout_manager.py" "$LAYOUT_DIR/transport_encoder_layout_manager.py"
    echo "  Restored: transport_encoder_layout_manager.py"
fi

# Restore product_defs
if [ -f "$BACKUP_DIR/launchkey_mk4_product_defs.py" ]; then
    cp "$BACKUP_DIR/launchkey_mk4_product_defs.py" "$PRODUCT_DEFS_DIR/launchkey_mk4_product_defs.py"
    echo "  Restored: launchkey_mk4_product_defs.py"
fi

# Restore surface_action_generator
if [ -f "$BACKUP_DIR/launchkey_mk4_surface_action_generator.py" ]; then
    cp "$BACKUP_DIR/launchkey_mk4_surface_action_generator.py" "$ACTION_GEN_DIR/launchkey_mk4_surface_action_generator.py"
    echo "  Restored: launchkey_mk4_surface_action_generator.py"
fi

# Restore application
if [ -f "$BACKUP_DIR/application.py" ]; then
    cp "$BACKUP_DIR/application.py" "$APP_DIR/application.py"
    echo "  Restored: application.py"
fi

# Clean up added files
rm -rf "$NOVATION_DIR/patched_views" 2>/dev/null && echo "  Removed: patched_views/"
rm -f "$NOVATION_DIR/transport_speed_config.py" 2>/dev/null && echo "  Removed: transport_speed_config.py"
rm -f "$NOVATION_DIR/tweaker_config.json" 2>/dev/null && echo "  Removed: tweaker_config.json"

echo ""
echo "=== Restore complete! Restart FL Studio. ==="
