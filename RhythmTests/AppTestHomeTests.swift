import XCTest

final class AppTestHomeTests: XCTestCase {
    func testLaunchEnvironmentSeparatesHistoryAndPreferencesWithoutDesktopInteraction() throws {
        let home = try AppTestHome()
        addTeardownBlock { try home.remove() }
        let otherHome = try AppTestHome()
        addTeardownBlock { try otherHome.remove() }
        XCTAssertNotEqual(home.url, otherHome.url)

        let products = Bundle(for: Self.self).bundleURL.deletingLastPathComponent()
        let testBundle = products.appendingPathComponent("RhythmUITests-Runner.app/Contents/PlugIns/RhythmUITests.xctest")
        let application = try home.prepareApplication(forUITestBundle: testBundle)
        XCTAssertEqual(Bundle(url: application)?.bundleIdentifier, home.bundleIdentifier)
        let domain = home.bundleIdentifier
        let source = home.url.appendingPathComponent("probe.swift")
        try """
            import Foundation
            guard NSHomeDirectory() == CommandLine.arguments[1] else { exit(2) }
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            let directory = support.appendingPathComponent("RhythmPrototype")
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

        let history = home.url.appendingPathComponent("Library/Application Support/RhythmPrototype/history.json")
        XCTAssertEqual(try String(contentsOf: history), "isolated history")
        let preferences = try XCTUnwrap(UserDefaults(suiteName: domain))
        XCTAssertEqual(preferences.string(forKey: "fixtureMarker"), "isolated preferences")
        let prototype = try XCTUnwrap(UserDefaults(suiteName: "com.mprlab.RhythmPrototype"))
        XCTAssertNil(prototype.string(forKey: "fixtureMarker"))
        XCTAssertNil(UserDefaults(suiteName: otherHome.bundleIdentifier)?.string(forKey: "fixtureMarker"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: otherHome.url.appendingPathComponent("Library").path))
        try home.remove()
        XCTAssertFalse(FileManager.default.fileExists(atPath: home.url.path))
        XCTAssertNil(preferences.string(forKey: "fixtureMarker"))
    }
}
