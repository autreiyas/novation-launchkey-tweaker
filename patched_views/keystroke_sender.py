#
# macOS keystroke simulation via background keystroke server.
# Used by Tweaker to send custom keyboard shortcuts from FL Studio.
#
# Writes to a FIFO at ~/.tweaker/keystroke.fifo which is read by
# the tweaker_keystroke_server daemon that sends CGEvents.
#
# Only os.system() works in FL Studio's Python subinterpreter.
# ctypes, subprocess, socket, and os.open all fail.
#
import os

_FIFO = os.path.expanduser("~/.tweaker/keystroke.fifo")


def send_keystroke(key, modifiers=None):
    msg = key.lower()
    if modifiers:
        mod_str = ",".join(m.lower() for m in modifiers if m)
        if mod_str:
            msg += " " + mod_str

    cmd = "echo %s > %s" % (msg, _FIFO)
    print("[Tweaker] keystroke cmd: %s" % cmd)
    os.system(cmd)
    return True
