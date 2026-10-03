# Custom Keystrokes

Tweaker can send arbitrary keyboard shortcuts from shift button presses on the Launchkey MK4. This enables actions that have no FL Studio API equivalent, like **Cmd+Shift+R** to export as MP3.

## How It Works

FL Studio's embedded Python subinterpreter is heavily sandboxed — it blocks file I/O, subprocess creation, sockets, and most `os.*` calls. Tweaker works around this with a three-stage pipeline:

```
Button Press (MIDI callback)
    → Queue keystroke in memory (no I/O needed)

OnIdle (FL Studio main loop)
    → Write command to file in script directory
      (the only location FL Studio allows file writes)

Keystroke Server (background daemon)
    → Polls command file every 50ms
    → Sends CGEvent keystroke to macOS
```

### Why This Architecture?

During MIDI callbacks, FL Studio's Python subinterpreter blocks:

| Method | Error |
|--------|-------|
| `open()` | `FileIO returned NULL without setting an exception` |
| `os.open()` | `bad argument type for built-in operation` |
| `os.popen()` | `audit hook returned NULL` |
| `os.system()` | Returns -1, shell command doesn't execute |
| `os.mkdir()` | `returned NULL without setting an exception` |
| `os.rename()` | `returned NULL without setting an exception` |
| `subprocess` | `bad argument type for built-in operation` |
| `socket` | `<slot wrapper> returned NULL` |
| `ctypes` | `does not support loading in subinterpreters` |

The only output that works during callbacks is `print()` (to FL Studio's Script Output).

However, during **OnIdle** (which FL Studio calls periodically outside of MIDI processing), `open()` works — but only for files in the **Novation script directory**. Writing to `~/.tweaker/` or any other path still fails.

The keystroke server is a compiled Swift binary that:
1. Polls the Novation script directory for a `keystroke_cmd` file
2. Reads the command (e.g., `r cmd,shift` for Cmd+Shift+R)
3. Sends a CGEvent keystroke via macOS Accessibility APIs
4. Deletes the command file

## Setup

### 1. Install

The installer handles everything automatically:

```bash
./install.sh
```

This installs the keystroke server binary to `~/.tweaker/tweaker_keystroke_server` and sets up a LaunchAgent to start it automatically on login.

### 2. Grant Accessibility Permission

The keystroke server needs macOS Accessibility permission to send keystrokes:

1. Open **System Settings → Privacy & Security → Accessibility**
2. Click **+**
3. Press **Cmd+Shift+G** and paste: `~/.tweaker/tweaker_keystroke_server`
4. Toggle it **on**

**Important**: If you ever reinstall or update the server binary, you must remove and re-add it to Accessibility (re-signing invalidates the trust entry).

### 3. Configure in Tweaker App

1. Open **Tweaker.app**
2. Set `enable_custom_keystrokes` to **true** (if not already)
3. Assign a button to **Custom Keystroke**
4. Set the key and modifiers

### 4. Restart FL Studio

The keystroke server starts automatically. FL Studio needs a restart to load the updated scripts.

## Command Protocol

The command file uses a simple text format, one keystroke per line:

```
key [modifiers]
```

Examples:
```
l                    → Press L (toggle pat/song)
r cmd,shift          → Cmd+Shift+R (export as MP3)
s cmd                → Cmd+S (save)
z cmd                → Cmd+Z (undo)
```

### Supported Keys

Single characters (`a`–`z`, `0`–`9`), plus:

| Key Name | Description |
|----------|-------------|
| `enter` / `return` | Enter/Return |
| `tab` | Tab |
| `space` | Spacebar |
| `delete` / `backspace` | Delete |
| `escape` / `esc` | Escape |
| `up` / `down` / `left` / `right` | Arrow keys |
| `home` / `end` / `pageup` / `pagedown` | Navigation |
| `f1`–`f12` | Function keys |

### Supported Modifiers

Comma-separated: `cmd`, `shift`, `alt` (or `opt`), `ctrl`

## Troubleshooting

### Server not running

```bash
# Check status
ps aux | grep tweaker_keystroke_server

# Start manually
~/.tweaker/tweaker_keystroke_server

# Or reload the LaunchAgent
launchctl load ~/Library/LaunchAgents/com.tweaker.keystroke-server.plist
```

### "NOT TRUSTED" in server log

The binary needs to be (re-)added to Accessibility settings. Check `~/.tweaker/server.log` for the current trust status.

### Keystrokes not arriving

1. Check FL Studio Script Output — you should see `[Tweaker] wrote to script dir via open()`
2. Check `~/.tweaker/server.log` — you should see `Command(novation): ...` and `Sent(CGEvent): ...`
3. Make sure the server is running and trusted

### Server keeps dying after update

Every time the binary is re-signed (`codesign -s -`), macOS invalidates its Accessibility trust. Remove and re-add it in System Settings.
