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
let catalog = assets.appendingPathComponent("AppIcon.appiconset")
let contents = try JSONSerialization.jsonObject(with: Data(contentsOf: catalog.appendingPathComponent("Contents.json"))) as! [String: Any]
for entry in contents["images"] as! [[String: String]] {
    let points = Int(entry["size"]!.split(separator: "x")[0])!
    let pixels = points * (entry["scale"] == "2x" ? 2 : 1)
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
    try png(context.makeImage()!, to: catalog.appendingPathComponent(entry["filename"]!))
}

// A simple crest retains the Great Wave silhouette at menu bar sizes.
let mark = assets.appendingPathComponent("WaveMark.imageset")
try FileManager.default.createDirectory(at: mark, withIntermediateDirectories: true)
var box = CGRect(x: 0, y: 0, width: 24, height: 24)
let output = mark.appendingPathComponent("WaveMark.pdf")
let pdf = CGContext(output as CFURL, mediaBox: &box, nil)!
pdf.beginPDFPage(nil)
let crest = CGMutablePath()
crest.move(to: CGPoint(x: 1, y: 3))
crest.addCurve(to: CGPoint(x: 6, y: 13), control1: CGPoint(x: 5, y: 4), control2: CGPoint(x: 4, y: 9))
crest.addCurve(to: CGPoint(x: 15, y: 22), control1: CGPoint(x: 7, y: 19), control2: CGPoint(x: 10, y: 23))
crest.addCurve(to: CGPoint(x: 23, y: 16), control1: CGPoint(x: 20, y: 22), control2: CGPoint(x: 23, y: 20))
crest.addLines(between: [CGPoint(x: 20, y: 18), CGPoint(x: 20, y: 15), CGPoint(x: 17, y: 18),
                        CGPoint(x: 16, y: 16), CGPoint(x: 15, y: 18)])
crest.addCurve(to: CGPoint(x: 11, y: 12), control1: CGPoint(x: 12, y: 19), control2: CGPoint(x: 10, y: 16))
crest.addCurve(to: CGPoint(x: 23, y: 3), control1: CGPoint(x: 12, y: 8), control2: CGPoint(x: 17, y: 4))
crest.closeSubpath()
pdf.addPath(crest)
pdf.setFillColor(CGColor(gray: 0, alpha: 1))
pdf.fillPath()
pdf.endPDFPage()
pdf.closePDF()
let markContents: [String: Any] = ["images": [["filename": "WaveMark.pdf", "idiom": "universal"]],
    "info": ["author": "xcode", "version": 1],
    "properties": ["preserves-vector-representation": true, "template-rendering-intent": "template"]]
try JSONSerialization.data(withJSONObject: markContents, options: [.prettyPrinted, .sortedKeys])
    .write(to: mark.appendingPathComponent("Contents.json"))
print("Generated Flow application icons and WaveMark.")
