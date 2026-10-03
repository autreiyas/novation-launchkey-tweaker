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
    PME_System = midi.PME_System
    GT_Global = midi.GT_Global
except (ImportError, AttributeError):
    PME_System = 1 << 2
    GT_Global = 64

# FL Studio globalTransport command codes
FPT_Save = 92
FPT_SaveNew = 93
FPT_NextWindow = 85
FPT_Enter = 100
FPT_Escape = 101
FPT_TapTempo = 106
FPT_Metronome = 110
FPT_LoopRecord = 113
FPT_Overdub = 112
FPT_StepEdit = 114
FPT_CountDown = 60
FPT_AddMarker = 61
FPT_Shuffle = 50
FPT_SnapOnOff = 41


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


def _execute_action(fl, action_name, params=None):
    """Execute an FL Studio action by name."""
    if action_name == "not_used":
        return

    if action_name == "toggle_pat_song":
        try:
            # Use FL Studio's direct API
            transport.globalTransport(midi.FPT_PatternSong, 1, PME_System)
        except (NameError, AttributeError):
            # Fallback: try known command IDs
            for cmd_id in (20, 17, 15):
                try:
                    transport.globalTransport(cmd_id, 1, PME_System)
                    break
                except Exception:
                    continue

    elif action_name == "tap_tempo":
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

    elif action_name == "save":
        transport.globalTransport(FPT_Save, 1, PME_System, GT_Global)

    elif action_name == "save_new":
        transport.globalTransport(FPT_SaveNew, 1, PME_System, GT_Global)

    elif action_name == "toggle_snap":
        transport.globalTransport(FPT_SnapOnOff, 1, PME_System, GT_Global)

    elif action_name == "add_marker":
        transport.globalTransport(FPT_AddMarker, 1, PME_System, GT_Global)

    elif action_name == "toggle_step_edit":
        transport.globalTransport(FPT_StepEdit, 1, PME_System, GT_Global)

    elif action_name == "toggle_countdown":
        transport.globalTransport(FPT_CountDown, 1, PME_System, GT_Global)

    elif action_name == "toggle_overdub":
        transport.globalTransport(FPT_Overdub, 1, PME_System, GT_Global)

    elif action_name == "toggle_shuffle":
        transport.globalTransport(FPT_Shuffle, 1, PME_System, GT_Global)

    elif action_name == "clone_pattern":
        fl.clone_selected_pattern()

    elif action_name == "toggle_master_sync":
        fl.enable_master_sync()

    elif action_name == "next_window":
        transport.globalTransport(FPT_NextWindow, 1, PME_System, GT_Global)

    elif action_name == "focus_mixer":
        fl.ui.focus_mixer_window()

    elif action_name == "focus_channel_rack":
        fl.ui.focus_channel_window()

    elif action_name == "focus_playlist":
        fl.ui.focus_playlist_window()

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
