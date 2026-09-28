import Foundation

let manifest = URL(fileURLWithPath: CommandLine.arguments[1])
    .appendingPathComponent("Contents/Resources/PrivacyInfo.xcprivacy")
let expected: NSDictionary = [
    "NSPrivacyTracking": false,
    "NSPrivacyTrackingDomains": [],
    "NSPrivacyCollectedDataTypes": [],
    "NSPrivacyAccessedAPITypes": [
        [
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
            "NSPrivacyAccessedAPITypeReasons": ["CA92.1"],
        ],
        [
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategorySystemBootTime",
            "NSPrivacyAccessedAPITypeReasons": ["35F9.1"],
        ],
    ],
]
do {
    let data = try Data(contentsOf: manifest)
    let actual = try PropertyListSerialization.propertyList(from: data, format: nil)
    guard let dictionary = actual as? NSDictionary, dictionary == expected else {
        throw NSError(domain: "Rhythm.PrivacyCheck", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Declarations do not match the application audit."])
    }
    print("Privacy declarations verified: \(manifest.path)")
} catch {
    fputs("Privacy check failed for \(manifest.path): \(error.localizedDescription)\n", stderr)
    exit(1)
}
