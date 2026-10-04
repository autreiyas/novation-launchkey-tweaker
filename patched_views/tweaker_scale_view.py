#
# Tweaker: Scale sync between the Launchkey MK4 and the Tweaker app.
#
# The MK4 reports its scale as feature-control CCs on channel 7 of the DAW port
# (CC 61 = root 0-11, CC 62 = scale type 1-30, CC 74 = scale mode on/off).
# Sending the same CC on channel 7 sets it; sending it on channel 8 queries it.
#
# FL Studio has no API to set piano roll scale highlighting, so this view
# mirrors the keyboard's scale to FL's hint bar and to tweaker_scale_state.json
# (read by the Tweaker app), and applies scale picks from tweaker_scale_request.json.
#
import json
import os
import time

from script.device_independent.util_view.view import View

try:
    import device
except Exception:
    device = None

try:
    import ui
except Exception:
    ui = None


CC_ROOT = 0x3D
CC_TYPE = 0x3E
CC_ENABLED = 0x4A
STATUS_SET = 0xB6    # CH7 — sets a value; replies also arrive here
STATUS_QUERY = 0xB7  # CH8 — asks for a value

ENABLED_POLL_SECONDS = 2.0  # scale on/off is only reported when queried

NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

# Encoder order from the Launchkey 49 MK4 user guide; MIDI value = index + 1.
SCALE_NAMES = [
    "Major", "Minor", "Dorian", "Mixolydian", "Lydian", "Phrygian", "Locrian",
    "Whole Tone", "Half Whole Dim", "Whole Half Diminished", "Blues",
    "Minor Pentatonic", "Major Pentatonic", "Harmonic Minor", "Harmonic Major",
    "Dorian #4", "Phrygian Dominant", "Melodic Minor", "Lydian Augmented",
    "Lydian Dominant", "Super Locrian", "8-tone Spanish", "Bhairav",
    "Hungarian Minor", "Hirajoshi", "In-Sen", "Iwato", "Kumoi",
    "Pelog-Selisir", "Pelog-Tembung",
]

_NOVATION_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_STATE_PATH = os.path.join(_NOVATION_DIR, "tweaker_scale_state.json")
_REQUEST_PATH = os.path.join(_NOVATION_DIR, "tweaker_scale_request.json")

# Shared with the surface action generator, which feeds incoming CCs in.
_state = {"root": None, "type": None, "enabled": None}
_changed = {"state": False, "scale": False}


def observe_midi_event(fl_event):
    """Record scale CCs from the keyboard. Never consumes the event."""
    if fl_event.status != STATUS_SET:
        return
    if fl_event.data1 == CC_ROOT:
        _update("root", fl_event.data2 % 12, scale_changed=True)
    elif fl_event.data1 == CC_TYPE:
        _update("type", fl_event.data2, scale_changed=True)
    elif fl_event.data1 == CC_ENABLED:
        _update("enabled", fl_event.data2 > 0, scale_changed=False)


def _update(key, value, scale_changed):
    if _state[key] != value:
        _state[key] = value
        _changed["state"] = True
        if scale_changed:
            _changed["scale"] = True


def scale_name(type_value):
    if type_value is not None and 1 <= type_value <= len(SCALE_NAMES):
        return SCALE_NAMES[type_value - 1]
    return "Scale %s" % type_value


def describe_scale():
    """Human-readable current scale, e.g. 'F Minor'."""
    if _state["root"] is None or _state["type"] is None:
        return None
    text = "%s %s" % (NOTE_NAMES[_state["root"]], scale_name(_state["type"]))
    if _state["enabled"] is False:
        text += " (scale mode off)"
    return text


def show_scale_hint():
    text = describe_scale()
    if ui is not None:
        ui.setHintMsg("Launchkey scale: %s" % text if text else "Launchkey scale: unknown")


def _send(status, cc, value):
    if device is not None:
        device.midiOutMsg(status | (cc << 8) | (value << 16))


def _query(ccs):
    for cc in ccs:
        _send(STATUS_QUERY, cc, 0)


def _mtime(path):
    try:
        return os.path.getmtime(path)
    except OSError:
        return None


class TweakerScaleView(View):
    """Mirrors the keyboard's scale to FL and the Tweaker app, and applies scale picks."""

    def __init__(self, action_dispatcher):
        super().__init__(action_dispatcher)
        self._started = False
        self._last_poll = 0.0
        # Ignore a request left over from a previous session.
        self._request_mtime = _mtime(_REQUEST_PATH)

    def handle_TimerEventAction(self, action):
        now = time.time()
        if not self._started:
            self._started = True
            self._last_poll = now
            _query((CC_ROOT, CC_TYPE, CC_ENABLED))
        elif now - self._last_poll >= ENABLED_POLL_SECONDS:
            self._last_poll = now
            _query((CC_ENABLED,))

        self._apply_request()

        if _changed["scale"]:
            _changed["scale"] = False
            show_scale_hint()
        if _changed["state"]:
            _changed["state"] = False
            self._write_state()

    def _apply_request(self):
        mtime = _mtime(_REQUEST_PATH)
        if mtime is None or mtime == self._request_mtime:
            return
        self._request_mtime = mtime
        try:
            with open(_REQUEST_PATH, "r") as f:
                request = json.load(f)
        except (OSError, ValueError) as e:
            print("[Tweaker] scale request unreadable: %s" % e)
            return

        root = request.get("root")
        type_value = request.get("type")
        enabled = request.get("enabled")
        if isinstance(root, int) and 0 <= root <= 11:
            _send(STATUS_SET, CC_ROOT, root)
        if isinstance(type_value, int) and 1 <= type_value <= len(SCALE_NAMES):
            _send(STATUS_SET, CC_TYPE, type_value)
        if isinstance(enabled, bool):
            _send(STATUS_SET, CC_ENABLED, 127 if enabled else 0)
        # Read back what the keyboard actually applied.
        _query((CC_ROOT, CC_TYPE, CC_ENABLED))

    def _write_state(self):
        state = dict(_state)
        state["root_name"] = NOTE_NAMES[state["root"]] if state["root"] is not None else None
        state["type_name"] = scale_name(state["type"]) if state["type"] is not None else None
        state["updated"] = time.time()
        try:
            with open(_STATE_PATH, "w") as f:
                json.dump(state, f)
        except OSError as e:
            print("[Tweaker] scale state write failed: %s" % e)
