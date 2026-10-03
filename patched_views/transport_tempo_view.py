#
# Modified transport tempo view — reads sensitivity from tweaker_config.json (live).
# Original: script/device_independent/view/transport_tempo_view.py
#
from math import ceil, floor

from script.actions import TempoChangedAction
from script.device_independent.util_view.view import View
from transport_speed_config import get_function_param


class TransportTempoView(View):
    def __init__(self, action_dispatcher, fl, *, control_index):
        super().__init__(action_dispatcher)
        self.fl = fl
        self.control_index = control_index

    def handle_ControlChangedAction(self, action):
        if action.control is not self.control_index:
            return
        self._increment_tempo(action.value)
        self.action_dispatcher.dispatch(TempoChangedAction())

    def _increment_tempo(self, value):
        current_tempo = self.fl.get_tempo()
        multiplier = get_function_param("tempo", "sensitivity_multiplier", 75)
        value *= multiplier
        value = ceil(value) if value > 0 else floor(value)
        new_tempo = current_tempo + value
        self.fl.set_tempo(new_tempo)
