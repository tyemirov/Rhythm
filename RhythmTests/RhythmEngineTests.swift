import XCTest

final class RhythmEngineTests: XCTestCase {
    let origin = Date(timeIntervalSince1970: 1_790_000_000)

    func testActionLabelsFollowWorkAndPauseStates() {
        XCTAssertEqual(WaveAction.next(mode: .ready, preparingPause: false).rawValue, "Start")
        XCTAssertEqual(WaveAction.next(mode: .working, preparingPause: false).rawValue, "Pause")
        XCTAssertEqual(WaveAction.next(mode: .working, preparingPause: true).rawValue, "Begin pause")
        XCTAssertEqual(WaveAction.next(mode: .pause, preparingPause: false).rawValue, "Continue")
        XCTAssertEqual(WaveAction.next(mode: .pause, preparingPause: true), .continueWork)
    }

    func testCurrentVocabularyInSavedState() throws {
        var engine = RhythmEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 60, at: origin.addingTimeInterval(60))
        engine.beginPause(note: "Next step", at: origin.addingTimeInterval(60))
        engine.beginWave(at: origin.addingTimeInterval(90))
        let data = try JSONEncoder().encode(engine)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["mode"] as? String, "working")
        let entries = try XCTUnwrap(json["entries"] as? [[String: Any]])
        XCTAssertEqual(entries.first?["kind"] as? String, "wave")
        let restored = try JSONDecoder().decode(RhythmEngine.self, from: data)
        XCTAssertEqual(restored.entries.count, engine.entries.count)
        XCTAssertEqual(restored.resumeNote, "Next step")
    }

    func testThresholdsFireExactlyOnce() {
        var engine = RhythmEngine()
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
        var engine = RhythmEngine()
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
        var engine = RhythmEngine()
        engine.beginWave(at: origin)
        XCTAssertEqual(engine.advance(by: 8000, at: origin), [.overrun])
        XCTAssertEqual(engine.advance(by: 1, at: origin), [])
    }

    func testLateDeferralNeverPromisesTimeBeyondOverrun() {
        var engine = RhythmEngine()
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
        var engine = RhythmEngine()
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
        XCTAssertEqual(engine.elapsed, 0)
        XCTAssertEqual(engine.stage, .quiet)
        XCTAssertEqual(engine.resumeNote, "Inspect the next step.")
    }

    func testEveryThirdWaveSuggestsLongerPause() {
        var engine = RhythmEngine()
        for index in 1...3 {
            engine.beginWave(at: origin)
            _ = engine.advance(by: 3600, at: origin)
            engine.beginPause(note: "", at: origin)
            XCTAssertEqual(engine.pauseTarget, index == 3 ? 900 : 300)
            _ = engine.advance(by: 300, at: origin)
        }
    }

    func testPersistenceAndRestoreExcludeOfflineWork() throws {
        var engine = RhythmEngine()
        engine.beginWave(at: origin)
        _ = engine.advance(by: 600, at: origin.addingTimeInterval(600))
        engine.resumeNote = "Continue here"
        let data = try JSONEncoder().encode(engine)
        var restored = try JSONDecoder().decode(RhythmEngine.self, from: data)
        restored.restore(at: origin.addingTimeInterval(4200))
        XCTAssertEqual(restored.mode, .pause)
        XCTAssertEqual(restored.entries[0].duration, 600)
        XCTAssertEqual(restored.elapsed, 3600)
        XCTAssertEqual(restored.resumeNote, "Continue here")
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
        var engine = RhythmEngine()
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
