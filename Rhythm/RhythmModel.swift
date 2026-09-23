import AppKit
import Combine
import Foundation

@MainActor
final class RhythmModel: ObservableObject {
    @Published private(set) var engine = RhythmEngine()
    @Published var draftNote = "" {
        didSet {
            if draftNote.count > 2000 { draftNote = String(draftNote.prefix(2000)) }
            engine.resumeNote = draftNote
            persist()
        }
    }
    @Published private(set) var idleSeconds: TimeInterval?
    @Published private(set) var storageError: String?
    @Published var focusRequested: Bool { didSet { defaults.set(focusRequested, forKey: "focusRequested"); updateFocus() } }
    @Published var autoPause: Bool { didSet { defaults.set(autoPause, forKey: "autoPause") } }
    @Published var chimesEnabled: Bool {
        didSet { defaults.set(chimesEnabled, forKey: "chimesEnabled"); if !chimesEnabled { chimes.stop() } }
    }
    @Published var chimeVolume: Double {
        didSet { defaults.set(chimeVolume, forKey: "chimeVolume") }
    }
    @Published private(set) var chimeError: String?
    private let chimes = ChimeService()
    let notifications = NotificationService()
    let focus: FocusControlling = ManualFocusService()
    var onIntervention: (() -> Void)?
    var onDismissIntervention: (() -> Void)?
    private let defaults = UserDefaults.standard
    private let store = LocalStore()
    private let activity: ActivitySensing = SystemActivityService()
    private var timer: Timer?
    private var lastTick = ProcessInfo.processInfo.systemUptime
    private var lastSave = Date.distantPast
    private var suspended = false
    private var sleepAt: Date?
    private var persistenceBlocked = false

    convenience init() { self.init(loadSaved: true) }

    init(loadSaved: Bool) {
        chimesEnabled = defaults.object(forKey: "chimesEnabled") as? Bool ?? true
        chimeVolume = min(max(defaults.object(forKey: "chimeVolume") as? Double ?? 0.4, 0), 1)
        focusRequested = defaults.bool(forKey: "focusRequested")
        autoPause = defaults.bool(forKey: "autoPause")
        if loadSaved {
            do { engine = try store.load(); engine.restore(at: Date()) }
            catch {
                storageError = "Saved History could not be read. This run stays in memory to preserve the existing file."
                persistenceBlocked = true
            }
        }
        draftNote = engine.resumeNote
        updateFocus()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }
    }

    var title: String {
        switch engine.mode {
        case .ready: return "Ready to start"
        case .pause: return engine.elapsed >= engine.pauseTarget ? "Ready to continue" : "Make room for a pause"
        case .working:
            if engine.deferredUntil != nil { return "Finish the wave" }
            switch engine.stage {
            case .quiet: return "Working"
            case .available: return "A pause is available"
            case .due: return "Time for a pause"
            case .overrun: return "This wave has run long"
            }
        }
    }

    var subtitle: String {
        switch engine.mode {
        case .ready: return "A little structure. Space to think."
        case .pause: return engine.elapsed >= engine.pauseTarget ? "Return when you’re ready. Your note is here." : engine.pauseReason
        case .working:
            if let deadline = engine.deferredUntil { return "Pause in \(RhythmFormat.clock(deadline - engine.elapsed))." }
            switch engine.stage {
            case .quiet: return "Settle in. Your first hour stays quiet."
            case .available: return "Take it at the next natural stopping point."
            case .due: return "Leave yourself a note, then step away."
            case .overrun: return "Give the next wave a little breathing room."
            }
        }
    }

    var menuTitle: String {
        if engine.mode == .ready { return "Rhythm" }
        let minutes = Int(engine.elapsed / 60)
        return "\(minutes)m\(engine.mode == .working && engine.stage == .overrun ? " !" : "")"
    }

    func beginWave() {
        syncTime()
        engine.beginWave(at: Date())
        lastTick = ProcessInfo.processInfo.systemUptime
        chimes.stop()
        notifications.clear()
        updateFocus()
        persist()
    }

    func pause(reason: String = "A little space between waves.") {
        syncTime(deliverEvents: false)
        engine.beginPause(note: draftNote, at: Date(), reason: reason)
        chimes.stop()
        notifications.clear()
        onDismissIntervention?()
        updateFocus()
        persist()
    }

    func deferPause() {
        syncTime(deliverEvents: false)
        engine.deferPause()
        onDismissIntervention?()
        persist()
    }

    func finish() {
        syncTime(deliverEvents: false)
        engine.finish(at: Date())
        chimes.stop()
        notifications.clear()
        onDismissIntervention?()
        updateFocus()
        persist()
    }

    func prepareForSleep() {
        guard !suspended else { return }
        if engine.mode == .working { pause(reason: "Your Mac rested. Continue when you’re ready.") }
        suspended = true
        sleepAt = Date()
        persist()
    }

    func wake() {
        if let sleepAt, engine.mode == .pause {
            // Sleep is recovery time, never work time. Suppress a wake-up reminder.
            _ = engine.advance(by: max(0, Date().timeIntervalSince(sleepAt)), at: Date())
        }
        sleepAt = nil
        suspended = false
        lastTick = ProcessInfo.processInfo.systemUptime
        persist()
    }

    func shutdown() {
        chimes.stop()
        if engine.mode == .working { pause(reason: "Rhythm was closed. Continue when you’re ready.") }
        else { syncTime(deliverEvents: false) }
        persist()
    }

    private func tick() {
        guard !suspended else { return }
        handleActivity(activity)
        syncTime()
        if Date().timeIntervalSince(lastSave) >= 15 { persist() }
    }

    private func handleActivity(_ sensor: ActivitySensing) {
        idleSeconds = sensor.idleSeconds()
        if autoPause, engine.mode == .working, let idleSeconds, idleSeconds >= 300 {
            // Five idle minutes remain part of the wave: reading/thinking may
            // be work. No claim is made that input inactivity means inattention.
            pause(reason: "A quiet moment became a pause. Continue when you’re ready.")
        }
    }

    private func syncTime(deliverEvents: Bool = true) {
        let uptime = ProcessInfo.processInfo.systemUptime
        let delta = max(0, uptime - lastTick)
        lastTick = uptime
        guard !suspended else { return }
        let events = engine.advance(by: delta, at: Date())
        if deliverEvents { handle(events) }
    }

    private func handle(_ events: [RhythmEvent]) {
        for event in events {
            switch event {
            case .gentle:
                playChime(.invitation)
                notifications.send(title: "A pause is available", body: "Take it at the next natural stopping point.")
            case .due, .overrun:
                playChime(.pause)
                onIntervention?()
            case .pauseComplete:
                playChime(.returnToWork)
                notifications.send(title: "Ready to continue", body: "Your pause has room to end. Return when you’re ready.")
            }
        }
        if !events.isEmpty { persist() }
    }

    func playChime(_ cue: ChimeService.Cue) {
        guard chimesEnabled else { return }
        do { try chimes.play(cue, volume: chimeVolume); chimeError = nil }
        catch { chimeError = "Chime playback failed: \(error.localizedDescription)" }
    }

    private func updateFocus() {
        focus.setWorking(engine.mode == .working, requested: focusRequested)
    }

    private func persist() {
        guard !persistenceBlocked else { return }
        do { try store.save(engine); storageError = nil; lastSave = Date() }
        catch { storageError = "History could not be saved: \(error.localizedDescription)" }
    }
}
