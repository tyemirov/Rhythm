import AppKit

enum FlowStatusIcon {
    static func image(for mode: WaveMode, bundle: Bundle = .main) -> NSImage {
        let image: NSImage
        switch mode {
        case .ready:
            image = crest(in: bundle).copy() as! NSImage
        case .working:
            let wave = crest(in: bundle)
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

    private static func crest(in bundle: Bundle) -> NSImage {
        guard let image = bundle.image(forResource: FlowIdentity.waveImage) else {
            preconditionFailure("Read \(FlowIdentity.waveImage) from \(bundle.bundleURL.path).")
        }
        return image
    }
}
