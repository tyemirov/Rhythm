import XCTest

final class WaveEngineTests: XCTestCase {
    let origin = Date(timeIntervalSince1970: 1_790_000_000)

    func testActionLabelsFollowWorkAndPauseStates() {
        XCTAssertEqual(WaveAction.next(mode: .ready, preparingPause: false).rawValue, "Start wave")
        XCTAssertEqual(WaveAction.next(mode: .working, preparingPause: false).rawValue, "Pause")
        XCTAssertEqual(WaveAction.next(mode: .working, preparingPause: true).rawValue, "Begin pause")
        XCTAssertEqual(WaveAction.next(mode: .pause, preparingPause: false).rawValue, "Continue")
        XCTAssertEqual(WaveAction.next(mode: .pause, preparingPause: true), .continueWork)
    }

    func testCurrentVocabularyInSavedState() throws {
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 60, at: origin.addingTimeInterval(60))
        engine.beginPause(note: "Next step", at: origin.addingTimeInterval(60))
        engine.beginWave(at: origin.addingTimeInterval(90))
        let data = try JSONEncoder().encode(engine)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["mode"] as? String, "working")
        let entries = try XCTUnwrap(json["entries"] as? [[String: Any]])
        XCTAssertEqual(entries.first?["kind"] as? String, "wave")
        let restored = try JSONDecoder().decode(WaveEngine.self, from: data)
        XCTAssertEqual(restored.entries.count, engine.entries.count)
        XCTAssertEqual(restored.resumeNote, "Next step")
    }

    func testThresholdsFireExactlyOnce() {
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        XCTAssertEqual(engine.advance(by: 3599, at: origin), [])
        XCTAssertEqual(engine.stage, .quiet)
        XCTAssertEqual(engine.advance(by: 1, at: origin), [.gentle])
        XCTAssertEqual(engine.advance(by: 1799, at: origin), [])
        XCTAssertEqual(engine.advance(by: 1, at: origin), [.due])
        XCTAssertEqual(engine.advance(by: 1799, at: origin), [])
        XCTAssertEqual(engine.advance(by: 1, at: origin), [.overrun])
        XCTAssertEqual(engine.advance(by: 3600, at: origin), [])
    }

    func testDeferralIsFiveMinutesAndOnlyOnce() {
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 5400, at: origin)
        XCTAssertTrue(engine.canDefer)
        engine.deferPause()
        XCTAssertFalse(engine.canDefer)
        XCTAssertEqual(engine.advance(by: 299, at: origin), [])
        XCTAssertEqual(engine.advance(by: 1, at: origin), [.due])
        engine.deferPause()
        XCTAssertNil(engine.deferredUntil)
        XCTAssertEqual(engine.advance(by: 1500, at: origin), [.overrun])
    }

    func testLargeJumpEmitsOnlyOverrun() {
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        XCTAssertEqual(engine.advance(by: 8000, at: origin), [.overrun])
        XCTAssertEqual(engine.advance(by: 1, at: origin), [])
    }

    func testLateDeferralNeverPromisesTimeBeyondOverrun() {
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 116 * 60, at: origin)
        XCTAssertFalse(engine.canDefer)
        engine.deferPause()
        XCTAssertNil(engine.deferredUntil)
        XCTAssertEqual(engine.advance(by: 4 * 60, at: origin), [.overrun])
    }

    func testDaylightSavingAllocationUsesActualDayLength() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        let start = calendar.date(from: DateComponents(year: 2026, month: 3, day: 8))!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let entry = HistoryEntry(kind: .pause, startedAt: start, endedAt: end,
                                 duration: end.timeIntervalSince(start), note: "")
        XCTAssertEqual(entry.duration(on: start, calendar: calendar), 23 * 3600)
        XCTAssertEqual(entry.duration(on: end, calendar: calendar), 0)
    }

    func testPauseNoteResumeAndHistory() {
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 3600, at: origin.addingTimeInterval(3600))
        engine.beginPause(note: "  Inspect the next step.  ", at: origin.addingTimeInterval(3600))
        XCTAssertEqual(engine.entries.count, 1)
        XCTAssertEqual(engine.entries[0].duration, 3600)
        XCTAssertEqual(engine.resumeNote, "Inspect the next step.")
        XCTAssertEqual(engine.advance(by: 300, at: origin.addingTimeInterval(3900)), [.pauseComplete])
        XCTAssertEqual(engine.advance(by: 1, at: origin.addingTimeInterval(3901)), [])
        engine.beginWave(at: origin.addingTimeInterval(3901))
        XCTAssertEqual(engine.entries.count, 2)
        XCTAssertEqual(engine.entries.last?.kind, .pause)
        XCTAssertEqual(engine.elapsed, 3600)
        XCTAssertEqual(engine.stage, .available)
        XCTAssertEqual(engine.resumeNote, "Inspect the next step.")
    }

    func testSavedPauseIncludesOfflineTimeAndKeepsWaveDurationFixed() throws {
        let testRoot = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        addTeardownBlock { try FileManager.default.removeItem(at: testRoot) }
        let store = LocalStore(url: testRoot.appendingPathComponent("history.json"))
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        let pauseStart = origin.addingTimeInterval(3600)
        _ = engine.advance(by: 3600, at: pauseStart)
        engine.beginPause(note: "Continue here", at: pauseStart)
        try store.save(engine)

        var restored = try store.load()
        let returnTime = pauseStart.addingTimeInterval(95 * 3600)
        restored.restore(at: returnTime)
        XCTAssertEqual(restored.mode, .pause)
        XCTAssertEqual(restored.elapsed, 95 * 3600)
        XCTAssertEqual(restored.entries.count, 1)
        XCTAssertEqual(restored.entries[0].duration, 3600)
        XCTAssertEqual(restored.resumeNote, "Continue here")
        XCTAssertEqual(restored.advance(by: 2, at: returnTime.addingTimeInterval(2)), [])
        XCTAssertEqual(restored.elapsed, 95 * 3600 + 2)
        XCTAssertEqual(restored.entries[0].duration, 3600)

        restored.beginWave(at: returnTime.addingTimeInterval(2))
        try store.save(restored)
        let resumed = try store.load()
        XCTAssertEqual(resumed.mode, .working)
        XCTAssertEqual(resumed.elapsed, 3600, "Continue must resume the saved Wave duration, excluding Pause time.")
        XCTAssertEqual(resumed.entries.count, 2)
        XCTAssertEqual(resumed.entries[0].kind, .wave)
        XCTAssertEqual(resumed.entries[0].duration, 3600)
        XCTAssertEqual(resumed.entries[1].kind, .pause)
        XCTAssertEqual(resumed.entries[1].duration, 95 * 3600 + 2)
        XCTAssertEqual(resumed.resumeNote, "Continue here")
    }

    func testPauseDisplayIdentifiesRecoveryTimeAndTheContinueAction() {
        XCTAssertEqual(WaveFormat.pausedTitle, "Wave paused")
        XCTAssertEqual(WaveFormat.pauseTime(0), "Pause time: 00:00")
        XCTAssertEqual(WaveFormat.pauseTime(95 * 3600 + 8 * 60 + 49), "Pause time: 95:08:49")
        XCTAssertEqual(WaveFormat.waveTime(3600), "Wave time: 1:00:00")
        XCTAssertEqual(WaveFormat.continueExplanation, "Continue resumes this Wave. Restart starts a new Wave.")
    }

    func testEveryThirdWaveSuggestsLongerPause() {
        var engine = WaveEngine()
        for index in 1...3 {
            engine.restartWave(at: origin)
            _ = engine.advance(by: 3600, at: origin)
            engine.beginPause(note: "", at: origin)
            XCTAssertEqual(engine.pauseTarget, index == 3 ? 900 : 300)
            _ = engine.advance(by: 300, at: origin)
        }
    }

    func testPersistenceAndRestoreExcludeOfflineWork() throws {
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 600, at: origin.addingTimeInterval(600))
        engine.resumeNote = "Continue here"
        let data = try JSONEncoder().encode(engine)
        var restored = try JSONDecoder().decode(WaveEngine.self, from: data)
        restored.restore(at: origin.addingTimeInterval(4200))
        XCTAssertEqual(restored.mode, .pause)
        XCTAssertEqual(restored.entries[0].duration, 600)
        XCTAssertEqual(restored.elapsed, 3600)
        XCTAssertEqual(restored.resumeNote, "Continue here")
    }

    func testContinueKeepsDeferredDeadlineThroughLocalStorage() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let store = LocalStore(url: root.appendingPathComponent("history.json"))
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        XCTAssertEqual(engine.advance(by: 5400, at: origin.addingTimeInterval(5400)), [.due])
        engine.deferPause()
        _ = engine.advance(by: 100, at: origin.addingTimeInterval(5500))
        let pauseStart = origin.addingTimeInterval(5500)
        engine.beginPause(note: "Keep this step", at: pauseStart)
        let id = try XCTUnwrap(engine.entries.first?.id)
        try store.save(engine)

        engine = try store.load()
        let resumedAt = pauseStart.addingTimeInterval(3600)
        engine.restore(at: resumedAt)
        XCTAssertEqual(engine.pausedWaveDuration, 5500)
        engine.beginWave(at: resumedAt)
        XCTAssertEqual(engine.elapsed, 5500)
        XCTAssertEqual(engine.deferredUntil, 5700)
        XCTAssertTrue(engine.hasDeferred)
        XCTAssertFalse(engine.canDefer)
        XCTAssertEqual(engine.advance(by: 199, at: resumedAt.addingTimeInterval(199)), [])
        XCTAssertEqual(engine.advance(by: 1, at: resumedAt.addingTimeInterval(200)), [.due])
        XCTAssertEqual(engine.advance(by: 1500, at: resumedAt.addingTimeInterval(1700)), [.overrun])
        engine.beginPause(note: "Keep this step", at: resumedAt.addingTimeInterval(1700))
        try store.save(engine)
        engine = try store.load()
        engine.beginWave(at: resumedAt.addingTimeInterval(1700))
        XCTAssertEqual(engine.advance(by: 1, at: resumedAt.addingTimeInterval(1701)), [])
        XCTAssertEqual(engine.entries.filter { $0.kind == .wave }.map(\.id), [id])
        XCTAssertEqual(engine.entries.first { $0.kind == .wave }?.duration, 7200)
        XCTAssertEqual(engine.resumeNote, "Keep this step")
    }

    func testRestartFromPauseAndWorkKeepsHistoryAndResetsReminders() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let store = LocalStore(url: root.appendingPathComponent("history.json"))
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 5400, at: origin.addingTimeInterval(5400))
        engine.deferPause()
        engine.beginPause(note: "Next step", at: origin.addingTimeInterval(5400))
        _ = engine.advance(by: 300, at: origin.addingTimeInterval(5700))
        let id = try XCTUnwrap(engine.entries.first?.id)
        try store.save(engine)
        engine = try store.load()
        engine.restartWave(at: origin.addingTimeInterval(5700))
        XCTAssertEqual(engine.mode, .working)
        XCTAssertEqual(engine.elapsed, 0)
        XCTAssertEqual(engine.stage, .quiet)
        XCTAssertFalse(engine.hasDeferred)
        XCTAssertNil(engine.deferredUntil)
        XCTAssertEqual(engine.entries.first?.id, id)
        XCTAssertEqual(engine.entries.first?.duration, 5400)
        XCTAssertEqual(engine.entries.last?.kind, .pause)
        XCTAssertEqual(engine.entries.last?.duration, 300)
        XCTAssertEqual(engine.resumeNote, "Next step")
        XCTAssertEqual(engine.advance(by: 3600, at: origin.addingTimeInterval(9300)), [.gentle])
        engine.restartWave(at: origin.addingTimeInterval(9300))
        try store.save(engine)
        engine = try store.load()
        XCTAssertEqual(engine.elapsed, 0)
        XCTAssertEqual(engine.entries.filter { $0.kind == .wave }.map(\.duration), [5400, 3600])
        XCTAssertEqual(engine.advance(by: 5400, at: origin.addingTimeInterval(14700)), [.due])
    }

    func testRepeatedContinueExcludesPausesFromDailyWorkTotals() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let midnight = calendar.startOfDay(for: origin)
        let start = midnight.addingTimeInterval(-600)
        let firstReturn = midnight.addingTimeInterval(86400 + 1200)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let store = LocalStore(url: root.appendingPathComponent("history.json"))
        var engine = WaveEngine()
        engine.beginWave(at: start)
        _ = engine.advance(by: 600, at: midnight)
        engine.beginPause(note: "First step", at: midnight)
        let id = try XCTUnwrap(engine.entries.first?.id)
        try store.save(engine)
        engine = try store.load()
        engine.restore(at: firstReturn)
        engine.beginWave(at: firstReturn)
        _ = engine.advance(by: 300, at: firstReturn.addingTimeInterval(300))
        engine.resumeNote = "Second step"
        try store.save(engine)
        engine = try store.load()
        // A closed application restores the continued Wave at its saved checkpoint.
        engine.restore(at: firstReturn.addingTimeInterval(300))
        XCTAssertEqual(engine.mode, .pause)
        XCTAssertEqual(engine.pausedWaveDuration, 900)
        _ = engine.advance(by: 300, at: firstReturn.addingTimeInterval(600))
        engine.beginWave(at: firstReturn.addingTimeInterval(600))
        _ = engine.advance(by: 300, at: firstReturn.addingTimeInterval(900))
        engine.finish(at: firstReturn.addingTimeInterval(900))
        try store.save(engine)
        engine = try store.load()
        let waves = engine.entries.filter { $0.kind == .wave }
        XCTAssertEqual(waves.count, 1)
        let wave = try XCTUnwrap(waves.first)
        XCTAssertEqual(wave.id, id)
        XCTAssertEqual(wave.duration, 1200)
        XCTAssertEqual(wave.note, "Second step")
        XCTAssertEqual(engine.entries.last?.id, id, "The latest recorded work must remain last in History.")
        XCTAssertEqual(wave.duration(on: start, calendar: calendar), 600, accuracy: 0.001)
        XCTAssertEqual(wave.duration(on: midnight, calendar: calendar), 0)
        XCTAssertEqual(wave.duration(on: firstReturn, calendar: calendar), 600, accuracy: 0.001)
        XCTAssertEqual(engine.entries.filter { $0.kind == .pause }.reduce(0) { $0 + $1.duration }, 87900)
    }

    func testContinueWithNoWorkDoesNotResumeAnEarlierWave() {
        var engine = WaveEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 60, at: origin.addingTimeInterval(60))
        engine.restartWave(at: origin.addingTimeInterval(60))
        engine.beginPause(note: "Next step", at: origin.addingTimeInterval(60))
        _ = engine.advance(by: 30, at: origin.addingTimeInterval(90))
        engine.beginWave(at: origin.addingTimeInterval(90))
        XCTAssertEqual(engine.elapsed, 0)
        _ = engine.advance(by: 30, at: origin.addingTimeInterval(120))
        engine.beginPause(note: "Next step", at: origin.addingTimeInterval(120))
        XCTAssertEqual(engine.entries.filter { $0.kind == .wave }.map(\.duration), [60, 30])
    }

    func testMidnightAllocation() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let midnight = calendar.startOfDay(for: origin)
        let entry = HistoryEntry(kind: .wave, startedAt: midnight.addingTimeInterval(-1800),
                                 endedAt: midnight.addingTimeInterval(1800), duration: 3600, note: "")
        XCTAssertEqual(entry.duration(on: midnight, calendar: calendar), 1800)
        XCTAssertEqual(entry.duration(on: midnight.addingTimeInterval(-86400), calendar: calendar), 1800)
    }

    func testInvalidAdvancesAndRepeatedActionsAreSafe() {
        var engine = WaveEngine()
        XCTAssertEqual(engine.advance(by: 30, at: origin), [])
        engine.beginWave(at: origin)
        _ = engine.advance(by: 30, at: origin)
        engine.beginWave(at: origin)
        XCTAssertEqual(engine.elapsed, 30)
        _ = engine.advance(by: -.infinity, at: origin)
        _ = engine.advance(by: .nan, at: origin)
        XCTAssertEqual(engine.elapsed, 30)
        engine.beginPause(note: "", at: origin)
        engine.beginPause(note: "", at: origin)
        XCTAssertEqual(engine.entries.count, 1)
        engine.finish(at: origin)
        engine.finish(at: origin)
        XCTAssertEqual(engine.mode, .ready)
        XCTAssertEqual(engine.entries.count, 1)
    }
}
