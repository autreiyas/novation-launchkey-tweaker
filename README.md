# Tweaker — Launchkey MK4 Transport Encoder Patch for FL Studio

The Novation Launchkey MK4's transport mode encoders are painfully slow in FL Studio — even with the keyboard's encoder speed set to "Fast". Tweaker fixes that and lets you remap all 8 transport knobs to any function you want.

Includes a native macOS config app. Changes apply live — no FL Studio restart needed after initial setup.

## The Problem

When the Launchkey MK4 is in transport mode, only 4 of 8 encoders are mapped, and the stock Novation scripts **ignore how fast you turn the knob**:

| Encoder | Stock Behavior | With Tweaker |
|---------|---------------|------------|
| **Knob 1** — Song Position | 1 beat per click, always | Scales with turn speed |
| **Knob 2** — Zoom | 1 zoom step per click | Scales with turn speed |
| **Knob 3** — *empty* | Does nothing | Configurable |
| **Knob 4** — *empty* | Does nothing | Configurable |
| **Knob 5** — Markers | Requires 3 clicks to jump | Instant |
| **Knob 6** — *empty* | Does nothing | Configurable |
| **Knob 7** — *empty* | Does nothing | Configurable |
| **Knob 8** — Tempo | ~1 BPM per click | Scales with turn speed |

## Available Knob Functions

Any of the 8 transport encoders can be mapped to any of these:

| Function | Description |
|----------|-------------|
| Song Position | Scrub through the song by beats |
| Horizontal Zoom | Zoom the playlist/piano roll left-right |
| Vertical Zoom | Zoom the playlist/piano roll up-down |
| Markers | Jump between arrangement markers |
| Tempo | Adjust project BPM |
| Track Volume | Selected mixer track volume |
| Track Pan | Selected mixer track panning |
| Channel Volume | Selected channel rack volume |
| Channel Pan | Selected channel rack panning |
| Swing | Project swing amount |
| Not Used | Disabled |

## Installation

```bash
cd launchkey_mk4321

chmod +x install.sh restore.sh

# Install the patch (backs up originals automatically)
./install.sh

# Restart FL Studio (one time only)
```

## Tweaker App

After installing, open the native config app to remap knobs and adjust speeds:

```bash
./Tweaker.app
```

Or build it from source:

```bash
cd Tweaker && swift build -c release
```

The app shows all 8 knobs with dropdown menus for function assignment and sliders for speed/sensitivity. Changes save to a JSON config file that FL Studio picks up live on the next encoder turn.

Three presets are included:
- **Stock** — original Novation behavior
- **Fast** — all knobs mapped, 3-4x faster
- **Turbo** — all knobs mapped, 6-8x faster

## Restoring Originals

```bash
./restore.sh
# Restart FL Studio
```

Backups are stored in `~/Documents/Image-Line/FL Studio/Settings/Hardware/Novation_backup_originals/`.

## Important Notes

- **Novation Components updates** may overwrite patched files. Re-run `./install.sh` after updates.
- **FL Studio updates** may also replace scripts. Same fix — re-run `./install.sh`.
- Only transport mode encoders are affected. Mixer, plugin, and sends modes are untouched.
- Works with all MK4 sizes (25/37/49/61/88) — they share the same scripts.

## Files

### Patched (backed up before modification)

```
script/device_independent/view/transport_song_position_view.py
script/device_independent/view/transport_zoom_view.py
script/device_independent/view/transport_marker_view.py
script/device_independent/view/transport_tempo_view.py
script/device_dependent/LaunchkeyMk4Range/transport_encoder_layout_manager.py
```

### Added

```
transport_speed_config.py          # Config loader (hot-reload from JSON)
tweaker_config.json                # Your settings (edited by Tweaker app)
patched_views/                     # Custom knob function modules
    transport_vertical_zoom_view.py
    transport_track_volume_view.py
    transport_track_pan_view.py
    transport_channel_volume_view.py
    transport_channel_pan_view.py
    transport_swing_view.py
```
