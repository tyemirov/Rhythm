import XCTest

final class LabDiscoveryTests: XCTestCase {
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
        if !app.buttons["Settings"].waitForExistence(timeout: 3) {
            let statusItem = app.statusItems.firstMatch
            XCTAssertTrue(statusItem.waitForExistence(timeout: 5), app.debugDescription)
            statusItem.click()
        }
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 5), app.debugDescription)
    }

    override func tearDownWithError() throws {
        app?.terminate()
        try testHome?.remove()
    }

    func testFooterOpensProjectsAndReturnsToFlow() {
        let note = app.textFields["Resume note"]
        let noteValue = note.value as? String
        XCTAssertTrue(app.staticTexts["Built by"].exists)
        assertLink("Marco Polo Research Lab", url: "https://mprlab.com/")
        app.buttons["More from the lab"].click()
        assertProjectPage()
        app.buttons["Back to Flow"].click()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["More from the lab"].exists)
        if let noteValue { XCTAssertEqual(note.value as? String, noteValue) }
    }

    func testSettingsOpensProjectsAndReturnsToSettings() {
        app.buttons["Settings"].click()
        let about = app.buttons["About Flow & the lab"]
        if !about.isHittable { app.scrollViews.firstMatch.swipeUp() }
        XCTAssertTrue(about.waitForExistence(timeout: 3))
        about.click()
        assertProjectPage()
        app.buttons["Back to Settings"].click()
        XCTAssertTrue(app.buttons["Quit Flow"].exists)
        XCTAssertTrue(app.buttons["Back to Flow"].exists)
    }

    private func assertProjectPage() {
        XCTAssertTrue(app.staticTexts["Useful tools. Built with care."].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Free · Built by Marco Polo Research Lab"].exists)
        for (project, url) in [
            ("Gravity Notes", "https://gravity.mprlab.com/"),
            ("Countdown Calendar", "https://countdown.mprlab.com/"),
            ("Hecate", "https://hecate.mprlab.com/")
        ] {
            assertLink(project, url: url)
        }
        assertLink("Explore all projects", url: "https://mprlab.com/#projects")
    }

    private func assertLink(_ title: String, url: String) {
        let link = app.links[title]
        XCTAssertTrue(link.exists, app.debugDescription)
        XCTAssertEqual(link.value as? String, url)
    }
}
