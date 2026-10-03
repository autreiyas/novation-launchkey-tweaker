#
# Modified transport song position view — reads speed from tweaker_config.json (live).
# Original: script/device_independent/view/transport_song_position_view.py
#
from script.actions import SongPositionChangedAction
from script.device_independent.util_view.view import View
from transport_speed_config import get_function_param


class TransportSongPositionView(View):
    def __init__(self, action_dispatcher, fl, *, control_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index

    def handle_ControlChangedAction(self, action):
        if action.control is not self.control_index:
            return
        self._increment_beat(action.value)
        self.action_dispatcher.dispatch(SongPositionChangedAction())

    def _increment_beat(self, value):
        ticks_per_beat = self.fl.get_ticks_per_beat()
        current_position = self.fl.transport_get_song_position_in_ticks()
        ticks_from_beat = current_position % ticks_per_beat

        multiplier = get_function_param("song_position", "beats_multiplier", 4)
        raw_delta = abs(value) * 127
        beats_to_skip = max(1, int(raw_delta * multiplier))
        direction = 1 if value > 0 else -1

        new_position = current_position - ticks_from_beat
        if ticks_from_beat == 0 or value > 0:
            new_position += direction * beats_to_skip * ticks_per_beat
        self.fl.transport_set_song_position_in_ticks(max(0, new_position))
