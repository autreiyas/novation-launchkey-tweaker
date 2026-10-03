#
# Custom transport view: Swing amount via encoder.
#
from script.device_independent.util_view.view import View
from transport_speed_config import get_function_param


class TransportSwingView(View):
    def __init__(self, action_dispatcher, fl, *, control_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index

    def handle_ControlChangedAction(self, action):
        if action.control != self.control_index:
            return
        sensitivity = get_function_param("swing", "sensitivity", 50)
        current = self.fl.get_swing()
        delta = action.value * sensitivity
        new_swing = max(0, min(128, current + delta))
        self.fl.set_swing(int(new_swing))
