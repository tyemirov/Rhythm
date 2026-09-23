import AppKit
import Combine
import SwiftUI

@main
struct RhythmApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        Settings { EmptyView() }
    }
}

/// AppKit owns status-item and window lifetimes. SwiftUI renders every surface.
/// This gives the pause intervention a reliable standalone window even when
/// the menu popover is closed. No private APIs or global input hooks are used.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var model: RhythmModel!
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var interventionWindow: NSWindow?
    private var subscription: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        model = RhythmModel()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: RhythmPopover(
            model: model,
            quit: { NSApp.terminate(nil) }))
        model.onIntervention = { [weak self] in self?.showIntervention() }
        model.onDismissIntervention = { [weak self] in self?.interventionWindow?.orderOut(nil) }
        model.notifications.onOpen = { [weak self] in self?.showPopover() }
        subscription = model.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.updateStatus() }
        }
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(willSleep), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(didWake), name: NSWorkspace.didWakeNotification, object: nil)
        updateStatus()
        // First launch shows the popover so a menu-bar-only app is discoverable.
        if !UserDefaults.standard.bool(forKey: "hasLaunched") {
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in self?.showPopover() }
        }
    }

    func applicationWillTerminate(_ notification: Notification) { model.shutdown() }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showPopover()
        return true
    }
    @objc private func willSleep() { model.prepareForSleep() }
    @objc private func didWake() { model.wake() }

    private func updateStatus() {
        guard let button = statusItem.button else { return }
        let icon = model.engine.mode == .pause ? "pause.fill" : "waveform.path"
        let image = NSImage(systemSymbolName: icon, accessibilityDescription: "Rhythm")
        image?.isTemplate = true
        button.image = image
        button.imagePosition = .imageOnly
        button.title = ""
        button.toolTip = model.title
        button.setAccessibilityLabel("Rhythm, \(model.title), \(model.menuTitle)")
    }

    @objc private func togglePopover() {
        if popover.isShown { popover.performClose(nil) } else { showPopover() }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func showIntervention() {
        popover.performClose(nil)
        if interventionWindow == nil {
            interventionWindow = makeWindow(title: "A moment for a pause", view: InterventionView(model: model, dismiss: { [weak self] in
                self?.interventionWindow?.orderOut(nil)
            }))
            interventionWindow?.level = .floating
            interventionWindow?.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        }
        show(interventionWindow)
    }

    private func show(_ window: NSWindow?) {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    private func makeWindow<V: View>(title: String, view: V) -> NSWindow {
        let controller = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: controller)
        window.title = title
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}
