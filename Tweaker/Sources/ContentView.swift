import SwiftUI

// MARK: - Selection model

enum ControlSelection: Hashable {
    case encoder(Int)
    case button(String)
}

enum PanelSide: String {
    case left, right
}

private func modSymbol(_ mod: String) -> String {
    switch mod {
    case "cmd": return "\u{2318}"
    case "shift": return "\u{21E7}"
    case "alt": return "\u{2325}"
    case "ctrl": return "\u{2303}"
    default: return mod
    }
}

// MARK: - Available keystroke keys

private let keystrokeAvailableKeys: [(String, String)] = {
    var keys: [(String, String)] = [
        ("", "None"),
        ("right", "Right \u{2192}"),
        ("left", "Left \u{2190}"),
        ("up", "Up \u{2191}"),
        ("down", "Down \u{2193}"),
        ("tab", "Tab"),
        ("space", "Space"),
        ("enter", "Enter"),
        ("return", "Return"),
        ("delete", "Delete"),
        ("escape", "Esc"),
        ("pageup", "Page Up"),
        ("pagedown", "Page Down"),
        ("home", "Home"),
        ("end", "End"),
    ]
    for c in "abcdefghijklmnopqrstuvwxyz" {
        keys.append((String(c), String(c).uppercased()))
    }
    for c in "0123456789" {
        keys.append((String(c), String(c)))
    }
    for i in 1...12 {
        keys.append(("f\(i)", "F\(i)"))
    }
    return keys
}()

// MARK: - Main view

struct ContentView: View {
    @StateObject private var viewModel = ConfigViewModel()
    @StateObject private var theme = ThemeProvider()
    @AppStorage("largeCards") private var largeCards = true
    @AppStorage("panelSideRight") private var panelSideRight = true
    private var panelSide: PanelSide { panelSideRight ? .right : .left }
    @State private var selection: ControlSelection? = nil

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

                panelContent

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

            // Open config file
            Button(action: { NSWorkspace.shared.open(ConfigFile.flStudioPath) }) {
                Image(systemName: "doc.text")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(t.textDim)
                    .frame(width: 36, height: 32)
                    .background(t.pillBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help("Open saved config (tweaker_config.json)")

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
                .help("3\u{2013}4x faster, all knobs mapped")
                PresetPill(label: "Turbo", isActive: viewModel.selectedPreset == .turbo, t: t) {
                    viewModel.applyPresetChoice(.turbo)
                }
                .help("6\u{2013}8x faster, all knobs mapped")
            }
            .padding(2)
            .background(t.pillBg)
            .clipShape(Capsule())

            // Panel side toggle
            HStack(spacing: 1) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) { panelSideRight = false }
                }) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(panelSide == .left ? t.accent : t.textDim)
                        .frame(width: 36, height: 32)
                        .background(panelSide == .left ? t.pillActive : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .help("Inspector panel (left)")

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) { panelSideRight = true }
                }) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(panelSide == .right ? t.accent : t.textDim)
                        .frame(width: 36, height: 32)
                        .background(panelSide == .right ? t.pillActive : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .help("Inspector panel (right)")
            }
            .padding(2)
            .background(t.pillBg)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Panel content

    private var panelContent: some View {
        HStack(spacing: 0) {
            if panelSide == .left {
                detailPanelContainer
                Rectangle().fill(t.cardBorder).frame(width: 1)
            }

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    HStack(alignment: .bottom, spacing: 32) {
                        VStack(alignment: .leading, spacing: 10) {
                            deviceLayout
                        }
                        if viewModel.config.enable_shift_buttons == true {
                            buttonGroupSection(ShiftButtonGroup.transport)
                        }
                    }
                }
                .padding(20)
            }

            if panelSide == .right {
                Rectangle().fill(t.cardBorder).frame(width: 1)
                detailPanelContainer
            }
        }
    }

    // MARK: - Section header

    private func sectionHeader(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(t.accent)
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(t.text)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(t.textMuted)
        }
    }

    // MARK: - Device layout (encoders + pads aligned, nav buttons inline)

    private func navButton(_ btn: ShiftButton, height: CGFloat = 96) -> some View {
        NavButtonView(btn: btn, height: height, isSelected: selection == .button(btn.configKey), t: t) {
            if !btn.isStock {
                withAnimation(.easeInOut(duration: 0.15)) { selection = .button(btn.configKey) }
            }
        }
    }

    private var deviceLayout: some View {
        let colSize: CGFloat = 120
        let columns = Array(repeating: GridItem(.fixed(colSize), spacing: 8), count: 8)
        let nav = ShiftButtonGroup.navigation.buttons
        // nav[0] = pads up, nav[1] = enc up, nav[2] = pads down, nav[3] = enc down
        return HStack(alignment: .top, spacing: 12) {
            // Pads up/down on left — aligned to bottom (pad rows)
            if nav.count >= 3 {
                let padGridHeight = colSize * 2 + 8  // 2 rows + spacing
                let padBtnHeight = (padGridHeight - 6) / 2
                VStack {
                    Spacer()
                    navButton(nav[0], height: padBtnHeight)
                    navButton(nav[2], height: padBtnHeight)
                }
            }
            // Encoders + pads column
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(icon: "dial.medium", title: "Transport Encoders", subtitle: "Knobs 1\u{2013}8 in transport mode")
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<8) { i in
                        knobCardView(index: i)
                    }
                }
                Spacer().frame(height: 50)
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<16, id: \.self) { i in
                        padCell(index: i)
                    }
                }
            }
            // Enc up/down on right — aligned to top (encoder rows)
            if nav.count >= 4 {
                VStack {
                    navButton(nav[1])
                    navButton(nav[3])
                    Spacer()
                }
            }
        }
    }

    private func padCell(index: Int) -> some View {
        let row = index / 8
        let col = index % 8
        let baseOpacity = 0.03 + Double(7 - col) * 0.01 + Double(row) * 0.015
        return RoundedRectangle(cornerRadius: 6)
            .fill(t.text.opacity(baseOpacity))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(t.cardBorder, lineWidth: 0.5)
            )
    }

    private var compactCardWidth: CGFloat { largeCards ? 180 : 140 }

    @ViewBuilder
    private func knobCardView(index: Int) -> some View {
        KnobCard(index: index, viewModel: viewModel, t: t, large: largeCards,
                 compact: true, isSelected: selection == .encoder(index)) {
            withAnimation(.easeInOut(duration: 0.15)) { selection = .encoder(index) }
        }
    }

    private func buttonGroupSection(_ group: ShiftButtonGroup) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            let columns: Int = {
                switch group.name {
                case "Transport": return 2
                case "Fader Select": return 9
                default: return 2
                }
            }()

            if group.name == "Transport" && group.buttons.count > 4 {
                let block1 = Array(group.buttons.prefix(4))
                let block2 = Array(group.buttons.suffix(from: 4))
                VStack(spacing: 16) {
                    buttonGrid(buttons: block1, columns: columns)
                    Rectangle().fill(t.cardBorder.opacity(0.5)).frame(height: 1).padding(.horizontal, 4)
                    buttonGrid(buttons: block2, columns: columns)
                }
            } else {
                buttonGrid(buttons: group.buttons, columns: columns)
            }
        }
    }

    private func buttonGrid(buttons: [ShiftButton], columns: Int) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: columns), spacing: 18) {
            ForEach(buttons) { btn in
                ButtonMappingCard(button: btn, viewModel: viewModel, t: t,
                                  compact: true, isSelected: selection == .button(btn.configKey)) {
                    if !btn.isStock {
                        withAnimation(.easeInOut(duration: 0.15)) { selection = .button(btn.configKey) }
                    }
                }
            }
        }
    }

    // MARK: - Detail panel container

    private var detailPanelContainer: some View {
        VStack {
            if let sel = selection {
                DetailPanel(selection: sel, viewModel: viewModel, t: t)
                    .id(sel)
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "cursorarrow.click.2")
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(t.textMuted.opacity(0.4))
                    Text("Select a control")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(t.textMuted.opacity(0.6))
                    Text("to edit its settings")
                        .font(.system(size: 12))
                        .foregroundStyle(t.textMuted.opacity(0.4))
                    Spacer()
                }
            }
        }
        .frame(width: 300)
        .background(t.cardBg.opacity(0.5))
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(viewModel.statusColor)
                .frame(width: 7, height: 7)
                .opacity(viewModel.statusVisible ? 1 : 0)

            Text(viewModel.statusText)
                .font(.system(size: 12))
                .foregroundStyle(t.textDim)
                .opacity(viewModel.statusVisible ? 1 : 0)

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

// MARK: - Detail panel

struct DetailPanel: View {
    let selection: ControlSelection
    @ObservedObject var viewModel: ConfigViewModel
    let t: ThemeColors

    @State private var cwKey = ""
    @State private var ccwKey = ""
    @State private var cwMods: Set<String> = []
    @State private var ccwMods: Set<String> = []
    @State private var keystrokeSensitivity: Double = 3
    @State private var buttonKey = ""
    @State private var buttonMods: Set<String> = []
    @State private var showingButtonPicker = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                switch selection {
                case .encoder(let index):
                    encoderDetail(index: index)
                case .button(let key):
                    buttonDetail(key: key)
                }
            }
            .padding(20)
        }
        .onAppear { loadState() }
    }

    // MARK: - Encoder detail

    @ViewBuilder
    private func encoderDetail(index: Int) -> some View {
        let function = viewModel.config.knobFunction(at: index)

        // Title
        HStack(spacing: 10) {
            Image(systemName: function.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(t.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Encoder \(index + 1)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(t.text)
                Text(function.displayName)
                    .font(.system(size: 12))
                    .foregroundStyle(t.textMuted)
            }
        }

        Divider()

        // Function picker
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Function")

            Picker("", selection: Binding(
                get: { viewModel.config.knobFunction(at: index) },
                set: {
                    viewModel.config.setKnobFunction($0, at: index)
                    viewModel.markDirty()
                }
            )) {
                ForEach(KnobFunction.allCases) { fn in
                    Label(fn.displayName, systemImage: fn.icon).tag(fn)
                }
            }
            .labelsHidden()
        }

        // Parameter slider
        if function != .encoderKeystroke, let label = function.paramLabel {
            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("Settings")
                encoderParamSlider(index: index, function: function, label: label)
            }
        }

        // Keystroke config
        if function == .encoderKeystroke {
            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("Sensitivity")
                sensitivitySlider(index: index)
            }

            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("Clockwise (CW)")
                keystrokePicker(key: $cwKey, mods: $cwMods) { saveEncoderKeystroke(index: index) }
            }

            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("Counter-clockwise (CCW)")
                keystrokePicker(key: $ccwKey, mods: $ccwMods) { saveEncoderKeystroke(index: index) }
            }
        }
    }

    // MARK: - Button detail

    @ViewBuilder
    private func buttonDetail(key: String) -> some View {
        let btn = findButton(key: key)
        let currentFunction = viewModel.config.buttonFunction(for: key)

        // Title
        HStack(spacing: 10) {
            Image(systemName: btn?.icon ?? "circle")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(t.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(btn?.displayName ?? key)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(t.text)
                Text(currentFunction.displayName)
                    .font(.system(size: 12))
                    .foregroundStyle(t.textMuted)
            }
        }

        Divider()

        // Function picker
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Function")

            Button(action: { showingButtonPicker.toggle() }) {
                HStack {
                    Image(systemName: currentFunction.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(t.accent)
                    Text(currentFunction.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(t.text)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(t.textMuted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(t.pillBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingButtonPicker, arrowEdge: .trailing) {
                buttonFunctionPicker(key: key, currentFunction: currentFunction)
            }
        }

        // Keystroke editor
        if currentFunction == .customKeystroke {
            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("Keystroke")
                keystrokePicker(key: $buttonKey, mods: $buttonMods) { saveButtonKeystroke(key: key) }
            }
        }
    }

    // MARK: - Shared components

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(t.textDim)
            .textCase(.uppercase)
    }

    private func keystrokePicker(key: Binding<String>, mods: Binding<Set<String>>, onSave: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Picker("Key", selection: key) {
                ForEach(keystrokeAvailableKeys, id: \.0) { value, display in
                    Text(display).tag(value)
                }
            }
            .onChange(of: key.wrappedValue) { _ in onSave() }

            HStack(spacing: 6) {
                ForEach(["cmd", "shift", "alt", "ctrl"], id: \.self) { mod in
                    Button(action: {
                        if mods.wrappedValue.contains(mod) { mods.wrappedValue.remove(mod) }
                        else { mods.wrappedValue.insert(mod) }
                        onSave()
                    }) {
                        Text(modSymbol(mod))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(mods.wrappedValue.contains(mod) ? t.accent : t.textMuted)
                            .frame(width: 36, height: 28)
                            .background(mods.wrappedValue.contains(mod) ? t.pillActive : t.pillBg)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
    }

    private func encoderParamSlider(index: Int, function: KnobFunction, label: String) -> some View {
        let range = function.paramRange
        let value = viewModel.config.paramValue(for: function)
        let formatted = function.usesIntParam ? "\(Int(value))" : String(format: "%.1f", value)

        return VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(t.textDim)
                Spacer()
                Text(formatted)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(t.accent)
            }
            customSlider(value: value, range: range) { newVal in
                let snapped = function.usesIntParam ? newVal.rounded() : (newVal * 10).rounded() / 10
                viewModel.config.setParamValue(snapped, for: function)
                viewModel.markDirty()
            }
        }
    }

    private func sensitivitySlider(index: Int) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text("Clicks per keystroke")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(t.textDim)
                Spacer()
                Text("\(Int(keystrokeSensitivity))")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(t.accent)
            }
            customSlider(value: keystrokeSensitivity, range: 1...10) { newVal in
                keystrokeSensitivity = newVal.rounded()
                saveEncoderKeystroke(index: index)
            }
        }
    }

    private func customSlider(value: Double, range: ClosedRange<Double>, onChange: @escaping (Double) -> Void) -> some View {
        let pct = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(t.sliderTrack).frame(height: 5)
                Capsule()
                    .fill(LinearGradient(
                        colors: [t.sliderFill.opacity(0.3), t.sliderFill.opacity(0.7)],
                        startPoint: .leading, endPoint: .trailing
                    ))
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
                        let p = max(0, min(1, drag.location.x / geo.size.width))
                        let raw = range.lowerBound + p * (range.upperBound - range.lowerBound)
                        onChange(raw)
                    }
            )
        }
        .frame(height: 18)
    }

    private func buttonFunctionPicker(key: String, currentFunction: ButtonFunction) -> some View {
        let available: [ButtonFunction] = {
            if viewModel.config.enable_custom_keystrokes == true { return ButtonFunction.allCases }
            return ButtonFunction.allCases.filter { $0 != .customKeystroke }
        }()

        return ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                pickerRow(.notUsed, key: key, current: currentFunction)

                ForEach(ButtonFunctionCategory.allCases, id: \.rawValue) { category in
                    let fns = available.filter { $0 != .notUsed && $0.category == category }
                    if !fns.isEmpty {
                        Text(category.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(t.textMuted)
                            .padding(.horizontal, 12)
                            .padding(.top, 6)
                            .padding(.bottom, 2)

                        ForEach(fns) { fn in
                            pickerRow(fn, key: key, current: currentFunction)
                        }
                    }
                }
            }
            .padding(8)
        }
        .frame(width: 220, height: 400)
    }

    private func pickerRow(_ fn: ButtonFunction, key: String, current: ButtonFunction) -> some View {
        Button(action: {
            if fn == .customKeystroke {
                viewModel.config.setButtonFunction(fn, for: key,
                                                    keystrokeKey: buttonKey.isEmpty ? nil : buttonKey,
                                                    keystrokeModifiers: buttonMods.isEmpty ? nil : Array(buttonMods))
            } else {
                viewModel.config.setButtonFunction(fn, for: key)
            }
            viewModel.markDirty()
            showingButtonPicker = false
        }) {
            HStack(spacing: 10) {
                Image(systemName: fn.icon)
                    .font(.system(size: 12))
                    .frame(width: 18)
                    .foregroundStyle(fn == current ? t.accent : .secondary)
                Text(fn.displayName)
                    .font(.system(size: 13))
                    .foregroundStyle(fn == current ? t.accent : .primary)
                Spacer()
                if fn == current {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(t.accent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(fn == current ? t.accent.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    // MARK: - State management

    private func loadState() {
        switch selection {
        case .encoder(let index):
            let ks = viewModel.config.encoderKeystroke(at: index)
            cwKey = ks.cw_key
            ccwKey = ks.ccw_key
            cwMods = Set(ks.cw_modifiers ?? [])
            ccwMods = Set(ks.ccw_modifiers ?? [])
            keystrokeSensitivity = Double(ks.sensitivity ?? 3)
        case .button(let key):
            let ks = viewModel.config.buttonKeystroke(for: key)
            buttonKey = ks.key
            buttonMods = Set(ks.modifiers)
        }
    }

    private func saveEncoderKeystroke(index: Int) {
        let mapping = TweakerConfig.EncoderKeystrokeMapping(
            cw_key: cwKey,
            cw_modifiers: cwMods.isEmpty ? nil : Array(cwMods),
            ccw_key: ccwKey,
            ccw_modifiers: ccwMods.isEmpty ? nil : Array(ccwMods),
            sensitivity: Int(keystrokeSensitivity)
        )
        viewModel.config.setEncoderKeystroke(mapping, at: index)
        viewModel.markDirty()
    }

    private func saveButtonKeystroke(key: String) {
        viewModel.config.setButtonFunction(
            .customKeystroke, for: key,
            keystrokeKey: buttonKey.isEmpty ? nil : buttonKey,
            keystrokeModifiers: buttonMods.isEmpty ? nil : Array(buttonMods)
        )
        viewModel.markDirty()
    }

    private func findButton(key: String) -> ShiftButton? {
        for group in ShiftButtonGroup.allGroups {
            if let btn = group.buttons.first(where: { $0.configKey == key }) { return btn }
        }
        return nil
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

// MARK: - Nav button

struct NavButtonView: View {
    let btn: ShiftButton
    let height: CGFloat
    let isSelected: Bool
    let t: ThemeColors
    var onSelect: (() -> Void)? = nil
    @State private var isHovered = false

    var body: some View {
        Button(action: { onSelect?() }) {
            Image(systemName: btn.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isSelected ? t.accent : (isHovered ? t.accent.opacity(0.8) : t.textDim))
                .frame(width: 48, height: height)
                .background(isSelected ? t.pillActive : (isHovered ? t.cardBg.opacity(0.8) : t.cardBg))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ? t.accent : (isHovered ? t.accent.opacity(0.6) : t.cardBorderActive),
                            lineWidth: isSelected ? 2 : (isHovered ? 1.5 : 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .shadow(color: isSelected ? t.accent.opacity(0.2) : (isHovered ? t.accent.opacity(0.15) : .clear), radius: isSelected ? 8 : 6, y: 2)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) { isHovered = hovering }
        }
    }
}

// MARK: - Knob card

struct KnobCard: View {
    let index: Int
    @ObservedObject var viewModel: ConfigViewModel
    let t: ThemeColors
    var large: Bool = true
    var compact: Bool = false
    var isSelected: Bool = false
    var onSelect: (() -> Void)? = nil
    @State private var showingPicker = false
    @State private var isHovered = false
    // Classic mode keystroke state
    @State private var cwKey = ""
    @State private var ccwKey = ""
    @State private var cwMods: Set<String> = []
    @State private var ccwMods: Set<String> = []
    @State private var keystrokeSensitivity: Double = 3

    private var function: KnobFunction {
        viewModel.config.knobFunction(at: index)
    }

    private var isActive: Bool {
        function != .notUsed
    }

    var body: some View {
        VStack(spacing: compact ? 8 : 10) {
            encoderKnob
                .padding(.top, compact ? 6 : 8)

            Text("\(index + 1)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(t.textMuted)
                .tracking(1)

            if compact {
                Text(function.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isActive ? t.text : t.textDim)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.bottom, 6)
            } else {
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

                // Parameter control or keystroke editor
                if function == .encoderKeystroke {
                    encoderKeystrokeEditor
                    encoderSensitivitySlider
                        .padding(.bottom, 4)
                } else if let label = function.paramLabel {
                    parameterSlider(label: label)
                        .padding(.bottom, 4)
                } else {
                    Color.clear.frame(height: 42)
                        .padding(.bottom, 4)
                }
            }
        }
        .padding(.horizontal, compact ? 12 : 14)
        .padding(.vertical, compact ? 6 : 6)
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
                .stroke(
                    isSelected ? t.accent :
                    (isHovered ? t.accent.opacity(0.6) : (isActive ? t.cardBorderActive : t.cardBorder)),
                    lineWidth: isSelected ? 2 : (isHovered ? 1.5 : 1)
                )
        )
        .frame(maxWidth: compact ? .infinity : nil)
        .aspectRatio(compact ? 1 : nil, contentMode: .fill)
        .scaleEffect(isHovered && !compact ? 1.03 : 1.0)
        .shadow(color: isSelected ? t.accent.opacity(0.2) : (isHovered ? t.accent.opacity(0.15) : .clear), radius: isSelected ? 10 : 8, y: 2)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) { isHovered = hovering }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if compact { onSelect?() }
        }
    }

    // MARK: - Encoder knob visual

    private var ringSize: CGFloat { compact ? 64 : (large ? 80 : 64) }
    private var knobSize: CGFloat { compact ? 50 : (large ? 62 : 50) }
    private var iconSize: CGFloat { compact ? 15 : (large ? 18 : 15) }
    private var notchHeight: CGFloat { compact ? 12 : (large ? 14 : 12) }
    private var notchOffset: CGFloat { compact ? -15 : (large ? -19 : -15) }

    private var encoderKnob: some View {
        ZStack {
            Circle()
                .stroke(isActive ? t.knobRingActive : t.knobRing, lineWidth: compact ? 2 : (large ? 3 : 2.5))
                .frame(width: ringSize, height: ringSize)

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

            Capsule()
                .fill(isActive ? t.accent : t.textMuted)
                .frame(width: 3, height: notchHeight)
                .offset(y: notchOffset)
                .rotationEffect(.degrees(isHovered ? 0 : -45))

            Image(systemName: function.icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(isActive ? t.accent.opacity(0.5) : t.textMuted.opacity(0.3))
                .offset(y: compact ? 2 : (large ? 4 : 3))
        }
        .animation(.easeInOut(duration: 0.3), value: isHovered)
    }

    // MARK: - Encoder keystroke editor (classic mode only)

    private var encoderKeystrokeEditor: some View {
        VStack(spacing: 6) {
            keystrokeField(label: "CW", key: $cwKey, mods: $cwMods, direction: "cw")
            keystrokeField(label: "CCW", key: $ccwKey, mods: $ccwMods, direction: "ccw")
        }
        .onAppear { loadEncoderKeystroke() }
    }

    private func keystrokeField(label: String, key: Binding<String>, mods: Binding<Set<String>>, direction: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(t.textMuted)
                .frame(width: 28, alignment: .leading)

            Picker("", selection: key) {
                ForEach(keystrokeAvailableKeys, id: \.0) { value, display in
                    Text(display).tag(value)
                }
            }
            .frame(width: 80)
            .onChange(of: key.wrappedValue) { _ in saveEncoderKeystroke() }

            ForEach(["cmd", "shift", "alt", "ctrl"], id: \.self) { mod in
                Toggle(mod, isOn: Binding(
                    get: { mods.wrappedValue.contains(mod) },
                    set: { on in
                        if on { mods.wrappedValue.insert(mod) }
                        else { mods.wrappedValue.remove(mod) }
                        saveEncoderKeystroke()
                    }
                ))
                .toggleStyle(.button)
                .font(.system(size: 8, weight: .medium))
                .controlSize(.mini)
            }
        }
    }

    private func loadEncoderKeystroke() {
        let ks = viewModel.config.encoderKeystroke(at: index)
        cwKey = ks.cw_key
        ccwKey = ks.ccw_key
        cwMods = Set(ks.cw_modifiers ?? [])
        ccwMods = Set(ks.ccw_modifiers ?? [])
        keystrokeSensitivity = Double(ks.sensitivity ?? 3)
    }

    private func saveEncoderKeystroke() {
        let mapping = TweakerConfig.EncoderKeystrokeMapping(
            cw_key: cwKey,
            cw_modifiers: cwMods.isEmpty ? nil : Array(cwMods),
            ccw_key: ccwKey,
            ccw_modifiers: ccwMods.isEmpty ? nil : Array(ccwMods),
            sensitivity: Int(keystrokeSensitivity)
        )
        viewModel.config.setEncoderKeystroke(mapping, at: index)
        viewModel.markDirty()
    }

    private var encoderSensitivitySlider: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Sensitivity (clicks per keystroke)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(t.textDim)
                Spacer()
                Text("\(Int(keystrokeSensitivity))")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(t.accent)
            }

            GeometryReader { geo in
                let range: ClosedRange<Double> = 1...10
                let pct = (keystrokeSensitivity - range.lowerBound) / (range.upperBound - range.lowerBound)

                ZStack(alignment: .leading) {
                    Capsule().fill(t.sliderTrack).frame(height: 5)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [t.sliderFill.opacity(0.3), t.sliderFill.opacity(0.7)],
                            startPoint: .leading, endPoint: .trailing
                        ))
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
                            let raw = 1.0 + pct * 9.0
                            keystrokeSensitivity = raw.rounded()
                            saveEncoderKeystroke()
                        }
                )
            }
            .frame(height: 18)
        }
    }

    // MARK: - Function picker popover (classic mode only)

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

    // MARK: - Parameter slider (classic mode only)

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
                    Capsule().fill(t.sliderTrack).frame(height: 5)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [t.sliderFill.opacity(0.3), t.sliderFill.opacity(0.7)],
                            startPoint: .leading, endPoint: .trailing
                        ))
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
    var compact: Bool = false
    var isSelected: Bool = false
    var onSelect: (() -> Void)? = nil
    @State private var showingPicker = false
    @State private var keystrokeKey = ""
    @State private var keystrokeMods: Set<String> = []
    @State private var isHovered = false

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
        VStack(spacing: 8) {
            if !button.icon.isEmpty {
                Image(systemName: button.icon)
                    .font(.system(size: compact ? 16 : 20, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            if !button.iconOnly {
                Text(button.shortName)
                    .font(.system(size: compact ? 11 : 13, weight: .semibold))
                    .foregroundStyle(button.isStock ? t.textMuted.opacity(0.5) : t.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            if button.isStock {
                Text(button.stockFunction ?? "Stock")
                    .font(.system(size: compact ? 10 : 12, weight: .medium))
                    .foregroundStyle(t.textMuted.opacity(0.4))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(t.pillBg.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else if compact {
                Text(currentFunction.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isActive ? t.text : t.textDim)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            } else {
                Button(action: { showingPicker.toggle() }) {
                    Text(currentFunction.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isActive ? t.text : t.textDim)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background(t.pillBg)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingPicker, arrowEdge: .bottom) {
                    buttonFunctionPicker
                }

                // Keystroke editor (classic mode only)
                if currentFunction == .customKeystroke {
                    keystrokeEditor
                }
            }
        }
        .padding(compact ? 8 : 10)
        .frame(maxWidth: .infinity, minHeight: compact ? 60 : 85, alignment: .top)
        .opacity(button.isStock ? 0.5 : 1.0)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(t.cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(
                    button.isStock ? t.cardBorder.opacity(0.5) :
                    (isSelected ? t.accent :
                    (isHovered ? t.accent.opacity(0.6) : (isActive ? t.cardBorderActive : t.cardBorder))),
                    lineWidth: isSelected ? 2 : (isHovered && !button.isStock ? 1.5 : 1)
                )
        )
        .scaleEffect(isHovered && !button.isStock && !compact ? 1.05 : 1.0)
        .shadow(color: isSelected ? t.accent.opacity(0.2) : (isHovered && !button.isStock ? t.accent.opacity(0.15) : .clear), radius: isSelected ? 8 : 6, y: 2)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) { isHovered = hovering }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if compact { onSelect?() }
        }
        .onAppear {
            guard !button.isStock else { return }
            let ks = viewModel.config.buttonKeystroke(for: button.configKey)
            keystrokeKey = ks.key
            keystrokeMods = Set(ks.modifiers)
        }
    }

    // MARK: - Keystroke editor (classic mode)

    private var keystrokeEditor: some View {
        VStack(spacing: 4) {
            Text("Keystroke")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(t.textDim)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                ForEach(["cmd", "shift", "alt", "ctrl"], id: \.self) { mod in
                    Button(action: {
                        if keystrokeMods.contains(mod) { keystrokeMods.remove(mod) }
                        else { keystrokeMods.insert(mod) }
                        saveKeystroke()
                    }) {
                        Text(modSymbol(mod))
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

                Picker("", selection: $keystrokeKey) {
                    ForEach(keystrokeAvailableKeys, id: \.0) { value, display in
                        Text(display).tag(value)
                    }
                }
                .frame(width: 90)
                .onChange(of: keystrokeKey) { _ in saveKeystroke() }
            }
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

    private var availableFunctions: [ButtonFunction] {
        if viewModel.config.enable_custom_keystrokes == true {
            return ButtonFunction.allCases
        }
        return ButtonFunction.allCases.filter { $0 != .customKeystroke }
    }

    private var buttonFunctionPicker: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                functionRow(.notUsed)

                ForEach(ButtonFunctionCategory.allCases, id: \.rawValue) { category in
                    let fns = availableFunctions.filter { $0 != .notUsed && $0.category == category }
                    if !fns.isEmpty {
                        Text(category.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(t.textMuted)
                            .padding(.horizontal, 12)
                            .padding(.top, 6)
                            .padding(.bottom, 2)

                        ForEach(fns) { fn in
                            functionRow(fn)
                        }
                    }
                }
            }
            .padding(8)
        }
        .frame(width: 220, height: 400)
    }

    private func functionRow(_ fn: ButtonFunction) -> some View {
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
    static let statusFadeDuration: TimeInterval = 4

    @Published var config = TweakerConfig.fast
    @Published var statusText = ""
    @Published var statusColor: Color = .gray
    @Published var statusVisible = true
    @Published var selectedPreset: PresetChoice = .fast
    private var suppressPresetChange = false
    private var statusFadeTask: DispatchWorkItem?

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
            setStatus("Saved \u{2014} applies on next encoder turn", color: .green)
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
        setStatus("\(choice.rawValue.capitalized) preset \u{2014} save to apply", color: .orange)
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
        statusFadeTask?.cancel()
        statusText = text
        statusColor = color
        withAnimation(.easeIn(duration: 0.15)) { statusVisible = true }

        let task = DispatchWorkItem { [weak self] in
            withAnimation(.easeOut(duration: 0.5)) {
                self?.statusVisible = false
            }
        }
        statusFadeTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.statusFadeDuration, execute: task)
    }
}
