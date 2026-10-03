# Launchkey Tweaker

Custom transport encoder speed patch + shift button remapping for the Novation Launchkey MK4 in FL Studio on macOS.

The stock Novation scripts ignore how fast you turn transport knobs, leave 20+ shift button combos completely dead, and only map 4 of 8 encoders. Tweaker fixes all of that.

Includes a native SwiftUI config app. Changes apply live — no FL Studio restart needed after initial setup.

![Launchkey Tweaker](screenshot.png)

## Features

### Transport Encoders

All 8 transport mode knobs are configurable with velocity-sensitive speed scaling:

| Encoder | Stock Behavior | With Tweaker |
|---------|---------------|------------|
| **Knob 1** — Song Position | 1 beat per click, always | Scales with turn speed |
| **Knob 2** — Zoom | 1 zoom step per click | Scales with turn speed |
| **Knob 3–4** — *empty* | Does nothing | Configurable |
| **Knob 5** — Markers | Requires 3 clicks to jump | Instant |
| **Knob 6–7** — *empty* | Does nothing | Configurable |
| **Knob 8** — Tempo | ~1 BPM per click | Scales with turn speed |

Available knob functions: Song Position, Horizontal/Vertical Zoom, Markers, Tempo, Track Volume/Pan, Channel Volume/Pan, Swing.

### Shift Button Mappings

20+ shift button combos that Novation left unmapped, now configurable:

| Group | Buttons |
|-------|---------|
| **Transport** | Stop, Play, Record, Loop, Capture MIDI, Quantise, Metronome |
| **Fader Select** | Faders 1–8, Arm/Select |
| **Navigation** | Pads ▲/▼, Encoder ▲/▼ |

Available actions: Toggle Pat/Song, Tap Tempo, Toggle Metronome, Toggle Loop Record, Undo, Redo, Save, Save New, Toggle Snap, Add Marker, Toggle Step Edit, Toggle Countdown, Toggle Overdub, Toggle Shuffle, Clone Pattern, Toggle Master Sync, Next Window, Focus Mixer/Channel Rack/Playlist, Open Plugin Picker, or any Custom Keystroke via macOS accessibility.

## Installation

```bash
chmod +x install.sh restore.sh

# Install the patch (backs up originals automatically)
./install.sh

# Restart FL Studio (one time only)
```

## Tweaker App

Build and open the config app:

```bash
cd Tweaker
swift build -c release
cp .build/arm64-apple-macosx/release/Tweaker ../Tweaker.app/Contents/MacOS/Tweaker
open ../Tweaker.app
```

Or just open `Tweaker.app` if already built.

The app has two sections:
- **Transport Encoders** — knob function assignment with speed/sensitivity sliders
- **Shift Button Mappings** — button cards laid out matching hardware positions with function picker popovers and custom keystroke support

Themes: Midnight, Arctic, FL Studio, System.

Encoder presets: Stock, Fast (3–4x), Turbo (6–8x).

## Restoring Originals

```bash
./restore.sh
# Restart FL Studio
```

## Notes

- **Novation Components** or **FL Studio updates** may overwrite patched files — re-run `./install.sh`.
- Only transport mode encoders are affected. Mixer, plugin, and sends modes are untouched.
- Works with all MK4 sizes (25/37/49/61/88).
- Custom Keystroke requires macOS Accessibility permissions for FL Studio.
