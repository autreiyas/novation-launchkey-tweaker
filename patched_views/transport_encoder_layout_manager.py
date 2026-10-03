#
# Modified transport encoder layout manager — reads knob assignments from
# tweaker_config.json so you can remap all 8 knobs in transport mode.
#
# Original: script/device_dependent/LaunchkeyMk4Range/transport_encoder_layout_manager.py
#
from script.device_independent.view import (
    NotUsedPreviewView,
    TransportIdleScreenView,
    TransportMarkerPreviewView,
    TransportMarkerScreenView,
    TransportMarkerView,
    TransportSongPositionPreviewView,
    TransportSongPositionScreenView,
    TransportSongPositionView,
    TransportTempoPreviewView,
    TransportTempoScreenView,
    TransportTempoView,
    TransportZoomPreviewView,
    TransportZoomScreenView,
    TransportZoomView,
)

# Custom views for the previously unused knobs
from patched_views.transport_vertical_zoom_view import TransportVerticalZoomView
from patched_views.transport_track_volume_view import TransportTrackVolumeView
from patched_views.transport_track_pan_view import TransportTrackPanView
from patched_views.transport_channel_volume_view import TransportChannelVolumeView
from patched_views.transport_channel_pan_view import TransportChannelPanView
from patched_views.transport_swing_view import TransportSwingView

from transport_speed_config import get_knob_function


def _create_views_for_function(func_name, action_dispatcher, fl, screen_writer, product_defs, control_index):
    """Return a list of views for a given function name and control index."""

    if func_name == "song_position":
        return [
            TransportSongPositionView(action_dispatcher, fl, control_index=control_index),
            TransportSongPositionScreenView(action_dispatcher, fl, screen_writer, control_index=control_index),
            TransportSongPositionPreviewView(action_dispatcher, product_defs, screen_writer, control_index=control_index),
        ]
    elif func_name == "horizontal_zoom":
        return [
            TransportZoomView(action_dispatcher, fl, control_index=control_index),
            TransportZoomScreenView(action_dispatcher, screen_writer, control_index=control_index),
            TransportZoomPreviewView(action_dispatcher, product_defs, screen_writer, control_index=control_index),
        ]
    elif func_name == "markers":
        return [
            TransportMarkerView(action_dispatcher, fl, control_index=control_index),
            TransportMarkerScreenView(action_dispatcher, screen_writer, control_index=control_index),
            TransportMarkerPreviewView(action_dispatcher, product_defs, screen_writer, control_index=control_index),
        ]
    elif func_name == "tempo":
        return [
            TransportTempoView(action_dispatcher, fl, control_index=control_index),
            TransportTempoScreenView(action_dispatcher, fl, screen_writer, control_index=control_index),
            TransportTempoPreviewView(action_dispatcher, product_defs, screen_writer, control_index=control_index),
        ]
    elif func_name == "vertical_zoom":
        return [
            TransportVerticalZoomView(action_dispatcher, fl, control_index=control_index),
        ]
    elif func_name == "track_volume":
        return [
            TransportTrackVolumeView(action_dispatcher, fl, control_index=control_index),
        ]
    elif func_name == "track_pan":
        return [
            TransportTrackPanView(action_dispatcher, fl, control_index=control_index),
        ]
    elif func_name == "channel_volume":
        return [
            TransportChannelVolumeView(action_dispatcher, fl, control_index=control_index),
        ]
    elif func_name == "channel_pan":
        return [
            TransportChannelPanView(action_dispatcher, fl, control_index=control_index),
        ]
    elif func_name == "swing":
        return [
            TransportSwingView(action_dispatcher, fl, control_index=control_index),
        ]
    else:
        # not_used
        return [
            NotUsedPreviewView(action_dispatcher, product_defs, screen_writer, control_index=control_index),
        ]


class TransportEncoderLayoutManager:
    def __init__(self, action_dispatcher, fl, screen_writer, device_manager, product_defs):
        self.device_manager = device_manager
        encoders = {
            index: product_defs.EncoderIndexToControlIndex.get(encoder)
            for index, encoder in enumerate(range(8))
        }

        self.views = [TransportIdleScreenView(action_dispatcher, screen_writer)]

        for knob_index in range(8):
            func_name = get_knob_function(knob_index)
            control_index = encoders[knob_index]
            self.views.extend(
                _create_views_for_function(
                    func_name, action_dispatcher, fl, screen_writer, product_defs, control_index
                )
            )

    def show(self):
        self.device_manager.enable_encoder_mode()
        for view in self.views:
            view.show()

    def hide(self):
        for view in self.views:
            view.hide()

    def focus_windows(self):
        pass
