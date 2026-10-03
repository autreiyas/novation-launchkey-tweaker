#
# macOS keystroke simulation via Tweaker.app's --keystroke mode.
# Used by Tweaker to send custom keyboard shortcuts from FL Studio.
#
# Tweaker.app has a CLI mode: Tweaker --keystroke <key> [modifiers]
# It uses CGEvents and must be in Accessibility settings.
#
# Only os.system() works in FL Studio's Python subinterpreter.
#
import os
import sys

# Find the Tweaker binary — check common locations
def _find_tweaker():
    candidates = [
        # Installed alongside the Novation scripts
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Tweaker.app", "Contents", "MacOS", "Tweaker"),
        # In the git repo
        os.path.expanduser("~/GitHub/launchkey_mk4321/Tweaker.app/Contents/MacOS/Tweaker"),
        # In Applications
        "/Applications/Tweaker.app/Contents/MacOS/Tweaker",
    ]
    for path in candidates:
        normalized = os.path.normpath(path)
        if os.path.isfile(normalized):
            return normalized
    return None

_TWEAKER_BIN = _find_tweaker()


def send_keystroke(key, modifiers=None):
    if not _TWEAKER_BIN:
        print("[Tweaker] Tweaker.app binary not found")
        return False

    key_lower = key.lower()
    # Use 'open' to launch via the app bundle so macOS recognizes Accessibility trust
    app_path = _TWEAKER_BIN.rsplit("/Contents/MacOS/", 1)[0] if "/Contents/MacOS/" in _TWEAKER_BIN else None
    if app_path:
        cmd = "open %s --args --keystroke %s" % (app_path, key_lower)
        if modifiers:
            mod_str = ",".join(m.lower() for m in modifiers if m)
            if mod_str:
                cmd += " " + mod_str
        cmd += " &"
    else:
        cmd = "%s --keystroke %s &" % (_TWEAKER_BIN, key_lower)

    print("[Tweaker] keystroke: %s" % cmd)
    os.system(cmd)
    return True
