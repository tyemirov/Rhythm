import UserNotifications

@MainActor
final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var status = "Reminders have not been enabled."
    @Published var allowed = false
    @Published var isRequesting = false
    var onOpen: (() -> Void)?
    private let center = UNUserNotificationCenter.current()
    private var generation = 0

    override init() {
        super.init()
        center.delegate = self
        Task { await refresh() }
    }

    func request() {
        guard !isRequesting else { return }
        isRequesting = true
        status = "Waiting for macOS permission. If no prompt appears, open System Settings → Notifications → Rhythm."
        Task {
            defer { isRequesting = false }
            do {
                _ = try await center.requestAuthorization(options: [.alert])
                await refresh()
            } catch { status = "Could not enable reminders: \(error.localizedDescription)" }
        }
    }

    func refresh() async {
        let settings = await center.notificationSettings()
        allowed = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        switch settings.authorizationStatus {
        case .authorized, .provisional: status = "Reminders enabled. Delivery follows your macOS settings."
        case .denied: status = "Reminders are off. Enable Rhythm in System Settings → Notifications."
        default: status = "Enable reminders to receive the gentle 60-minute nudge."
        }
    }

    func send(title: String, body: String) {
        let expectedGeneration = generation
        Task {
            await refresh()
            guard allowed, expectedGeneration == generation else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = nil
            // Ordinary silent notifications respect Focus. Allow Rhythm in your
            // chosen Focus to receive the 60-minute reminder while it is active.
            // The 90/120-minute app window is a separate, visible intervention.
            content.interruptionLevel = .active
            let identifier = "rhythm-" + UUID().uuidString
            do {
                try await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: nil))
                if generation != expectedGeneration {
                    center.removeDeliveredNotifications(withIdentifiers: [identifier])
                    center.removePendingNotificationRequests(withIdentifiers: [identifier])
                }
            } catch { status = "Reminder delivery failed: \(error.localizedDescription)" }
        }
    }

    func clear() {
        generation += 1
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification,
                                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list])
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse,
                                            withCompletionHandler completionHandler: @escaping () -> Void) {
        Task { @MainActor in self.onOpen?() }
        completionHandler()
    }
}
