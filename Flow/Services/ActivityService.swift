import CoreGraphics
import Foundation

protocol ActivitySensing {
    func idleSeconds() -> TimeInterval?
}

/// Public Quartz aggregate counter. No event tap, keystroke capture, window
/// titles, screenshots, Accessibility permission, or activity log is used.
struct SystemActivityService: ActivitySensing {
    func idleSeconds() -> TimeInterval? {
        // The all-events sentinel is documented by Quartz as UINT32_MAX.
        let allEvents = CGEventType(rawValue: UInt32.max)!
        let aggregate = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: allEvents)
        return aggregate.isFinite && aggregate >= 0 && aggregate < 365 * 86400 ? aggregate : nil
    }
}
