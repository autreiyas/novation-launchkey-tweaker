# Tweaker — Launchkey MK4 Transport Encoder Patch for FL Studio

The Novation Launchkey MK4's transport mode encoders are painfully slow in FL Studio — even with the keyboard's encoder speed set to "Fast". Tweaker fixes that, lets you remap all 8 transport knobs to any function, and adds configurable shift button mappings for 20+ button combos that Novation left unmapped.

Includes a native macOS config app with theme support. Changes apply live — no FL Studio restart needed after initial setup.

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

## Shift Button Mappings

The stock Novation scripts leave 20+ shift button combos completely dead — pressing Shift + Play/Record/Loop/etc does nothing. Tweaker intercepts these and lets you map them to FL Studio functions.

### Available Shift Buttons

| Group | Buttons |
|-------|---------|
| **Transport** | Stop, Play, Record, Loop, Capture MIDI, Quantise, Metronome, Undo (stock: Redo) |
| **Fader Select** | Faders 1–8, Arm/Select |
| **Navigation** | Track ◀/▶ (stock: Prev/Next Track), Pads ▲/▼, Encoder ▲/▼ |

### Available Button Functions

| Function | Description |
|----------|-------------|
| Toggle Pat/Song | Switch between pattern and song mode |
| Tap Tempo | Tap tempo input |
| Toggle Metronome | Metronome on/off |
| Toggle Loop Record | Loop recording on/off |
| Undo / Redo | Undo or redo last action |
| Save / Save New | Save project or save as new version |
| Toggle Snap | Snap to grid on/off |
| Add Marker | Add arrangement marker at current position |
| Toggle Step Edit | Step editing mode |
| Toggle Countdown | Pre-count before recording |
| Toggle Overdub | Overdub recording mode |
| Toggle Shuffle | Shuffle/swing mode |
| Clone Pattern | Duplicate the selected pattern |
| Toggle Master Sync | Master sync on/off |
| Next Window | Cycle through FL Studio windows |
| Focus Mixer / Channel Rack / Playlist | Bring specific window to front |
| Open Plugin Picker | Open the plugin browser |
| Custom Keystroke | Send any key combo (e.g. ⌘⇧V) via macOS accessibility |

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

The app shows:
- **Transport Encoders** — all 8 knobs with function assignment dropdowns and speed sliders
- **Shift Button Mappings** — transport, fader select, and navigation buttons laid out matching hardware positions, with function picker popovers and custom keystroke support

Four themes are included: Midnight, Arctic, FL Studio, and System.

Three encoder presets are included:
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
script/product_defs/launchkey_mk4_product_defs.py
script/action_generators/surface_action_generator/launchkey_mk4_surface_action_generator.py
script/device_dependent/LaunchkeyMk4/application.py
```

### Added

```
transport_speed_config.py          # Config loader (hot-reload from JSON)
tweaker_config.json                # Your settings (edited by Tweaker app)
patched_views/                     # Custom modules
    transport_vertical_zoom_view.py
    transport_track_volume_view.py
    transport_track_pan_view.py
    transport_channel_volume_view.py
    transport_channel_pan_view.py
    transport_swing_view.py
    tweaker_button_view.py         # Shift button handler
    keystroke_sender.py            # macOS keystroke simulation via CGEvents
    launchkey_mk4_product_defs.py  # Patched product defs (adds shifted buttons)
    launchkey_mk4_surface_action_generator.py  # Patched action generator
    application.py                 # Patched app (registers button view)
Tweaker/                           # Native SwiftUI config app
```
