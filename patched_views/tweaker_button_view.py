#
# Tweaker: Handles shifted button presses with configurable actions.
# Reads button mappings from tweaker_config.json.
#
from script.device_independent.util_view.view import View
from transport_speed_config import get_button_mapping

try:
    import transport
    import ui
except ImportError:
    transport = None
    ui = None


try:
    import midi
except Exception:
    midi = None


# Button name -> FunctionToButton key mapping
SHIFT_BUTTONS = {
    # Transport
    "shift_metronome": "ShiftMetronome",
    "shift_play": "ShiftPlay",
    "shift_stop": "ShiftStop",
    "shift_record": "ShiftRecord",
    "shift_loop": "ShiftLoop",
    "shift_capture_midi": "ShiftCaptureMidi",
    "shift_quantise": "ShiftQuantise",
    # Navigation
    "shift_encoder_page_up": "ShiftEncoderPageUp",
    "shift_encoder_page_down": "ShiftEncoderPageDown",
    "shift_pads_page_up": "ShiftPadsPageUp",
    "shift_pads_page_down": "ShiftPadsPageDown",
}


def _gt(command_name):
    """Get a globalTransport command constant from the midi module."""
    if midi is None:
        return None
    return getattr(midi, command_name, None)


def _run_gt(command_name):
    """Run a globalTransport command by midi module attribute name."""
    cmd = _gt(command_name)
    if cmd is not None:
        result = transport.globalTransport(cmd, 1, midi.PME_System, midi.GT_All)
        print("[Tweaker] globalTransport(%s=%d) -> %s" % (command_name, cmd, result))
    else:
        print("[Tweaker] midi.%s not found" % command_name)


def _execute_action(fl, action_name, params=None):
    """Execute an FL Studio action by name."""
    if action_name == "not_used":
        return

    print("[Tweaker] action: %s" % action_name)

    # --- Direct FL wrapper methods ---
    if action_name == "tap_tempo":
        fl.send_tap_tempo_event()
    elif action_name == "toggle_metronome":
        fl.toggle_metronome()
    elif action_name == "toggle_loop_record":
        fl.toggle_loop_record()
    elif action_name == "undo":
        fl.undo()
    elif action_name == "redo":
        fl.redo()
    elif action_name == "open_plugin_picker":
        fl.toggle_plugin_picker()
    elif action_name == "clone_pattern":
        fl.clone_selected_pattern()
    elif action_name == "toggle_master_sync":
        fl.enable_master_sync()
    elif action_name == "focus_mixer":
        fl.ui.focus_mixer_window()
    elif action_name == "focus_channel_rack":
        fl.ui.focus_channel_window()
    elif action_name == "focus_playlist":
        fl.ui.focus_playlist_window()
    elif action_name == "toggle_pat_song":
        transport.setLoopMode()

    # --- Clipboard / editing ---
    elif action_name == "copy":
        _run_gt("FPT_Copy")
    elif action_name == "cut":
        _run_gt("FPT_Cut")
    elif action_name == "paste":
        _run_gt("FPT_Paste")
    elif action_name == "delete":
        _run_gt("FPT_Delete")
    elif action_name == "insert":
        _run_gt("FPT_Insert")

    # --- globalTransport commands (FPT_ constants) ---
    elif action_name == "save":
        _run_gt("FPT_Save")
    elif action_name == "save_new":
        _run_gt("FPT_SaveNew")
    elif action_name == "toggle_snap":
        _run_gt("FPT_Snap")
    elif action_name == "add_marker":
        _run_gt("FPT_AddMarker")
    elif action_name == "toggle_step_edit":
        _run_gt("FPT_StepEdit")
    elif action_name == "toggle_countdown":
        _run_gt("FPT_CountDown")
    elif action_name == "toggle_overdub":
        _run_gt("FPT_Overdub")
    elif action_name == "toggle_shuffle":
        _run_gt("FPT_Shuffle")
    elif action_name == "next_window":
        _run_gt("FPT_NextWindow")
    elif action_name == "toggle_browser":
        ui.navigateBrowser(0, 0)
    elif action_name == "open_menu":
        _run_gt("FPT_Menu")
    # F-keys (FL Studio shortcuts via API)
    elif action_name == "f1":
        _run_gt("FPT_F1")
    elif action_name == "f2":
        _run_gt("FPT_F2")
    elif action_name == "f3":
        _run_gt("FPT_F3")
    elif action_name == "f4":
        _run_gt("FPT_F4")
    elif action_name == "f5":
        _run_gt("FPT_F5")
    elif action_name == "f6":
        _run_gt("FPT_F6")
    elif action_name == "f7":
        _run_gt("FPT_F7")
    elif action_name == "f8":
        _run_gt("FPT_F8")
    elif action_name == "f9":
        _run_gt("FPT_F9")
    elif action_name == "f10":
        _run_gt("FPT_F10")
    elif action_name == "f11":
        _run_gt("FPT_F11")
    elif action_name == "f12":
        _run_gt("FPT_F12")
    elif action_name == "nudge_plus":
        _run_gt("FPT_NudgePlus")
    elif action_name == "nudge_minus":
        _run_gt("FPT_NudgeMinus")
    elif action_name == "punch_in":
        _run_gt("FPT_PunchIn")
    elif action_name == "punch_out":
        _run_gt("FPT_PunchOut")
    elif action_name == "mute":
        _run_gt("FPT_Mute")
    elif action_name == "toggle_wait_for_input":
        _run_gt("FPT_WaitForInput")

    elif action_name == "custom_keystroke":
        if params:
            key = params.get("key", "")
            modifiers = params.get("modifiers", [])
            if key:
                # Build keystroke_helper command with stderr log
                helper = os.path.expanduser("~/.tweaker/keystroke_helper")
                log = os.path.expanduser("~/.tweaker/keystroke.log")
                mod_str = ",".join(m.lower() for m in modifiers) if modifiers else ""
                if mod_str:
                    cmd = "%s %s %s 2>>%s" % (helper, key.lower(), mod_str, log)
                else:
                    cmd = "%s %s 2>>%s" % (helper, key.lower(), log)
                # Also write a test file to prove os.system runs
                os.system("echo '%s' >> %s" % (cmd, os.path.expanduser("~/.tweaker/commands.log")))
                print("[Tweaker] running: %s" % cmd)
                os.system(cmd)

    else:
        print("[Tweaker] unknown action: %s" % action_name)


class TweakerButtonView(View):
    """Handles all Tweaker-configured shifted button actions."""

    def __init__(self, action_dispatcher, fl, product_defs):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.product_defs = product_defs

    def handle_ButtonPressedAction(self, action):
        for config_name, function_key in SHIFT_BUTTONS.items():
            expected_button = self.product_defs.FunctionToButton.get(function_key)
            if expected_button is not None and action.button == expected_button:
                mapping = get_button_mapping(config_name)
                if mapping:
                    func_name = mapping.get("function", "not_used")
                    params = mapping.get("params")
                    _execute_action(self.fl, func_name, params)
                return
