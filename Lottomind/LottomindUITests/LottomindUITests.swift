//
//  LottomindUITests.swift
//  LottomindUITests
//

import XCTest

final class LottomindUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testMainNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Add basic tab flow validation
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5.0), "Tab bar should exist at launch")
        
        // By default we are on home/dashboard
        let navBar = app.navigationBars["LottoMind"]
        XCTAssertTrue(navBar.exists)
        
        // Tap Settings Tab (Assumption: tab title matches the localization)
        let settingsTab = tabBar.buttons["设置"]
        if settingsTab.exists {
            settingsTab.tap()
            XCTAssertTrue(app.navigationBars["设置"].waitForExistence(timeout: 2.0))
        }
        
        // Tap Analyze Tab
        let analyzeTab = tabBar.buttons["分析"]
        if analyzeTab.exists {
            analyzeTab.tap()
            XCTAssertTrue(app.navigationBars["智能分析"].waitForExistence(timeout: 2.0) || app.navigationBars["分析"].exists)
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
