import SwiftUI

enum RhythmStyle {
    static let button = Color(red: 0.20, green: 0.43, blue: 0.37)
    static let accent = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 0.53, green: 0.78, blue: 0.69, alpha: 1)
            : NSColor(red: 0.20, green: 0.43, blue: 0.37, alpha: 1)
    })
    static let amber = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 0.88, green: 0.69, blue: 0.39, alpha: 1)
            : NSColor(red: 0.58, green: 0.33, blue: 0.10, alpha: 1)
    })
}

struct RhythmPopover: View {
    private enum Page { case home, settings, history }
    @ObservedObject var model: RhythmModel
    var quit: () -> Void
    @State private var page = Page.home
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .top) {
            if page == .home {
                RhythmView(model: model,
                           openHistory: { page = .history },
                           openSettings: { page = .settings })
                    .transition(reduceMotion ? .opacity : .move(edge: .leading).combined(with: .opacity))
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Button { page = .home } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Back to Rhythm")
                        .keyboardShortcut("[", modifiers: .command)
                        Spacer()
                        if page == .settings {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18))
                                .accessibilityLabel("Settings")
                                .help("Settings")
                        } else {
                            WaveIcon()
                                .accessibilityLabel("Today’s waves")
                                .help("Today’s waves")
                        }
                    }.padding(20)
                    Divider()
                    if page == .settings {
                        SettingsView(model: model, notifications: model.notifications, quit: quit)
                    } else {
                        WaveHistoryView(model: model)
                    }
                }
                .transition(reduceMotion ? .opacity : .move(edge: .trailing).combined(with: .opacity))
            }
        }
        .frame(width: 388)
        .fixedSize(horizontal: false, vertical: true)
        .background(.regularMaterial)
        .clipped()
        .tint(RhythmStyle.accent)
        .animation(.easeInOut(duration: reduceMotion ? 0.12 : 0.24), value: page)
    }
}

struct WaveIcon: View {
    var body: some View {
        Text("🌊")
            .font(.system(size: 22))
            .frame(width: 26, height: 26)
            .accessibilityLabel("Wave")
    }
}

struct RhythmView: View {
    @ObservedObject var model: RhythmModel
    var openHistory: () -> Void
    var openSettings: () -> Void
    @State private var preparingPause = false

    private var primaryAction: WaveAction {
        WaveAction.next(mode: model.engine.mode, preparingPause: preparingPause)
    }

    private func performPrimaryAction() {
        switch primaryAction {
        case .start, .continueWork: model.beginWave()
        case .preparePause: preparingPause = true
        case .beginPause: model.pause()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Label("Rhythm", systemImage: "waveform.path")
                    .font(.system(.headline, design: .rounded))
                Spacer()
                Button(action: openSettings) { Image(systemName: "gearshape") }
                    .buttonStyle(.plain).help("Settings").accessibilityLabel("Settings")
            }
            if model.engine.mode == .pause {
                HStack {
                    Label("Pause", systemImage: "pause.fill")
                    Text(RhythmFormat.clock(model.engine.elapsed)).monospacedDigit()
                    Spacer()
                    Button(primaryAction.rawValue, action: performPrimaryAction)
                        .buttonStyle(.borderedProminent).tint(RhythmStyle.button)
                }
                Text(model.subtitle).font(.caption).foregroundStyle(.secondary)
                NoteEditor(model: model)
            } else {
                WaveTimeline(elapsed: model.engine.mode == .working ? model.engine.elapsed : nil,
                             actionTitle: primaryAction.rawValue, action: performPrimaryAction)
                if model.engine.mode == .working {
                    if model.engine.stage != .quiet {
                        Text(model.title).font(.caption).foregroundStyle(.secondary)
                    }
                    if preparingPause {
                        NoteEditor(model: model)
                        Button("Keep working") { preparingPause = false }.buttonStyle(.plain)
                    }
                    if model.engine.canDefer {
                        Button("Finish in 5 min") { model.deferPause() }.buttonStyle(.bordered)
                    }
                }
            }
            if model.focusRequested && model.engine.mode == .working {
                Label(model.focus.status, systemImage: "moon")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Divider()
            Button(action: openHistory) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            WaveIcon().accessibilityHidden(true)
                            Text("Today’s waves").font(.headline)
                        }
                        Text(todaySummary).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                }.contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityLabel("Open Today’s waves")
            if let error = model.storageError {
                Label(error, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.orange)
            }
        }
        .onChange(of: model.engine.mode) { _ in preparingPause = false }
        .padding(24)
        .frame(width: 388)
        .background(.regularMaterial)
        .tint(RhythmStyle.accent)
    }

    private var todaySummary: String {
        let today = model.engine.entries.filter { Calendar.current.isDateInToday($0.endedAt) }
        let waves = today.filter { $0.kind == .wave }.count
        let pauses = today.filter { $0.kind == .pause }.count
        return "\(waves) \(waves == 1 ? "wave" : "waves") · \(pauses) \(pauses == 1 ? "pause" : "pauses") completed"
    }
}

struct WaveTimeline: View {
    var elapsed: TimeInterval?
    var actionTitle: String
    var action: () -> Void
    private let gradient = LinearGradient(stops: [
        .init(color: Color(red: 0.28, green: 0.70, blue: 0.48), location: 0),
        .init(color: Color(red: 0.38, green: 0.74, blue: 0.45), location: 0.35),
        .init(color: Color(red: 0.85, green: 0.78, blue: 0.35), location: 0.50),
        .init(color: Color(red: 0.94, green: 0.68, blue: 0.32), location: 0.68),
        .init(color: Color(red: 0.93, green: 0.49, blue: 0.32), location: 0.75),
        .init(color: Color(red: 0.86, green: 0.30, blue: 0.32), location: 0.90),
        .init(color: Color(red: 0.86, green: 0.30, blue: 0.32), location: 1)
    ], startPoint: .leading, endPoint: .trailing)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                GeometryReader { geometry in
                let inset: CGFloat = 16
                let width = max(0, geometry.size.width - inset * 2)
                Capsule()
                    .fill(gradient)
                    .frame(width: width, height: 14)
                    .offset(x: inset, y: 32)
                ForEach([0, 60, 90, 120], id: \.self) { minute in
                    let x = inset + width * Double(minute) / 120
                    Rectangle()
                        .fill(Color.primary.opacity(0.35))
                        .frame(width: 1, height: 5)
                        .position(x: x, y: 54)
                    Text("\(minute)m")
                        .font(.system(size: 10)).monospacedDigit()
                        .foregroundStyle(.secondary)
                        .position(x: x, y: 68)
                }
                if let elapsed {
                    let x = inset + width * min(max(elapsed / 7200, 0), 1)
                    WaveIcon()
                        .position(x: x, y: 38)
                    Text(RhythmFormat.clock(elapsed))
                        .font(.system(size: 11, weight: .medium)).monospacedDigit()
                        .position(x: min(max(x, 24), geometry.size.width - 24), y: 12)
                }
                }.frame(height: 78)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Green for the first hour, gradually yellow around 60 minutes, then red around 90 minutes.")
                    .accessibilityValue(elapsed.map { "Elapsed \(RhythmFormat.clock($0))" } ?? "Ready")
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent).tint(RhythmStyle.button)
                    .frame(width: 94)
                    .padding(.top, 28)
            }
            HStack {
                Text("Settle in")
                Spacer()
                Text("Consider a pause")
                Spacer()
                Text("Time to pause")
            }.font(.system(size: 10)).foregroundStyle(.secondary)
        }
    }
}

struct NoteEditor: View {
    @ObservedObject var model: RhythmModel
    @FocusState private var noteFocused: Bool
    @State private var showDictationHelp = false
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Where to pick up").font(.subheadline.weight(.medium))
            HStack(alignment: .top, spacing: 8) {
                TextField("What’s the next small step?", text: $model.draftNote, axis: .vertical)
                    .lineLimit(2...3).textFieldStyle(.plain)
                    .accessibilityLabel("Resume note")
                    .focused($noteFocused)
                Button {
                    noteFocused = true
                    showDictationHelp.toggle()
                } label: { Image(systemName: "mic").frame(width: 20, height: 20) }
                .buttonStyle(.plain)
                .accessibilityLabel("How to dictate a note")
                .help("Use macOS Dictation")
            }
            .padding(8)
            .background(Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(noteFocused ? RhythmStyle.accent : Color.primary.opacity(0.15), lineWidth: noteFocused ? 2 : 1))
            if showDictationHelp {
                Text("Press your keyboard’s microphone key or Dictation shortcut to speak. Enable Dictation in System Settings → Keyboard.")
                    .font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct InterventionView: View {
    @ObservedObject var model: RhythmModel
    var dismiss: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Label("Rhythm", systemImage: "pause.circle").font(.headline).foregroundStyle(RhythmStyle.accent)
                Spacer()
            }
            Text(model.title).font(.system(size: 30, weight: .medium, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
            Text("\(RhythmFormat.duration(model.engine.elapsed)) in this wave.\nLeave yourself a note, then step away for a few minutes.")
                .font(.body).foregroundStyle(.secondary).lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            NoteEditor(model: model)
            HStack {
                Button("Begin pause") { model.pause() }
                    .buttonStyle(.borderedProminent).tint(RhythmStyle.button).keyboardShortcut(.defaultAction)
                if model.engine.canDefer {
                    Button("Finish in 5 min") { model.deferPause() }.buttonStyle(.bordered)
                }
                Spacer()
                Button("Keep working", action: dismiss).buttonStyle(.plain).foregroundStyle(.secondary)
                    .keyboardShortcut(.cancelAction)
            }.controlSize(.large)
            Text("A pause is an invitation. You stay in control.")
                .font(.caption).foregroundStyle(.tertiary)
        }.padding(32).frame(width: 540).fixedSize(horizontal: false, vertical: true).tint(RhythmStyle.accent)
    }
}

struct SettingsView: View {
    @ObservedObject var model: RhythmModel
    @ObservedObject var notifications: NotificationService
    var quit: () -> Void

    var body: some View {
        Form {
            Section("A little structure") {
                LabeledContent("Pause suggestion", value: "60 minutes")
                LabeledContent("Pause reminder", value: "90 minutes")
                LabeledContent("Finish the wave", value: "One 5-minute defer")
                LabeledContent("Extended work reminder", value: "120 minutes")
                LabeledContent("Suggested pause", value: "5 min · 15 min every third wave")
            }
            Section("Chimes") {
                Toggle("Play gentle chimes", isOn: $model.chimesEnabled)
                Slider(value: $model.chimeVolume, in: 0...1) {
                    Text("Volume")
                }.disabled(!model.chimesEnabled)
                ForEach(ChimeService.Cue.allCases) { cue in
                    Button { model.playChime(cue) } label: {
                        Label(cue.rawValue, systemImage: "play.circle")
                    }.disabled(!model.chimesEnabled)
                }
                Text("One tone at 60 minutes, two at 90 minutes and after a defer or overrun, and a return tone when your rest is complete. Plays through your current audio output, including during Focus. System volume and mute still apply.")
                    .font(.caption).foregroundStyle(.secondary)
                if let error = model.chimeError {
                    Text(error).font(.caption).foregroundStyle(.orange)
                }
            }
            Section("Notifications") {
                Text(notifications.status).foregroundStyle(.secondary)
                Button("Enable reminders") { notifications.request() }
                    .disabled(notifications.allowed || notifications.isRequesting)
                Button("Refresh reminder status") { Task { await notifications.refresh() } }
                Text("Notification banners are silent; chimes are controlled above. To receive banners during Focus, allow Rhythm in that Focus. The 90-minute pause reminder appears independently of notification permission.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Focus") {
                Toggle("Use macOS Focus while working", isOn: $model.focusRequested)
                Label("Manual Focus setup", systemImage: "hand.raised")
                    .font(.subheadline.weight(.medium))
                Text("This preference is saved; it does not switch Focus automatically. Use Control Center → Focus to choose Do Not Disturb or your preferred Focus when you start, and turn it off when you pause.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Quiet moments") {
                Toggle("Start a pause after 5 minutes without input", isOn: $model.autoPause)
                Text("Optional. Reading and thinking can look like inactivity. Rhythm checks only elapsed time since input and keeps your resume note. Return manually when you’re ready. Sleep always starts a pause.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Application") {
                Button("Quit Rhythm", action: quit)
            }
            Section("On this Mac") {
                Text("Your notes and up to 90 days of history stay locally on this Mac. No account, network service, or analytics.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }.formStyle(.grouped).frame(height: 500)
            .tint(RhythmStyle.accent)
            .task { await notifications.refresh() }
    }
}

struct WaveHistoryView: View {
    @ObservedObject var model: RhythmModel
    private var entries: [HistoryEntry] {
        model.engine.entries.filter { $0.duration(on: Date()) > 0 }.reversed()
    }
    private func total(_ kind: HistoryEntry.Kind) -> TimeInterval {
        entries.filter { $0.kind == kind }.reduce(0) { $0 + $1.duration(on: Date()) }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day()).foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack(spacing: 12) {
                metric("Working", value: RhythmFormat.duration(total(.wave)), symbol: "waveform.path")
                metric("Resting", value: RhythmFormat.duration(total(.pause)), symbol: "pause")
                metric("Waves", value: "\(entries.filter { $0.kind == .wave && Calendar.current.isDateInToday($0.endedAt) }.count)", symbol: "music.note.list")
            }
            if model.engine.mode != .ready {
                Label("\(model.engine.mode == .working ? "Wave" : "Pause") in progress · \(RhythmFormat.duration(model.engine.elapsed))", systemImage: "circle.dotted")
                    .font(.callout).foregroundStyle(RhythmStyle.accent)
            }
            if entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "waveform.path").font(.largeTitle).foregroundStyle(RhythmStyle.accent)
                    Text("Your day has room to unfold.").font(.headline)
                    Text("Completed waves and pauses will appear here.").foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(entries) { entry in
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: entry.kind == .wave ? "waveform.path" : "pause.fill")
                                    .foregroundStyle(RhythmStyle.accent).frame(width: 24).padding(.top, 3)
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(entry.kind == .wave ? "Wave" : "Pause").font(.headline)
                                        Spacer()
                                        Text(RhythmFormat.duration(entry.duration(on: Date()))).monospacedDigit()
                                    }
                                    Text("\(entry.startedAt.formatted(date: .omitted, time: .shortened)) – \(entry.endedAt.formatted(date: .omitted, time: .shortened))")
                                        .font(.caption).foregroundStyle(.secondary)
                                    if entry.kind == .wave && !entry.note.isEmpty {
                                        Text(entry.note).font(.callout).foregroundStyle(.secondary).lineLimit(3)
                                    }
                                }
                            }.padding(.vertical, 16)
                            Divider()
                        }
                    }
                }
            }
            Text("Completed time, with space between waves. No score to chase.")
                .font(.caption).foregroundStyle(.tertiary)
        }.padding(20).frame(height: 440)
    }
    private func metric(_ label: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(label, systemImage: symbol).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.system(size: 22, weight: .light, design: .rounded)).monospacedDigit()
        }.frame(maxWidth: .infinity, alignment: .leading).padding(10)
            .background(RhythmStyle.accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
    }
}
