#
# macOS keystroke simulation via CoreGraphics CGEvents.
# Used by Tweaker to send custom keyboard shortcuts from FL Studio.
#
# Requires FL Studio to have Accessibility permissions on macOS:
#   System Settings > Privacy & Security > Accessibility > FL Studio
#
import ctypes
import ctypes.util

_cg = None
_cf = None

# macOS virtual key codes
KEY_CODES = {
    "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7,
    "c": 8, "v": 9, "b": 11, "q": 12, "w": 13, "e": 14, "r": 15,
    "y": 16, "t": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
    "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
    "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35,
    "enter": 36, "return": 36, "l": 37, "j": 38, "'": 39, "k": 40,
    ";": 41, "\\": 42, ",": 43, "/": 44, "n": 45, "m": 46, ".": 47,
    "tab": 48, "space": 49, "`": 50, "delete": 51, "backspace": 51,
    "escape": 53, "esc": 53,
    "f1": 122, "f2": 120, "f3": 99, "f4": 118, "f5": 96, "f6": 97,
    "f7": 98, "f8": 100, "f9": 101, "f10": 109, "f11": 103, "f12": 111,
    "up": 126, "down": 125, "left": 123, "right": 124,
    "home": 115, "end": 119, "pageup": 116, "pagedown": 121,
}

# Modifier flags
kCGEventFlagMaskCommand = 0x100000
kCGEventFlagMaskShift = 0x20000
kCGEventFlagMaskAlternate = 0x80000
kCGEventFlagMaskControl = 0x40000

MODIFIER_FLAGS = {
    "cmd": kCGEventFlagMaskCommand,
    "command": kCGEventFlagMaskCommand,
    "shift": kCGEventFlagMaskShift,
    "alt": kCGEventFlagMaskAlternate,
    "opt": kCGEventFlagMaskAlternate,
    "option": kCGEventFlagMaskAlternate,
    "ctrl": kCGEventFlagMaskControl,
    "control": kCGEventFlagMaskControl,
}


def _load_frameworks():
    global _cg, _cf
    if _cg is not None:
        return True
    try:
        cg_path = ctypes.util.find_library("CoreGraphics")
        cf_path = ctypes.util.find_library("CoreFoundation")
        if not cg_path or not cf_path:
            return False
        _cg = ctypes.cdll.LoadLibrary(cg_path)
        _cf = ctypes.cdll.LoadLibrary(cf_path)

        _cg.CGEventSourceCreate.argtypes = [ctypes.c_int32]
        _cg.CGEventSourceCreate.restype = ctypes.c_void_p

        _cg.CGEventCreateKeyboardEvent.argtypes = [
            ctypes.c_void_p, ctypes.c_uint16, ctypes.c_bool
        ]
        _cg.CGEventCreateKeyboardEvent.restype = ctypes.c_void_p

        _cg.CGEventSetFlags.argtypes = [ctypes.c_void_p, ctypes.c_uint64]
        _cg.CGEventSetFlags.restype = None

        _cg.CGEventPost.argtypes = [ctypes.c_uint32, ctypes.c_void_p]
        _cg.CGEventPost.restype = None

        _cf.CFRelease.argtypes = [ctypes.c_void_p]
        _cf.CFRelease.restype = None

        return True
    except (OSError, AttributeError):
        return False


def send_keystroke(key, modifiers=None):
    """
    Send a keyboard event to the system.

    Args:
        key: Key name (e.g. "e", "f5", "space", "enter")
        modifiers: List of modifier names (e.g. ["cmd", "shift"])
    """
    if not _load_frameworks():
        return False

    key_lower = key.lower()
    key_code = KEY_CODES.get(key_lower)
    if key_code is None:
        return False

    flags = 0
    if modifiers:
        for mod in modifiers:
            flag = MODIFIER_FLAGS.get(mod.lower(), 0)
            flags |= flag

    # kCGEventSourceStateHIDSystemState = 1
    source = _cg.CGEventSourceCreate(1)
    if not source:
        return False

    try:
        # Key down
        event_down = _cg.CGEventCreateKeyboardEvent(source, key_code, True)
        if flags:
            _cg.CGEventSetFlags(event_down, flags)
        _cg.CGEventPost(0, event_down)  # kCGHIDEventTap
        _cf.CFRelease(event_down)

        # Key up
        event_up = _cg.CGEventCreateKeyboardEvent(source, key_code, False)
        if flags:
            _cg.CGEventSetFlags(event_up, flags)
        _cg.CGEventPost(0, event_up)
        _cf.CFRelease(event_up)
    finally:
        _cf.CFRelease(source)

    return True
