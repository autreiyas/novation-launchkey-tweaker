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
    # Faders
    "shift_fader_1": "ShiftFader1",
    "shift_fader_2": "ShiftFader2",
    "shift_fader_3": "ShiftFader3",
    "shift_fader_4": "ShiftFader4",
    "shift_fader_5": "ShiftFader5",
    "shift_fader_6": "ShiftFader6",
    "shift_fader_7": "ShiftFader7",
    "shift_fader_8": "ShiftFader8",
    "shift_arm_select": "ShiftArmSelect",
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
        transport.globalTransport(cmd, 1, midi.PME_System)
    else:
        print("[Tweaker] midi.%s not found" % command_name)


def _execute_action(fl, action_name, params=None):
    """Execute an FL Studio action by name."""
    if action_name == "not_used":
        return

    print("[Tweaker] action: %s" % action_name)

    # --- Direct FL wrapper methods (no globalTransport needed) ---
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

    # --- globalTransport commands (use midi module constants) ---
    elif action_name == "toggle_pat_song":
        transport.setLoopMode()
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

    elif action_name == "custom_keystroke":
        if params:
            key = params.get("key", "")
            modifiers = params.get("modifiers", [])
            if key:
                try:
                    from patched_views.keystroke_sender import send_keystroke
                    result = send_keystroke(key, modifiers)
                    if not result:
                        print("[Tweaker] keystroke failed for key=%r mods=%r" % (key, modifiers))
                except Exception as e:
                    print("[Tweaker] keystroke error: %s" % e)

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
