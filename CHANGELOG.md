# Changelog

## 1.0.4

### Added
- `enable_custom_keystrokes` config flag — custom keystroke option hidden in UI when `false`
- Background keystroke server (`tweaker_keystroke_server`) with FIFO-based IPC for macOS keystroke simulation
- LaunchAgent plist for auto-starting the keystroke server

### Changed
- Keystroke sender rewritten to use FIFO pipe to background server (replaces direct `osascript` calls)
- Keystroke helper binary installed to `~/.tweaker/` (avoids spaces in FL Studio path)

### Known Issues
- Custom keystrokes not yet functional — FL Studio's Python subinterpreter blocks `ctypes`, `subprocess`, `socket`, and `os.open`; `os.system()` echo to FIFO not reaching the server during MIDI callbacks

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
