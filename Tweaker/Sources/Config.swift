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

// MARK: - Config model

struct TweakerConfig: Codable {
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

    static let stock = TweakerConfig(
        knobs: ["0": "song_position", "1": "horizontal_zoom", "2": "not_used", "3": "not_used",
                "4": "markers", "5": "not_used", "6": "not_used", "7": "tempo"],
        song_position: .init(["beats_multiplier": 1]), horizontal_zoom: .init(["steps_multiplier": 1]),
        vertical_zoom: .init(["steps_multiplier": 1]), markers: .init(["damper_threshold": 3]),
        tempo: .init(["sensitivity_multiplier": 25]), track_volume: .init(["sensitivity": 1.0]),
        track_pan: .init(["sensitivity": 1.0]), channel_volume: .init(["sensitivity": 1.0]),
        channel_pan: .init(["sensitivity": 1.0]), swing: .init(["sensitivity": 50])
    )

    static let fast = TweakerConfig(
        knobs: ["0": "song_position", "1": "horizontal_zoom", "2": "vertical_zoom", "3": "track_volume",
                "4": "markers", "5": "track_pan", "6": "swing", "7": "tempo"],
        song_position: .init(["beats_multiplier": 4]), horizontal_zoom: .init(["steps_multiplier": 3]),
        vertical_zoom: .init(["steps_multiplier": 3]), markers: .init(["damper_threshold": 1]),
        tempo: .init(["sensitivity_multiplier": 75]), track_volume: .init(["sensitivity": 1.5]),
        track_pan: .init(["sensitivity": 1.5]), channel_volume: .init(["sensitivity": 1.5]),
        channel_pan: .init(["sensitivity": 1.5]), swing: .init(["sensitivity": 50])
    )

    static let turbo = TweakerConfig(
        knobs: ["0": "song_position", "1": "horizontal_zoom", "2": "vertical_zoom", "3": "track_volume",
                "4": "markers", "5": "track_pan", "6": "swing", "7": "tempo"],
        song_position: .init(["beats_multiplier": 8]), horizontal_zoom: .init(["steps_multiplier": 6]),
        vertical_zoom: .init(["steps_multiplier": 6]), markers: .init(["damper_threshold": 1]),
        tempo: .init(["sensitivity_multiplier": 150]), track_volume: .init(["sensitivity": 3.0]),
        track_pan: .init(["sensitivity": 3.0]), channel_volume: .init(["sensitivity": 3.0]),
        channel_pan: .init(["sensitivity": 3.0]), swing: .init(["sensitivity": 100])
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
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)

        // Save to FL Studio location if directory exists
        let flDir = flStudioPath.deletingLastPathComponent()
        if FileManager.default.fileExists(atPath: flDir.path) {
            try data.write(to: flStudioPath)
        }

        // Also save locally
        try data.write(to: localPath)
    }
}
