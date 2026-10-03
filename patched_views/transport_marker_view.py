#
# Modified transport marker view — reads damper from tweaker_config.json (live).
# Original: script/device_independent/view/transport_marker_view.py
#
from script.actions import MarkerSelectBlockedAction, NextMarkerSelectedAction, PreviousMarkerSelectedAction
from script.device_independent.util_view.view import View
from script.fl_constants import LoopMode
from transport_speed_config import get_function_param


class TransportMarkerView(View):
    def __init__(self, action_dispatcher, fl, *, control_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index
        self.damperValue = 0

    def handle_ControlChangedAction(self, action):
        if action.control != self.control_index:
            return

        if self.fl.transport_get_loop_mode() == LoopMode.Pattern:
            self.action_dispatcher.dispatch(MarkerSelectBlockedAction(message="Pattern mode"))
            return

        self.fl.ui.focus_playlist_window()
        if action.control == self.control_index:
            threshold = get_function_param("markers", "damper_threshold", 1)
            self.damperValue += 1 if action.value > 0 else -1
            if self.damperValue > threshold:
                self.damperValue = 0
                self.fl.transport_go_to_next_marker()
                self.action_dispatcher.dispatch(NextMarkerSelectedAction())
            elif self.damperValue < -threshold:
                self.damperValue = 0
                self.fl.transport_go_to_previous_marker()
                self.action_dispatcher.dispatch(PreviousMarkerSelectedAction())
