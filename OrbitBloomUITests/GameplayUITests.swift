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
    func attach(_ name:String) {
        // Capture after the 200-ms room crossfade, rather than blending two destinations.
        Thread.sleep(forTimeInterval:0.5)
        let shot = XCTAttachment(screenshot:app.screenshot())
        shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    func confirmLeave() {
        app.buttons["leaveLevel"].tap()
        XCTAssertTrue(app.buttons["confirmAbandon"].waitForExistence(timeout:5))
        app.buttons["confirmAbandon"].tap()
    }
    func testFullGardenViewportAndLargePuzzleKeepControlsReachable() throws {
        let map=app.descendants(matching:.any)["gardenMap"].firstMatch
        XCTAssertGreaterThanOrEqual(map.frame.width,app.frame.width*0.95)
        XCTAssertGreaterThanOrEqual(map.frame.height,app.frame.height*0.85)
        let controls=["openTasks","openFarm","openRace","openIslandHub","openWorldEvents","openRoomRecords","restoreProject","playLevel"]
        for id in controls {
            let button=app.buttons[id]
            XCTAssertTrue(button.isHittable,id)
            XCTAssertTrue(app.frame.insetBy(dx:-1,dy:-1).contains(button.frame),id)
            XCTAssertGreaterThanOrEqual(button.frame.height+0.000001,44,id)
        }
        XCTAssertFalse(app.buttons["openFarm"].frame.intersects(app.buttons["openRace"].frame))
        attach("build12-01-connected-garden")
        map.swipeLeft()
        XCTAssertEqual(app.staticTexts["islandRange"].label,"11–20")
        XCTAssertFalse(app.buttons["level11"].isEnabled)
        XCTAssertFalse(app.buttons["playLevel"].exists)
        attach("build12-02-next-district-locked")
        app.buttons["openCurrentIsland"].tap(); app.buttons["playLevel"].tap()
        let board=app.descendants(matching:.any)["puzzleBoard"].firstMatch
        XCTAssertGreaterThanOrEqual(board.frame.width,app.frame.width*0.90)
        let tools=["hintButton","shuffleButton","burstButton","toolbomb","tooltnt","toolmega","toolrainbow","pauseGame","backFromPuzzle"]
        for id in tools {
            let button=app.buttons[id]
            XCTAssertTrue(button.isHittable,id)
            XCTAssertTrue(app.frame.insetBy(dx:-1,dy:-1).contains(button.frame),id)
            XCTAssertGreaterThanOrEqual(button.frame.height+0.000001,44,id)
        }
        for key in 0..<49 {
            let tile=app.buttons["tile\(key)"]
            XCTAssertTrue(tile.isHittable)
            XCTAssertGreaterThanOrEqual(tile.frame.width+0.000001,44)
        }
        XCTAssertEqual(app.scrollViews.count,0)
        attach("build12-03-large-puzzle")
        try winCurrentLevel(); app.buttons["backToGarden"].tap()
        XCTAssertTrue(app.buttons["level2"].isEnabled)
        XCTAssertFalse(app.buttons["level3"].isEnabled)
        attach("build12-04-first-clear-connected-garden")
    }
    func testSeparateActivityRoomMapsHaveClearEntrancesExitsAndSavedProgress() throws {
        func fits(_ element:XCUIElement) {
            XCTAssertTrue(element.waitForExistence(timeout:10))
            XCTAssertTrue(element.isHittable)
            XCTAssertTrue(app.frame.insetBy(dx:-1,dy:-1).contains(element.frame),"Room control must fit: \(element.frame)")
            XCTAssertGreaterThanOrEqual(element.frame.height,44)
        }
        let farm=app.buttons["openFarm"], rally=app.buttons["openRace"]
        fits(farm); fits(rally)
        XCTAssertTrue(farm.label.contains("Farm room")); XCTAssertTrue(rally.label.contains("Rally room"))
        XCTAssertFalse(farm.frame.intersects(rally.frame),"Each room needs a distinct entrance")
        attach("build10-room-entrances")
        farm.tap()
        let terraceMap=app.descendants(matching:.any)["farmRoomMap"].firstMatch
        XCTAssertTrue(terraceMap.waitForExistence(timeout:5))
        XCTAssertFalse(app.descendants(matching:.any)["rallyRoomMap"].firstMatch.exists)
        for key in 0..<6 { fits(app.buttons["plot\(key)"]) }
        app.buttons["plot0"].tap()
        XCTAssertFalse(app.buttons["plot0"].label.contains("empty"))
        fits(app.buttons["returnWorld"]); XCTAssertTrue(app.buttons["returnWorld"].label.contains("Exit Farm room"))
        let plantingMessage=app.staticTexts["Coral rose planted. Tap to water and grow faster."]
        let toastCleared=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in !plantingMessage.exists },object:app)
        XCTAssertEqual(XCTWaiter.wait(for:[toastCleared],timeout:5),.completed)
        attach("build10-farm-room-map")
        app.buttons["returnWorld"].tap(); fits(rally); rally.tap()
        let route=app.descendants(matching:.any)["rallyRoomMap"].firstMatch
        XCTAssertTrue(route.waitForExistence(timeout:5)); XCTAssertTrue(route.label.contains("Garage"))
        XCTAssertFalse(terraceMap.exists)
        fits(app.buttons["startRace"]); fits(app.buttons["returnWorld"])
        XCTAssertTrue(app.buttons["returnWorld"].label.contains("Exit Rally room"))
        attach("build10-rally-room-map")
        app.buttons["startRace"].tap()
        let road=app.descendants(matching:.any)["raceTrack"].firstMatch
        XCTAssertTrue(road.waitForExistence(timeout:5)); road.swipeLeft()
        XCTAssertEqual(road.value as? String,"Lane 1 of 3")
        app.buttons["pauseRace"].tap(); fits(app.buttons["leaveRace"])
        XCTAssertTrue(app.buttons["leaveRace"].label.contains("Exit rally room"))
        attach("build10-rally-exit")
        app.buttons["leaveRace"].tap(); fits(farm); farm.tap()
        XCTAssertFalse(app.buttons["plot0"].label.contains("empty"),"Leaving a room must retain its planted crop")
        app.buttons["openToolShed"].tap(); fits(app.buttons["craftrainbow"])
        app.buttons["returnWorld"].tap()
        app.terminate(); app.launchArguments=["--uitesting","--keep-progress"]; app.launch()
        fits(farm); farm.tap(); XCTAssertFalse(app.buttons["plot0"].label.contains("empty"))
        app.buttons["returnWorld"].tap()
        app.terminate(); app.launchArguments=["--uitesting","-UIPreferredContentSizeCategoryName","UICTContentSizeCategoryAccessibilityM"]; app.launch()
        fits(farm); fits(rally); XCTAssertFalse(farm.frame.intersects(rally.frame))
        XCTAssertEqual(app.scrollViews.count,0)
        attach("build10-large-room-entrances")
        rally.tap(); fits(app.buttons["returnWorld"]); fits(app.buttons["startRace"])
        XCTAssertTrue(route.exists); XCTAssertEqual(app.scrollViews.count,0)
        attach("build10-large-rally-room")
        app.buttons["returnWorld"].tap(); fits(farm); farm.tap()
        let largePlots=(0..<6).map { app.buttons["plot\($0)"] }
        for plot in largePlots { fits(plot) }
        for row in 0..<2 {
            XCTAssertFalse(largePlots[row*2].frame.intersects(largePlots[row*2+2].frame),"Large-text terrace controls must not overlap")
            XCTAssertFalse(largePlots[row*2+1].frame.intersects(largePlots[row*2+3].frame),"Large-text terrace controls must not overlap")
        }
        fits(app.buttons["openToolShed"]); fits(app.buttons["returnWorld"])
        attach("build10-large-farm-room")
    }
    func testBackCancelAbandonAndRestartChargeExactlyOneLifePerAttempt() throws {
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
        app.buttons["playLevel"].tap()
        XCTAssertTrue(app.buttons["backFromPuzzle"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("4 lives"))
        let moves = app.staticTexts["movesCounter"].label
        app.buttons["backFromPuzzle"].tap()
        XCTAssertTrue(app.buttons["confirmAbandon"].waitForExistence(timeout:5))
        XCTAssertTrue(app.staticTexts["abandonExplanation"].label.contains("charge another"))
        attach("build9-abandon-confirmation")
        app.buttons["cancelAbandon"].tap()
        XCTAssertEqual(app.staticTexts["movesCounter"].label,moves)
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("4 lives"))
        app.buttons["pauseGame"].tap(); confirmLeave()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("4 lives"))
        app.terminate(); app.launchArguments = ["--uitesting","--keep-progress"]; app.launch()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:10))
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("4 lives"))
        app.buttons["playLevel"].tap(); app.buttons["pauseGame"].tap()
        app.buttons["restartLevel"].tap()
        XCTAssertTrue(app.buttons["confirmRestart"].waitForExistence(timeout:5))
        app.buttons["cancelAbandon"].tap()
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("3 lives"))
        app.buttons["pauseGame"].tap(); app.buttons["restartLevel"].tap()
        app.buttons["confirmRestart"].tap()
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("2 lives"))
        app.buttons["backFromPuzzle"].tap(); app.buttons["confirmAbandon"].tap()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("2 lives"))
    }
    func testOneShotDifficultyUsesARealWinningSwipeAndReturnsTheLife() throws {
        app.terminate(); app.launchArguments = ["--uitesting","--ui-stage","30"]; app.launch()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:15))
        let badge = app.descendants(matching:.any)["selectedDifficulty"].firstMatch
        XCTAssertTrue(badge.label.contains("One shot"))
        attach("build9-one-shot-island")
        app.buttons["playLevel"].tap()
        XCTAssertEqual(app.staticTexts["movesCounter"].label,"1")
        XCTAssertTrue(app.descendants(matching:.any)["puzzleDifficulty"].firstMatch.label.contains("ultra super hard"))
        XCTAssertFalse(app.buttons["burstButton"].isEnabled)
        XCTAssertFalse(app.buttons["shuffleButton"].isEnabled)
        XCTAssertFalse(app.buttons["toolrainbow"].isEnabled)
        attach("build9-one-shot-puzzle")
        try winCurrentLevel()
        attach("build9-one-shot-victory")
        app.buttons["backToGarden"].tap()
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
        XCTAssertTrue(app.buttons["level31"].isEnabled)
        XCTAssertTrue(app.descendants(matching:.any)["selectedDifficulty"].firstMatch.label.contains("Simple"))
        app.descendants(matching:.any)["gardenMap"].firstMatch.swipeRight()
        app.buttons["level29"].tap()
        XCTAssertTrue(app.descendants(matching:.any)["selectedDifficulty"].firstMatch.label.contains("Super hard"))
        app.buttons["level28"].tap()
        XCTAssertTrue(app.descendants(matching:.any)["selectedDifficulty"].firstMatch.label.contains("Hard"))
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
    func testPlayerAccountGuestSaveAndReturnToGameplay() throws {
        app.buttons["openFarm"].tap(); app.buttons["plot0"].tap()
        app.buttons["returnWorld"].tap(); app.buttons["settings"].tap()
        app.buttons["playerAccount"].tap()
        XCTAssertTrue(app.buttons["connectGameCenter"].waitForExistence(timeout:5))
        XCTAssertTrue(app.staticTexts["saveSummary"].label.contains("160 coins"))
        XCTAssertTrue(app.staticTexts["saveStatus"].label.contains("Saved on this device"))
        let shot = XCTAttachment(screenshot:XCUIScreen.main.screenshot()); shot.name = "v6-player-and-saved-garden"; shot.lifetime = .keepAlways; add(shot)
        app.buttons["connectGameCenter"].tap()
        XCTAssertTrue(app.staticTexts["saveStatus"].label.contains("local save is safe"))
        XCTAssertTrue(app.navigationBars.buttons["Settings"].exists)
        app.navigationBars.buttons["Settings"].tap(); app.navigationBars.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
        app.terminate(); app.launchArguments = ["--uitesting","--keep-progress"]; app.launch()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:10))
        app.buttons["openFarm"].tap()
        XCTAssertFalse(app.buttons["plot0"].label.contains("Empty"), "The planted crop must survive relaunch after visiting account settings")
    }
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
    func testIslandPagesUnlockSequentiallyAndUseInWorldNavigation() throws {
        XCTAssertEqual(app.scrollViews.count,0,"The game map must fit without website scrolling")
        XCTAssertTrue(app.buttons["level1"].isEnabled)
        XCTAssertFalse(app.buttons["level2"].isEnabled)
        XCTAssertEqual(app.staticTexts["islandRange"].label,"1–10")
        attach("v4-01-living-island")
        app.descendants(matching:.any)["gardenMap"].swipeLeft()
        XCTAssertEqual(app.staticTexts["islandRange"].label,"11–20")
        XCTAssertFalse(app.buttons["level11"].isEnabled)
        XCTAssertFalse(app.buttons["playLevel"].exists,"A locked island must not offer a start bypass")
        attach("v4-02-locked-island")
        app.buttons["openCurrentIsland"].tap()
        XCTAssertEqual(app.staticTexts["islandRange"].label,"1–10")
        app.buttons["playLevel"].tap()
        XCTAssertEqual(app.staticTexts["movesCounter"].label,"10")
        XCTAssertEqual(app.scrollViews.count,0,"Puzzle swipes must never scroll the screen")
        try winCurrentLevel(); app.buttons["backToGarden"].tap()
        XCTAssertTrue(app.buttons["level2"].isEnabled)
        XCTAssertFalse(app.buttons["level3"].isEnabled)
        app.buttons["openTasks"].tap(); app.buttons["journalPatterns"].tap()
        XCTAssertTrue(app.staticTexts["Patterns make power."].waitForExistence(timeout:5))
        let mega = app.descendants(matching:.any)["journalPower_mega"].firstMatch
        if !mega.exists { app.descendants(matching:.any)["journalPages"].firstMatch.swipeLeft() }
        XCTAssertTrue(mega.waitForExistence(timeout:5))
        XCTAssertEqual(app.scrollViews.count,0)
        attach("v5-19-power-patterns"); app.navigationBars.buttons["Done"].tap()
        app.buttons["openFarm"].tap()
        XCTAssertTrue(app.buttons["plot5"].isHittable,"All six farm plots fit in the scene")
        XCTAssertEqual(app.scrollViews.count,0)
        attach("v4-03-farm-terraces")
        app.descendants(matching:.any)["farmScene"].swipeLeft()
        XCTAssertTrue(app.buttons["craftrainbow"].waitForExistence(timeout:5))
        attach("v4-04-crafting-shed")
        app.buttons["returnWorld"].tap()
        XCTAssertTrue(app.buttons["openRace"].isHittable)
    }
    func testCompleteConnectedCampaignAndRestoreWorld() throws {
        attach("v2-01-world")
        app.buttons["playLevel"].tap(); XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout:5)); attach("v2-02-botanical-circuit")
        try winCurrentLevel(); attach("v2-03-victory")
        app.buttons["nextLevel"].tap()
        XCTAssertTrue(app.buttons["tile25"].isHittable,"Advancing must restore board hit regions after the victory overlay")
        try winCurrentLevel(); app.buttons["backToGarden"].tap()
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
        app.buttons["openFarm"].tap(); attach("v2-04-farm")
        for id in [0,1] {
            let plot = app.buttons["plot\(id)"]
            plot.tap()
            for _ in 0..<3 { if !plot.label.contains("ready") { plot.tap() } }
            XCTAssertTrue(plot.label.contains("ready")); plot.tap()
        }
        XCTAssertTrue(app.staticTexts["farmTotals"].label.contains("Harvested: 2"))
        app.buttons["returnWorld"].tap(); app.buttons["openTasks"].tap()
        let reward = app.buttons["claim_harvest1"]; XCTAssertTrue(reward.waitForExistence(timeout:5))
        attach("product-field-tasks")
        reward.tap(); XCTAssertFalse(reward.isEnabled)
        attach("v3-15-field-tasks"); app.navigationBars.buttons["Done"].tap(); app.buttons["openFarm"].tap()
        app.buttons["openToolShed"].tap()
        app.buttons["craftbomb"].tap(); attach("v2-05-tool-shed")
        app.terminate(); app.launchArguments = ["--uitesting","--keep-progress"]; app.launch(); app.buttons["openFarm"].tap()
        XCTAssertTrue(app.staticTexts["farmTotals"].waitForExistence(timeout:5)); XCTAssertTrue(app.staticTexts["farmTotals"].label.contains("Harvested: 2"))
    }
    func testPuzzleWaterReachesFarmAndCanPlantAfterRelaunch() throws {
        app.buttons["openFarm"].tap()
        let water = app.descendants(matching:.any)["farmMeterWater"]
        XCTAssertTrue(water.waitForExistence(timeout:5))
        XCTAssertEqual(water.label,"Water: 12")
        app.buttons["returnWorld"].tap(); app.buttons["playLevel"].tap()
        app.buttons["tooltnt"].tap(); app.buttons["tile24"].tap(); settle()
        if app.staticTexts["winTitle"].exists { app.buttons["backToGarden"].tap() }
        else { app.buttons["pauseGame"].tap(); confirmLeave() }
        app.buttons["openFarm"].tap()
        let amount = try XCTUnwrap(Int(water.label.replacingOccurrences(of:"Water: ",with:"")))
        XCTAssertGreaterThan(amount,12,"Collected puzzle dew must be available for planting")

        app.terminate(); app.launchArguments = ["--uitesting","--keep-progress"]; app.launch()
        XCTAssertTrue(app.buttons["openFarm"].waitForExistence(timeout:15)); app.buttons["openFarm"].tap()
        XCTAssertEqual(water.label,"Water: \(amount)")
        attach("daily-20261009-water-reward")
        app.buttons["plot0"].tap()
        XCTAssertEqual(water.label,"Water: \(amount-2)")
        XCTAssertTrue(app.buttons["plot0"].label.contains("growing"))
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
            guard let key = candidate else { app.buttons["shuffleButton"].tap(); settle(); continue }
            app.buttons["tile\(key)"].tap(); settle()
            if app.staticTexts["winTitle"].exists { app.buttons["nextLevel"].tap(); continue }
            XCTAssertGreaterThan(powers.count,0,"A real formation must create a power on the board")
            attach("v3-16-board-power")
            let count = powers.count, turns = app.staticTexts["movesCounter"].label
            app.buttons["shuffleButton"].tap()
            settle()
            XCTAssertEqual(powers.count,count,"Shuffling must preserve on-board powers")
            XCTAssertEqual(app.staticTexts["movesCounter"].label,turns)
            powers.firstMatch.tap(); settle()
            if !app.staticTexts["winTitle"].exists { XCTAssertEqual(Int(app.staticTexts["movesCounter"].label),Int(turns)!-1) }
            return
        }
        XCTFail("Power formation needs a playable board before victory")
    }
    func testDeliveryRaceWithRealSteeringAndReward() {
        app.buttons["openRace"].tap(); attach("v2-06-race-lobby"); app.buttons["startRace"].tap()
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
        app.buttons["pauseGame"].tap(); confirmLeave(); app.buttons["openShop"].tap(); attach("v2-12-lives-and-shop")
        XCTAssertTrue(app.staticTexts["lifeTimer"].exists); XCTAssertTrue(app.buttons["refillLives"].isEnabled)
        app.buttons["refillLives"].tap(); XCTAssertFalse(app.buttons["refillLives"].isEnabled)
        app.buttons["explorePacks"].tap(); attach("v2-13-coin-packs")
        for product in ["coins400","coins1500","coins3000","coins7000","lives5","starter"] {
            XCTAssertTrue(app.buttons["buy_com.orbitbloom.\(product)"].waitForExistence(timeout:5),"Every pack must be reachable by swiping")
            attach("app-store-review-\(product)")
            if product != "starter" { app.descendants(matching:.any)["suppliesScene"].swipeLeft() }
        }
        attach("v2-14-starter-bundle")
        app.buttons["returnWorld"].tap(); app.buttons["openFarm"].tap(); XCTAssertTrue(app.buttons["plot0"].waitForExistence(timeout:5))
    }
}

// Uses the dedicated iPad release device without resetting its saved progress.
@MainActor final class IPadReleaseUITests: XCTestCase {
    func testFullGardenAndPuzzleRailsFitBothOrientations() throws {
        let app=XCUIApplication(); app.launchArguments=["--uitesting","--keep-progress"]
        XCUIDevice.shared.orientation = .portrait; app.launch()
        defer { XCUIDevice.shared.orientation = .portrait; app.terminate() }
        try XCTSkipIf(app.frame.width < 700,"Run on iPad")
        continueAfterFailure=false
        // Keep-progress QA can resume an attempt after an interrupted layout run.
        // Return through the real abandon flow rather than resetting its save.
        let back=app.buttons["backFromPuzzle"]
        if back.exists {
            back.tap()
            XCTAssertTrue(app.buttons["confirmAbandon"].waitForExistence(timeout:5))
            app.buttons["confirmAbandon"].tap()
        }
        func fits(_ id:String) {
            let control=app.buttons[id]
            XCTAssertTrue(control.exists || control.waitForExistence(timeout:15)); XCTAssertTrue(control.isHittable,id)
            XCTAssertTrue(app.frame.insetBy(dx:-1,dy:-1).contains(control.frame),"\(id): \(control.frame)")
            XCTAssertGreaterThanOrEqual(control.frame.height+0.000001,44)
        }
        func capture(_ name:String) {
            let shot=XCTAttachment(data:XCUIScreen.main.screenshot().pngRepresentation,uniformTypeIdentifier:"public.png")
            shot.name=name; shot.lifetime = .keepAlways; add(shot)
        }
        fits("playLevel"); fits("openFarm"); fits("openRace"); capture("build12-ipad-01-garden-portrait")
        let map=app.descendants(matching:.any)["gardenMap"].firstMatch
        XCTAssertGreaterThanOrEqual(map.frame.width,app.frame.width*0.95)
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.wait(for:.runningForeground,timeout:5))
        let rotated=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.width > app.frame.height },object:app)
        XCTAssertEqual(XCTWaiter.wait(for:[rotated],timeout:15),.completed)
        fits("playLevel"); fits("openFarm"); fits("openRace"); capture("build12-ipad-02-garden-landscape")
        app.buttons["playLevel"].tap()
        for id in ["toolbomb","tooltnt","toolmega","toolrainbow","hintButton","shuffleButton","burstButton","pauseGame","backFromPuzzle"] { fits(id) }
        let board=app.descendants(matching:.any)["puzzleBoard"].firstMatch
        XCTAssertGreaterThan(board.frame.width,600,"The landscape board must exceed the former 650-point total-column layout")
        for key in 0..<49 { fits("tile\(key)") }
        capture("build12-ipad-03-puzzle-landscape")
        XCUIDevice.shared.orientation = .portrait
        let portrait=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.height > app.frame.width },object:app)
        XCTAssertEqual(XCTWaiter.wait(for:[portrait],timeout:15),.completed)
        for id in ["toolbomb","toolrainbow","hintButton","pauseGame"] { fits(id) }
        for key in 0..<49 { fits("tile\(key)") }
        capture("build12-ipad-04-puzzle-portrait")
        app.buttons["backFromPuzzle"].tap(); fits("cancelAbandon"); app.buttons["cancelAbandon"].tap()
        fits("backFromPuzzle"); app.buttons["backFromPuzzle"].tap(); fits("confirmAbandon"); app.buttons["confirmAbandon"].tap(); fits("playLevel")
        XCTAssertEqual(app.scrollViews.count,0)
    }
    func testPortraitAndLandscapeReleaseScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--keep-progress"]
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        defer { XCUIDevice.shared.orientation = .portrait; app.terminate() }
        try XCTSkipIf(app.frame.width < 700, "Run this release layout check on an iPad")
        continueAfterFailure = false
        func capture(_ name: String) {
            // Materialize the frame before later controls change the live scene.
            let shot = XCTAttachment(data: XCUIScreen.main.screenshot().pngRepresentation, uniformTypeIdentifier: "public.png")
            shot.name = name; shot.lifetime = .keepAlways; add(shot)
        }
        func fits(_ element: XCUIElement) {
            if !element.exists { XCTAssertTrue(element.waitForExistence(timeout: 15)) }
            XCTAssertTrue(element.isHittable, "\(element.identifier) must be reachable")
            XCTAssertTrue(app.frame.insetBy(dx: -1, dy: -1).contains(element.frame), "\(element.identifier) must fit on screen: \(element.frame)")
        }
        fits(app.buttons["playLevel"]); fits(app.buttons["openFarm"])
        XCTAssertEqual(app.scrollViews.count, 0)
        capture("ipad-01-world")
        app.buttons["openFarm"].tap()
        for key in 0..<6 { fits(app.buttons["plot\(key)"]) }
        capture("ipad-02-farm")
        XCTAssertTrue(app.descendants(matching:.any)["farmRoomMap"].firstMatch.exists)
        fits(app.buttons["returnWorld"])
        XCUIDevice.shared.orientation = .landscapeLeft
        let farmLandscape = XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.width > app.frame.height },object:app)
        XCTAssertEqual(XCTWaiter.wait(for:[farmLandscape],timeout:15),.completed)
        for key in 0..<6 { fits(app.buttons["plot\(key)"]) }
        fits(app.buttons["returnWorld"]); capture("build10-ipad-farm-landscape")
        XCUIDevice.shared.orientation = .portrait
        let farmPortrait = XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.height > app.frame.width },object:app)
        XCTAssertEqual(XCTWaiter.wait(for:[farmPortrait],timeout:15),.completed)
        app.descendants(matching: .any)["farmScene"].swipeLeft()
        fits(app.buttons["craftrainbow"]); capture("ipad-03-crafting")
        app.buttons["returnWorld"].tap(); app.buttons["openRace"].tap()
        XCTAssertTrue(app.descendants(matching:.any)["rallyRoomMap"].firstMatch.exists)
        fits(app.buttons["startRace"]); capture("ipad-04-rally-lobby")
        XCUIDevice.shared.orientation = .landscapeLeft
        let rallyLandscape = XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.width > app.frame.height },object:app)
        XCTAssertEqual(XCTWaiter.wait(for:[rallyLandscape],timeout:15),.completed)
        fits(app.buttons["returnWorld"]); fits(app.buttons["startRace"])
        fits(app.descendants(matching:.any)["rallyRoomMap"].firstMatch)
        capture("build10-ipad-rally-landscape")
        XCUIDevice.shared.orientation = .portrait
        let rallyPortrait = XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.height > app.frame.width },object:app)
        XCTAssertEqual(XCTWaiter.wait(for:[rallyPortrait],timeout:15),.completed)
        app.buttons["startRace"].tap()
        let road = app.descendants(matching: .any)["raceTrack"]
        fits(road); road.swipeLeft()
        XCTAssertEqual(road.value as? String, "Lane 1 of 3", "The iPad road must respond to actual swipe steering")
        XCTAssertEqual(app.buttons["pauseRace"].label, "Pause race")
        capture("ipad-10-rally-road")
        fits(app.buttons["pauseRace"]); app.buttons["pauseRace"].tap()
        app.buttons["leaveRace"].tap()
        app.buttons["openTasks"].tap()
        let instructions = app.staticTexts["journalInstructions"]
        fits(instructions)
        XCTAssertGreaterThan(instructions.frame.height,24,"The full help sentence must wrap in the iPad sheet")
        fits(app.buttons["journalPatterns"]); capture("ipad-11-field-tasks")
        app.navigationBars.buttons["Done"].tap()
        app.buttons["openRace"].tap()
        app.buttons["returnWorld"].tap(); app.buttons["openShop"].tap()
        app.buttons["explorePacks"].tap()
        fits(app.buttons["buy_com.orbitbloom.coins400"])
        capture("ipad-05-supplies")
        app.buttons["returnWorld"].tap(); app.buttons["settings"].tap()
        app.buttons["playerAccount"].tap(); fits(app.buttons["connectGameCenter"])
        fits(app.staticTexts["saveSummary"]); capture("ipad-09-player-and-saved-garden")
        app.navigationBars.buttons["Settings"].tap(); app.navigationBars.buttons["Done"].tap()
        app.buttons["playLevel"].tap()
        for key in 0..<49 { fits(app.buttons["tile\(key)"]) }
        fits(app.buttons["pauseGame"]); fits(app.buttons["toolrainbow"])
        capture("ipad-06-puzzle-portrait")
        XCUIDevice.shared.orientation = .landscapeLeft
        let landscape = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in app.frame.width > app.frame.height }, object: app)
        XCTAssertEqual(XCTWaiter.wait(for: [landscape], timeout: 15), .completed, "The app must actually rotate to landscape")
        for key in 0..<49 { fits(app.buttons["tile\(key)"]) }
        fits(app.buttons["pauseGame"]); fits(app.buttons["toolrainbow"])
        XCTAssertEqual(app.scrollViews.count, 0)
        capture("ipad-07-puzzle-landscape")
        app.buttons["pauseGame"].tap(); fits(app.buttons["leaveLevel"])
        app.buttons["leaveLevel"].tap(); fits(app.buttons["confirmAbandon"])
        capture("build9-ipad-abandon-confirmation")
        app.buttons["confirmAbandon"].tap(); fits(app.buttons["openFarm"])
        fits(app.buttons["openRace"]); fits(app.buttons["playLevel"])
        capture("ipad-08-world-landscape")
        app.buttons["openTasks"].tap()
        fits(app.staticTexts["journalInstructions"]); fits(app.buttons["journalPatterns"])
        app.buttons["journalPatterns"].tap()
        let journal = app.descendants(matching:.any)["journalPages"].firstMatch
        if !app.descendants(matching:.any)["journalPower_mega"].firstMatch.exists { journal.swipeLeft() }
        fits(app.descendants(matching:.any)["journalPower_mega"].firstMatch)
        fits(app.descendants(matching:.any)["journalPower_rainbow"].firstMatch)
        XCTAssertEqual(app.scrollViews.count,0)
        capture("build8-ipad-journal-landscape")
        app.navigationBars.buttons["Done"].tap()
    }
}
