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
| **Navigation** | Pads up/down, Encoder up/down |

Available actions include native FL Studio API calls (Toggle Pat/Song, Save, Undo, Redo, Copy, Cut, Paste, F1–F12, etc.) and custom keystrokes for anything else (like Cmd+Shift+R to export as MP3).

### Custom Keystrokes

Send any macOS keyboard shortcut from a shift button press. Works around FL Studio's sandboxed Python by queuing commands during MIDI callbacks and flushing them via a background keystroke server during OnIdle. See [docs/custom-keystrokes.md](docs/custom-keystrokes.md) for technical details.

## Installation

```bash
chmod +x install.sh restore.sh

# Install the patch (backs up originals automatically)
./install.sh

# Restart FL Studio (one time only)
```

The installer handles everything: patched scripts, config files, keystroke server binary, and LaunchAgent setup.

### Custom Keystroke Setup

If you want to use custom keystrokes (e.g., Cmd+Shift+R for export):

1. Run `./install.sh` (installs and starts the keystroke server)
2. Open **System Settings → Privacy & Security → Accessibility**
3. Click **+**, press **Cmd+Shift+G**, paste `~/.tweaker/tweaker_keystroke_server`
4. Toggle it **on**
5. Set `enable_custom_keystrokes` to `true` in Tweaker.app
6. Assign a button to **Custom Keystroke** and configure the key/modifiers

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

Encoder presets: Stock, Fast (3x–4x), Turbo (6x–8x).

## Restoring Originals

```bash
./restore.sh
# Restart FL Studio
```

## Documentation

- [Custom Keystrokes](docs/custom-keystrokes.md) — architecture, setup, troubleshooting
- [Known Issues](docs/known-issues.md) — FL Studio subinterpreter limitations, Accessibility trust
- [Changelog](CHANGELOG.md) — version history

## Notes

- **Novation Components** or **FL Studio updates** may overwrite patched files — re-run `./install.sh`.
- Only transport mode encoders are affected. Mixer, plugin, and sends modes are untouched.
- Works with all MK4 sizes (25/37/49/61/88).
