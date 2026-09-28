import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let repository = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let artwork = repository.appendingPathComponent("artwork/great-wave.jpg")
let assets = repository.appendingPathComponent("Flow/Assets.xcassets")
let colorSpace = CGColorSpaceCreateDeviceRGB()

func png(_ image: CGImage, to url: URL) throws {
    guard let output = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw NSError(domain: "Flow.IconGenerator", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Create PNG output at \(url.path)."])
    }
    CGImageDestinationAddImage(output, image, nil)
    guard CGImageDestinationFinalize(output) else {
        throw NSError(domain: "Flow.IconGenerator", code: 2,
                      userInfo: [NSLocalizedDescriptionKey: "Write PNG output at \(url.path)."])
    }
}

guard let source = CGImageSourceCreateWithURL(artwork as CFURL, nil),
      let printImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    fatalError("Read Great Wave artwork at \(artwork.path).")
}
func icon(pixels: Int) -> CGImage {
    let side = CGFloat(pixels)
    let context = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8,
                            bytesPerRow: pixels * 4, space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    let tile = CGRect(x: side / 16, y: side / 16, width: side * 7 / 8, height: side * 7 / 8)
    context.addPath(CGPath(roundedRect: tile, cornerWidth: side * 0.18, cornerHeight: side * 0.18, transform: nil))
    context.clip()
    context.interpolationQuality = .high
    // A square crop keeps the crest and Mount Fuji within the application tile.
    let ratio = tile.height / CGFloat(printImage.height)
    let width = CGFloat(printImage.width) * ratio
    context.draw(printImage, in: CGRect(x: tile.minX - (width - tile.width) * 0.30,
                                       y: tile.minY, width: width, height: tile.height))
    return context.makeImage()!
}

let catalog = assets.appendingPathComponent("AppIcon.appiconset")
let contents = try JSONSerialization.jsonObject(with: Data(contentsOf: catalog.appendingPathComponent("Contents.json"))) as! [String: Any]
for entry in contents["images"] as! [[String: String]] {
    let points = Int(entry["size"]!.split(separator: "x")[0])!
    let pixels = points * (entry["scale"] == "2x" ? 2 : 1)
    try png(icon(pixels: pixels), to: catalog.appendingPathComponent(entry["filename"]!))
}

// In-app images preserve the original artwork colors at normal and Retina sizes.
let mark = assets.appendingPathComponent("GreatWave.imageset")
try FileManager.default.createDirectory(at: mark, withIntermediateDirectories: true)
var images: [[String: String]] = []
for (scale, pixels) in [("1x", 26), ("2x", 52)] {
    let filename = "great-wave-\(scale).png"
    try png(icon(pixels: pixels), to: mark.appendingPathComponent(filename))
    images.append(["filename": filename, "idiom": "universal", "scale": scale])
}
let markContents: [String: Any] = ["images": images, "info": ["author": "xcode", "version": 1],
                                 "properties": ["template-rendering-intent": "original"]]
try JSONSerialization.data(withJSONObject: markContents, options: [.prettyPrinted, .sortedKeys])
    .write(to: mark.appendingPathComponent("Contents.json"))
print("Generated Flow application icons and GreatWave artwork images.")
