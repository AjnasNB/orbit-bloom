import XCTest
import StoreKitTest

@MainActor final class GameplayUITests: XCTestCase {
    let app = XCUIApplication()
    var session: SKTestSession!
    override func setUpWithError() throws {
        continueAfterFailure = false
        session = try SKTestSession(contentsOf: XCTUnwrap(Bundle(for: Self.self).url(forResource: "OrbitBloom", withExtension: "storekit")))
        session.resetToDefaultState(); session.clearTransactions(); session.disableDialogs = true
        app.launchArguments = ["--uitesting"]
        app.launch()
        XCTAssertTrue(app.buttons["introStart"].waitForExistence(timeout: 10))
        app.buttons["introStart"].tap()
    }
    func attach(_ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    func winCurrentLevel() throws {
        for _ in 0..<35 {
            if app.staticTexts["winTitle"].exists { return }
            XCTAssertFalse(app.staticTexts["loseTitle"].exists, "The tutorial should be winnable with suggested moves")
            let burst = app.buttons["burstButton"]
            if burst.exists && burst.isEnabled && burst.label.contains("Ready!") {
                burst.tap()
                let frozen = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'tile' AND label CONTAINS 'frozen'")).firstMatch
                let target = frozen.exists ? frozen : app.buttons["tile24"]
                target.tap()
                let idle = app.buttons["hintButton"]
                expectation(for: NSPredicate { _, _ in self.app.staticTexts["winTitle"].exists || idle.isEnabled }, evaluatedWith: app)
                waitForExpectations(timeout: 10)
                if app.staticTexts["winTitle"].exists { return }
            }
            let hint = app.buttons["hintButton"]
            XCTAssertTrue(hint.waitForExistence(timeout: 5))
            let enabled = NSPredicate(format: "enabled == true")
            expectation(for: enabled, evaluatedWith: hint)
            waitForExpectations(timeout: 10)
            hint.tap()
            let instruction = app.staticTexts["hintInstruction"]
            XCTAssertTrue(instruction.waitForExistence(timeout: 5))
            let regex = try NSRegularExpression(pattern: "[0-9]+")
            let text = instruction.label as NSString
            let values = regex.matches(in: instruction.label, range: NSRange(location: 0, length: text.length)).compactMap { Int(text.substring(with: $0.range)) }
            XCTAssertEqual(values.count, 4)
            let a = (7 - values[0]) * 7 + values[1] - 1
            let b = (7 - values[2]) * 7 + values[3] - 1
            let before = app.staticTexts["movesCounter"].label
            app.buttons["tile\(a)"].tap(); app.buttons["tile\(b)"].tap()
            let settled = NSPredicate { _, _ in self.app.staticTexts["winTitle"].exists || self.app.staticTexts["loseTitle"].exists || self.app.staticTexts["movesCounter"].label != before }
            expectation(for: settled, evaluatedWith: app)
            waitForExpectations(timeout: 10)
        }
        XCTFail("Level never reached the win screen")
    }
    func testCompleteCampaignRestoreAndPersistGarden() throws {
        attach("01-garden-home")
        app.buttons["playLevel"].tap()
        XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout: 5))
        attach("02-playable-puzzle")
        try winCurrentLevel(); attach("03-real-level-victory")
        app.buttons["nextLevel"].tap()
        try winCurrentLevel()
        app.buttons["backToGarden"].tap()
        app.buttons["restoreProject"].tap()
        XCTAssertTrue(app.staticTexts["1/6 restored"].waitForExistence(timeout: 5))
        attach("04-restored-greenhouse")
        app.terminate(); app.launchArguments = ["--uitesting", "--keep-progress"]; app.launch()
        XCTAssertTrue(app.staticTexts["1/6 restored"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["playLevel"].label.contains("3"))
        for level in 3...12 {
            app.buttons["playLevel"].tap()
            try winCurrentLevel()
            if level == 12 { attach("07-chapter-finale") }
            app.buttons["backToGarden"].tap()
            if level % 2 == 0 { app.buttons["restoreProject"].tap() }
        }
        XCTAssertTrue(app.staticTexts["6/6 restored"].exists)
        XCTAssertTrue(app.staticTexts["A world in bloom."].exists)
        attach("08-complete-garden")
    }
    func testShopDoesNotBlockFreeGameplay() {
        app.buttons["tabShop"].tap()
        XCTAssertTrue(app.buttons["buyAurora"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["restorePurchases"].exists)
        app.buttons["tabGarden"].tap()
        app.buttons["playLevel"].tap()
        XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout: 5))
    }
    func testShopPurchaseAndRestoreUI() throws {
        app.buttons["tabShop"].tap()
        let buy = app.buttons["buyAurora"]
        XCTAssertTrue(buy.waitForExistence(timeout: 10))
        let ready = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: buy)], timeout: 8)
        guard ready == .completed else { throw XCTSkip("Local StoreKit service could not load the test product on the installed simulator runtime") }
        attach("05-storekit-local-shop")
        buy.tap()
        XCTAssertTrue(app.staticTexts["purchasedLabel"].waitForExistence(timeout: 15))
        let toggle = app.switches["auroraToggle"]
        XCTAssertTrue(toggle.exists); toggle.tap()
        app.buttons["restorePurchases"].tap()
        XCTAssertTrue(app.staticTexts["purchaseStatus"].waitForExistence(timeout: 10))
        attach("06-purchase-unlocked")
        app.buttons["tabGarden"].tap()
        XCTAssertTrue(app.buttons["playLevel"].exists)
    }
    func testPauseShuffleAndResumeSession() throws {
        app.buttons["playLevel"].tap()
        let before = app.staticTexts["movesCounter"].label
        app.buttons["shuffleButton"].tap()
        XCTAssertEqual(app.staticTexts["movesCounter"].label, before)
        app.buttons["pauseGame"].tap()
        XCTAssertTrue(app.buttons["resumeGame"].exists)
        app.buttons["resumeGame"].tap()
        let label = app.buttons["tile0"].label
        app.terminate(); app.launchArguments = ["--uitesting", "--keep-progress"]; app.launch()
        XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons["tile0"].label, label)
        XCTAssertEqual(app.staticTexts["movesCounter"].label, before)
    }
    func testSuggestedMoveSupportsSwipe() throws {
        app.buttons["playLevel"].tap()
        app.buttons["hintButton"].tap()
        let instruction = app.staticTexts["hintInstruction"].label as NSString
        let regex = try NSRegularExpression(pattern: "[0-9]+")
        let values = regex.matches(in: instruction as String, range: NSRange(location: 0, length: instruction.length)).compactMap { Int(instruction.substring(with: $0.range)) }
        XCTAssertEqual(values.count, 4)
        let first = (7 - values[0]) * 7 + values[1] - 1
        let second = (7 - values[2]) * 7 + values[3] - 1
        let before = app.staticTexts["movesCounter"].label
        let start = app.buttons["tile\(first)"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = app.buttons["tile\(second)"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        expectation(for: NSPredicate { _, _ in self.app.staticTexts["movesCounter"].label != before }, evaluatedWith: app)
        waitForExpectations(timeout: 10)
        attach("09-swipe-match")
    }
}
