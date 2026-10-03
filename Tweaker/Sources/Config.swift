import Foundation

// MARK: - Function definitions

enum KnobFunction: String, CaseIterable, Identifiable, Codable {
    case notUsed = "not_used"
    case songPosition = "song_position"
    case horizontalZoom = "horizontal_zoom"
    case verticalZoom = "vertical_zoom"
    case markers = "markers"
    case tempo = "tempo"
    case trackVolume = "track_volume"
    case trackPan = "track_pan"
    case channelVolume = "channel_volume"
    case channelPan = "channel_pan"
    case swing = "swing"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .notUsed: return "Not Used"
        case .songPosition: return "Song Position"
        case .horizontalZoom: return "Horizontal Zoom"
        case .verticalZoom: return "Vertical Zoom"
        case .markers: return "Markers"
        case .tempo: return "Tempo"
        case .trackVolume: return "Track Volume"
        case .trackPan: return "Track Pan"
        case .channelVolume: return "Channel Volume"
        case .channelPan: return "Channel Pan"
        case .swing: return "Swing"
        }
    }

    var paramLabel: String? {
        switch self {
        case .notUsed: return nil
        case .markers: return "Sensitivity (clicks to jump)"
        default: return "Speed"
        }
    }

    var paramKey: String {
        switch self {
        case .songPosition: return "beats_multiplier"
        case .horizontalZoom, .verticalZoom: return "steps_multiplier"
        case .markers: return "damper_threshold"
        case .tempo: return "sensitivity_multiplier"
        case .trackVolume, .trackPan, .channelVolume, .channelPan: return "sensitivity"
        case .swing: return "sensitivity"
        case .notUsed: return ""
        }
    }

    var paramRange: ClosedRange<Double> {
        switch self {
        case .songPosition: return 1...16
        case .horizontalZoom, .verticalZoom: return 1...10
        case .markers: return 1...5
        case .tempo: return 10...200
        case .trackVolume, .trackPan, .channelVolume, .channelPan: return 0.5...5.0
        case .swing: return 10...200
        case .notUsed: return 0...1
        }
    }

    var paramDefault: Double {
        switch self {
        case .songPosition: return 4
        case .horizontalZoom, .verticalZoom: return 3
        case .markers: return 1
        case .tempo: return 75
        case .trackVolume, .trackPan, .channelVolume, .channelPan: return 1.5
        case .swing: return 50
        case .notUsed: return 0
        }
    }

    var usesIntParam: Bool {
        switch self {
        case .trackVolume, .trackPan, .channelVolume, .channelPan: return false
        default: return true
        }
    }

    var icon: String {
        switch self {
        case .notUsed: return "circle.dashed"
        case .songPosition: return "waveform.path"
        case .horizontalZoom: return "arrow.left.and.right"
        case .verticalZoom: return "arrow.up.and.down"
        case .markers: return "bookmark"
        case .tempo: return "metronome"
        case .trackVolume: return "speaker.wave.2"
        case .trackPan: return "dial.low"
        case .channelVolume: return "slider.vertical.3"
        case .channelPan: return "dial.medium"
        case .swing: return "waveform.path.ecg"
        }
    }
}

// MARK: - Shift button function definitions

enum ButtonFunctionCategory: String, CaseIterable {
    case transport = "Transport"
    case editing = "Editing"
    case windows = "Windows"
    case navigation = "Navigation"
    case other = "Other"
}

enum ButtonFunction: String, CaseIterable, Identifiable, Codable {
    case notUsed = "not_used"
    // Transport
    case togglePatSong = "toggle_pat_song"
    case tapTempo = "tap_tempo"
    case toggleMetronome = "toggle_metronome"
    case toggleLoopRecord = "toggle_loop_record"
    case toggleCountdown = "toggle_countdown"
    case toggleOverdub = "toggle_overdub"
    case toggleWaitForInput = "toggle_wait_for_input"
    case punchIn = "punch_in"
    case punchOut = "punch_out"
    // Editing
    case undo = "undo"
    case redo = "redo"
    case copy = "copy"
    case cut = "cut"
    case paste = "paste"
    case delete = "delete"
    case insert = "insert"
    case toggleSnap = "toggle_snap"
    case toggleStepEdit = "toggle_step_edit"
    case toggleShuffle = "toggle_shuffle"
    case nudgePlus = "nudge_plus"
    case nudgeMinus = "nudge_minus"
    case clonePattern = "clone_pattern"
    case mute = "mute"
    // Windows & Browser
    case openPluginPicker = "open_plugin_picker"
    case nextWindow = "next_window"
    case focusMixer = "focus_mixer"
    case focusChannelRack = "focus_channel_rack"
    case focusPlaylist = "focus_playlist"
    case toggleBrowser = "toggle_browser"
    case openMenu = "open_menu"
    // F-Keys (FL Studio shortcuts)
    case f1 = "f1"
    case f2 = "f2"
    case f3 = "f3"
    case f4 = "f4"
    case f5 = "f5"
    case f6 = "f6"
    case f7 = "f7"
    case f8 = "f8"
    case f9 = "f9"
    case f10 = "f10"
    case f11 = "f11"
    case f12 = "f12"
    // Navigation
    case addMarker = "add_marker"
    // Other
    case save = "save"
    case saveNew = "save_new"
    case toggleMasterSync = "toggle_master_sync"
    case customKeystroke = "custom_keystroke"

    var id: String { rawValue }

    var category: ButtonFunctionCategory {
        switch self {
        case .notUsed: return .other
        case .togglePatSong, .tapTempo, .toggleMetronome, .toggleLoopRecord,
             .toggleCountdown, .toggleOverdub, .toggleWaitForInput, .punchIn, .punchOut:
            return .transport
        case .undo, .redo, .copy, .cut, .paste, .delete, .insert,
             .toggleSnap, .toggleStepEdit, .toggleShuffle, .nudgePlus, .nudgeMinus,
             .clonePattern, .mute:
            return .editing
        case .openPluginPicker, .nextWindow, .focusMixer, .focusChannelRack, .focusPlaylist,
             .toggleBrowser, .openMenu,
             .f1, .f2, .f3, .f4, .f5, .f6, .f7, .f8, .f9, .f10, .f11, .f12:
            return .windows
        case .addMarker:
            return .navigation
        case .save, .saveNew, .toggleMasterSync, .customKeystroke:
            return .other
        }
    }

    var displayName: String {
        switch self {
        case .notUsed: return "Not Used"
        case .togglePatSong: return "Pattern / Song"
        case .tapTempo: return "Tap Tempo"
        case .toggleMetronome: return "Metronome"
        case .toggleLoopRecord: return "Loop Record"
        case .toggleCountdown: return "Countdown"
        case .toggleOverdub: return "Overdub"
        case .toggleWaitForInput: return "Wait for Input"
        case .punchIn: return "Punch In"
        case .punchOut: return "Punch Out"
        case .undo: return "Undo"
        case .redo: return "Redo"
        case .copy: return "Copy"
        case .cut: return "Cut"
        case .paste: return "Paste"
        case .delete: return "Delete"
        case .insert: return "Insert"
        case .toggleSnap: return "Snap On/Off"
        case .toggleStepEdit: return "Step Edit"
        case .toggleShuffle: return "Shuffle"
        case .nudgePlus: return "Nudge +"
        case .nudgeMinus: return "Nudge -"
        case .clonePattern: return "Clone Pattern"
        case .mute: return "Mute"
        case .openPluginPicker: return "Plugin Picker"
        case .nextWindow: return "Next Window"
        case .focusMixer: return "Focus Mixer"
        case .focusChannelRack: return "Focus Channel Rack"
        case .focusPlaylist: return "Focus Playlist"
        case .toggleBrowser: return "Toggle Browser"
        case .openMenu: return "Open Menu"
        case .f1: return "F1 — Help"
        case .f2: return "F2 — Rename"
        case .f3: return "F3 — Find"
        case .f4: return "F4 — Next Empty Pat"
        case .f5: return "F5 — Playlist"
        case .f6: return "F6 — Channel Rack"
        case .f7: return "F7 — Piano Roll"
        case .f8: return "F8 — Plugin Picker"
        case .f9: return "F9 — Mixer"
        case .f10: return "F10 — MIDI Settings"
        case .f11: return "F11 — Song Info"
        case .f12: return "F12 — Close All"
        case .addMarker: return "Add Marker"
        case .save: return "Save"
        case .saveNew: return "Save As"
        case .toggleMasterSync: return "Master Sync"
        case .customKeystroke: return "Custom Keystroke"
        }
    }

    var icon: String {
        switch self {
        case .notUsed: return "circle.dashed"
        case .togglePatSong: return "repeat"
        case .tapTempo: return "hand.tap"
        case .toggleMetronome: return "metronome"
        case .toggleLoopRecord: return "arrow.triangle.2.circlepath"
        case .toggleCountdown: return "timer"
        case .toggleOverdub: return "waveform.badge.plus"
        case .toggleWaitForInput: return "clock.badge.questionmark"
        case .punchIn: return "arrow.right.to.line.compact"
        case .punchOut: return "arrow.left.to.line.compact"
        case .undo: return "arrow.uturn.backward"
        case .redo: return "arrow.uturn.forward"
        case .copy: return "doc.on.doc"
        case .cut: return "scissors"
        case .paste: return "doc.on.clipboard"
        case .delete: return "trash"
        case .insert: return "plus.rectangle"
        case .toggleSnap: return "arrow.right.to.line"
        case .toggleStepEdit: return "pianokeys"
        case .toggleShuffle: return "shuffle"
        case .nudgePlus: return "plus.circle"
        case .nudgeMinus: return "minus.circle"
        case .clonePattern: return "plus.square.on.square"
        case .mute: return "speaker.slash"
        case .openPluginPicker: return "square.grid.2x2"
        case .nextWindow: return "macwindow.on.rectangle"
        case .focusMixer: return "slider.horizontal.3"
        case .focusChannelRack: return "rectangle.split.3x1"
        case .focusPlaylist: return "list.bullet.rectangle"
        case .toggleBrowser: return "sidebar.left"
        case .openMenu: return "filemenu.and.selection"
        case .f1: return "questionmark.circle"
        case .f2: return "character.cursor.ibeam"
        case .f3: return "magnifyingglass"
        case .f4: return "plus.square"
        case .f5: return "list.bullet.rectangle"
        case .f6: return "rectangle.split.3x1"
        case .f7: return "pianokeys"
        case .f8: return "square.grid.2x2"
        case .f9: return "slider.horizontal.3"
        case .f10: return "gear"
        case .f11: return "info.circle"
        case .f12: return "xmark.square"
        case .addMarker: return "bookmark.fill"
        case .save: return "square.and.arrow.down"
        case .saveNew: return "square.and.arrow.down.on.square"
        case .toggleMasterSync: return "link"
        case .customKeystroke: return "keyboard"
        }
    }
}

struct ShiftButton: Identifiable {
    let configKey: String
    let displayName: String
    let shortName: String
    let icon: String
    let isStock: Bool  // true = already mapped by stock firmware (shown disabled)
    let stockFunction: String?
    var id: String { configKey }
}

struct ShiftButtonGroup: Identifiable {
    let name: String
    let icon: String
    let buttons: [ShiftButton]
    var id: String { name }

    // Transport buttons: 2 rows × 4, matching hardware layout
    static let transport = ShiftButtonGroup(name: "Transport", icon: "play.rectangle", buttons: [
        // Row 1: Stop, Loop, Capture, Undo
        ShiftButton(configKey: "shift_stop", displayName: "Shift + Stop", shortName: "Stop", icon: "stop.fill", isStock: false, stockFunction: nil),
        ShiftButton(configKey: "shift_loop", displayName: "Shift + Loop", shortName: "Loop", icon: "arrow.triangle.2.circlepath", isStock: false, stockFunction: nil),
        ShiftButton(configKey: "shift_capture_midi", displayName: "Shift + Capture", shortName: "Capture", icon: "pianokeys", isStock: false, stockFunction: nil),
        ShiftButton(configKey: "_stock_undo", displayName: "Shift + Undo", shortName: "Undo", icon: "arrow.uturn.backward", isStock: true, stockFunction: "Redo"),
        // Row 2: Play, Record, Quantise, Metronome
        ShiftButton(configKey: "shift_play", displayName: "Shift + Play", shortName: "Play", icon: "play.fill", isStock: false, stockFunction: nil),
        ShiftButton(configKey: "shift_record", displayName: "Shift + Record", shortName: "Record", icon: "record.circle", isStock: false, stockFunction: nil),
        ShiftButton(configKey: "shift_quantise", displayName: "Shift + Quantise", shortName: "Quantise", icon: "square.grid.3x3", isStock: false, stockFunction: nil),
        ShiftButton(configKey: "shift_metronome", displayName: "Shift + Metronome", shortName: "Metronome", icon: "metronome", isStock: false, stockFunction: nil),
    ])

    // Navigation buttons — stacked up/down pairs: Track (stock), Pads, Enc
    static let navigation = ShiftButtonGroup(name: "Navigation", icon: "arrow.left.arrow.right", buttons: [
        // Column 1: Track (stock)
        ShiftButton(configKey: "_stock_track_left", displayName: "Shift + Track \u{25C0}", shortName: "Track \u{25C0}", icon: "chevron.left", isStock: true, stockFunction: "Prev Track"),
        // Column 2: Pads
        ShiftButton(configKey: "shift_pads_page_up", displayName: "Shift + Pads \u{25B2}", shortName: "Pads \u{25B2}", icon: "chevron.up.2", isStock: false, stockFunction: nil),
        // Column 3: Encoder
        ShiftButton(configKey: "shift_encoder_page_up", displayName: "Shift + Enc \u{25B2}", shortName: "Enc \u{25B2}", icon: "chevron.up", isStock: false, stockFunction: nil),
        // Row 2
        ShiftButton(configKey: "_stock_track_right", displayName: "Shift + Track \u{25B6}", shortName: "Track \u{25B6}", icon: "chevron.right", isStock: true, stockFunction: "Next Track"),
        ShiftButton(configKey: "shift_pads_page_down", displayName: "Shift + Pads \u{25BC}", shortName: "Pads \u{25BC}", icon: "chevron.down.2", isStock: false, stockFunction: nil),
        ShiftButton(configKey: "shift_encoder_page_down", displayName: "Shift + Enc \u{25BC}", shortName: "Enc \u{25BC}", icon: "chevron.down", isStock: false, stockFunction: nil),
    ])

    static let allGroups: [ShiftButtonGroup] = [transport, navigation]
}

// MARK: - Button mapping model

struct ButtonMapping: Codable {
    var function: String
    var key: String?
    var modifiers: [String]?

    private enum CodingKeys: String, CodingKey {
        case function, key, modifiers, params
    }

    struct KeystrokeParams: Codable {
        var key: String?
        var modifiers: [String]?
    }

    init(function: String, key: String? = nil, modifiers: [String]? = nil) {
        self.function = function
        self.key = key
        self.modifiers = modifiers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        function = try container.decode(String.self, forKey: .function)
        // Try reading key/modifiers from top level first, then from params
        key = try? container.decode(String.self, forKey: .key)
        modifiers = try? container.decode([String].self, forKey: .modifiers)
        if key == nil, let params = try? container.decode(KeystrokeParams.self, forKey: .params) {
            key = params.key
            modifiers = params.modifiers
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(function, forKey: .function)
        if function == "custom_keystroke" {
            try container.encodeIfPresent(key, forKey: .key)
            try container.encodeIfPresent(modifiers, forKey: .modifiers)
        }
    }
}

// MARK: - Config model

struct TweakerConfig: Codable {
    var enable_shift_buttons: Bool?
    var enable_custom_keystrokes: Bool?
    var knobs: [String: String]
    var song_position: ParamSet?
    var horizontal_zoom: ParamSet?
    var vertical_zoom: ParamSet?
    var markers: ParamSet?
    var tempo: ParamSet?
    var track_volume: ParamSet?
    var track_pan: ParamSet?
    var channel_volume: ParamSet?
    var channel_pan: ParamSet?
    var swing: ParamSet?
    var buttons: [String: ButtonMapping]?

    struct ParamSet: Codable {
        // Use a flexible dict since each function has different param names
        var values: [String: Double]

        init(_ dict: [String: Double] = [:]) {
            self.values = dict
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.values = try container.decode([String: Double].self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(values)
        }
    }

    func paramValue(for function: KnobFunction) -> Double {
        let key = function.paramKey
        guard !key.isEmpty else { return 0 }
        let params = paramsFor(function)
        return params?.values[key] ?? function.paramDefault
    }

    mutating func setParamValue(_ value: Double, for function: KnobFunction) {
        let key = function.paramKey
        guard !key.isEmpty else { return }
        var params = paramsFor(function) ?? ParamSet()
        params.values[key] = value
        setParams(params, for: function)
    }

    func knobFunction(at index: Int) -> KnobFunction {
        let raw = knobs["\(index)"] ?? "not_used"
        return KnobFunction(rawValue: raw) ?? .notUsed
    }

    mutating func setKnobFunction(_ function: KnobFunction, at index: Int) {
        knobs["\(index)"] = function.rawValue
    }

    private func paramsFor(_ function: KnobFunction) -> ParamSet? {
        switch function {
        case .songPosition: return song_position
        case .horizontalZoom: return horizontal_zoom
        case .verticalZoom: return vertical_zoom
        case .markers: return markers
        case .tempo: return tempo
        case .trackVolume: return track_volume
        case .trackPan: return track_pan
        case .channelVolume: return channel_volume
        case .channelPan: return channel_pan
        case .swing: return swing
        case .notUsed: return nil
        }
    }

    private mutating func setParams(_ params: ParamSet, for function: KnobFunction) {
        switch function {
        case .songPosition: song_position = params
        case .horizontalZoom: horizontal_zoom = params
        case .verticalZoom: vertical_zoom = params
        case .markers: markers = params
        case .tempo: tempo = params
        case .trackVolume: track_volume = params
        case .trackPan: track_pan = params
        case .channelVolume: channel_volume = params
        case .channelPan: channel_pan = params
        case .swing: swing = params
        case .notUsed: break
        }
    }

    func buttonFunction(for key: String) -> ButtonFunction {
        guard let mapping = buttons?[key] else { return .notUsed }
        return ButtonFunction(rawValue: mapping.function) ?? .notUsed
    }

    func buttonKeystroke(for key: String) -> (key: String, modifiers: [String]) {
        guard let mapping = buttons?[key] else { return ("", []) }
        return (mapping.key ?? "", mapping.modifiers ?? [])
    }

    mutating func setButtonFunction(_ function: ButtonFunction, for key: String,
                                     keystrokeKey: String? = nil, keystrokeModifiers: [String]? = nil) {
        if buttons == nil { buttons = [:] }
        if function == .customKeystroke {
            buttons?[key] = ButtonMapping(
                function: function.rawValue,
                key: keystrokeKey,
                modifiers: keystrokeModifiers
            )
        } else {
            buttons?[key] = ButtonMapping(function: function.rawValue)
        }
    }

    static let defaultButtons: [String: ButtonMapping] = [
        "shift_metronome": ButtonMapping(function: "toggle_pat_song"),
        "shift_play": ButtonMapping(function: "not_used"),
        "shift_stop": ButtonMapping(function: "not_used"),
        "shift_record": ButtonMapping(function: "not_used"),
        "shift_loop": ButtonMapping(function: "not_used"),
        "shift_capture_midi": ButtonMapping(function: "not_used"),
        "shift_quantise": ButtonMapping(function: "not_used"),
        "shift_fader_1": ButtonMapping(function: "not_used"),
        "shift_fader_2": ButtonMapping(function: "not_used"),
        "shift_fader_3": ButtonMapping(function: "not_used"),
        "shift_fader_4": ButtonMapping(function: "not_used"),
        "shift_fader_5": ButtonMapping(function: "not_used"),
        "shift_fader_6": ButtonMapping(function: "not_used"),
        "shift_fader_7": ButtonMapping(function: "not_used"),
        "shift_fader_8": ButtonMapping(function: "not_used"),
        "shift_arm_select": ButtonMapping(function: "not_used"),
        "shift_encoder_page_up": ButtonMapping(function: "not_used"),
        "shift_encoder_page_down": ButtonMapping(function: "not_used"),
        "shift_pads_page_up": ButtonMapping(function: "not_used"),
        "shift_pads_page_down": ButtonMapping(function: "not_used"),
    ]

    static let stock = TweakerConfig(
        knobs: ["0": "song_position", "1": "horizontal_zoom", "2": "not_used", "3": "not_used",
                "4": "markers", "5": "not_used", "6": "not_used", "7": "tempo"],
        song_position: .init(["beats_multiplier": 1]), horizontal_zoom: .init(["steps_multiplier": 1]),
        vertical_zoom: .init(["steps_multiplier": 1]), markers: .init(["damper_threshold": 3]),
        tempo: .init(["sensitivity_multiplier": 25]), track_volume: .init(["sensitivity": 1.0]),
        track_pan: .init(["sensitivity": 1.0]), channel_volume: .init(["sensitivity": 1.0]),
        channel_pan: .init(["sensitivity": 1.0]), swing: .init(["sensitivity": 50]),
        buttons: defaultButtons
    )

    static let fast = TweakerConfig(
        knobs: ["0": "song_position", "1": "horizontal_zoom", "2": "vertical_zoom", "3": "track_volume",
                "4": "markers", "5": "track_pan", "6": "swing", "7": "tempo"],
        song_position: .init(["beats_multiplier": 4]), horizontal_zoom: .init(["steps_multiplier": 3]),
        vertical_zoom: .init(["steps_multiplier": 3]), markers: .init(["damper_threshold": 1]),
        tempo: .init(["sensitivity_multiplier": 75]), track_volume: .init(["sensitivity": 1.5]),
        track_pan: .init(["sensitivity": 1.5]), channel_volume: .init(["sensitivity": 1.5]),
        channel_pan: .init(["sensitivity": 1.5]), swing: .init(["sensitivity": 50]),
        buttons: defaultButtons
    )

    static let turbo = TweakerConfig(
        knobs: ["0": "song_position", "1": "horizontal_zoom", "2": "vertical_zoom", "3": "track_volume",
                "4": "markers", "5": "track_pan", "6": "swing", "7": "tempo"],
        song_position: .init(["beats_multiplier": 8]), horizontal_zoom: .init(["steps_multiplier": 6]),
        vertical_zoom: .init(["steps_multiplier": 6]), markers: .init(["damper_threshold": 1]),
        tempo: .init(["sensitivity_multiplier": 150]), track_volume: .init(["sensitivity": 3.0]),
        track_pan: .init(["sensitivity": 3.0]), channel_volume: .init(["sensitivity": 3.0]),
        channel_pan: .init(["sensitivity": 3.0]), swing: .init(["sensitivity": 100]),
        buttons: defaultButtons
    )
}

// MARK: - File I/O

struct ConfigFile {
    static let fileName = "tweaker_config.json"

    static var flStudioPath: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/Image-Line/FL Studio/Settings/Hardware/Novation")
            .appendingPathComponent(fileName)
    }

    static var localPath: URL {
        URL(fileURLWithPath: CommandLine.arguments[0])
            .deletingLastPathComponent()
            .appendingPathComponent(fileName)
    }

    static func load() -> TweakerConfig {
        let paths = [flStudioPath, localPath]
        for path in paths {
            if let data = try? Data(contentsOf: path),
               let config = try? JSONDecoder().decode(TweakerConfig.self, from: data) {
                return config
            }
        }
        return .fast
    }

    static func save(_ config: TweakerConfig) throws {
        // Build the JSON dict manually to match the Python config format:
        // buttons entries need {"function": "...", "params": {"key": "...", "modifiers": [...]}}
        // for custom_keystroke, but just {"function": "..."} for others.
        var dict: [String: Any] = [:]
        dict["enable_shift_buttons"] = config.enable_shift_buttons ?? false
        dict["enable_custom_keystrokes"] = config.enable_custom_keystrokes ?? false
        dict["knobs"] = config.knobs

        // Encode knob param sets
        let knobFunctions: [(String, TweakerConfig.ParamSet?)] = [
            ("song_position", config.song_position),
            ("horizontal_zoom", config.horizontal_zoom),
            ("vertical_zoom", config.vertical_zoom),
            ("markers", config.markers),
            ("tempo", config.tempo),
            ("track_volume", config.track_volume),
            ("track_pan", config.track_pan),
            ("channel_volume", config.channel_volume),
            ("channel_pan", config.channel_pan),
            ("swing", config.swing),
        ]
        for (key, params) in knobFunctions {
            if let p = params {
                dict[key] = p.values
            }
        }

        // Encode buttons
        if let buttons = config.buttons {
            var buttonsDict: [String: Any] = [:]
            for (key, mapping) in buttons {
                var entry: [String: Any] = ["function": mapping.function]
                if mapping.function == "custom_keystroke" {
                    var params: [String: Any] = [:]
                    if let k = mapping.key { params["key"] = k }
                    if let m = mapping.modifiers { params["modifiers"] = m }
                    entry["params"] = params
                }
                buttonsDict[key] = entry
            }
            dict["buttons"] = buttonsDict
        }

        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])

        // Save to FL Studio location if directory exists
        let flDir = flStudioPath.deletingLastPathComponent()
        if FileManager.default.fileExists(atPath: flDir.path) {
            try data.write(to: flStudioPath)
        }

        // Also save locally
        try data.write(to: localPath)
    }
}
