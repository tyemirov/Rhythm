import Foundation

struct LocalStore {
    let url: URL

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        url = root.appendingPathComponent("RhythmPrototype", isDirectory: true).appendingPathComponent("history.json")
    }

    func load() throws -> RhythmEngine {
        guard FileManager.default.fileExists(atPath: url.path) else { return RhythmEngine() }
        return try JSONDecoder().decode(RhythmEngine.self, from: Data(contentsOf: url))
    }

    func save(_ engine: RhythmEngine) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(engine).write(to: url, options: .atomic)
    }
}
