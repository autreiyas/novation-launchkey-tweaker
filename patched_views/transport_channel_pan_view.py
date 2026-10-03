#
# Custom transport view: Selected channel rack pan via encoder.
#
from script.device_independent.util_view.view import View
from transport_speed_config import get_function_param

try:
    import channels
except ImportError:
    channels = None


class TransportChannelPanView(View):
    def __init__(self, action_dispatcher, fl, *, control_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index

    def handle_ControlChangedAction(self, action):
        if action.control != self.control_index:
            return
        if channels is None:
            return
        ch = channels.selectedChannel()
        if ch < 0:
            return
        sensitivity = get_function_param("channel_pan", "sensitivity", 1.5)
        current = self.fl.get_channel_pan(ch)
        delta = action.value * sensitivity
        new_pan = max(-1.0, min(1.0, current + delta))
        self.fl.set_channel_pan(ch, new_pan, bypass_pickup=True)
