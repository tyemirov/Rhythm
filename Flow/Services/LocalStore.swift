import Foundation

struct LocalStore {
    let url: URL

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        url = root.appendingPathComponent(FlowIdentity.storageDirectory, isDirectory: true).appendingPathComponent("history.json")
    }

    init(url: URL) { self.url = url }

    func load() throws -> WaveEngine {
        guard FileManager.default.fileExists(atPath: url.path) else { return WaveEngine() }
        return try JSONDecoder().decode(WaveEngine.self, from: Data(contentsOf: url))
    }

    func save(_ engine: WaveEngine) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(engine).write(to: url, options: .atomic)
    }
}
