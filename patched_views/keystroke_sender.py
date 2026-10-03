#
# macOS keystroke simulation via osascript (AppleScript).
# Used by Tweaker to send custom keyboard shortcuts from FL Studio.
#
# ctypes and subprocess do not work in FL Studio's Python subinterpreter,
# so we use os.system() with osascript instead.
#
import os

# Key name -> AppleScript key code (for special keys)
SPECIAL_KEYS = {
    "return": 36, "enter": 36, "tab": 48, "space": 49,
    "delete": 51, "backspace": 51, "escape": 53, "esc": 53,
    "up": 126, "down": 125, "left": 123, "right": 124,
    "home": 115, "end": 119, "pageup": 116, "pagedown": 121,
    "f1": 122, "f2": 120, "f3": 99, "f4": 118, "f5": 96, "f6": 97,
    "f7": 98, "f8": 100, "f9": 101, "f10": 109, "f11": 103, "f12": 111,
}

MODIFIER_MAP = {
    "cmd": "command down",
    "command": "command down",
    "shift": "shift down",
    "alt": "option down",
    "opt": "option down",
    "option": "option down",
    "ctrl": "control down",
    "control": "control down",
}


def send_keystroke(key, modifiers=None):
    """
    Send a keyboard event via osascript.

    Args:
        key: Key name (e.g. "l", "f5", "space", "enter")
        modifiers: List of modifier names (e.g. ["cmd", "shift"])
    """
    key_lower = key.lower()

    # Build modifier clause
    mod_parts = []
    if modifiers:
        for mod in modifiers:
            m = MODIFIER_MAP.get(mod.lower())
            if m:
                mod_parts.append(m)

    using_clause = ""
    if mod_parts:
        using_clause = " using {%s}" % ", ".join(mod_parts)

    # Use key code for special keys, keystroke for regular characters
    if key_lower in SPECIAL_KEYS:
        code = SPECIAL_KEYS[key_lower]
        script = 'tell application "System Events" to key code %d%s' % (code, using_clause)
    elif len(key_lower) == 1:
        script = 'tell application "System Events" to keystroke "%s"%s' % (key_lower, using_clause)
    else:
        print("[Tweaker] unknown key: %s" % key)
        return False

    try:
        cmd = '/usr/bin/osascript -e "%s" &' % script.replace('"', '\\"')
        print("[Tweaker] sending keystroke: %s" % cmd)
        os.system(cmd)
        return True
    except Exception as e:
        print("[Tweaker] osascript error: %s" % e)
        return False
