import XCTest
import UIKit

/// Store QA only: launch resets are isolated by scripts/test-ios.sh's device choice.
@MainActor final class SevenRoomsUITests: XCTestCase {
    private let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
        XCTAssertTrue(app.buttons["openIslandHub"].waitForExistence(timeout: 15))
    }

    private func element(_ id: String) -> XCUIElement { app.descendants(matching: .any)[id].firstMatch }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    private func fits(_ control: XCUIElement) {
        XCTAssertTrue(control.waitForExistence(timeout: 5)); XCTAssertTrue(control.isHittable)
        XCTAssertTrue(app.frame.insetBy(dx: -1, dy: -1).contains(control.frame), "Control must fit: \(control.identifier) \(control.frame)")
        XCTAssertGreaterThanOrEqual(control.frame.height, 44 - 1e-6, "Interactive target must be at least 44pt: \(control.identifier) \(control.frame)")
    }
    private func coins() throws -> Int {
        let words = app.buttons["openShop"].label.components(separatedBy: CharacterSet.decimalDigits.inverted)
        return try XCTUnwrap(Int(words.filter { !$0.isEmpty }.joined()))
    }
    private func roomDoor(_ room: String) -> XCUIElement {
        if app.buttons["openIslandHub"].exists { app.buttons["openIslandHub"].tap() }
        let hub = element("islandHub")
        XCTAssertTrue(hub.waitForExistence(timeout: 5))
        if app.buttons["keeperNextProject"].exists { app.buttons["keeperNextProject"].tap() }
        if app.buttons["chooseIslandRoom"].exists { app.buttons["chooseIslandRoom"].tap() }
        let door = app.buttons["hubRoom_\(room)"]
        let roomOrder = ["bloom", "farm", "rally", "canal", "fireflies", "windmill", "observatory"]
        for _ in 0..<12 {
            if door.exists && door.isHittable { return door }
            let visibleIndices = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "hubRoom_")).allElementsBoundByIndex
                .filter { $0.isHittable }.compactMap { roomOrder.firstIndex(of: String($0.identifier.dropFirst(8))) }
            if let target = roomOrder.firstIndex(of: room), let first = visibleIndices.min(), target < first {
                hub.swipeRight()
            } else { hub.swipeLeft() }
        }
        XCTFail("The swipe directory must expose the \(room) room")
        return door
    }
    private func enter(_ room: String) {
        let door = roomDoor(room); fits(door); door.tap()
    }
    private func returnedToRoom(_ room: String) {
        XCTAssertTrue(element("islandHub").waitForExistence(timeout: 5))
        // Do not use roomDoor here: paging would conceal a lost selection.
        fits(app.buttons["hubRoom_\(room)"])
        XCTAssertFalse(app.buttons["chooseIslandRoom"].exists, "Returning to a room must not replay the keeper welcome")
        XCTAssertFalse(app.buttons["keeperNextProject"].exists, "Returning to a room must preserve the selected door")
    }
    private func collect(_ title: String, room: String) {
        XCTAssertTrue(app.staticTexts["activityResult"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["activityResult"].label, title)
        fits(app.buttons["activityCollect"]); capture("build11-\(room)-victory")
        app.buttons["activityCollect"].tap()
        returnedToRoom(room)
    }

    func testAllSevenDoorsHaveDistinctRoomsAndClearExits() {
        app.buttons["openIslandHub"].tap()
        XCTAssertTrue(element("keeperStory").waitForExistence(timeout: 5), "A fresh launch must introduce the keeper before the room directory")
        enter("bloom")
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout: 5))
        app.buttons["playLevel"].tap()
        XCTAssertTrue(app.buttons["tile0"].waitForExistence(timeout: 5))
        app.buttons["backFromPuzzle"].tap(); app.buttons["confirmAbandon"].tap()
        enter("farm")
        XCTAssertTrue(element("farmRoomMap").waitForExistence(timeout: 5))
        fits(app.buttons["plot0"]); app.buttons["plot0"].tap()
        XCTAssertFalse(app.buttons["plot0"].label.contains("empty")); capture("build11-seven-rooms-farm")
        app.buttons["returnWorld"].tap()
        XCTAssertTrue(app.buttons["openIslandHub"].waitForExistence(timeout: 5))
        app.buttons["openIslandHub"].tap()
        returnedToRoom("farm")
        enter("rally")
        XCTAssertTrue(element("rallyRoomMap").waitForExistence(timeout: 5))
        fits(app.buttons["startRace"]); capture("build11-seven-rooms-rally")
        app.buttons["returnWorld"].tap()
        XCTAssertTrue(app.buttons["openIslandHub"].waitForExistence(timeout: 5))
        app.buttons["openIslandHub"].tap()
        returnedToRoom("rally")
        for (room, surface) in [("canal", "canalBoard"), ("fireflies", "fireflyStatus"), ("windmill", "windmillDial"), ("observatory", "observatoryBoard")] {
            enter(room)
            XCTAssertTrue(element(surface).waitForExistence(timeout: 5)); fits(app.buttons["activityExit"])
            capture("build11-seven-rooms-\(room)")
            app.buttons["activityExit"].tap()
            returnedToRoom(room)
        }
        XCTAssertEqual(app.scrollViews.count, 0)
        app.buttons["exitIslandHub"].tap()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("4 lives"), "Only entering the Bloom puzzle should spend a life")
    }

    func testFourNewRoomsWinThroughRealInputSaveRewardsAndAdvanceAfterRelaunch() throws {
        let before = try coins()
        enter("canal"); try solveCanal()
        collect("Water reaches the garden!", room: "canal")
        XCTAssertEqual(try coins(), before + 25)
        enter("fireflies"); try repeatFireflies()
        collect("The island hears your signal!", room: "fireflies")
        XCTAssertEqual(try coins(), before + 50)
        enter("windmill"); chargeWindmill()
        collect("The workshop has power!", room: "windmill")
        XCTAssertEqual(try coins(), before + 75)
        enter("observatory"); try solveObservatory()
        collect("A new route is in the stars!", room: "observatory")
        XCTAssertEqual(try coins(), before + 100)
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
        capture("build11-seven-rooms-earned-progress")
        app.terminate(); app.launchArguments = ["--uitesting", "--keep-progress"]; app.launch()
        XCTAssertTrue(app.buttons["openIslandHub"].waitForExistence(timeout: 15))
        XCTAssertEqual(try coins(), before + 100)
        for room in ["canal", "fireflies", "windmill", "observatory"] {
            let door = roomDoor(room)
            XCTAssertTrue(door.label.contains("Challenge 2"), "The completed room must reopen at its next challenge")
            door.tap(); app.buttons["activityExit"].tap()
            returnedToRoom(room)
        }
        for _ in 0..<12 {
            if element("hubRestoration").exists { break }
            element("islandHub").swipeRight()
        }
        XCTAssertTrue(element("hubRestoration").waitForExistence(timeout: 5))
        XCTAssertTrue(element("hubRestoration").label.contains("4 stars"))
    }

    func testRallyIgnoresVerticalSwipesPausesResumesAndBanksRealPickups() throws {
        let before = try coins()
        app.buttons["openRace"].tap(); app.buttons["startRace"].tap()
        let road = element("raceTrack")
        XCTAssertTrue(road.waitForExistence(timeout: 5)); XCTAssertEqual(road.value as? String, "Lane 2 of 3")
        road.swipeUp(); XCTAssertEqual(road.value as? String, "Lane 2 of 3", "A vertical swipe must never steer")
        app.buttons["pauseRace"].tap()
        XCTAssertTrue(app.buttons["resumeRace"].waitForExistence(timeout: 5))
        let pausedDistance = app.staticTexts["raceDistance"].label
        road.swipeRight(); XCTAssertEqual(road.value as? String, "Lane 2 of 3", "A paused race must not steer")
        let remainsPaused = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in self.app.staticTexts["raceDistance"].label != pausedDistance }, object: app)
        XCTAssertEqual(XCTWaiter.wait(for: [remainsPaused], timeout: 1), .timedOut, "Pause must freeze the actual race clock")
        capture("build11-rally-paused")
        app.buttons["resumeRace"].tap()
        let advanced = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in self.app.staticTexts["raceDistance"].label != pausedDistance }, object: app)
        XCTAssertEqual(XCTWaiter.wait(for: [advanced], timeout: 5), .completed)
        road.swipeLeft(); XCTAssertEqual(road.value as? String, "Lane 1 of 3")
        capture("build11-rally-new-rover")
        XCTAssertTrue(app.staticTexts["raceResult"].waitForExistence(timeout: 40))
        let firstResult = app.staticTexts["raceResult"].label
        XCTAssertTrue(["Delivery complete!", "Time for a tune-up"].contains(firstResult))
        capture(firstResult == "Delivery complete!" ? "build11-rally-controls-complete" : "build11-rally-controls-tune-up")
        app.buttons["raceDone"].tap()
        let beforeControlledRun = try coins()
        // AX control assertions consume real race time. Verify a clean drive in a fresh run.
        app.buttons["openRace"].tap(); app.buttons["startRace"].tap()
        XCTAssertTrue(road.waitForExistence(timeout: 5)); road.swipeLeft()
        XCTAssertEqual(road.value as? String, "Lane 1 of 3")
        capture("build11-rally-controlled-drive")
        XCTAssertTrue(app.staticTexts["raceResult"].waitForExistence(timeout: 40))
        XCTAssertEqual(app.staticTexts["raceResult"].label, "Delivery complete!", "A real controlled drive must survive barriers and finish")
        XCTAssertFalse(element("raceCollectedCoins").label.hasPrefix("0 coins"), "This run must actually collect a road pickup")
        capture("build11-rally-complete")
        app.buttons["raceDone"].tap()
        XCTAssertGreaterThan(try coins(), beforeControlledRun)
        XCTAssertGreaterThan(try coins(), before)
    }

    func testMaximumAccessibilityTextKeepsSevenRoomControlsEventsAndRecordsInBounds() {
        app.terminate()
        app.launchArguments = ["--uitesting", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["openIslandHub"].waitForExistence(timeout: 15))
        app.buttons["openIslandHub"].tap()
        let hub = element("islandHub")
        inBounds(element("keeperStory")); fits(app.buttons["keeperNextProject"])
        app.buttons["keeperNextProject"].tap()
        inBounds(element("hubRestoration")); fits(app.buttons["chooseIslandRoom"])
        capture("build11-max-text-keeper-project")
        app.buttons["chooseIslandRoom"].tap()
        let rooms = ["bloom", "farm", "rally", "canal", "fireflies", "windmill", "observatory"]
        for (index, room) in rooms.enumerated() {
            fits(app.buttons["hubRoom_\(room)"]); fits(app.buttons["exitIslandHub"])
            XCTAssertFalse(app.buttons["hubRoom_\(room)"].frame.intersects(app.buttons["exitIslandHub"].frame))
            if index < rooms.count - 1 { hub.swipeLeft() }
        }
        capture("build11-max-text-seven-room-door")
        app.buttons["exitIslandHub"].tap()
        for room in ["canal", "fireflies", "windmill", "observatory"] {
            enter(room)
            fits(app.buttons["activityExit"]); fits(app.buttons["activityRestart"]); fits(app.buttons["activityPause"])
            XCTAssertFalse(app.buttons["activityExit"].frame.intersects(app.buttons["activityRestart"].frame))
            XCTAssertFalse(app.buttons["activityRestart"].frame.intersects(app.buttons["activityPause"].frame))
            inBounds(app.staticTexts["activityTitle"])
            switch room {
            case "canal":
                for index in 0..<12 { fits(app.buttons["canalPipe\(index)"]); XCTAssertGreaterThanOrEqual(app.buttons["canalPipe\(index)"].frame.width, 44) }
            case "fireflies":
                fits(app.buttons["fireflyWatch"])
                for index in 0..<4 { inBounds(app.buttons["fireflyLight\(index)"]); XCTAssertGreaterThanOrEqual(app.buttons["fireflyLight\(index)"].frame.width, 44); XCTAssertGreaterThanOrEqual(app.buttons["fireflyLight\(index)"].frame.height, 44) }
            case "windmill":
                fits(app.buttons["windmillCharge"]); inBounds(element("windmillDial"))
                XCTAssertGreaterThanOrEqual(element("windmillDial").frame.height, 100)
            default:
                inBounds(element("observatoryGap"))
                for tile in 1...8 { fits(app.buttons["observatoryTile\(tile)"]); XCTAssertGreaterThanOrEqual(app.buttons["observatoryTile\(tile)"].frame.width, 44) }
            }
            capture("build11-max-text-\(room)")
            fits(app.buttons["activityHelp"]); app.buttons["activityHelp"].tap()
            let instruction = element("activityHelpStep")
            inBounds(instruction); fits(app.buttons["activityHelpDone"])
            let firstStep = instruction.label
            instruction.swipeLeft()
            XCTAssertNotEqual(instruction.label, firstStep, "A real help swipe must advance the instruction")
            inBounds(instruction); capture("build11-max-text-\(room)-help")
            app.buttons["activityHelpDone"].tap()
            app.buttons["activityPause"].tap(); fits(app.buttons["activityResume"])
            app.buttons["activityResume"].tap(); app.buttons["activityExit"].tap()
        }
        app.buttons["exitIslandHub"].tap()
        app.buttons["openWorldEvents"].tap()
        let eventPages = element("worldEventPages")
        let clockStatus = element("worldClockStatus")
        let retry = app.buttons["retryWorldClock"]
        let checked = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            eventPages.exists || (retry.exists && clockStatus.exists && !clockStatus.label.hasPrefix("Connecting"))
        }, object: app)
        XCTAssertEqual(XCTWaiter.wait(for: [checked], timeout: 20), .completed)
        inBounds(app.navigationBars.buttons["Done"])
        XCTAssertTrue(app.navigationBars.buttons["Done"].isHittable)
        if eventPages.exists {
            for index in 0..<9 {
                XCTAssertEqual(eventPages.value as? String, "Page \(index + 1) of 9")
                inBounds(eventPages)
                switch index % 3 {
                case 0: inBounds(element("eventTiming"))
                case 1: inBounds(element("eventProgress"))
                default:
                    inBounds(clockStatus)
                    if app.buttons["eventEnterRoom"].exists { fits(app.buttons["eventEnterRoom"]) }
                    else { inBounds(app.buttons["claimWorldEvent"]) }
                }
                inBounds(app.navigationBars.buttons["Done"])
                capture("build11-max-text-event-\(index + 1)")
                if index < 8 { element("worldEvents").swipeLeft() }
            }
        } else {
            inBounds(clockStatus); fits(retry)
            capture("build11-max-text-events-offline")
        }
        app.navigationBars.buttons["Done"].tap()
        app.buttons["openRoomRecords"].tap()
        XCTAssertTrue(element("roomRecords").waitForExistence(timeout: 5))
        let recordPages = element("roomRecordPages")
        for index in 0..<11 {
            XCTAssertEqual(recordPages.value as? String, "Page \(index + 1) of 11")
            inBounds(recordPages); inBounds(app.navigationBars.buttons["Done"])
            XCTAssertTrue(app.navigationBars.buttons["Done"].isHittable)
            if index < 8 {
                inBounds(element(index % 2 == 0 ? "roomBestScore" : "roomCompletedChallenges"))
            } else if index == 10 { inBounds(element("leaderboardStatus")) }
            capture("build11-max-text-record-\(index + 1)")
            if index < 10 { element("roomRecords").swipeLeft() }
        }
        app.navigationBars.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["openIslandHub"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.scrollViews.count, 0, "Game rooms and activity pages must not introduce a vertical scrolling menu")
    }

    func testNormalStoryEventsRecordsAndSavedGardenReleaseViews() throws {
        let originalCoins = try coins()
        let originalLives = app.buttons["lifeBalance"].label
        app.buttons["openIslandHub"].tap()
        let hub = element("islandHub")
        inBounds(element("keeperStory")); inBounds(element("hubRestoration"))
        fits(app.buttons["chooseIslandRoom"]); fits(app.buttons["exitIslandHub"])
        capture("build11-keeper-world")
        app.buttons["chooseIslandRoom"].tap()
        let roomPages = [["bloom", "farm"], ["rally", "canal"], ["fireflies", "windmill"], ["observatory"]]
        for (index, rooms) in roomPages.enumerated() {
            XCTAssertEqual(element("hubPages").value as? String, "Page \(index + 2) of 5")
            for room in rooms { fits(app.buttons["hubRoom_\(room)"]) }
            fits(app.buttons["exitIslandHub"])
            XCTAssertEqual(app.scrollViews.count, 0, "The normal room directory must use swipe pages")
            capture("build11-room-doors-\(index + 1)")
            if index < roomPages.count - 1 { hub.swipeLeft() }
        }
        app.buttons["exitIslandHub"].tap()
        app.buttons["openWorldEvents"].tap()
        let eventPages = element("worldEventPages")
        let clockStatus = element("worldClockStatus")
        let retry = app.buttons["retryWorldClock"]
        let checkedClock = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            eventPages.exists || (retry.exists && clockStatus.exists && !clockStatus.label.hasPrefix("Connecting"))
        }, object: app)
        XCTAssertEqual(XCTWaiter.wait(for: [checkedClock], timeout: 20), .completed)
        if eventPages.exists {
            for index in 0..<3 {
                XCTAssertEqual(eventPages.value as? String, "Page \(index + 1) of 3")
                inBounds(eventPages); inBounds(clockStatus)
                inBounds(element("eventTiming")); inBounds(element("eventProgress"))
                let action = app.buttons["eventEnterRoom"]
                fits(action); XCTAssertGreaterThanOrEqual(action.frame.height, 48)
                XCTAssertTrue(action.label.hasPrefix("Enter "), "Event actions must name the room they open")
                inBounds(app.navigationBars.buttons["Done"])
                XCTAssertEqual(app.scrollViews.count, 0, "World events must remain swipe pages")
                capture("build11-world-event-\(index + 1)")
                if index < 2 { element("worldEvents").swipeLeft() }
            }
        } else {
            inBounds(clockStatus); fits(retry); XCTAssertGreaterThanOrEqual(retry.frame.height, 48)
            XCTAssertEqual(app.scrollViews.count, 0)
            capture("build11-world-events-offline")
        }
        XCTAssertTrue(app.navigationBars.buttons["Done"].isHittable)
        app.navigationBars.buttons["Done"].tap()
        app.buttons["openRoomRecords"].tap()
        let records = element("roomRecords")
        XCTAssertTrue(records.waitForExistence(timeout: 5))
        for index in 0..<5 {
            XCTAssertEqual(element("roomRecordPages").value as? String, "Page \(index + 1) of 5")
            inBounds(element("roomRecordPages")); inBounds(app.navigationBars.buttons["Done"])
            if index < 4 {
                inBounds(element("roomBestScore")); inBounds(element("roomCompletedChallenges"))
                XCTAssertTrue(element("roomBestScore").label.contains("0 points"))
                XCTAssertEqual(element("roomCompletedChallenges").label, "0 challenges completed")
            } else {
                inBounds(element("leaderboardStatus"))
                inBounds(app.staticTexts["Connect Game Center in Settings for worldwide rankings."])
            }
            XCTAssertEqual(app.scrollViews.count, 0, "Records must use native swipe pages")
            capture(index == 4 ? "build11-apple-rankings-info" : "build11-room-record-\(index + 1)")
            if index < 4 { records.swipeLeft() }
        }
        app.navigationBars.buttons["Done"].tap()
        fits(app.buttons["settings"]); app.buttons["settings"].tap()
        fits(app.buttons["playerAccount"]); app.buttons["playerAccount"].tap()
        inBounds(element("saveStatus")); inBounds(element("saveSummary"))
        XCTAssertTrue(element("saveSummary").label.contains("\(originalCoins) coins"))
        fits(app.buttons["connectGameCenter"])
        capture("build11-player-saved-garden")
        XCTAssertTrue(app.navigationBars.buttons["Settings"].waitForExistence(timeout: 5))
        app.navigationBars.buttons["Settings"].tap()
        app.navigationBars.buttons["Done"].tap()
        app.buttons["openShop"].tap()
        let supplies = element("suppliesScene")
        XCTAssertTrue(supplies.waitForExistence(timeout: 5))
        inBounds(element("lifeTimer")); fits(app.buttons["explorePacks"])
        capture("build11-supplies-and-lives")
        app.buttons["explorePacks"].tap()
        let packs = ["coins400", "coins1500", "coins3000", "coins7000", "lives5", "starter"]
        for (index, pack) in packs.enumerated() {
            XCTAssertEqual(element("supplyPage").label, "Swipe supplies · \(index + 2) of 7")
            let purchase = app.buttons["buy_com.orbitbloom.\(pack)"]
            // CGRect arithmetic can report an exact 44pt target as 43.99999999999994.
            inBounds(purchase); XCTAssertGreaterThanOrEqual(purchase.frame.height, 44 - 1e-6)
            XCTAssertEqual(app.scrollViews.count, 0, "Supply packs must remain swipe pages")
            capture("build11-supply-\(pack)")
            if index < packs.count - 1 {
                // Swipe the noninteractive title area, away from every purchase button.
                let start = supplies.coordinate(withNormalizedOffset: CGVector(dx: 0.82, dy: 0.08))
                let end = supplies.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.08))
                start.press(forDuration: 0.05, thenDragTo: end)
            }
        }
        XCTAssertEqual(try coins(), originalCoins, "The release gallery must not buy, claim, or spend currency")
        XCTAssertEqual(app.buttons["lifeBalance"].label, originalLives, "The release gallery must not consume lives")
    }

    private func inBounds(_ item: XCUIElement) {
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        XCTAssertTrue(app.frame.insetBy(dx: -1, dy: -1).contains(item.frame), "Maximum text must fit: \(item.identifier) \(item.frame)")
        XCTAssertGreaterThan(item.frame.width, 0); XCTAssertGreaterThan(item.frame.height, 0)
    }

    private func solveCanal() throws {
        // Serpentine water route from west inlet to east outlet. Read actual AX ports.
        let expected = [10, 10, 10, 12, 6, 10, 10, 9, 3, 10, 10, 10]
        for (index, target) in expected.enumerated() {
            let pipe = app.buttons["canalPipe\(index)"]
            for _ in 0..<4 {
                if app.staticTexts["activityResult"].exists { return }
                if !pipe.exists {
                    XCTAssertTrue(app.staticTexts["activityResult"].waitForExistence(timeout: 3), "A pipe may disappear only when the result replaces the board. Preserve unique canalPipe identifiers while playing.")
                    return
                }
                let value = pipe.value as? String ?? ""
                var mask = 0
                for (word, port) in [("north", 1), ("east", 2), ("south", 4), ("west", 8)] where value.contains(word) { mask |= port }
                if mask == target { break }
                XCTAssertNotEqual(mask, 0, "Every pipe must announce its real ports")
                pipe.tap()
                let changed = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in pipe.value as? String != value || self.app.staticTexts["activityResult"].exists }, object: pipe)
                XCTAssertEqual(XCTWaiter.wait(for: [changed], timeout: 3), .completed)
            }
        }
    }

    private func repeatFireflies() throws {
        for round in 0..<3 {
            XCTAssertTrue(app.buttons["fireflyWatch"].waitForExistence(timeout: 5))
            app.buttons["fireflyWatch"].tap()
            let status = app.staticTexts["fireflyStatus"]
            var seen: [Int] = []
            let deadline = Date().addingTimeInterval(12)
            while Date() < deadline {
                let text = status.label
                if text.hasPrefix("Your turn") { break }
                if text.hasPrefix("Lantern "), let number = Int(text.dropFirst(8).prefix(1)), seen.last != number { seen.append(number) }
            }
            XCTAssertTrue(status.label.hasPrefix("Your turn"))
            XCTAssertEqual(seen.count, 3 + round, "Observe every real lantern demonstration before answering")
            for light in seen { app.buttons["fireflyLight\(light - 1)"].tap() }
        }
    }

    private func chargeWindmill() {
        app.buttons["windmillCharge"].tap()
        let dial = element("windmillDial")
        let charge = app.buttons["windmillCharge"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        for _ in 0..<4 {
            // Observe the opening edge, rather than sampling once a second near its end.
            if dial.value as? String == "Charge window is open" {
                let closes = Date().addingTimeInterval(4)
                while Date() < closes && dial.value as? String == "Charge window is open" { }
            }
            let opens = Date().addingTimeInterval(5)
            while Date() < opens && dial.value as? String != "Charge window is open" { }
            XCTAssertEqual(dial.value as? String, "Charge window is open")
            charge.tap()
        }
    }

    private func solveObservatory() throws {
        var board = Array(repeating: 0, count: 9)
        let gapElement = element("observatoryGap")
        for tile in 1...8 {
            let button = app.buttons["observatoryTile\(tile)"]
            let position = try positionInChart(button.label)
            board[position] = tile
        }
        let goal = Array(1...8) + [0]
        var queue: [([Int], [Int])] = [(board, [])], cursor = 0
        var visited: Set<[Int]> = [board]
        var solution: [Int]?
        while cursor < queue.count && cursor < 181_440 {
            let (state, steps) = queue[cursor]; cursor += 1
            if state == goal { solution = steps; break }
            let gap = try XCTUnwrap(state.firstIndex(of: 0))
            for candidate in 0..<9 where abs(candidate / 3 - gap / 3) + abs(candidate % 3 - gap % 3) == 1 {
                var next = state; next.swapAt(candidate, gap)
                if visited.insert(next).inserted { queue.append((next, steps + [state[candidate]])) }
            }
        }
        for tile in try XCTUnwrap(solution) {
            let button = app.buttons["observatoryTile\(tile)"]
            let oldCenter = CGPoint(x: button.frame.midX, y: button.frame.midY)
            let gapCenter = CGPoint(x: gapElement.frame.midX, y: gapElement.frame.midY)
            if abs(oldCenter.x - gapCenter.x) > abs(oldCenter.y - gapCenter.y) {
                if gapCenter.x < oldCenter.x { button.swipeLeft() } else { button.swipeRight() }
            } else if gapCenter.y < oldCenter.y { button.swipeUp() } else { button.swipeDown() }
            let moved = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
                self.app.staticTexts["activityResult"].exists || hypot(gapElement.frame.midX - oldCenter.x, gapElement.frame.midY - oldCenter.y) < 5
            }, object: gapElement)
            XCTAssertEqual(XCTWaiter.wait(for: [moved], timeout: 4), .completed, "One real swipe must move exactly one tile into the gap")
        }
    }

    private func positionInChart(_ label: String) throws -> Int {
        let expression = try NSRegularExpression(pattern: "row ([1-3]), column ([1-3])")
        let range = NSRange(label.startIndex..<label.endIndex, in: label)
        let match = try XCTUnwrap(expression.firstMatch(in: label, range: range))
        let row = try XCTUnwrap(Int((label as NSString).substring(with: match.range(at: 1))))
        let column = try XCTUnwrap(Int((label as NSString).substring(with: match.range(at: 2))))
        return (row - 1) * 3 + column - 1
    }
}

/// Runs only on the dedicated iPad QA device. Existing progress is retained.
@MainActor final class SevenRoomsIPadUITests: XCTestCase {
    private let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app.launchArguments = ["--uitesting", "--keep-progress"]
        app.launch()
        try XCTSkipIf(app.frame.width < 700, "Run the seven-room layout tour on the dedicated iPad QA simulator")
        XCTAssertTrue(app.buttons["openIslandHub"].waitForExistence(timeout: 15))
    }

    private func element(_ id: String) -> XCUIElement { app.descendants(matching: .any)[id].firstMatch }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    private func inBounds(_ control: XCUIElement, interactive: Bool = false) {
        XCTAssertTrue(control.waitForExistence(timeout: 5))
        XCTAssertTrue(app.frame.insetBy(dx: -1, dy: -1).contains(control.frame), "iPad control must fit: \(control.identifier) \(control.frame)")
        XCTAssertGreaterThan(control.frame.width, 0); XCTAssertGreaterThan(control.frame.height, 0)
        if interactive { XCTAssertTrue(control.isHittable); XCTAssertGreaterThanOrEqual(control.frame.height, 44 - 1e-6) }
    }
    private func enter(_ room: String) {
        if app.buttons["openIslandHub"].exists { app.buttons["openIslandHub"].tap() }
        let hub = element("islandHub")
        XCTAssertTrue(hub.waitForExistence(timeout: 5))
        if app.buttons["keeperNextProject"].exists { app.buttons["keeperNextProject"].tap() }
        if app.buttons["chooseIslandRoom"].exists { app.buttons["chooseIslandRoom"].tap() }
        let door = app.buttons["hubRoom_\(room)"]
        let roomOrder = ["bloom", "farm", "rally", "canal", "fireflies", "windmill", "observatory"]
        for _ in 0..<12 {
            if door.exists && door.isHittable { inBounds(door, interactive: true); door.tap(); return }
            let visibleIndices = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "hubRoom_")).allElementsBoundByIndex
                .filter { $0.isHittable }.compactMap { roomOrder.firstIndex(of: String($0.identifier.dropFirst(8))) }
            if let target = roomOrder.firstIndex(of: room), let first = visibleIndices.min(), target < first {
                hub.swipeRight()
            } else { hub.swipeLeft() }
        }
        XCTFail("The iPad directory must expose the \(room) room")
    }

    func testSevenRoomLayoutFitsPortraitAndLandscapeWithoutChangingRewards() {
        defer { XCUIDevice.shared.orientation = .portrait; app.terminate() }
        let originalCoins = app.buttons["openShop"].label
        let originalLives = app.buttons["lifeBalance"].label
        for (orientation, name) in [(UIDeviceOrientation.portrait, "portrait"), (.landscapeLeft, "landscape")] {
            XCUIDevice.shared.orientation = orientation
            let rotated = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
                orientation == .portrait ? self.app.frame.height > self.app.frame.width : self.app.frame.width > self.app.frame.height
            }, object: app)
            XCTAssertEqual(XCTWaiter.wait(for: [rotated], timeout: 15), .completed)
            app.buttons["openIslandHub"].tap()
            // The second orientation retains the last visited room. Page back
            // deliberately for the welcome screenshot without resetting saves.
            for _ in 0..<12 {
                if element("keeperStory").exists { break }
                element("islandHub").swipeRight()
            }
            inBounds(element("keeperStory")); inBounds(app.buttons["exitIslandHub"], interactive: true)
            capture("build11-ipad-\(name)-keeper-world")
            app.buttons["exitIslandHub"].tap()
            for room in ["bloom", "farm", "rally", "canal", "fireflies", "windmill", "observatory"] {
                enter(room)
                switch room {
                case "bloom":
                    inBounds(app.buttons["playLevel"], interactive: true)
                    capture("build11-ipad-\(name)-bloom-map")
                case "farm":
                    inBounds(element("farmRoomMap"))
                    for plot in 0..<6 { inBounds(app.buttons["plot\(plot)"], interactive: true) }
                    inBounds(app.buttons["returnWorld"], interactive: true)
                    capture("build11-ipad-\(name)-farm")
                    app.buttons["returnWorld"].tap()
                case "rally":
                    inBounds(element("rallyRoomMap")); inBounds(app.buttons["startRace"], interactive: true)
                    inBounds(app.buttons["returnWorld"], interactive: true)
                    capture("build11-ipad-\(name)-rally")
                    app.buttons["returnWorld"].tap()
                default:
                    inBounds(app.buttons["activityExit"], interactive: true)
                    inBounds(app.buttons["activityRestart"], interactive: true)
                    inBounds(app.buttons["activityPause"], interactive: true)
                    inBounds(element("activityTitle"))
                    if room == "canal" { for pipe in 0..<12 { inBounds(app.buttons["canalPipe\(pipe)"], interactive: true) } }
                    else if room == "fireflies" {
                        inBounds(app.buttons["fireflyWatch"], interactive: true)
                        for light in 0..<4 { inBounds(app.buttons["fireflyLight\(light)"]) }
                    } else if room == "windmill" {
                        inBounds(element("windmillDial")); inBounds(app.buttons["windmillCharge"], interactive: true)
                    } else {
                        inBounds(element("observatoryGap"))
                        for tile in 1...8 { inBounds(app.buttons["observatoryTile\(tile)"], interactive: true) }
                    }
                    capture("build11-ipad-\(name)-\(room)")
                    app.buttons["activityExit"].tap()
                    app.buttons["exitIslandHub"].tap()
                }
                XCTAssertEqual(app.scrollViews.count, 0)
            }
            XCTAssertEqual(app.buttons["openShop"].label, originalCoins, "A layout tour must not mint or spend coins")
            XCTAssertEqual(app.buttons["lifeBalance"].label, originalLives, "A layout tour must not start a life-consuming puzzle")
        }
    }
}
