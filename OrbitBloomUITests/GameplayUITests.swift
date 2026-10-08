import XCTest
import StoreKitTest

@MainActor final class GameplayUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:15))
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
            XCTAssertTrue(hint.waitForExistence(timeout:5)); XCTAssertTrue(hint.isEnabled); hint.press(forDuration:0.15)
            let label = app.staticTexts["hintInstruction"]
            XCTAssertTrue(label.waitForExistence(timeout:5))
            let suggested = NSPredicate(format:"label CONTAINS 'Slide row'")
            if XCTWaiter.wait(for:[XCTNSPredicateExpectation(predicate:suggested,object:label)],timeout:5) != .completed {
                attach("hint-failure"); XCTFail("Hint failed: \(label.label). \(app.debugDescription)"); return
            }
            let text = label.label as NSString
            let values = try NSRegularExpression(pattern:"[0-9]+").matches(in:text as String,range:NSRange(location:0,length:text.length)).compactMap { Int(text.substring(with:$0.range)) }
            XCTAssertEqual(values.count,4)
            guard values.count == 4 else { return }
            let key = (7-values[0])*7+values[1]-1, other = (7-values[2])*7+values[3]-1
            let turns = Int(app.staticTexts["movesCounter"].label)!
            app.buttons["tile\(key)"].press(forDuration:0.1,thenDragTo:app.buttons["tile\(other)"])
            settle()
            if !app.staticTexts["winTitle"].exists { XCTAssertEqual(Int(app.staticTexts["movesCounter"].label),turns-1,"The hinted swipe must swap pieces and spend exactly one turn") }
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
        app.buttons["tabWorld"].tap(); app.swipeUp(); app.buttons["openTasks"].tap()
        let reward = app.buttons["claim_harvest1"]; XCTAssertTrue(reward.waitForExistence(timeout:5)); reward.tap(); XCTAssertFalse(reward.isEnabled)
        attach("v3-15-field-tasks"); app.navigationBars.buttons["Done"].tap(); app.buttons["tabFarm"].tap()
        app.swipeUp()
        app.buttons["craftbomb"].tap(); attach("v2-05-tool-shed")
        app.terminate(); app.launchArguments = ["--uitesting","--keep-progress"]; app.launch(); app.buttons["tabFarm"].tap(); app.swipeUp()
        XCTAssertTrue(app.staticTexts["farmTotals"].waitForExistence(timeout:5)); XCTAssertTrue(app.staticTexts["farmTotals"].label.contains("Harvested: 2"))
    }
    func testBoardPowerFormationAndAnimatedShuffle() {
        attach("v3-01-world")
        app.buttons["playLevel"].tap(); attach("v3-02-botanical-circuit")
        let powers = app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH 'tile' AND (label BEGINSWITH 'Bomb,' OR label BEGINSWITH 'TNT,' OR label BEGINSWITH 'Mega bomb,' OR label BEGINSWITH 'Rainbow,')"))
        for _ in 0..<10 {
            var kinds:[Int:String] = [:]
            for key in 0..<49 { kinds[key] = app.buttons["tile\(key)"].label.components(separatedBy:",").first }
            var candidate:Int?
            var smallest = 50
            for key in 0..<49 {
                var group:Set<Int> = [key], pending = [key]
                while let item = pending.popLast() {
                    for neighbor in [item-7,item+7,item-1,item+1] where (0..<49).contains(neighbor) && abs(item/7-neighbor/7)+abs(item%7-neighbor%7) == 1 {
                        if kinds[neighbor] == kinds[key] && group.insert(neighbor).inserted { pending.append(neighbor) }
                    }
                }
                if group.count >= 4 && group.count < smallest { candidate = key; smallest = group.count }
            }
            guard let key = candidate else { app.buttons["shuffleButton"].tap(); continue }
            app.buttons["tile\(key)"].tap(); settle()
            if app.staticTexts["winTitle"].exists { app.buttons["nextLevel"].tap(); continue }
            XCTAssertGreaterThan(powers.count,0,"A real formation must create a power on the board")
            attach("v3-16-board-power")
            let count = powers.count, turns = app.staticTexts["movesCounter"].label
            app.buttons["shuffleButton"].tap()
            XCTAssertEqual(powers.count,count,"Shuffling must preserve on-board powers")
            XCTAssertEqual(app.staticTexts["movesCounter"].label,turns)
            powers.firstMatch.tap(); settle()
            if !app.staticTexts["winTitle"].exists { XCTAssertEqual(Int(app.staticTexts["movesCounter"].label),Int(turns)!-1) }
            return
        }
        XCTFail("Power formation needs a playable board before victory")
    }
    func testDeliveryRaceWithRealSteeringAndReward() {
        app.buttons["tabRace"].tap(); attach("v2-06-race-lobby"); app.buttons["startRace"].tap()
        XCTAssertTrue(app.descendants(matching:.any)["raceTrack"].waitForExistence(timeout:5)); app.descendants(matching:.any)["raceTrack"].swipeLeft()
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
