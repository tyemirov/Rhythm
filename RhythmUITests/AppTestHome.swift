import Foundation

struct AppTestHome {
    private static let applicationName = "Rhythm.app"
    let url: URL
    let bundleIdentifier: String

    var launchEnvironment: [String: String] { ["CFFIXED_USER_HOME": url.path] }

    init() throws {
        let identifier = UUID().uuidString
        url = FileManager.default.temporaryDirectory.appendingPathComponent("RhythmAppTests")
            .appendingPathComponent(identifier, isDirectory: true)
        bundleIdentifier = "com.mprlab.RhythmTest.run\(identifier.replacingOccurrences(of: "-", with: ""))"
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    func prepareApplication(forUITestBundle testBundle: URL) throws -> URL {
        let products = testBundle.deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        return try prepareApplication(productsDirectory: products)
    }

    func prepareApplication(productsDirectory: URL) throws -> URL {
        let application = url.appendingPathComponent(Self.applicationName)
        try FileManager.default.copyItem(at: productsDirectory.appendingPathComponent(Self.applicationName), to: application)
        let info = application.appendingPathComponent("Contents/Info.plist")
        var properties = try PropertyListSerialization.propertyList(from: Data(contentsOf: info), format: nil) as! [String: Any]
        properties["CFBundleIdentifier"] = bundleIdentifier
        try PropertyListSerialization.data(fromPropertyList: properties, format: .xml, options: 0).write(to: info)
        let signer = Process()
        signer.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        signer.arguments = ["--force", "--sign", "-", application.path]
        try signer.run()
        signer.waitUntilExit()
        guard signer.terminationStatus == 0 else {
            throw NSError(domain: "Rhythm.TestHome", code: Int(signer.terminationStatus),
                          userInfo: [NSLocalizedDescriptionKey: "Sign test application at \(application.path)."])
        }
        return application
    }

    func remove() throws {
        let defaults = UserDefaults(suiteName: bundleIdentifier)!
        defaults.removePersistentDomain(forName: bundleIdentifier)
        guard defaults.synchronize() else {
            throw NSError(domain: "Rhythm.TestHome", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Remove test preferences for \(bundleIdentifier)."])
        }
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
