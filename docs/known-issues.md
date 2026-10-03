# Known Issues & Limitations

## FL Studio Python Subinterpreter

FL Studio runs MIDI scripts in a Python 3.9 subinterpreter with severe restrictions:

- **No file I/O** outside the script directory — `open()`, `os.open()`, `io.open()` all fail
- **No process creation** — `subprocess`, `os.popen()`, `ctypes` all blocked
- **No networking** — `socket` module returns NULL
- **`os.system()` is unreliable** — returns but the shell command may not execute
- **`print()` is the only reliable output** during MIDI callbacks

File writes via `open()` work during OnIdle, but only to the Novation script directory.

## Export (Ctrl+R)

There is no FL Studio API equivalent for the Export dialog. However, with custom keystrokes enabled, you can assign **Cmd+Shift+R** (or any other export shortcut) to a shift button.

## Fader Select Buttons

Shift+Fader buttons (1–8) cannot be remapped. The stock firmware uses these combinations for fader mode switching (Volume, Pan, Sends, etc.). These are handled at the hardware level before reaching the MIDI script.

## Accessibility Trust & Code Signing

The keystroke server binary is ad-hoc signed (`codesign -s -`). On macOS Tahoe and later:

- Every re-sign **invalidates** the existing Accessibility trust entry
- After updating the binary, you must **remove and re-add** it to System Settings → Accessibility
- There is no way to automate this — it requires manual user interaction

## Novation Components / FL Studio Updates

Novation Components and FL Studio updates may overwrite the patched script files. After an update:

1. Re-run `./install.sh`
2. Restart FL Studio

The installer backs up original files on first run and never overwrites your `tweaker_config.json`.

## Stale Bytecode Cache

FL Studio caches compiled Python bytecode in `__pycache__` directories. If you see unexpected behavior after an update, the installer automatically clears these. If issues persist, manually delete:

```bash
find ~/Documents/Image-Line/FL\ Studio/Settings/Hardware/Novation/ -name "__pycache__" -exec rm -rf {} +
```

## Keystroke Server PID

The LaunchAgent restarts the server automatically, but the PID changes each time. The current architecture doesn't require PID tracking — the server polls for command files independently.
