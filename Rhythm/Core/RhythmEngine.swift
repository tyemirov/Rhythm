import Foundation

enum RhythmMode: String, Codable { case ready, working, pause }
enum WaveAction: String {
    case start = "Start", preparePause = "Pause", beginPause = "Begin pause", continueWork = "Continue"

    static func next(mode: RhythmMode, preparingPause: Bool) -> WaveAction {
        switch mode {
        case .ready: return .start
        case .working: return preparingPause ? .beginPause : .preparePause
        case .pause: return .continueWork
        }
    }
}

enum WaveStage { case quiet, available, due, overrun }
enum RhythmEvent: Equatable { case gentle, due, overrun, pauseComplete }

struct HistoryEntry: Codable, Identifiable {
    enum Kind: String, Codable { case wave, pause }
    var id = UUID()
    var kind: Kind
    var startedAt: Date
    var endedAt: Date
    var duration: TimeInterval
    var note: String

    /// Allocate durations proportionally across calendar days, including DST.
    func duration(on day: Date, calendar: Calendar = .current) -> TimeInterval {
        guard let interval = calendar.dateInterval(of: .day, for: day) else { return 0 }
        let wallDuration = endedAt.timeIntervalSince(startedAt)
        guard wallDuration > 0 else {
            return calendar.isDate(startedAt, inSameDayAs: day) ? duration : 0
        }
        let overlap = min(endedAt, interval.end).timeIntervalSince(max(startedAt, interval.start))
        return duration * max(0, overlap) / wallDuration
    }
}

struct RhythmEngine: Codable {
    var mode: RhythmMode = .ready
    var elapsed: TimeInterval = 0
    var startedAt: Date?
    var updatedAt: Date = Date()
    var resumeNote = ""
    var pauseReason = ""
    var entries: [HistoryEntry] = []
    var gentleSent = false
    var dueSent = false
    var overrunSent = false
    var deferredUntil: TimeInterval?
    var hasDeferred = false
    var pauseCompleteSent = false
    var pauseTarget: TimeInterval = 5 * 60

    var stage: WaveStage {
        if elapsed >= 120 * 60 { return .overrun }
        if elapsed >= 90 * 60 { return .due }
        if elapsed >= 60 * 60 { return .available }
        return .quiet
    }

    var canDefer: Bool {
        mode == .working && stage == .due && !hasDeferred && elapsed <= 115 * 60
    }

    mutating func beginWave(at now: Date) {
        guard mode != .working else { return }
        if mode == .pause { appendEntry(.pause, at: now) }
        mode = .working
        elapsed = 0
        startedAt = now
        updatedAt = now
        gentleSent = false
        dueSent = false
        overrunSent = false
        deferredUntil = nil
        hasDeferred = false
        pauseReason = ""
    }

    mutating func advance(by seconds: TimeInterval, at now: Date) -> [RhythmEvent] {
        updatedAt = now
        guard mode != .ready, seconds.isFinite, seconds >= 0 else { return [] }
        elapsed += seconds
        if mode == .pause {
            if elapsed >= pauseTarget && !pauseCompleteSent {
                pauseCompleteSent = true
                return [.pauseComplete]
            }
            return []
        }
        // A delayed timer emits only the most relevant intervention.
        if elapsed >= 120 * 60 && !overrunSent {
            overrunSent = true
            dueSent = true
            gentleSent = true
            deferredUntil = nil
            return [.overrun]
        }
        if let deadline = deferredUntil {
            if elapsed >= deadline {
                deferredUntil = nil
                return [.due]
            }
            return []
        }
        if elapsed >= 90 * 60 && !dueSent {
            dueSent = true
            gentleSent = true
            return [.due]
        }
        if elapsed >= 60 * 60 && !gentleSent {
            gentleSent = true
            return [.gentle]
        }
        return []
    }

    mutating func deferPause() {
        guard canDefer else { return }
        hasDeferred = true
        deferredUntil = elapsed + 5 * 60
    }

    mutating func beginPause(note: String, at now: Date, reason: String = "A little space between waves.") {
        guard mode == .working else { return }
        resumeNote = String(note.prefix(2000)).trimmingCharacters(in: .whitespacesAndNewlines)
        appendEntry(.wave, at: now)
        let wavesToday = entries.filter {
            $0.kind == .wave && Calendar.current.isDate($0.endedAt, inSameDayAs: now)
        }.count
        pauseTarget = wavesToday > 0 && wavesToday.isMultiple(of: 3) ? 15 * 60 : 5 * 60
        mode = .pause
        elapsed = 0
        startedAt = now
        updatedAt = now
        pauseCompleteSent = false
        deferredUntil = nil
        pauseReason = reason
    }

    mutating func finish(at now: Date) {
        if mode == .working { appendEntry(.wave, at: now) }
        if mode == .pause { appendEntry(.pause, at: now) }
        mode = .ready
        elapsed = 0
        startedAt = nil
        updatedAt = now
        deferredUntil = nil
    }

    /// Work never accumulates while the process is closed. Restore it as a pause
    /// at the last saved checkpoint, preserving the note and completed work.
    mutating func restore(at now: Date) {
        if mode == .working {
            beginPause(note: resumeNote, at: updatedAt,
                       reason: "Rhythm was closed. Continue when you’re ready.")
        }
        if mode == .pause {
            elapsed += max(0, now.timeIntervalSince(updatedAt))
            pauseCompleteSent = elapsed >= pauseTarget
        }
        updatedAt = now
    }

    private mutating func appendEntry(_ kind: HistoryEntry.Kind, at now: Date) {
        guard let start = startedAt, elapsed > 0 else { return }
        entries.append(HistoryEntry(kind: kind, startedAt: start, endedAt: now,
                                    duration: elapsed, note: resumeNote))
        // A small, local prototype history: retain up to 90 days.
        let cutoff = now.addingTimeInterval(-90 * 86400)
        entries.removeAll { $0.endedAt < cutoff }
    }
}

enum RhythmFormat {
    static func clock(_ seconds: TimeInterval) -> String {
        let value = max(0, Int(seconds))
        if value >= 3600 { return String(format: "%d:%02d:%02d", value / 3600, value / 60 % 60, value % 60) }
        return String(format: "%02d:%02d", value / 60, value % 60)
    }
    static func duration(_ seconds: TimeInterval) -> String {
        let minutes = max(0, Int(seconds / 60))
        if minutes >= 60 { return "\(minutes / 60)h \(minutes % 60)m" }
        return "\(minutes)m"
    }
}
