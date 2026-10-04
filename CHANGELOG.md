# Changelog

## 1.0.9

### Added
- Sensitivity slider for encoder keystroke mode — controls how many clicks before a keystroke fires (1–10, default 3)
- Open Config button in header bar — opens the saved `tweaker_config.json` in your default editor
- Button keystroke key picker now uses a dropdown instead of a text field — Space, Enter, Return, and arrow keys are now selectable

### Fixed
- Encoder keystrokes config was not being saved to the JSON file (missing serialization)

## 1.0.8

### Added
- Encoder keystroke mode — send configurable keystrokes on encoder turns (e.g., arrow left/right for navigation)
- Each encoder can be set to "Keystroke" with separate clockwise and counter-clockwise key + modifier bindings
- Encoder turns repeat the keystroke proportionally to turn speed

## 1.0.7

### Added
- Hover effects on encoder and button cards (scale, accent border glow)
- Encoder knob notch rotates 45 degrees on hover
- Status bar notifications fade out after 4 seconds

### Changed
- Button card icons enlarged (14pt → 20pt), labels (10pt → 13pt), function text (10pt → 12pt)
- Button grid spacing increased (8pt → 18pt) to accommodate hover scaling

## 1.0.6

### Fixed
- **Custom keystrokes now working** — complete pipeline from button press to macOS keystroke delivery
- Discovered FL Studio's subinterpreter allows `open()` in the script directory but nowhere else
- Keystroke commands queued during MIDI callbacks, flushed during OnIdle via `TimerEventAction`

### Added
- File-based IPC: Python writes command file to Novation script dir, server polls and executes
- Keystroke server auto-install via `install.sh` (binary, LaunchAgent, Accessibility instructions)
- `docs/` directory with custom keystroke architecture, known issues documentation

### Changed
- Keystroke server rewritten to use file polling instead of FIFO (FIFO blocked by subinterpreter)
- Keystroke server uses CGEvents (with AppleScript fallback) instead of standalone helper binary
- `install.sh` now handles full keystroke server setup (binary install, LaunchAgent, codesign)
- Updated README with custom keystroke setup instructions

## 1.0.5

### Added
- Native FL Studio API actions: Copy, Cut, Paste, Delete, Insert, Nudge +/-, Punch In/Out, Mute, Wait for Input
- F1–F12 keyboard shortcuts mapped to `FPT_F*` API constants (F5=Playlist, F9=Mixer, F10=MIDI Settings, etc.)
- Toggle Browser and Open Menu actions
- Button function picker now grouped by category (Transport, Editing, Windows, Navigation, Other)
- Configurable debug flags in `tweaker_config.json` (`debug.log_actions`, `debug.dump_midi_constants`, `debug.dump_api_methods`)

### Removed
- Fader select buttons from shift mapping — Shift+Fader is used by stock firmware for fader mode switching

### Changed
- F-key dispatch simplified to single lookup (`FPT_F1`–`FPT_F12`)
- Debug output on FL Studio startup now controlled by config flags instead of hardcoded

## 1.0.4

### Added
- `enable_custom_keystrokes` config flag — custom keystroke option hidden in UI when `false`
- Background keystroke server (`tweaker_keystroke_server`) with FIFO-based IPC for macOS keystroke simulation
- LaunchAgent plist for auto-starting the keystroke server

### Changed
- Keystroke sender rewritten to use FIFO pipe to background server (replaces direct `osascript` calls)
- Keystroke helper binary installed to `~/.tweaker/` (avoids spaces in FL Studio path)

## 1.0.3

### Fixed
- Pat/song toggle now works — uses `transport.setLoopMode()` (takes no arguments, it's a toggle)
- All globalTransport commands now use `midi` module constants directly via `getattr` instead of hardcoded values
- Keystroke sender rewritten to use `os.system` + `osascript` — ctypes and subprocess both fail in FL Studio's Python subinterpreter

### Changed
- Discovered correct midi constant names from FL Studio's midi module dump (e.g. `FPT_Mode`, `FPT_Snap`, `FPT_Save`)
- Action dispatcher logs all actions to Script Output for debugging

## 1.0.2

### Fixed
- Removed dangerous globalTransport command ID fallback loop that was triggering undo/redo
- Keystroke sender now falls back to hardcoded framework paths when `ctypes.util.find_library` fails in FL Studio's embedded Python
- Cleared stale `__pycache__` `.cpython-314` bytecode that was crashing FL Studio's Python 3.9
- install.sh now clears all `__pycache__` on every install

### Added
- `enable_shift_buttons` config flag — shift button patches only install when `true`
- Tweaker app hides the button mapping section when shift buttons are disabled
- install.sh conditionally installs/restores shift button patches based on the flag

### Changed
- All globalTransport constants use safe `getattr` lookups from FL Studio's `midi` module with hardcoded fallbacks
- Broader `except Exception` on midi module import to prevent silent failures

## 1.0.1

### Fixed
- Pat/song toggle now uses `midi.FPT_PatternSong` from FL Studio's midi module with fallback to known command IDs
- Custom keystroke sender switched from HID system state to session event tap for reliable delivery to FL Studio
- Keystroke errors now log to FL Studio's Script Output window for debugging
- Config changes auto-save immediately — no need to press Save after changing a button mapping

### Added
- Accessibility Settings button in the header bar (opens System Settings directly)
- Version badge in header links to GitHub repo
- App icon embedded in .app bundle for Finder visibility

### Changed
- Header title: "LAUNCHKEY TWEAKER" with branded wordmark styling
- Section labels increased to 18pt for readability
- Play button icon always green, Record button icon always red
- Track nav buttons moved to left side of navigation grid

## 1.0.0

Initial release — transport encoder speed patch, shift button remapping, and native SwiftUI config app.
