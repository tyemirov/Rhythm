import AppKit
import XCTest

final class AppTestHomeTests: XCTestCase {
    func testGreatWaveMenuIconsFollowRealEngineTransitions() throws {
        let products = Bundle(for: Self.self).bundleURL.deletingLastPathComponent()
        let application = try XCTUnwrap(Bundle(url: products.appendingPathComponent("Flow.app")))
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let store = LocalStore(url: root.appendingPathComponent("history.json"))
        var engine = try store.load()
        let ready = FlowStatusIcon.image(for: engine.mode, bundle: application)
        let readyPixels = try pixels(of: ready)
        let now = Date(timeIntervalSince1970: 1_790_000_000)
        engine.beginWave(at: now)
        let working = FlowStatusIcon.image(for: engine.mode, bundle: application)
        let workingPixels = try pixels(of: working)
        XCTAssertNotEqual(readyPixels, workingPixels)
        _ = engine.advance(by: 60, at: now.addingTimeInterval(60))
        engine.beginPause(note: "Next step", at: now.addingTimeInterval(60))
        try store.save(engine)
        engine = try store.load()
        let paused = FlowStatusIcon.image(for: engine.mode, bundle: application)
        let pausePixels = try pixels(of: paused)
        XCTAssertNotEqual(pausePixels, readyPixels)
        XCTAssertNotEqual(pausePixels, workingPixels)
        for image in [ready, working, paused] {
            XCTAssertTrue(image.isTemplate)
            XCTAssertEqual(image.size, NSSize(width: 18, height: 18))
        }
        engine.beginWave(at: now.addingTimeInterval(90))
        XCTAssertEqual(engine.elapsed, 0)
        XCTAssertEqual(engine.entries.first?.duration, 60)
        XCTAssertEqual(engine.resumeNote, "Next step")
        XCTAssertEqual(try pixels(of: FlowStatusIcon.image(for: engine.mode, bundle: application)), workingPixels)
    }

    func testBuiltApplicationUsesFlowNameAndGreatWaveAssets() throws {
        let products = Bundle(for: Self.self).bundleURL.deletingLastPathComponent()
        let application = try XCTUnwrap(Bundle(url: products.appendingPathComponent("Flow.app")))
        XCTAssertEqual(application.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, "Flow")
        XCTAssertEqual(application.object(forInfoDictionaryKey: "CFBundleExecutable") as? String, "Flow")
        // Fixed local identity preserves preferences and notification permission.
        XCTAssertEqual(application.bundleIdentifier, FlowIdentity.localBundleIdentifier)
        XCTAssertEqual(LocalStore().url.deletingLastPathComponent().lastPathComponent, FlowIdentity.storageDirectory)
        let crest = try XCTUnwrap(application.image(forResource: FlowIdentity.waveImage))
        XCTAssertGreaterThan(crest.size.width, 0)
        XCTAssertGreaterThan(crest.size.height, 0)
        let iconName = try XCTUnwrap(application.object(forInfoDictionaryKey: "CFBundleIconFile") as? String)
        let icon = try XCTUnwrap(application.url(forResource: iconName, withExtension: "icns"))
        XCTAssertNotNil(NSImage(contentsOf: icon))
    }

    private func pixels(of image: NSImage) throws -> Data {
        let side = 36
        let context = try XCTUnwrap(CGContext(data: nil, width: side, height: side, bitsPerComponent: 8,
                                             bytesPerRow: side * 4, space: CGColorSpaceCreateDeviceRGB(),
                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        let raster = try XCTUnwrap(image.cgImage(forProposedRect: nil, context: nil, hints: nil))
        context.draw(raster, in: CGRect(x: 0, y: 0, width: side, height: side))
        let data = Data(bytes: try XCTUnwrap(context.data), count: side * side * 4)
        let visible = stride(from: 3, to: data.count, by: 4).filter { data[$0] > 0 }.count
        XCTAssertGreaterThan(visible, 0, "Each state icon must contain a visible shape.")
        XCTAssertLessThan(visible, side * side, "Each state icon must retain transparent space.")
        return data
    }

    func testLaunchEnvironmentSeparatesHistoryAndPreferencesWithoutDesktopInteraction() throws {
        let home = try AppTestHome()
        addTeardownBlock { try home.remove() }
        let otherHome = try AppTestHome()
        addTeardownBlock { try otherHome.remove() }
        XCTAssertNotEqual(home.url, otherHome.url)

        let products = Bundle(for: Self.self).bundleURL.deletingLastPathComponent()
        let testBundle = products.appendingPathComponent("FlowUITests-Runner.app/Contents/PlugIns/FlowUITests.xctest")
        let application = try home.prepareApplication(forUITestBundle: testBundle)
        XCTAssertEqual(Bundle(url: application)?.bundleIdentifier, home.bundleIdentifier)
        let domain = home.bundleIdentifier
        let source = home.url.appendingPathComponent("probe.swift")
        try """
            import Foundation
            guard NSHomeDirectory() == CommandLine.arguments[1] else { exit(2) }
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            let directory = support.appendingPathComponent("\(FlowIdentity.storageDirectory)")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try Data("isolated history".utf8).write(to: directory.appendingPathComponent("history.json"))
            guard Bundle.main.bundleIdentifier == CommandLine.arguments[2] else { exit(5) }
            let defaults = UserDefaults.standard
            defaults.set("isolated preferences", forKey: "fixtureMarker")
            guard defaults.synchronize() else { exit(3) }
            guard defaults.string(forKey: "fixtureMarker") == "isolated preferences" else { exit(4) }
            """.write(to: source, atomically: true, encoding: .utf8)
        let executable = home.url.appendingPathComponent("probe")
        let info = home.url.appendingPathComponent("probe.plist")
        try PropertyListSerialization.data(fromPropertyList: ["CFBundleIdentifier": domain], format: .xml, options: 0)
            .write(to: info)
        let compiler = Process()
        compiler.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        compiler.arguments = ["swiftc", source.path, "-o", executable.path,
                              "-Xlinker", "-sectcreate", "-Xlinker", "__TEXT",
                              "-Xlinker", "__info_plist", "-Xlinker", info.path]
        try compiler.run()
        compiler.waitUntilExit()
        XCTAssertEqual(compiler.terminationStatus, 0)
        guard compiler.terminationStatus == 0 else { return }

        let probe = Process()
        probe.executableURL = executable
        probe.arguments = [home.url.path, domain]
        probe.environment = ProcessInfo.processInfo.environment.merging(home.launchEnvironment) { _, value in value }
        try probe.run()
        probe.waitUntilExit()
        XCTAssertEqual(probe.terminationStatus, 0, "Foundation must use the isolated application home.")
        guard probe.terminationStatus == 0 else { return }

        let history = home.url.appendingPathComponent("Library/Application Support")
            .appendingPathComponent(FlowIdentity.storageDirectory).appendingPathComponent("history.json")
        XCTAssertEqual(try String(contentsOf: history), "isolated history")
        let preferences = try XCTUnwrap(UserDefaults(suiteName: domain))
        XCTAssertEqual(preferences.string(forKey: "fixtureMarker"), "isolated preferences")
        let prototype = try XCTUnwrap(UserDefaults(suiteName: FlowIdentity.localBundleIdentifier))
        XCTAssertNil(prototype.string(forKey: "fixtureMarker"))
        XCTAssertNil(UserDefaults(suiteName: otherHome.bundleIdentifier)?.string(forKey: "fixtureMarker"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: otherHome.url.appendingPathComponent("Library").path))
        try home.remove()
        XCTAssertFalse(FileManager.default.fileExists(atPath: home.url.path))
        XCTAssertNil(preferences.string(forKey: "fixtureMarker"))
    }
}
