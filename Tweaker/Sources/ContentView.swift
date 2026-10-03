import SwiftUI

// MARK: - Main view

struct ContentView: View {
    @StateObject private var viewModel = ConfigViewModel()
    @StateObject private var theme = ThemeProvider()
    @State private var compactLayout = false
    @State private var largeCards = true

    private var t: ThemeColors { theme.colors }

    var body: some View {
        ZStack {
            VisualEffectBackground(
                material: t.isDark ? .hudWindow : .headerView,
                blendingMode: .behindWindow
            )
            .ignoresSafeArea()

            t.bg.opacity(t.isDark ? 0.85 : 0.75).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .padding(.bottom, 14)

                Rectangle().fill(t.cardBorder).frame(height: 1)

                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "dial.medium")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(t.accent)

                                Text("Transport Encoders")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(t.text)

                                Text("Knobs 1–8 in transport mode")
                                    .font(.system(size: 12))
                                    .foregroundStyle(t.textMuted)
                            }
                            knobStrip
                        }
                        if viewModel.config.enable_shift_buttons == true {
                            buttonSection
                        }
                    }
                    .padding(20)
                }

                Rectangle().fill(t.cardBorder).frame(height: 1)

                footer
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
        }
        .preferredColorScheme(t.isDark ? .dark : .light)
        .environmentObject(theme)
        .onAppear { viewModel.load() }
    }

    private func openAccessibilitySettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            (Text("LAUNCH").font(.system(size: 20, weight: .bold, design: .rounded))
             + Text("KEY").font(.system(size: 20, weight: .light, design: .rounded))
             + Text(" TWEAKER").font(.system(size: 20, weight: .bold, design: .rounded)))
                .foregroundStyle(t.text)

            Link(destination: URL(string: "https://github.com/autreiyas/novation-launchkey-tweaker")!) {
                Text("v\(AppVersion.current)")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(t.textMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(t.pillBg)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            // Accessibility settings
            Button(action: { openAccessibilitySettings() }) {
                Image(systemName: "hand.raised")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(t.textDim)
                    .frame(width: 36, height: 32)
                    .background(t.pillBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help("Open Accessibility Settings (required for custom keystrokes)")

            // Theme picker
            HStack(spacing: 1) {
                ForEach(ThemeMode.allCases) { mode in
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { theme.mode = mode } }) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(theme.mode == mode ? t.accent : t.textDim)
                            .frame(width: 36, height: 32)
                            .background(theme.mode == mode ? t.pillActive : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .help(mode.rawValue)
                }
            }
            .padding(2)
            .background(t.pillBg)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Preset pills
            HStack(spacing: 1) {
                PresetPill(label: "Stock", isActive: viewModel.selectedPreset == .stock, t: t) {
                    viewModel.applyPresetChoice(.stock)
                }
                .help("Original Novation speeds")
                PresetPill(label: "Fast", isActive: viewModel.selectedPreset == .fast, t: t) {
                    viewModel.applyPresetChoice(.fast)
                }
                .help("3–4x faster, all knobs mapped")
                PresetPill(label: "Turbo", isActive: viewModel.selectedPreset == .turbo, t: t) {
                    viewModel.applyPresetChoice(.turbo)
                }
                .help("6–8x faster, all knobs mapped")
            }
            .padding(2)
            .background(t.pillBg)
            .clipShape(Capsule())

            // Card size + layout toggles
            HStack(spacing: 1) {
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { largeCards.toggle() } }) {
                    Image(systemName: largeCards ? "rectangle.expand.vertical" : "rectangle.compress.vertical")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(t.textDim)
                        .frame(width: 36, height: 32)
                        .background(t.pillBg)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .help(largeCards ? "Smaller cards" : "Larger cards")

                Button(action: { withAnimation(.easeInOut(duration: 0.25)) { compactLayout.toggle() } }) {
                    Image(systemName: compactLayout ? "rectangle.split.2x2" : "rectangle.split.1x2")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(t.textDim)
                        .frame(width: 36, height: 32)
                        .background(t.pillBg)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .help(compactLayout ? "Single row" : "Two rows")
            }
            .padding(2)
            .background(t.pillBg)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Knob strip

    private var cardWidth: CGFloat { largeCards ? 240 : 160 }

    private var knobStrip: some View {
        Group {
            if compactLayout {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(cardWidth), spacing: 12), count: 4), spacing: 12) {
                    ForEach(0..<8) { i in
                        KnobCard(index: i, viewModel: viewModel, t: t, large: largeCards)
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(0..<8) { i in
                        KnobCard(index: i, viewModel: viewModel, t: t, large: largeCards)
                            .frame(width: cardWidth)
                    }
                }
            }
        }
    }

    // MARK: - Button mapping section

    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "keyboard")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(t.accent)

                Text("Shift Button Mappings")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(t.text)

                Text("Hold Shift + press a button")
                    .font(.system(size: 12))
                    .foregroundStyle(t.textMuted)
            }

            ForEach(ShiftButtonGroup.allGroups) { group in
                buttonGroupSection(group)
            }
        }
    }

    private func buttonGroupSection(_ group: ShiftButtonGroup) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: group.icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(t.textDim)
                Text(group.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(t.textDim)
            }

            let columns: Int = {
                switch group.name {
                case "Transport": return 4   // 4×2 grid
                case "Fader Select": return 9 // 8 + arm/select
                default: return 3            // navigation: 3×2 (up/down pairs)
                }
            }()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 8) {
                ForEach(group.buttons) { btn in
                    ButtonMappingCard(button: btn, viewModel: viewModel, t: t)
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(viewModel.statusColor)
                .frame(width: 7, height: 7)

            Text(viewModel.statusText)
                .font(.system(size: 12))
                .foregroundStyle(t.textDim)

            Spacer()

            Button(action: { viewModel.save() }) {
                Text("Save")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(t.isDark ? t.bg : .white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 7)
                    .background(t.accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .keyboardShortcut("s", modifiers: .command)
        }
    }
}

// MARK: - Custom preset pill

struct PresetPill: View {
    let label: String
    let isActive: Bool
    let t: ThemeColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                .foregroundStyle(isActive ? t.accent : t.textDim)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isActive ? t.pillActive : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// MARK: - Knob card

struct KnobCard: View {
    let index: Int
    @ObservedObject var viewModel: ConfigViewModel
    let t: ThemeColors
    var large: Bool = true
    @State private var showingPicker = false

    private var function: KnobFunction {
        viewModel.config.knobFunction(at: index)
    }

    private var isActive: Bool {
        function != .notUsed
    }

    var body: some View {
        VStack(spacing: 10) {
            // Centered encoder visual — larger
            encoderKnob
                .padding(.top, 8)

            // Knob number
            Text("\(index + 1)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(t.textMuted)
                .tracking(1)

            // Function selector
            Button(action: { showingPicker.toggle() }) {
                HStack(spacing: 5) {
                    Text(function.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isActive ? t.text : t.textDim)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(t.textMuted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity)
                .background(t.pillBg)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingPicker, arrowEdge: .bottom) {
                functionPicker
            }

            // Parameter control
            if let label = function.paramLabel {
                parameterSlider(label: label)
                    .padding(.bottom, 4)
            } else {
                Color.clear.frame(height: 42)
                    .padding(.bottom, 4)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(t.cardBg)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(t.isDark ? 0.3 : 0.5))
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isActive ? t.cardBorderActive : t.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Encoder knob visual (larger)

    private var ringSize: CGFloat { large ? 80 : 64 }
    private var knobSize: CGFloat { large ? 62 : 50 }
    private var iconSize: CGFloat { large ? 18 : 15 }
    private var notchHeight: CGFloat { large ? 14 : 12 }
    private var notchOffset: CGFloat { large ? -19 : -15 }

    private var encoderKnob: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(isActive ? t.knobRingActive : t.knobRing, lineWidth: large ? 3 : 2.5)
                .frame(width: ringSize, height: ringSize)

            // Knob body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            isActive ? t.knobBodyActive : t.knobBody,
                            t.knobBody.opacity(0.8)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: knobSize
                    )
                )
                .frame(width: knobSize, height: knobSize)
                .shadow(color: .black.opacity(t.isDark ? 0.5 : 0.15), radius: 5, y: 3)

            // Indicator notch
            Capsule()
                .fill(isActive ? t.accent : t.textMuted)
                .frame(width: 3, height: notchHeight)
                .offset(y: notchOffset)
                .rotationEffect(.degrees(-45))

            // Function icon inside knob
            Image(systemName: function.icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(isActive ? t.accent.opacity(0.5) : t.textMuted.opacity(0.3))
                .offset(y: large ? 4 : 3)
        }
    }

    // MARK: - Function picker popover

    private var functionPicker: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(KnobFunction.allCases) { fn in
                Button(action: {
                    viewModel.config.setKnobFunction(fn, at: index)
                    viewModel.markDirty()
                    showingPicker = false
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: fn.icon)
                            .font(.system(size: 12))
                            .frame(width: 18)
                            .foregroundStyle(fn == function ? t.accent : .secondary)

                        Text(fn.displayName)
                            .font(.system(size: 13))
                            .foregroundStyle(fn == function ? t.accent : .primary)

                        Spacer()

                        if fn == function {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(t.accent)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(fn == function ? t.accent.opacity(0.1) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .frame(width: 210)
    }

    // MARK: - Parameter slider

    private func parameterSlider(label: String) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(t.textDim)
                Spacer()
                Text(formattedParamValue)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(t.accent)
            }

            GeometryReader { geo in
                let range = function.paramRange
                let value = viewModel.config.paramValue(for: function)
                let pct = (value - range.lowerBound) / (range.upperBound - range.lowerBound)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(t.sliderTrack)
                        .frame(height: 5)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [t.sliderFill.opacity(0.3), t.sliderFill.opacity(0.7)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: max(5, geo.size.width * pct), height: 5)

                    Circle()
                        .fill(t.accent)
                        .frame(width: 14, height: 14)
                        .shadow(color: t.accent.opacity(0.4), radius: 5)
                        .offset(x: (geo.size.width - 14) * pct)
                }
                .frame(height: 18)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            let pct = max(0, min(1, drag.location.x / geo.size.width))
                            let raw = range.lowerBound + pct * (range.upperBound - range.lowerBound)
                            let snapped = function.usesIntParam ? raw.rounded() : (raw * 10).rounded() / 10
                            viewModel.config.setParamValue(snapped, for: function)
                            viewModel.markDirty()
                        }
                )
            }
            .frame(height: 18)
        }
    }

    private var formattedParamValue: String {
        let value = viewModel.config.paramValue(for: function)
        return function.usesIntParam ? "\(Int(value))" : String(format: "%.1f", value)
    }
}

// MARK: - Button mapping card

struct ButtonMappingCard: View {
    let button: ShiftButton
    @ObservedObject var viewModel: ConfigViewModel
    let t: ThemeColors
    @State private var showingPicker = false
    @State private var keystrokeKey = ""
    @State private var keystrokeMods: Set<String> = []

    private var currentFunction: ButtonFunction {
        button.isStock ? .notUsed : viewModel.config.buttonFunction(for: button.configKey)
    }

    private var isActive: Bool { button.isStock || currentFunction != .notUsed }

    private var iconColor: Color {
        if button.isStock { return t.textMuted.opacity(0.5) }
        if button.configKey == "shift_play" { return .green }
        if button.configKey == "shift_record" { return .red }
        return isActive ? t.accent : t.textMuted
    }

    var body: some View {
        VStack(spacing: 6) {
            // Button icon + short name
            Image(systemName: button.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(iconColor)

            Text(button.shortName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(button.isStock ? t.textMuted.opacity(0.5) : t.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Function display / selector
            if button.isStock {
                // Stock-mapped button — show as disabled
                Text(button.stockFunction ?? "Stock")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(t.textMuted.opacity(0.4))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(t.pillBg.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Button(action: { showingPicker.toggle() }) {
                    Text(currentFunction.displayName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isActive ? t.text : t.textDim)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                        .background(t.pillBg)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingPicker, arrowEdge: .bottom) {
                    buttonFunctionPicker
                }
            }

            // Keystroke editor (shown only for custom_keystroke)
            if !button.isStock && currentFunction == .customKeystroke {
                keystrokeEditor
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .top)
        .opacity(button.isStock ? 0.5 : 1.0)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(t.cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(button.isStock ? t.cardBorder.opacity(0.5) : (isActive ? t.cardBorderActive : t.cardBorder), lineWidth: 1)
        )
        .onAppear {
            guard !button.isStock else { return }
            let ks = viewModel.config.buttonKeystroke(for: button.configKey)
            keystrokeKey = ks.key
            keystrokeMods = Set(ks.modifiers)
        }
    }

    private var keystrokeEditor: some View {
        VStack(spacing: 4) {
            Text("Keystroke")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(t.textDim)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                ForEach(["cmd", "shift", "alt", "ctrl"], id: \.self) { mod in
                    Button(action: {
                        if keystrokeMods.contains(mod) {
                            keystrokeMods.remove(mod)
                        } else {
                            keystrokeMods.insert(mod)
                        }
                        saveKeystroke()
                    }) {
                        Text(modLabel(mod))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(keystrokeMods.contains(mod) ? t.accent : t.textMuted)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(keystrokeMods.contains(mod) ? t.pillActive : t.pillBg)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                KeystrokeField(key: $keystrokeKey, t: t, onCommit: saveKeystroke)
                    .frame(width: 40, height: 24)
            }
        }
    }

    private func modLabel(_ mod: String) -> String {
        switch mod {
        case "cmd": return "\u{2318}"
        case "shift": return "\u{21E7}"
        case "alt": return "\u{2325}"
        case "ctrl": return "\u{2303}"
        default: return mod
        }
    }

    private func saveKeystroke() {
        viewModel.config.setButtonFunction(
            .customKeystroke, for: button.configKey,
            keystrokeKey: keystrokeKey.isEmpty ? nil : keystrokeKey,
            keystrokeModifiers: keystrokeMods.isEmpty ? nil : Array(keystrokeMods)
        )
        viewModel.markDirty()
    }

    private var buttonFunctionPicker: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(ButtonFunction.allCases) { fn in
                    Button(action: {
                        if fn == .customKeystroke {
                            viewModel.config.setButtonFunction(fn, for: button.configKey,
                                                                keystrokeKey: keystrokeKey.isEmpty ? nil : keystrokeKey,
                                                                keystrokeModifiers: keystrokeMods.isEmpty ? nil : Array(keystrokeMods))
                        } else {
                            viewModel.config.setButtonFunction(fn, for: button.configKey)
                        }
                        viewModel.markDirty()
                        showingPicker = false
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: fn.icon)
                                .font(.system(size: 12))
                                .frame(width: 18)
                                .foregroundStyle(fn == currentFunction ? t.accent : .secondary)

                            Text(fn.displayName)
                                .font(.system(size: 13))
                                .foregroundStyle(fn == currentFunction ? t.accent : .primary)

                            Spacer()

                            if fn == currentFunction {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(t.accent)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(fn == currentFunction ? t.accent.opacity(0.1) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
        }
        .frame(width: 220, height: 350)
    }
}

// MARK: - Keystroke capture field

struct KeystrokeField: NSViewRepresentable {
    @Binding var key: String
    let t: ThemeColors
    var onCommit: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.isEditable = true
        field.isBordered = true
        field.bezelStyle = .roundedBezel
        field.alignment = .center
        field.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .bold)
        field.stringValue = key.uppercased()
        field.delegate = context.coordinator
        field.focusRingType = .none
        return field
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = key.uppercased()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: KeystrokeField
        init(_ parent: KeystrokeField) { self.parent = parent }

        func controlTextDidEndEditing(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            let text = field.stringValue.lowercased().trimmingCharacters(in: .whitespaces)
            if text.count <= 3 || ["f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12",
                                    "up","down","left","right","space","tab","enter","esc","delete",
                                    "home","end","pageup","pagedown"].contains(text) {
                parent.key = text
                parent.onCommit()
            }
        }
    }
}

// MARK: - NSVisualEffectView wrapper

struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// MARK: - Preset enum

enum PresetChoice: String, CaseIterable {
    case stock, fast, turbo, custom
}

// MARK: - View model

class ConfigViewModel: ObservableObject {
    @Published var config = TweakerConfig.fast
    @Published var statusText = ""
    @Published var statusColor: Color = .gray
    @Published var selectedPreset: PresetChoice = .fast
    private var suppressPresetChange = false

    func load() {
        config = ConfigFile.load()
        suppressPresetChange = true
        selectedPreset = detectPreset()
        suppressPresetChange = false
        setStatus("Loaded", color: .gray)
    }

    func save() {
        do {
            try ConfigFile.save(config)
            setStatus("Saved — applies on next encoder turn", color: .green)
        } catch {
            setStatus("Save failed: \(error.localizedDescription)", color: .red)
        }
    }

    func applyPresetChoice(_ choice: PresetChoice) {
        guard !suppressPresetChange else { return }
        guard choice != .custom else { return }

        suppressPresetChange = true
        selectedPreset = choice
        suppressPresetChange = false

        switch choice {
        case .stock: config = .stock
        case .fast: config = .fast
        case .turbo: config = .turbo
        case .custom: break
        }
        setStatus("\(choice.rawValue.capitalized) preset — save to apply", color: .orange)
    }

    func markDirty() {
        suppressPresetChange = true
        selectedPreset = .custom
        suppressPresetChange = false
        save()
    }

    private func detectPreset() -> PresetChoice {
        let tempoMult = config.paramValue(for: .tempo)
        if tempoMult <= 25 { return .stock }
        if tempoMult <= 75 { return .fast }
        if tempoMult <= 150 { return .turbo }
        return .custom
    }

    private func setStatus(_ text: String, color: Color) {
        statusText = text
        statusColor = color
    }
}
