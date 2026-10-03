#
# Custom transport view: Selected mixer track volume via encoder.
#
from script.device_independent.util_view.view import View
from transport_speed_config import get_function_param


class TransportTrackVolumeView(View):
    def __init__(self, action_dispatcher, fl, *, control_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index

    def handle_ControlChangedAction(self, action):
        if action.control != self.control_index:
            return
        track = self.fl.get_selected_mixer_track()
        if track is None:
            return
        sensitivity = get_function_param("track_volume", "sensitivity", 1.5)
        current = self.fl.get_mixer_track_volume(track)
        delta = action.value * sensitivity
        new_vol = max(0.0, min(1.0, current + delta))
        self.fl.set_mixer_track_volume(track, new_vol, bypass_pickup=True)
