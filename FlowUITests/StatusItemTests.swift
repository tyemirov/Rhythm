import XCTest

final class StatusItemTests: XCTestCase {
    private var app: XCUIApplication!
    private var testHome: AppTestHome?

    override func setUpWithError() throws {
        continueAfterFailure = false
        let home = try AppTestHome()
        testHome = home
        let application = try home.prepareApplication(forUITestBundle: Bundle(for: Self.self).bundleURL)
        app = XCUIApplication(url: application)
        app.launchEnvironment = home.launchEnvironment
        app.launch()
        if !app.buttons["Start wave"].waitForExistence(timeout: 3) {
            app.statusItems.firstMatch.click()
        }
        XCTAssertTrue(app.buttons["Start wave"].waitForExistence(timeout: 5), app.debugDescription)
    }

    override func tearDownWithError() throws {
        app?.terminate()
        try testHome?.remove()
    }

    func testMenuBarRemainsIconOnlyAndChangesForWaveAndPause() {
        let status = app.statusItems.firstMatch
        XCTAssertEqual(status.title, "")
        let readyIcon = status.screenshot().pngRepresentation

        app.buttons["Start wave"].click()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 3))
        waitForStatus("Wave in progress")
        XCTAssertEqual(status.title, "")
        let waveIcon = status.screenshot().pngRepresentation
        XCTAssertNotEqual(waveIcon, readyIcon, "An active Wave must have a distinct icon.")

        app.buttons["Pause"].click()
        app.buttons["Begin pause"].click()
        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 3), app.debugDescription)
        waitForStatus("Pause")
        XCTAssertEqual(status.title, "")
        let pauseIcon = status.screenshot().pngRepresentation
        XCTAssertNotEqual(pauseIcon, waveIcon)
        XCTAssertNotEqual(pauseIcon, readyIcon)

        app.buttons["Continue"].click()
        waitForStatus("Wave in progress")
        XCTAssertEqual(status.title, "")
        XCTAssertEqual(status.screenshot().pngRepresentation, waveIcon)
    }

    private func waitForStatus(_ state: String) {
        let predicate = NSPredicate(format: "label CONTAINS %@", state)
        let status = app.statusItems.matching(predicate).firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 3), app.debugDescription)
    }
}
