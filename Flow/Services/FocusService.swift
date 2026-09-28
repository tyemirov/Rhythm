import Foundation

@MainActor
protocol FocusControlling {
    var status: String { get }
    func setWorking(_ active: Bool, requested: Bool)
}

/// Deliberately isolated integration point. Apple's public INFocusStatusCenter
/// reads shared status; it does not set the system Focus / Do Not Disturb mode.
/// This prototype does not access private frameworks, preference databases,
/// AppleScript UI automation, or undocumented Focus switches.
/// A future adapter could invoke a user-created Shortcut with explicit setup,
/// while remembering and restoring any pre-existing user Focus state.
@MainActor
final class ManualFocusService: FocusControlling {
    private(set) var status = "Focus is managed by you."
    func setWorking(_ active: Bool, requested: Bool) {
        status = requested && active
            ? "Turn on your preferred Focus in Control Center."
            : "Focus is managed by you."
    }
}
