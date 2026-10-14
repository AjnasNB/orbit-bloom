import XCTest
import StoreKitTest

@MainActor final class GameplayUITests:XCTestCase {
    let app=XCUIApplication()
    override func setUpWithError() throws { continueAfterFailure=false;XCUIDevice.shared.orientation = .portrait;app.launchArguments=["--uitesting"];app.launch();XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:15)) }
    func attach(_ name:String) { Thread.sleep(forTimeInterval:0.4);let a=XCTAttachment(screenshot:XCUIScreen.main.screenshot());a.name=name;a.lifetime = .keepAlways;add(a) }
    func fits(_ e:XCUIElement) { XCTAssertTrue(e.waitForExistence(timeout:5));XCTAssertTrue(e.isHittable);XCTAssertTrue(app.frame.insetBy(dx:-1,dy:-1).contains(e.frame),"\(e.identifier): \(e.frame)");XCTAssertGreaterThanOrEqual(e.frame.height,44-1e-6) }
    func start() { app.buttons["playLevel"].tap();XCTAssertTrue(app.buttons["confirmLoadout"].waitForExistence(timeout:5));app.buttons["confirmLoadout"].tap();XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout:5)) }
    func target()->XCUIElement { let e=app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH 'tile' AND (label CONTAINS 'frozen' OR label CONTAINS 'hits remaining')")).firstMatch;return e.exists ? e : app.buttons["tile24"] }
    func testLoadoutCancelCapAndStartedPowersAreRealBoardPieces() {
        app.buttons["playLevel"].tap();fits(app.buttons["confirmLoadout"]);attach("build17-prelevel-powers")
        app.buttons["loadoutbomb"].tap();app.buttons["loadouttnt"].tap();app.buttons["loadoutrainbow"].tap();app.buttons["loadoutmega"].tap()
        XCTAssertEqual(app.descendants(matching:.any)["loadoutSlots"].firstMatch.label,"3 of 3 starting power-up slots selected")
        app.buttons["cancelLoadout"].tap();XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
        app.buttons["playLevel"].tap();for id in ["loadoutbomb","loadouttnt","loadoutrainbow"] { app.buttons[id].tap() };app.buttons["confirmLoadout"].tap()
        XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout:5));XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("4 lives"))
        XCTAssertTrue(app.buttons["tile9"].label.hasPrefix("Bomb,"));XCTAssertTrue(app.buttons["tile24"].label.hasPrefix("TNT,"));XCTAssertTrue(app.buttons["tile39"].label.hasPrefix("Rainbow,"))
        XCTAssertTrue(app.buttons["toolbomb"].label.contains("1 available"));attach("build17-puzzle-three-starting-powers")
        app.buttons["tile24"].tap();settle();attach("build17-puzzle-layered-damage")
        XCTAssertFalse(app.buttons["tile24"].label.hasPrefix("TNT,"),"Tapping must detonate the actual starting board power")
    }
    func testBackCancelAbandonAndRestartChargeExactlyOneLifePerAttempt() {
        start();let moves=app.staticTexts["movesCounter"].label
        app.buttons["backFromPuzzle"].tap();fits(app.buttons["confirmAbandon"]);app.buttons["cancelAbandon"].tap()
        XCTAssertEqual(app.staticTexts["movesCounter"].label,moves);XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("4 lives"))
        app.buttons["backFromPuzzle"].tap();app.buttons["confirmAbandon"].tap();XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("4 lives"));start();XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("3 lives"))
        app.buttons["pauseGame"].tap();app.buttons["restartLevel"].tap();app.buttons["confirmRestart"].tap();fits(app.buttons["confirmLoadout"])
        app.buttons["cancelLoadout"].tap();XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("3 lives"))
        app.buttons["resumeGame"].tap();app.buttons["pauseGame"].tap();app.buttons["restartLevel"].tap();app.buttons["confirmRestart"].tap();app.buttons["confirmLoadout"].tap()
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("2 lives"));attach("build17-confirmed-restart")
    }
    func testHardOpeningHasLargeTilesLayeredObstaclesAndEarnedNextKit() throws {
        start();let board=app.descendants(matching:.any)["puzzleBoard"].firstMatch
        XCTAssertGreaterThanOrEqual(board.frame.width,app.frame.width*0.9)
        for key in 0..<49 { fits(app.buttons["tile\(key)"]);XCTAssertGreaterThanOrEqual(app.buttons["tile\(key)"].frame.width,44) }
        XCTAssertEqual(app.staticTexts["movesCounter"].label,"10");XCTAssertTrue(app.descendants(matching:.any)["puzzleDifficulty"].firstMatch.label.contains("Hard"))
        XCTAssertTrue(app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH 'tile' AND label CONTAINS '2 hits remaining'")).count >= 2)
        attach("build17-puzzle-hard-ice-rope-mud");try winCurrentLevel();attach("build17-win-and-bomb-kit")
        XCTAssertTrue(app.descendants(matching:.any)["nextStartKit"].firstMatch.label.contains("Bomb"));app.buttons["nextLevel"].tap()
        XCTAssertEqual(app.descendants(matching:.any)["loadoutSlots"].firstMatch.label,"1 of 3 starting power-up slots selected")
        app.buttons["confirmLoadout"].tap();XCTAssertTrue(app.buttons["tile9"].waitForExistence(timeout:5));XCTAssertTrue(app.buttons["tile9"].label.hasPrefix("Bomb,"))
    }
    func testOneShotUsesOneRealWinningSwipeWithNoInventoryCharge() throws {
        app.terminate();app.launchArguments=["--uitesting","--ui-stage","30"];app.launch();XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:15));start()
        XCTAssertEqual(app.staticTexts["movesCounter"].label,"1");XCTAssertFalse(app.buttons["shuffleButton"].isEnabled);XCTAssertFalse(app.buttons["toolrainbow"].isEnabled)
        attach("build17-one-shot");try winCurrentLevel();XCTAssertTrue(app.staticTexts["winTitle"].exists);app.buttons["backToGarden"].tap();XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
    }
    func testFarmFieldsSwipeIndependentlyAndPersistOfflineHarvests() {
        app.terminate();app.launchArguments=["--uitesting","--ui-stage","10"];app.launch();XCTAssertTrue(app.buttons["openFarm"].waitForExistence(timeout:15));app.buttons["openFarm"].tap()
        for id in 0..<6 { fits(app.buttons["plot\(id)"]) }
        app.buttons["cropapple"].tap();app.buttons["plot0"].tap();XCTAssertTrue((app.buttons["plot0"].value as? String)?.contains("Moon apple") == true);app.buttons["plot0"].tap();app.buttons["plot0"].tap()
        app.buttons["croprose"].tap();app.buttons["plot1"].tap();app.buttons["plot1"].tap();attach("build17-farm-first-field-growing")
        let map=app.descendants(matching:.any)["farmRoomMap"].firstMatch;map.swipeLeft();fits(app.buttons["plot6"]);app.buttons["plot6"].tap();app.buttons["plot6"].tap();attach("build17-farm-second-field")
        map.swipeLeft();fits(app.buttons["plot12"]);app.buttons["plot12"].tap();app.buttons["plot12"].tap();attach("build17-farm-third-field")
        map.swipeRight();XCTAssertTrue(app.buttons["plot6"].label.contains("growing") || app.buttons["plot6"].label.contains("ready"))
        app.buttons["returnWorld"].tap();app.terminate();app.launchArguments=["--uitesting","--keep-progress"];app.launch();XCTAssertTrue(app.buttons["openFarm"].waitForExistence(timeout:15));app.buttons["openFarm"].tap()
        let ready=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in self.app.buttons["plot0"].label.contains("ready") && self.app.buttons["plot1"].label.contains("ready") },object:app)
        XCTAssertEqual(XCTWaiter.wait(for:[ready],timeout:35),.completed);attach("build17-farm-ripe-orchard")
        app.buttons["plot0"].doubleTap();XCTAssertTrue(app.buttons["plot0"].label.contains("harvest collected"));app.buttons["plot1"].tap()
        XCTAssertEqual(Int(app.buttons["openShop"].label.components(separatedBy:CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }.joined()),1325,"Nine completed QA stages and two harvests must have exactly 1325 coins, independent of accessibility digit grouping")
        attach("build17-farm-sickle-harvest");map.swipeLeft();XCTAssertTrue(app.buttons["plot6"].label.contains("ready"));map.swipeLeft();let lastReady=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in self.app.buttons["plot12"].label.contains("ready") },object:app);XCTAssertEqual(XCTWaiter.wait(for:[lastReady],timeout:20),.completed)
    }
    func testFarmLockedFieldHasNoPlantingBypassAndShedIsSeparate() {
        app.buttons["openFarm"].tap();app.descendants(matching:.any)["farmRoomMap"].firstMatch.swipeLeft()
        XCTAssertTrue(app.descendants(matching:.any)["lockedFarmField"].firstMatch.waitForExistence(timeout:5));XCTAssertFalse(app.buttons["plot6"].exists);attach("build17-farm-field-locked")
        app.buttons["openToolShed"].tap();for tool in ["bomb","tnt","mega","rainbow"] { fits(app.buttons["craft\(tool)"]) };attach("build17-tool-shed-icons")
        app.buttons["backToTerraces"].tap();XCTAssertTrue(app.descendants(matching:.any)["lockedFarmField"].firstMatch.exists)
    }
    func testPlayerAccountAndSuppliesKeepGuestSaveAndNoRealPurchase() {
        app.buttons["settings"].tap();app.buttons["playerAccount"].tap();fits(app.buttons["connectGameCenter"])
        XCTAssertTrue(app.staticTexts["saveStatus"].label.contains("Saved on this device"));attach("build17-apple-save-settings")
        app.navigationBars.buttons["Settings"].tap();app.navigationBars.buttons["Done"].tap();app.buttons["openShop"].tap();fits(app.buttons["explorePacks"]);attach("build17-optional-supplies")
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
            let frozen = app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH 'tile' AND (label CONTAINS 'frozen' OR label CONTAINS 'hits remaining')")).firstMatch
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
            if !app.buttons["tile\(key)"].isHittable {
                attach("highlight-hit-region-failure")
                print(app.debugDescription)
            }
            app.buttons["tile\(key)"].press(forDuration:0.1,thenDragTo:app.buttons["tile\(other)"])
            settle()
            if !app.staticTexts["winTitle"].exists { XCTAssertEqual(Int(app.staticTexts["movesCounter"].label),turns-1,"The hinted swipe must swap pieces and spend exactly one turn") }
        }
        XCTFail("Circuit never completed")
    }
    func testRallyCanFinishByFollowingItsVisibleCoinGuide() {
        func walletCoins()->Int { Int(app.buttons["openShop"].label.components(separatedBy:CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }.joined()) ?? -1 }
        let before=walletCoins()
        app.buttons["openRace"].tap();app.buttons["startRace"].tap()
        let road=app.descendants(matching:.any)["raceTrack"].firstMatch, guide=app.descendants(matching:.any)["raceTrafficGuide"].firstMatch
        XCTAssertTrue(road.waitForExistence(timeout:5))
        let deadline=Date().addingTimeInterval(40)
        while Date() < deadline && !app.staticTexts["raceResult"].exists {
            guard let text=guide.value as? String,let target=Int(text.components(separatedBy:"Coin: lane ").last?.prefix(1) ?? ""),let current=Int((road.value as? String ?? "").dropFirst(5).prefix(1)) else { continue }
            if target < current { road.swipeLeft() } else if target > current { road.swipeRight() }
        }
        XCTAssertEqual(app.staticTexts["raceResult"].label,"Delivery complete!");attach("build17-rally-real-delivery")
        XCTAssertFalse(app.descendants(matching:.any)["raceCollectedCoins"].firstMatch.label.hasPrefix("0 coins"))
        let collected=Int(app.descendants(matching:.any)["raceCollectedCoins"].firstMatch.label.components(separatedBy:CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }.joined()) ?? -1
        XCTAssertGreaterThan(collected,0)
        app.buttons["raceDone"].tap();XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
        XCTAssertEqual(walletCoins(),before+60+collected*10+40,"The completed route banks its real pickups and exactly one starting-cargo bonus")
        XCTAssertTrue((app.buttons["openRace"].value as? String ?? "").hasPrefix("1 successful deliveries"))
        app.buttons["openFarm"].tap();app.descendants(matching:.any)["farmRoomMap"].firstMatch.swipeLeft()
        let lock=app.descendants(matching:.any)["lockedFarmField"].firstMatch
        XCTAssertTrue(lock.waitForExistence(timeout:5));XCTAssertTrue(lock.label.contains("1 wins so far"))
        attach("build20-one-delivery-one-farm-win");app.buttons["returnWorld"].tap()
        let banked=walletCoins();app.terminate();app.launchArguments=["--uitesting","--keep-progress"];app.launch()
        XCTAssertTrue(app.buttons["openRace"].waitForExistence(timeout:15));XCTAssertEqual(walletCoins(),banked)
        XCTAssertTrue((app.buttons["openRace"].value as? String ?? "").hasPrefix("1 successful deliveries"))
        attach("build20-rally-single-reward-after-relaunch")
    }
    func testRallyTrafficGuideUpdatesAndPauseKeepsRouteStable() {
        XCUIDevice.shared.orientation = .portrait
        app.buttons["openRace"].tap(); app.buttons["startRace"].tap()
        let road = app.descendants(matching: .any)["raceTrack"].firstMatch
        let guide = app.descendants(matching: .any)["raceTrafficGuide"].firstMatch
        XCTAssertTrue(road.waitForExistence(timeout: 5))
        app.buttons["pauseRace"].tap()
        XCTAssertTrue(app.buttons["resumeRace"].waitForExistence(timeout: 5))
        XCTAssertTrue(guide.exists)
        let preview = guide.value as? String
        XCTAssertTrue(preview?.contains("Next barrier: lane") == true)
        XCTAssertTrue(preview?.contains("Coin: lane") == true)
        XCTAssertTrue((road.value as? String)?.contains(preview ?? "missing preview") == true)
        let distance = app.staticTexts["raceDistance"].label
        let shield = app.descendants(matching: .any)["raceShield"].firstMatch.label
        road.swipeLeft(); Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(guide.value as? String, preview)
        XCTAssertEqual(app.staticTexts["raceDistance"].label, distance)
        XCTAssertEqual(app.descendants(matching: .any)["raceShield"].firstMatch.label, shield)
        XCTAssertTrue((road.value as? String)?.hasPrefix("Lane 2 of 3, center.") == true)
        attach("build14-rally-traffic-paused")
        app.buttons["resumeRace"].tap(); road.swipeLeft()
        XCTAssertTrue((road.value as? String)?.hasPrefix("Lane 1 of 3, left.") == true)
        road.swipeUp()
        XCTAssertTrue((road.value as? String)?.hasPrefix("Lane 1 of 3, left.") == true)
        let changed = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in (guide.value as? String) != preview }, object: guide)
        XCTAssertEqual(XCTWaiter.wait(for: [changed], timeout: 8), .completed)
        XCTAssertTrue((road.value as? String)?.contains(guide.value as? String ?? "missing preview") == true)
        attach("build14-rally-traffic-driving")
        app.buttons["pauseRace"].tap()
        if app.frame.width > 600 {
            XCUIDevice.shared.orientation = .landscapeLeft
            XCTAssertTrue(app.frame.insetBy(dx: -1, dy: -1).contains(guide.frame))
            XCTAssertGreaterThan(road.frame.height, 100)
            attach("build14-ipad-rally-traffic-landscape")
            XCUIDevice.shared.orientation = .portrait
        }
        app.buttons["leaveRace"].tap()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
    }
    func testRallyTrafficGuideAndControlsFitAccessibilityTextSize() {
        app.terminate()
        app.launchArguments = ["--uitesting", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["openRace"].waitForExistence(timeout: 15))
        app.buttons["openRace"].tap()
        XCTAssertTrue(app.buttons["startRace"].isHittable)
        XCTAssertTrue(app.frame.insetBy(dx: -1, dy: -1).contains(app.buttons["startRace"].frame))
        attach("build14-rally-lobby-accessibility-text")
        app.buttons["startRace"].tap()
        let road = app.descendants(matching: .any)["raceTrack"].firstMatch
        let guide = app.descendants(matching: .any)["raceTrafficGuide"].firstMatch
        XCTAssertTrue(road.waitForExistence(timeout: 5))
        app.buttons["pauseRace"].tap()
        for element in [guide, app.buttons["pauseRace"], app.buttons["resumeRace"], app.buttons["leaveRace"]] {
            XCTAssertTrue(element.isHittable)
            XCTAssertTrue(app.frame.insetBy(dx: -1, dy: -1).contains(element.frame))
        }
        XCTAssertGreaterThan(road.frame.height, 100)
        XCTAssertFalse(app.buttons["resumeRace"].frame.intersects(guide.frame))
        XCTAssertEqual(app.scrollViews.count, 0)
        attach("build14-rally-traffic-accessibility-text")
        app.buttons["leaveRace"].tap()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout: 5))
    }
    func testJournalLargeTextKeepsEveryRewardAndPowerReachable() throws {
        app.terminate()
        app.launchArguments = ["--uitesting", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityM"]
        app.launch()
        XCTAssertTrue(app.buttons["openTasks"].waitForExistence(timeout:15))
        app.buttons["openTasks"].tap()
        let journal = app.descendants(matching:.any)["journalPages"].firstMatch
        let instructions = app.staticTexts["journalInstructions"]
        XCTAssertTrue(instructions.waitForExistence(timeout:5))
        XCTAssertGreaterThan(instructions.frame.height,80,"Accessibility text must wrap, not shrink into a clipped line")
        let entries = ["journalTask_harvest1","journalTask_harvest3","journalTask_delivery1","journalTask_delivery3","journalTask_circuit3","journalTask_blast3","journalPower_bomb","journalPower_tnt","journalPower_mega","journalPower_rainbow"]
        for (index,id) in entries.enumerated() {
            let entry = app.descendants(matching:.any)[id].firstMatch
            XCTAssertTrue(entry.waitForExistence(timeout:5),"Every journal entry must be reachable by a real swipe")
            XCTAssertTrue(app.frame.insetBy(dx:-1,dy:-1).contains(entry.frame),"Large text must fit: \(entry.frame)")
            XCTAssertLessThanOrEqual(instructions.frame.maxY,entry.frame.minY+1)
            XCTAssertLessThanOrEqual(entry.frame.maxY,app.buttons["journalPatterns"].frame.minY+1,"Cards must not overlap page controls")
            XCTAssertTrue(app.buttons["journalPatterns"].isHittable)
            XCTAssertEqual(app.scrollViews.count,0,"The journal pages must fit without vertical scrolling")
            if index == 0 || index == 8 { attach("build8-journal-large-\(index)") }
            if index < entries.count-1 { journal.swipeLeft() }
        }
        let pageCounter = app.descendants(matching:.any)["journalPageCount"].firstMatch
        let lastPage = pageCounter.value as? String
        XCTAssertEqual(lastPage,"Page 10 of 10")
        journal.swipeLeft()
        XCTAssertEqual(pageCounter.value as? String,lastPage,"Swiping past the last page must stay there")
        app.buttons["journalPatterns"].tap()
        XCTAssertTrue(app.buttons["claim_harvest1"].exists)
        journal.swipeRight()
        XCTAssertTrue(app.buttons["claim_harvest1"].exists,"Swiping before the first page must stay there")
        app.navigationBars.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
    }

}

@MainActor final class IPadReleaseUITests:XCTestCase {
    func testEightActivitiesFarmAndPuzzleFitBothTabletOrientations() throws {
        let app=XCUIApplication();continueAfterFailure=false;XCUIDevice.shared.orientation = .portrait
        app.launchArguments=["--uitesting","--keep-progress"];app.launch();try XCTSkipIf(app.frame.width < 700,"Dedicated iPad QA only")
        if app.buttons["backFromPuzzle"].waitForExistence(timeout:3) { app.buttons["backFromPuzzle"].tap();app.buttons["confirmAbandon"].tap() }
        XCTAssertTrue(app.buttons["openFarm"].waitForExistence(timeout:15))
        func fits(_ id:String) { let e=app.buttons[id];XCTAssertTrue(e.waitForExistence(timeout:5));XCTAssertTrue(e.isHittable);XCTAssertTrue(app.frame.insetBy(dx:-1,dy:-1).contains(e.frame),"\(id): \(e.frame)");XCTAssertGreaterThanOrEqual(e.frame.height,44-1e-6) }
        func shot(_ name:String) { let a=XCTAttachment(screenshot:XCUIScreen.main.screenshot());a.name=name;a.lifetime = .keepAlways;add(a) }
        for orientation in [UIDeviceOrientation.portrait,.landscapeLeft] {
            XCUIDevice.shared.orientation=orientation
            let name=orientation == .portrait ? "portrait" : "landscape"
            let rotated=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in orientation == .portrait ? app.frame.height > app.frame.width : app.frame.width > app.frame.height },object:app)
            XCTAssertEqual(XCTWaiter.wait(for:[rotated],timeout:15),.completed)
            for id in ["openBloom","openFarm","openRace","openCanal","openFireflies","openWindmill","openObservatory","openShuttle","playLevel"] { fits(id) };shot("build17-ipad-island-\(name)")
            app.buttons["openFarm"].tap();for id in 0..<6 { fits("plot\(id)") };shot("build17-ipad-farm-\(name)");app.buttons["returnWorld"].tap()
            app.buttons["openRace"].tap();fits("startRace");shot("build17-ipad-rally-lobby-\(name)");app.buttons["startRace"].tap();app.buttons["pauseRace"].tap();fits("resumeRace");shot("build17-ipad-rally-road-\(name)");app.buttons["leaveRace"].tap()
            for room in ["Canal","Fireflies","Windmill","Observatory","Shuttle"] {
                app.buttons["open\(room)"].tap();fits("activityExit")
                if room == "Shuttle" { for id in 0..<12 { fits("shuttleSeat\(id)");fits("passenger\(id)") } }
                shot("build17-ipad-\(room.lowercased())-\(name)");app.buttons["activityExit"].tap()
            }
            app.buttons["playLevel"].tap();fits("confirmLoadout");shot("build17-ipad-loadout-\(name)");app.buttons["confirmLoadout"].tap();fits("tile0");fits("backFromPuzzle");shot("build17-ipad-puzzle-\(name)")
            app.buttons["backFromPuzzle"].tap();app.buttons["confirmAbandon"].tap()
        }
        XCUIDevice.shared.orientation = .portrait
    }
}
