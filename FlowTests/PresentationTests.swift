import AppKit
import SwiftUI
import Vision
import XCTest

final class PresentationTests: XCTestCase {
    @MainActor
    func testPlaybackControlsAreCompactAcrossWorkStates() {
        for actions: [WaveAction] in [[.start], [.restart, .preparePause], [.restart, .beginPause], [.restart, .continueWork]] {
            let view = NSHostingView(rootView: WavePlaybackControls(actions: actions, perform: { _ in }))
            view.sizingOptions = [.intrinsicContentSize]
            view.frame.size = view.fittingSize
            view.layoutSubtreeIfNeeded()
            XCTAssertNil(view.window)
            XCTAssertGreaterThanOrEqual(view.fittingSize.height, 20)
            XCTAssertLessThanOrEqual(view.fittingSize.height, 26)
            XCTAssertGreaterThanOrEqual(view.fittingSize.width, actions.count == 1 ? 24 : 52)
            XCTAssertLessThanOrEqual(view.fittingSize.width, actions.count == 1 ? 30 : 64)
        }
    }

    @MainActor
    func testFooterShowsTheLabNameWithoutTheProjectPageButton() throws {
        let footer = LabFooter()
            .frame(width: 340, alignment: .leading)
            .padding(8)
            .background(Color.black)
            .environment(\.colorScheme, .dark)
        let image = try render(footer, scale: 3)
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        try VNImageRequestHandler(cgImage: image).perform([request])
        let text = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        XCTAssertTrue(text.contains("Built by"), text)
        XCTAssertTrue(text.contains("Marco Polo Research Lab"), text)
        XCTAssertFalse(text.localizedCaseInsensitiveContains("More from the lab"), text)
        XCTAssertEqual(LabContent.website.absoluteString, "https://mprlab.com/")
    }

    @MainActor
    func testTimelineShowsTheWaveEmojiAtTheElapsedPosition() throws {
        let actions: [WaveAction] = [.restart, .preparePause]
        let controls = NSHostingView(rootView: WavePlaybackControls(actions: actions, perform: { _ in }))
        let markerX = (340 - 12 - controls.fittingSize.width) / 2
        XCTAssertNil(controls.window)
        let area = CGRect(x: markerX - 13, y: 25, width: 26, height: 26)
        let timeline = try render(WaveTimeline(elapsed: 3600, actions: actions, perform: { _ in }).frame(width: 340))
        let background = try render(WaveTimeline(elapsed: nil, actions: actions, perform: { _ in }).frame(width: 340))
        let expected = try render(Text("🌊").font(.system(size: 24)).frame(width: 26, height: 26))
        let actualMarker = try XCTUnwrap(timeline.cropping(to: area))
        let markerBackground = try XCTUnwrap(background.cropping(to: area))
        let context = try XCTUnwrap(CGContext(data: nil, width: 26, height: 26, bitsPerComponent: 8,
                                             bytesPerRow: 26 * 4, space: CGColorSpaceCreateDeviceRGB(),
                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        let bounds = CGRect(x: 0, y: 0, width: 26, height: 26)
        context.draw(markerBackground, in: bounds)
        context.draw(expected, in: bounds)
        let actualPixels = try pixels(actualMarker)
        let expectedPixels = Data(bytes: try XCTUnwrap(context.data), count: 26 * 26 * 4)
        let errors = zip(actualPixels, expectedPixels).map { abs(Int($0) - Int($1)) }
        // Compositing the emoji over the gradient can round a channel by one byte.
        XCTAssertLessThanOrEqual(try XCTUnwrap(errors.max()), 1,
                                 "The timeline must show the system wave emoji at the elapsed position.")
    }

    @MainActor
    private func render<V: View>(_ view: V, scale: CGFloat = 1) throws -> CGImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        return try XCTUnwrap(renderer.cgImage)
    }

    private func pixels(_ image: CGImage) throws -> Data {
        let context = try XCTUnwrap(CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8,
                                             bytesPerRow: image.width * 4, space: CGColorSpaceCreateDeviceRGB(),
                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return Data(bytes: try XCTUnwrap(context.data), count: image.width * image.height * 4)
    }
}
