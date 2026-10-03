#
# Modified transport zoom view — reads speed from tweaker_config.json (live).
# Original: script/device_independent/view/transport_zoom_view.py
#
from script.actions import HorZoomChangedAction
from script.constants import Zoom
from script.device_independent.util_view.view import View
from transport_speed_config import get_function_param


class TransportZoomView(View):
    def __init__(self, action_dispatcher, fl, *, control_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index

    def handle_ControlChangedAction(self, action):
        if action.control == self.control_index:
            zoom_value = (Zoom.In if action.value > 0 else Zoom.Out).value
            multiplier = get_function_param("horizontal_zoom", "steps_multiplier", 3)
            raw_delta = abs(action.value) * 127
            steps = max(1, int(raw_delta * multiplier))
            for _ in range(steps):
                self.fl.ui.horizontal_zoom(zoom_value)
            self.action_dispatcher.dispatch(HorZoomChangedAction(value=zoom_value))
