#
# Custom transport view: Vertical Zoom via encoder.
# Uses ui.move_up/move_down with Ctrl held (simulated via jog).
#
from script.constants import Zoom
from script.device_independent.util_view.view import View
from transport_speed_config import get_function_param

try:
    import ui
except ImportError:
    ui = None


class TransportVerticalZoomView(View):
    def __init__(self, action_dispatcher, fl, *, control_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index

    def handle_ControlChangedAction(self, action):
        if action.control != self.control_index:
            return
        if ui is None:
            return
        multiplier = get_function_param("vertical_zoom", "steps_multiplier", 3)
        raw_delta = abs(action.value) * 127
        steps = max(1, int(raw_delta * multiplier))
        direction = 1 if action.value > 0 else -1
        for _ in range(steps):
            ui.verZoom(direction)
