# Changelog

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
