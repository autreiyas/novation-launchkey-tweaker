import SwiftUI

// MARK: - Scale catalog

/// The Launchkey MK4's 30 scales in encoder order. MIDI value (CC 62) = index + 1.
/// Intervals are standard definitions; Novation doesn't publish theirs.
struct LaunchkeyScale: Identifiable {
    let value: Int
    let name: String
    let intervals: [Int]
    var id: Int { value }

    static let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    static let all: [LaunchkeyScale] = [
        ("Major", [0, 2, 4, 5, 7, 9, 11]),
        ("Minor", [0, 2, 3, 5, 7, 8, 10]),
        ("Dorian", [0, 2, 3, 5, 7, 9, 10]),
        ("Mixolydian", [0, 2, 4, 5, 7, 9, 10]),
        ("Lydian", [0, 2, 4, 6, 7, 9, 11]),
        ("Phrygian", [0, 1, 3, 5, 7, 8, 10]),
        ("Locrian", [0, 1, 3, 5, 6, 8, 10]),
        ("Whole Tone", [0, 2, 4, 6, 8, 10]),
        ("Half Whole Dim", [0, 1, 3, 4, 6, 7, 9, 10]),
        ("Whole Half Diminished", [0, 2, 3, 5, 6, 8, 9, 11]),
        ("Blues", [0, 3, 5, 6, 7, 10]),
        ("Minor Pentatonic", [0, 3, 5, 7, 10]),
        ("Major Pentatonic", [0, 2, 4, 7, 9]),
        ("Harmonic Minor", [0, 2, 3, 5, 7, 8, 11]),
        ("Harmonic Major", [0, 2, 4, 5, 7, 8, 11]),
        ("Dorian #4", [0, 2, 3, 6, 7, 9, 10]),
        ("Phrygian Dominant", [0, 1, 4, 5, 7, 8, 10]),
        ("Melodic Minor", [0, 2, 3, 5, 7, 9, 11]),
        ("Lydian Augmented", [0, 2, 4, 6, 8, 9, 11]),
        ("Lydian Dominant", [0, 2, 4, 6, 7, 9, 10]),
        ("Super Locrian", [0, 1, 3, 4, 6, 8, 10]),
        ("8-tone Spanish", [0, 1, 3, 4, 5, 6, 8, 10]),
        ("Bhairav", [0, 1, 4, 5, 7, 8, 11]),
        ("Hungarian Minor", [0, 2, 3, 6, 7, 8, 11]),
        ("Hirajoshi", [0, 2, 3, 7, 8]),
        ("In-Sen", [0, 1, 5, 7, 10]),
        ("Iwato", [0, 1, 5, 6, 10]),
        ("Kumoi", [0, 2, 3, 7, 9]),
        ("Pelog-Selisir", [0, 1, 3, 7, 8]),
        ("Pelog-Tembung", [0, 1, 5, 7, 8]),
    ].enumerated().map { LaunchkeyScale(value: $0.offset + 1, name: $0.element.0, intervals: $0.element.1) }

    static func with(value: Int?) -> LaunchkeyScale? {
        guard let v = value, v >= 1, v <= all.count else { return nil }
        return all[v - 1]
    }

    /// Pitch classes (0–11) in this scale for a given root.
    func pitchClasses(root: Int) -> Set<Int> {
        Set(intervals.map { ($0 + root) % 12 })
    }

    func noteNames(root: Int) -> [String] {
        intervals.map { LaunchkeyScale.noteNames[($0 + root) % 12] }
    }
}

// MARK: - Sync model

/// Watches tweaker_scale_state.json (written by the FL script) and writes
/// tweaker_scale_request.json (read by the FL script, which sends it to the keyboard).
final class ScaleSyncModel: ObservableObject {
    @Published private(set) var root: Int?
    @Published private(set) var type: Int?
    @Published private(set) var enabled: Bool?
    @Published private(set) var lastUpdate: Date?

    private var timer: Timer?
    private var lastMtime: Date?

    private static var novationDir: URL { ConfigFile.flStudioPath.deletingLastPathComponent() }
    static var statePath: URL { novationDir.appendingPathComponent("tweaker_scale_state.json") }
    static var requestPath: URL { novationDir.appendingPathComponent("tweaker_scale_request.json") }

    var scale: LaunchkeyScale? { LaunchkeyScale.with(value: type) }
    var hasState: Bool { root != nil && type != nil }

    func start() {
        guard timer == nil else { return }
        poll()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in self?.poll() }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        let path = Self.statePath
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path.path),
              let mtime = attrs[.modificationDate] as? Date,
              mtime != lastMtime,
              let data = try? Data(contentsOf: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }
        lastMtime = mtime
        root = json["root"] as? Int
        type = json["type"] as? Int
        enabled = json["enabled"] as? Bool
        lastUpdate = mtime
    }

    /// Ask FL to set the keyboard's scale. Updates locally right away; the
    /// keyboard's reply (via the state file) confirms it.
    func request(root newRoot: Int? = nil, type newType: Int? = nil, enabled newEnabled: Bool? = nil) {
        var payload: [String: Any] = ["requested": Date().timeIntervalSince1970]
        if let r = newRoot ?? root { payload["root"] = r; root = r }
        if let s = newType ?? type { payload["type"] = s; type = s }
        if let e = newEnabled { payload["enabled"] = e; enabled = e }
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]) else { return }
        try? data.write(to: Self.requestPath, options: .atomic)
    }
}

// MARK: - Scale section

struct ScaleSection: View {
    @ObservedObject var model: ScaleSyncModel
    let t: ThemeColors

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "music.quarternote.3")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(t.accent)
                Text("Scale")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(t.text)
                Text("Synced with the Launchkey \u{2014} match it in FL\u{2019}s piano roll")
                    .font(.system(size: 12))
                    .foregroundStyle(t.textMuted)
            }

            HStack(alignment: .top, spacing: 24) {
                currentScale
                    .frame(width: 220, alignment: .leading)
                OctaveKeyboard(root: model.root, pitchClasses: currentPitchClasses, t: t)
                    .frame(width: 280, height: 96)
                pickers
            }
            .padding(16)
            .background(t.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(t.cardBorder, lineWidth: 1))

            flHint
        }
        .onAppear { model.start() }
    }

    private var currentPitchClasses: Set<Int> {
        guard let root = model.root, let scale = model.scale else { return [] }
        return scale.pitchClasses(root: root)
    }

    private var currentScale: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let root = model.root, let scale = model.scale {
                Text("\(LaunchkeyScale.noteNames[root]) \(scale.name)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(t.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(scale.noteNames(root: root).joined(separator: "  "))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(t.textDim)
                HStack(spacing: 6) {
                    Circle()
                        .fill(model.enabled == false ? t.textMuted : t.green)
                        .frame(width: 7, height: 7)
                    Text(model.enabled == false ? "Scale mode off on keyboard" : "Scale mode on")
                        .font(.system(size: 11))
                        .foregroundStyle(t.textMuted)
                }
            } else {
                Text("Waiting for FL Studio")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(t.textDim)
                Text("Open FL Studio with the Launchkey connected. The scale appears here once the script reports it.")
                    .font(.system(size: 11))
                    .foregroundStyle(t.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var pickers: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Root: 12 pills in two rows
            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<2) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<6) { col in
                            rootPill(row * 6 + col)
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                Picker("", selection: Binding(
                    get: { model.type ?? 1 },
                    set: { model.request(type: $0) }
                )) {
                    ForEach(LaunchkeyScale.all) { scale in
                        Text(scale.name).tag(scale.value)
                    }
                }
                .labelsHidden()
                .frame(width: 190)

                Toggle("Scale mode", isOn: Binding(
                    get: { model.enabled ?? false },
                    set: { model.request(enabled: $0) }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)
                .font(.system(size: 11))
                .foregroundStyle(t.textDim)
            }
        }
    }

    private func rootPill(_ note: Int) -> some View {
        let isSelected = model.root == note
        return Button(action: { model.request(root: note) }) {
            Text(LaunchkeyScale.noteNames[note])
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? (t.isDark ? t.bg : .white) : t.textDim)
                .frame(width: 34, height: 26)
                .background(isSelected ? t.accent : t.pillBg)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help("Set root to \(LaunchkeyScale.noteNames[note])")
    }

    @ViewBuilder
    private var flHint: some View {
        if let root = model.root, let scale = model.scale {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                Text("In FL Studio: piano roll toolbar \u{2192} right-click the Snap to scale icon \u{2192} root \(LaunchkeyScale.noteNames[root]), then \(scale.name) (or the scale with these notes)")
                    .font(.system(size: 11))
            }
            .foregroundStyle(t.textMuted)
        }
    }
}

// MARK: - One-octave keyboard

struct OctaveKeyboard: View {
    let root: Int?
    let pitchClasses: Set<Int>
    let t: ThemeColors

    private let whites = [0, 2, 4, 5, 7, 9, 11]
    // Black key pitch class -> index of the white key it sits after
    private let blacks: [(Int, Int)] = [(1, 0), (3, 1), (6, 3), (8, 4), (10, 5)]

    var body: some View {
        GeometryReader { geo in
            let whiteW = geo.size.width / CGFloat(whites.count)
            let blackW = whiteW * 0.6
            ZStack(alignment: .topLeading) {
                HStack(spacing: 2) {
                    ForEach(whites, id: \.self) { pc in
                        key(pc, isBlack: false)
                    }
                }
                ForEach(blacks, id: \.0) { pc, after in
                    key(pc, isBlack: true)
                        .frame(width: blackW, height: geo.size.height * 0.58)
                        .offset(x: whiteW * CGFloat(after + 1) - blackW / 2)
                }
            }
        }
    }

    private func key(_ pc: Int, isBlack: Bool) -> some View {
        let inScale = pitchClasses.contains(pc)
        let isRoot = root == pc && inScale
        let base: Color = isBlack ? t.text.opacity(t.isDark ? 0.25 : 0.75) : t.text.opacity(t.isDark ? 0.12 : 0.04)
        let fill: Color = isRoot ? t.accent : (inScale ? t.accent.opacity(isBlack ? 0.7 : 0.35) : base)
        return RoundedRectangle(cornerRadius: 4)
            .fill(fill)
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(t.cardBorder, lineWidth: 0.5))
            .overlay(alignment: .bottom) {
                if !isBlack {
                    Text(LaunchkeyScale.noteNames[pc])
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(isRoot ? (t.isDark ? t.bg : .white) : t.textMuted)
                        .padding(.bottom, 4)
                }
            }
    }
}
