#
# Hot-reloadable config loader for Launchkey MK4 transport encoder patch.
# Reads tweaker_config.json and caches it. Re-reads automatically when
# the file is modified — no FL Studio restart needed.
#
import json
import os

_config_cache = None
_config_mtime = 0
_config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tweaker_config.json")


def _default_config():
    return {
        "knobs": {
            "0": "song_position",
            "1": "horizontal_zoom",
            "2": "not_used",
            "3": "not_used",
            "4": "markers",
            "5": "not_used",
            "6": "not_used",
            "7": "tempo",
        },
        "song_position": {"beats_multiplier": 4},
        "horizontal_zoom": {"steps_multiplier": 3},
        "vertical_zoom": {"steps_multiplier": 3},
        "markers": {"damper_threshold": 1},
        "tempo": {"sensitivity_multiplier": 75},
        "track_volume": {"sensitivity": 1.5},
        "track_pan": {"sensitivity": 1.5},
        "channel_volume": {"sensitivity": 1.5},
        "channel_pan": {"sensitivity": 1.5},
        "swing": {"sensitivity": 50},
    }


def get_config():
    global _config_cache, _config_mtime
    try:
        mtime = os.path.getmtime(_config_path)
        if _config_cache is None or mtime != _config_mtime:
            with open(_config_path, "r") as f:
                _config_cache = json.load(f)
            _config_mtime = mtime
    except (OSError, json.JSONDecodeError):
        if _config_cache is None:
            _config_cache = _default_config()
    return _config_cache


def get_knob_function(knob_index):
    cfg = get_config()
    return cfg.get("knobs", {}).get(str(knob_index), "not_used")


def get_function_param(function_name, param_name, default=1):
    cfg = get_config()
    return cfg.get(function_name, {}).get(param_name, default)


# Convenience accessors used by patched views
SONG_POSITION_BEATS_MULTIPLIER = property(lambda self: get_function_param("song_position", "beats_multiplier", 4))
ZOOM_STEPS_MULTIPLIER = property(lambda self: get_function_param("horizontal_zoom", "steps_multiplier", 3))
MARKER_DAMPER_THRESHOLD = property(lambda self: get_function_param("markers", "damper_threshold", 1))
TEMPO_SENSITIVITY_MULTIPLIER = property(lambda self: get_function_param("tempo", "sensitivity_multiplier", 75))
