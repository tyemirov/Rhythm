import AppKit

enum FlowStatusIcon {
    static func image(for mode: WaveMode) -> NSImage {
        let image: NSImage
        switch mode {
        case .ready:
            image = water()
        case .working:
            let wave = water()
            image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { bounds in
                NSColor.black.setFill()
                NSBezierPath(ovalIn: bounds).fill()
                wave.draw(in: bounds.insetBy(dx: 3, dy: 3), from: .zero,
                          operation: .destinationOut, fraction: 1)
                return true
            }
        case .pause:
            image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "Pause")!
        }
        image.size = NSSize(width: 18, height: 18)
        image.isTemplate = true
        return image
    }

    private static func water() -> NSImage {
        NSImage(systemSymbolName: "water.waves", accessibilityDescription: "Wave")!
    }
}
