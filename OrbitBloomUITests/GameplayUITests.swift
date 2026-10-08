import XCTest
import StoreKitTest

@MainActor final class GameplayUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
        XCTAssertTrue(app.buttons["introStart"].waitForExistence(timeout:15))
        app.buttons["introStart"].tap()
    }
    func attach(_ name:String) { let shot = XCTAttachment(screenshot:app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot) }
    func target() -> XCUIElement {
        let frozen = app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH 'tile' AND label CONTAINS 'frozen'")).firstMatch
        return frozen.exists ? frozen : app.buttons["tile24"]
    }
    func settle() {
        let hint = app.buttons["hintButton"]
        expectation(for:NSPredicate { _,_ in self.app.staticTexts["winTitle"].exists || self.app.staticTexts["loseTitle"].exists || hint.isEnabled },evaluatedWith:app)
        waitForExpectations(timeout:12)
    }
    func winCurrentLevel() throws {
        for _ in 0..<45 {
            if app.staticTexts["winTitle"].exists { return }
            XCTAssertFalse(app.staticTexts["loseTitle"].exists,"Circuit must be reachable with normal groups and supplied/earned tools")
            let burst = app.buttons["burstButton"]
            if burst.exists && burst.isEnabled && burst.label.contains("Ready!") { burst.tap(); target().tap(); settle(); if app.staticTexts["winTitle"].exists { return } }
            let frozen = app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH 'tile' AND label CONTAINS 'frozen'")).firstMatch
            if frozen.exists {
                for tool in ["bomb","tnt","mega","rainbow"] {
                    let button = app.buttons["tool\(tool)"]
                    if button.exists && button.isEnabled && !button.label.contains(", 0 available") { button.tap(); target().tap(); settle(); break }
                }
                if app.staticTexts["winTitle"].exists { return }
            }
            let hint = app.buttons["hintButton"]
            XCTAssertTrue(hint.waitForExistence(timeout:5)); XCTAssertTrue(hint.isEnabled); hint.tap()
            let label = app.staticTexts["hintInstruction"]
            XCTAssertTrue(label.waitForExistence(timeout:5))
            let text = label.label as NSString
            let values = try NSRegularExpression(pattern:"[0-9]+").matches(in:text as String,range:NSRange(location:0,length:text.length)).compactMap { Int(text.substring(with:$0.range)) }
            XCTAssertEqual(values.count,2)
            let key = (7-values[0])*7+values[1]-1
            app.buttons["tile\(key)"].tap(); settle()
        }
        XCTFail("Circuit never completed")
    }
    func testCompleteConnectedCampaignAndRestoreWorld() throws {
        attach("v2-01-world")
        app.buttons["playLevel"].tap(); XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout:5)); attach("v2-02-botanical-circuit")
        try winCurrentLevel(); attach("v2-03-victory")
        app.buttons["nextLevel"].tap(); try winCurrentLevel(); app.buttons["backToGarden"].tap()
        app.buttons["restoreProject"].tap()
        app.terminate(); app.launchArguments = ["--uitesting","--keep-progress"]; app.launch()
        XCTAssertTrue(app.staticTexts["1/6 restored"].waitForExistence(timeout:10))
        for level in 3...12 {
            app.buttons["playLevel"].tap(); try winCurrentLevel()
            if level == 12 { attach("v2-08-chapter-finale") }
            app.buttons["backToGarden"].tap()
            if level%2 == 0 { app.buttons["restoreProject"].tap() }
        }
        XCTAssertTrue(app.staticTexts["6/6 restored"].exists); XCTAssertTrue(app.staticTexts["A world in bloom."].exists)
        attach("v2-09-complete-world")
    }
    func testFarmHarvestCraftAndSave() throws {
        app.buttons["tabFarm"].tap(); attach("v2-04-farm")
        for id in [0,1] {
            let plot = app.buttons["plot\(id)"]
            plot.tap()
            for _ in 0..<3 { if !plot.label.contains("ready") { plot.tap() } }
            XCTAssertTrue(plot.label.contains("ready")); plot.tap()
        }
        XCTAssertTrue(app.staticTexts["farmTotals"].label.contains("Harvested: 2"))
        app.swipeUp()
        app.buttons["craftbomb"].tap(); attach("v2-05-tool-shed")
        app.terminate(); app.launchArguments = ["--uitesting","--keep-progress"]; app.launch(); app.buttons["tabFarm"].tap(); app.swipeUp()
        XCTAssertTrue(app.staticTexts["farmTotals"].waitForExistence(timeout:5)); XCTAssertTrue(app.staticTexts["farmTotals"].label.contains("Harvested: 2"))
    }
    func testDeliveryRaceWithRealSteeringAndReward() {
        app.buttons["tabRace"].tap(); attach("v2-06-race-lobby"); app.buttons["startRace"].tap()
        XCTAssertTrue(app.buttons["raceLane0"].waitForExistence(timeout:5)); app.buttons["raceLane0"].tap()
        attach("v2-07-delivery-race")
        XCTAssertTrue(app.staticTexts["raceResult"].waitForExistence(timeout:40)); XCTAssertEqual(app.staticTexts["raceResult"].label,"Delivery complete!")
        attach("v2-10-delivery-complete"); app.buttons["raceDone"].tap()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
    }
    func testPauseResumeToolAndShopFlows() {
        app.buttons["playLevel"].tap(); let before = app.staticTexts["movesCounter"].label
        app.buttons["toolbomb"].tap(); app.buttons["tile0"].tap(); settle(); attach("v2-11-bomb-blast")
        XCTAssertEqual(app.staticTexts["movesCounter"].label,before)
        app.buttons["pauseGame"].tap(); XCTAssertTrue(app.buttons["resumeGame"].exists); app.buttons["resumeGame"].tap()
        app.terminate(); app.launchArguments = ["--uitesting","--keep-progress"]; app.launch()
        XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout:10)); XCTAssertEqual(app.staticTexts["movesCounter"].label,before)
        app.buttons["pauseGame"].tap(); app.buttons["leaveLevel"].tap(); app.buttons["tabShop"].tap(); attach("v2-12-lives-and-shop")
        XCTAssertTrue(app.staticTexts["lifeTimer"].exists); XCTAssertTrue(app.buttons["refillLives"].isEnabled)
        app.buttons["refillLives"].tap(); XCTAssertFalse(app.buttons["refillLives"].isEnabled)
        app.swipeUp(); attach("v2-13-coin-packs"); app.swipeUp(); attach("v2-14-starter-bundle")
        app.buttons["tabFarm"].tap(); XCTAssertTrue(app.buttons["plot0"].waitForExistence(timeout:5))
    }
}
