import SwiftUI
import AppKit

// MARK: - Theme definition

struct ThemeColors {
    let bg: Color
    let cardBg: Color
    let cardBorder: Color
    let cardBorderActive: Color
    let accent: Color
    let accentDim: Color
    let text: Color
    let textDim: Color
    let textMuted: Color
    let pillBg: Color
    let pillActive: Color
    let sliderTrack: Color
    let sliderFill: Color
    let knobBody: Color
    let knobBodyActive: Color
    let knobRing: Color
    let knobRingActive: Color
    let green: Color
    let orange: Color
    let isDark: Bool
}

// MARK: - Theme identifiers

enum ThemeMode: String, CaseIterable, Identifiable, Codable {
    case midnight = "Midnight"
    case arctic = "Arctic"
    case flStudio = "FL Studio"
    case system = "System"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .midnight: return "moon.stars"
        case .arctic: return "snowflake"
        case .flStudio: return "music.note"
        case .system: return "laptopcomputer"
        }
    }
}

// MARK: - Theme provider

class ThemeProvider: ObservableObject {
    @Published var mode: ThemeMode = .midnight {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: "tweaker_theme") }
    }

    var colors: ThemeColors {
        switch mode {
        case .midnight: return Self.midnight
        case .arctic: return Self.arctic
        case .flStudio: return Self.flStudio
        case .system: return systemTheme()
        }
    }

    init() {
        if let saved = UserDefaults.standard.string(forKey: "tweaker_theme"),
           let m = ThemeMode(rawValue: saved) {
            mode = m
        }
    }

    // MARK: - Midnight (default dark blue)

    static let midnight = ThemeColors(
        bg:               Color(red: 0.08, green: 0.08, blue: 0.10),
        cardBg:           Color.white.opacity(0.04),
        cardBorder:       Color.white.opacity(0.06),
        cardBorderActive: Color(red: 0.35, green: 0.55, blue: 0.95).opacity(0.35),
        accent:           Color(red: 0.4, green: 0.65, blue: 1.0),
        accentDim:        Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.15),
        text:             .white,
        textDim:          Color.white.opacity(0.45),
        textMuted:        Color.white.opacity(0.25),
        pillBg:           Color.white.opacity(0.07),
        pillActive:       Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.2),
        sliderTrack:      Color.white.opacity(0.08),
        sliderFill:       Color(red: 0.4, green: 0.65, blue: 1.0),
        knobBody:         Color(red: 0.17, green: 0.17, blue: 0.20),
        knobBodyActive:   Color(red: 0.22, green: 0.22, blue: 0.26),
        knobRing:         Color.white.opacity(0.08),
        knobRingActive:   Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.2),
        green:            Color(red: 0.3, green: 0.8, blue: 0.5),
        orange:           Color(red: 0.95, green: 0.65, blue: 0.25),
        isDark:           true
    )

    // MARK: - Arctic (white/cyan — matches white Launchkey)

    static let arctic = ThemeColors(
        bg:               Color(red: 0.94, green: 0.95, blue: 0.96),
        cardBg:           Color.white.opacity(0.7),
        cardBorder:       Color.black.opacity(0.06),
        cardBorderActive: Color(red: 0.0, green: 0.70, blue: 0.85).opacity(0.4),
        accent:           Color(red: 0.0, green: 0.65, blue: 0.82),
        accentDim:        Color(red: 0.0, green: 0.65, blue: 0.82).opacity(0.12),
        text:             Color(red: 0.12, green: 0.12, blue: 0.14),
        textDim:          Color.black.opacity(0.45),
        textMuted:        Color.black.opacity(0.25),
        pillBg:           Color.black.opacity(0.05),
        pillActive:       Color(red: 0.0, green: 0.65, blue: 0.82).opacity(0.15),
        sliderTrack:      Color.black.opacity(0.08),
        sliderFill:       Color(red: 0.0, green: 0.65, blue: 0.82),
        knobBody:         Color(red: 0.88, green: 0.89, blue: 0.90),
        knobBodyActive:   Color(red: 0.92, green: 0.93, blue: 0.94),
        knobRing:         Color.black.opacity(0.08),
        knobRingActive:   Color(red: 0.0, green: 0.65, blue: 0.82).opacity(0.25),
        green:            Color(red: 0.15, green: 0.70, blue: 0.45),
        orange:           Color(red: 0.90, green: 0.55, blue: 0.15),
        isDark:           false
    )

    // MARK: - FL Studio (charcoal/orange)

    static let flStudio = ThemeColors(
        bg:               Color(red: 0.14, green: 0.14, blue: 0.15),
        cardBg:           Color(red: 0.18, green: 0.18, blue: 0.19).opacity(0.8),
        cardBorder:       Color.white.opacity(0.05),
        cardBorderActive: Color(red: 1.0, green: 0.55, blue: 0.10).opacity(0.4),
        accent:           Color(red: 1.0, green: 0.55, blue: 0.10),
        accentDim:        Color(red: 1.0, green: 0.55, blue: 0.10).opacity(0.12),
        text:             Color(red: 0.92, green: 0.92, blue: 0.90),
        textDim:          Color.white.opacity(0.40),
        textMuted:        Color.white.opacity(0.22),
        pillBg:           Color.white.opacity(0.06),
        pillActive:       Color(red: 1.0, green: 0.55, blue: 0.10).opacity(0.2),
        sliderTrack:      Color.white.opacity(0.07),
        sliderFill:       Color(red: 1.0, green: 0.55, blue: 0.10),
        knobBody:         Color(red: 0.20, green: 0.20, blue: 0.21),
        knobBodyActive:   Color(red: 0.25, green: 0.25, blue: 0.26),
        knobRing:         Color.white.opacity(0.07),
        knobRingActive:   Color(red: 1.0, green: 0.55, blue: 0.10).opacity(0.2),
        green:            Color(red: 0.3, green: 0.8, blue: 0.5),
        orange:           Color(red: 1.0, green: 0.55, blue: 0.10),
        isDark:           true
    )

    // MARK: - System (follows macOS)

    private func systemTheme() -> ThemeColors {
        let appearance = NSApp.effectiveAppearance
        let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let accentColor = Color.accentColor

        if isDark {
            return ThemeColors(
                bg:               Color(nsColor: .windowBackgroundColor),
                cardBg:           Color.white.opacity(0.04),
                cardBorder:       Color.white.opacity(0.06),
                cardBorderActive: accentColor.opacity(0.35),
                accent:           accentColor,
                accentDim:        accentColor.opacity(0.15),
                text:             .white,
                textDim:          Color.white.opacity(0.45),
                textMuted:        Color.white.opacity(0.25),
                pillBg:           Color.white.opacity(0.07),
                pillActive:       accentColor.opacity(0.2),
                sliderTrack:      Color.white.opacity(0.08),
                sliderFill:       accentColor,
                knobBody:         Color(red: 0.17, green: 0.17, blue: 0.20),
                knobBodyActive:   Color(red: 0.22, green: 0.22, blue: 0.26),
                knobRing:         Color.white.opacity(0.08),
                knobRingActive:   accentColor.opacity(0.2),
                green:            Color(red: 0.3, green: 0.8, blue: 0.5),
                orange:           Color(red: 0.95, green: 0.65, blue: 0.25),
                isDark:           true
            )
        } else {
            return ThemeColors(
                bg:               Color(nsColor: .windowBackgroundColor),
                cardBg:           Color.white.opacity(0.6),
                cardBorder:       Color.black.opacity(0.06),
                cardBorderActive: accentColor.opacity(0.35),
                accent:           accentColor,
                accentDim:        accentColor.opacity(0.12),
                text:             Color(red: 0.12, green: 0.12, blue: 0.14),
                textDim:          Color.black.opacity(0.45),
                textMuted:        Color.black.opacity(0.25),
                pillBg:           Color.black.opacity(0.05),
                pillActive:       accentColor.opacity(0.15),
                sliderTrack:      Color.black.opacity(0.08),
                sliderFill:       accentColor,
                knobBody:         Color(red: 0.88, green: 0.89, blue: 0.90),
                knobBodyActive:   Color(red: 0.92, green: 0.93, blue: 0.94),
                knobRing:         Color.black.opacity(0.08),
                knobRingActive:   accentColor.opacity(0.25),
                green:            Color(red: 0.15, green: 0.70, blue: 0.45),
                orange:           Color(red: 0.90, green: 0.55, blue: 0.15),
                isDark:           false
            )
        }
    }
}
