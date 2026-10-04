#
# Patched by Tweaker — adds shifted button mappings for custom remapping.
# Original: script/action_generators/surface_action_generator/launchkey_mk4_surface_action_generator.py
#
from script.action_generators.surface_action_generator.keyboard_controller_common import (
    KeyboardControllerCommonButtonActionGenerator,
    KeyboardControllerCommonEncoderActionGenerator,
    KeyboardControllerCommonEncoderLayoutActionGenerator,
    KeyboardControllerCommonFaderActionGenerator,
    KeyboardControllerCommonFaderLayoutActionGenerator,
    KeyboardControllerCommonPadActionGenerator,
    KeyboardControllerCommonPadLayoutActionGenerator,
)
from script.action_generators.surface_action_generator.surface_actions import (
    EncoderLayoutChangedAction,
    FaderLayoutChangedAction,
    PadLayoutChangedAction,
)
from transport_speed_config import get_config
from patched_views.tweaker_scale_view import observe_midi_event


def _log_midi_event(fl_event):
    """Tweaker: print one incoming MIDI message to FL's script output."""
    status = fl_event.status
    if status == 0xF0:
        print("[Tweaker MIDI] sysex %s" % " ".join("%02X" % b for b in (fl_event.sysex or b"")))
        return
    print(
        "[Tweaker MIDI] status=0x%02X (ch%d) data1=%d (0x%02X) data2=%d"
        % (status, (status & 0x0F) + 1, fl_event.data1, fl_event.data1, fl_event.data2)
    )


class LaunchkeyMk4SurfaceActionGenerator:
    def __init__(self, product_defs):
        self.product_defs = product_defs
        self.event_type_to_button = {
            self.product_defs.SurfaceEvent.ButtonTrackRight.value: self.product_defs.Button.TrackRight,
            self.product_defs.SurfaceEvent.ButtonTrackLeft.value: self.product_defs.Button.TrackLeft,
            self.product_defs.SurfaceEvent.ButtonCaptureMidi.value: self.product_defs.Button.CaptureMidi,
            self.product_defs.SurfaceEvent.ButtonMetronome.value: self.product_defs.Button.Metronome,
            self.product_defs.SurfaceEvent.ButtonQuantise.value: self.product_defs.Button.Quantise,
            self.product_defs.SurfaceEvent.ButtonTransportLoop.value: self.product_defs.Button.TransportLoop,
            self.product_defs.SurfaceEvent.ButtonTransportPlay.value: self.product_defs.Button.TransportPlay,
            self.product_defs.SurfaceEvent.ButtonTransportRecord.value: self.product_defs.Button.TransportRecord,
            self.product_defs.SurfaceEvent.ButtonTransportStop.value: self.product_defs.Button.TransportStop,
            self.product_defs.SurfaceEvent.ButtonUndo.value: self.product_defs.Button.Undo,
            self.product_defs.SurfaceEvent.ButtonShift.value: self.product_defs.Button.Shift,
            self.product_defs.SurfaceEvent.LegacyButtonShift.value: self.product_defs.Button.Shift,
            self.product_defs.SurfaceEvent.ButtonFader_1.value: self.product_defs.Button.Fader_1,
            self.product_defs.SurfaceEvent.ButtonFader_2.value: self.product_defs.Button.Fader_2,
            self.product_defs.SurfaceEvent.ButtonFader_3.value: self.product_defs.Button.Fader_3,
            self.product_defs.SurfaceEvent.ButtonFader_4.value: self.product_defs.Button.Fader_4,
            self.product_defs.SurfaceEvent.ButtonFader_5.value: self.product_defs.Button.Fader_5,
            self.product_defs.SurfaceEvent.ButtonFader_6.value: self.product_defs.Button.Fader_6,
            self.product_defs.SurfaceEvent.ButtonFader_7.value: self.product_defs.Button.Fader_7,
            self.product_defs.SurfaceEvent.ButtonFader_8.value: self.product_defs.Button.Fader_8,
            self.product_defs.SurfaceEvent.ButtonArmSelect.value: self.product_defs.Button.ArmSelect,
            self.product_defs.SurfaceEvent.ButtonEncoderPageUp.value: self.product_defs.Button.EncoderPageUp,
            self.product_defs.SurfaceEvent.ButtonEncoderPageDown.value: self.product_defs.Button.EncoderPageDown,
            self.product_defs.SurfaceEvent.ButtonPadsPageUp.value: self.product_defs.Button.PadsPageUp,
            self.product_defs.SurfaceEvent.ButtonPadsPageDown.value: self.product_defs.Button.PadsPageDown,
        }

        self.modified_event_type_to_button = {
            self.product_defs.SurfaceEvent.ButtonTrackLeftShift.value: self.product_defs.Button.TrackLeftShift,
            self.product_defs.SurfaceEvent.ButtonTrackRightShift.value: self.product_defs.Button.TrackRightShift,
            self.product_defs.SurfaceEvent.ButtonUndo.value: self.product_defs.Button.UndoShift,
            # Tweaker: shifted button mappings — transport
            self.product_defs.SurfaceEvent.ButtonMetronome.value: self.product_defs.Button.MetronomeShift,
            self.product_defs.SurfaceEvent.ButtonTransportPlay.value: self.product_defs.Button.PlayShift,
            self.product_defs.SurfaceEvent.ButtonTransportStop.value: self.product_defs.Button.StopShift,
            self.product_defs.SurfaceEvent.ButtonTransportRecord.value: self.product_defs.Button.RecordShift,
            self.product_defs.SurfaceEvent.ButtonTransportLoop.value: self.product_defs.Button.LoopShift,
            self.product_defs.SurfaceEvent.ButtonCaptureMidi.value: self.product_defs.Button.CaptureMidiShift,
            self.product_defs.SurfaceEvent.ButtonQuantise.value: self.product_defs.Button.QuantiseShift,
            # Tweaker: shifted button mappings — faders
            self.product_defs.SurfaceEvent.ButtonFader_1.value: self.product_defs.Button.Fader_1_Shift,
            self.product_defs.SurfaceEvent.ButtonFader_2.value: self.product_defs.Button.Fader_2_Shift,
            self.product_defs.SurfaceEvent.ButtonFader_3.value: self.product_defs.Button.Fader_3_Shift,
            self.product_defs.SurfaceEvent.ButtonFader_4.value: self.product_defs.Button.Fader_4_Shift,
            self.product_defs.SurfaceEvent.ButtonFader_5.value: self.product_defs.Button.Fader_5_Shift,
            self.product_defs.SurfaceEvent.ButtonFader_6.value: self.product_defs.Button.Fader_6_Shift,
            self.product_defs.SurfaceEvent.ButtonFader_7.value: self.product_defs.Button.Fader_7_Shift,
            self.product_defs.SurfaceEvent.ButtonFader_8.value: self.product_defs.Button.Fader_8_Shift,
            self.product_defs.SurfaceEvent.ButtonArmSelect.value: self.product_defs.Button.ArmSelectShift,
            # Tweaker: shifted button mappings — navigation
            self.product_defs.SurfaceEvent.ButtonEncoderPageUp.value: self.product_defs.Button.EncoderPageUpShift,
            self.product_defs.SurfaceEvent.ButtonEncoderPageDown.value: self.product_defs.Button.EncoderPageDownShift,
            self.product_defs.SurfaceEvent.ButtonPadsPageUp.value: self.product_defs.Button.PadsPageUpShift,
            self.product_defs.SurfaceEvent.ButtonPadsPageDown.value: self.product_defs.Button.PadsPageDownShift,
        }

        self.common_action_generators = [
            KeyboardControllerCommonButtonActionGenerator(
                self._get_button_for_event,
                is_modifier_event=lambda event: event == product_defs.SurfaceEvent.ButtonShift.value
                or event == product_defs.SurfaceEvent.LegacyButtonShift.value,
            ),
            KeyboardControllerCommonEncoderActionGenerator(product_defs),
            KeyboardControllerCommonFaderActionGenerator(product_defs),
            KeyboardControllerCommonFaderLayoutActionGenerator(product_defs),
            KeyboardControllerCommonFaderActionGenerator(product_defs),
            KeyboardControllerCommonPadActionGenerator(product_defs),
            KeyboardControllerCommonPadLayoutActionGenerator(product_defs),
            KeyboardControllerCommonEncoderLayoutActionGenerator(product_defs),
        ]

    def handle_midi_event(self, fl_event):
        # Tweaker: raw MIDI logging (debug.log_midi)
        if get_config().get("debug", {}).get("log_midi"):
            _log_midi_event(fl_event)
        # Tweaker: track the keyboard's scale (CH7 CC 61/62/74)
        observe_midi_event(fl_event)
        for action_generator in self.common_action_generators:
            if actions := action_generator.handle_midi_event(fl_event):
                return actions
        if actions := self._handle_legacy_message(fl_event):
            return actions
        return []

    def _get_button_for_event(self, event, modifier_button_is_held):
        if (
            event == self.product_defs.SurfaceEvent.ButtonShift.value
            or event == self.product_defs.SurfaceEvent.LegacyButtonShift.value
        ):
            return self.product_defs.Button.Shift
        if modifier_button_is_held:
            return self.modified_event_type_to_button.get(event)
        return self.event_type_to_button.get(event)

    def _handle_legacy_message(self, fl_event):
        event_type = fl_event.status, fl_event.data1
        if event_type == self.product_defs.SurfaceEvent.LegacyPadLayout.value:
            return [PadLayoutChangedAction(layout=fl_event.data2)]
        if event_type == self.product_defs.SurfaceEvent.LegacyEncoderLayout.value:
            return [EncoderLayoutChangedAction(layout=fl_event.data2)]
        if event_type == self.product_defs.SurfaceEvent.LegacyFaderLayout.value:
            return [FaderLayoutChangedAction(layout=fl_event.data2)]
        return []
