#
# Encoder keystroke view — sends configurable keystrokes on encoder turns.
# Clockwise sends one key, counter-clockwise sends another.
# Uses the same file-based IPC as the button keystroke sender.
#
import os
from script.device_independent.util_view.view import View
from transport_speed_config import get_config, get_function_param

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PARENT_DIR = os.path.dirname(_SCRIPT_DIR)
_CMD_FILE = os.path.join(_PARENT_DIR, "keystroke_cmd")

# Pending keystrokes — flushed during OnIdle (TimerEventAction)
_pending = []


def _queue_keystroke(key, modifiers=None):
    if not key:
        return
    key_lower = key.lower()
    if modifiers:
        mod_str = ",".join(m.lower() for m in modifiers if m)
        line = "%s %s" % (key_lower, mod_str) if mod_str else key_lower
    else:
        line = key_lower
    _pending.append(line)


def _flush_pending():
    if not _pending:
        return
    lines = "\n".join(_pending) + "\n"
    _pending.clear()
    try:
        f = open(_CMD_FILE, "a")
        f.write(lines)
        f.close()
    except Exception as e:
        print("[Tweaker] encoder keystroke flush failed: %s" % e)


class TransportEncoderKeystrokeView(View):
    def __init__(self, action_dispatcher, fl, *, control_index, knob_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index
        self.knob_index = knob_index

    def _get_encoder_keystroke_config(self):
        config = get_config()
        return config.get("encoder_keystrokes", {}).get(str(self.knob_index), {})

    def handle_ControlChangedAction(self, action):
        if action.control is not self.control_index:
            return

        cfg = self._get_encoder_keystroke_config()
        print("[Tweaker] encoder %d turn: value=%s cfg=%s" % (self.knob_index, action.value, cfg))
        if not cfg:
            return

        if action.value > 0:
            key = cfg.get("cw_key", "")
            mods = cfg.get("cw_modifiers", [])
        else:
            key = cfg.get("ccw_key", "")
            mods = cfg.get("ccw_modifiers", [])

        if key:
            sensitivity = int(get_function_param("encoder_keystroke", "sensitivity", 3))
            repeat_count = max(1, abs(action.value) // sensitivity)
            for _ in range(repeat_count):
                _queue_keystroke(key, mods)

    def handle_TimerEventAction(self, action):
        _flush_pending()
