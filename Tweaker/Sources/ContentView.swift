import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ConfigViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()

            // Knobs grid
            ScrollView {
                knobGrid
                    .padding(20)
            }

            Divider()

            // Footer
            footer
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear { viewModel.load() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Tweaker")
                    .font(.system(size: 22, weight: .bold, design: .default))
                Text("Launchkey MK4 Transport Encoders")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Text("Preset")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Button("Stock") { viewModel.applyPreset(.stock, name: "Stock") }
                    .controlSize(.small)
                Button("Fast") { viewModel.applyPreset(.fast, name: "Fast") }
                    .controlSize(.small)
                Button("Turbo") { viewModel.applyPreset(.turbo, name: "Turbo") }
                    .controlSize(.small)
            }
        }
    }

    // MARK: - Knob grid

    private var knobGrid: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                ForEach(0..<4) { i in
                    KnobCard(index: i, viewModel: viewModel)
                }
            }
            GridRow {
                ForEach(4..<8) { i in
                    KnobCard(index: i, viewModel: viewModel)
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Image(systemName: viewModel.statusIcon)
                .foregroundStyle(viewModel.statusColor)
                .font(.system(size: 11))

            Text(viewModel.statusText)
                .font(.system(size: 12))
                .foregroundStyle(viewModel.statusColor)

            Spacer()

            Button("Save") { viewModel.save() }
                .keyboardShortcut("s", modifiers: .command)
                .controlSize(.regular)
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Knob card

struct KnobCard: View {
    let index: Int
    @ObservedObject var viewModel: ConfigViewModel

    private var function: KnobFunction {
        viewModel.config.knobFunction(at: index)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Knob number + icon
            HStack {
                ZStack {
                    Circle()
                        .fill(function == .notUsed
                              ? Color(nsColor: .separatorColor)
                              : Color.accentColor.opacity(0.15))
                        .frame(width: 28, height: 28)

                    Image(systemName: function.icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(function == .notUsed ? .secondary : .primary)
                }

                Text("Knob \(index + 1)")
                    .font(.system(size: 13, weight: .semibold))

                Spacer()
            }

            // Function picker
            Picker("", selection: Binding(
                get: { function },
                set: { newValue in
                    viewModel.config.setKnobFunction(newValue, at: index)
                    viewModel.markDirty()
                }
            )) {
                ForEach(KnobFunction.allCases) { fn in
                    Text(fn.displayName).tag(fn)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)

            // Parameter slider
            if let label = function.paramLabel {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(label)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(formattedParamValue)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }

                    Slider(
                        value: Binding(
                            get: { viewModel.config.paramValue(for: function) },
                            set: { newValue in
                                let snapped = function.usesIntParam ? newValue.rounded() : (newValue * 10).rounded() / 10
                                viewModel.config.setParamValue(snapped, for: function)
                                viewModel.markDirty()
                            }
                        ),
                        in: function.paramRange
                    )
                    .controlSize(.small)
                }
            } else {
                Spacer()
                    .frame(height: 30)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }

    private var formattedParamValue: String {
        let value = viewModel.config.paramValue(for: function)
        if function.usesIntParam {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
}

// MARK: - View model

class ConfigViewModel: ObservableObject {
    @Published var config = TweakerConfig.fast
    @Published var statusText = ""
    @Published var statusIcon = "circle"
    @Published var statusColor: Color = .secondary
    private var isDirty = false

    func load() {
        config = ConfigFile.load()
        setStatus("Loaded", icon: "checkmark.circle", color: .secondary)
    }

    func save() {
        do {
            try ConfigFile.save(config)
            isDirty = false
            setStatus("Saved — applies on next encoder turn", icon: "checkmark.circle.fill", color: .green)
        } catch {
            setStatus("Save failed: \(error.localizedDescription)", icon: "exclamationmark.triangle", color: .red)
        }
    }

    func applyPreset(_ preset: TweakerConfig, name: String) {
        config = preset
        markDirty()
        setStatus("Preset '\(name)' applied — save to apply", icon: "arrow.triangle.2.circlepath", color: .orange)
    }

    func markDirty() {
        isDirty = true
        setStatus("Unsaved changes", icon: "pencil.circle", color: .orange)
    }

    private func setStatus(_ text: String, icon: String, color: Color) {
        statusText = text
        statusIcon = icon
        statusColor = color
    }
}

