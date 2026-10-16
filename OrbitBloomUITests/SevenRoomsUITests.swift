import XCTest
import UIKit

/// Real gesture/button play on the isolated Store QA simulator.
@MainActor final class SevenRoomsUITests:XCTestCase {
    private let app=XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure=false; XCUIDevice.shared.orientation = .portrait
        app.launchArguments=["--uitesting"]; app.launch()
        XCTAssertTrue(app.buttons["openFarm"].waitForExistence(timeout:15))
    }
    private func element(_ id:String)->XCUIElement { app.descendants(matching:.any)[id].firstMatch }
    private func capture(_ name:String) { let a=XCTAttachment(screenshot:XCUIScreen.main.screenshot());a.name=name;a.lifetime = .keepAlways;add(a) }
    private func fits(_ e:XCUIElement) { XCTAssertTrue(e.waitForExistence(timeout:5));XCTAssertTrue(e.isHittable);XCTAssertTrue(app.frame.insetBy(dx:-1,dy:-1).contains(e.frame),"\(e.identifier): \(e.frame)");XCTAssertGreaterThanOrEqual(e.frame.height,44-1e-6) }
    private func coins() throws ->Int { try XCTUnwrap(Int(app.buttons["openShop"].label.components(separatedBy:CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }.joined())) }
    private func enter(_ room:String) { let id=room == "rally" ? "openRace" : "open\(room.capitalized)";fits(app.buttons[id]);app.buttons[id].tap() }
    func testRestartDecisionFreezesWindmillAndCancelKeepsAttempt() throws {
        func cancelRestart() {
            if app.buttons["Keep playing"].exists { app.buttons["Keep playing"].tap() }
            else { app.coordinate(withNormalizedOffset:CGVector(dx:0.1,dy:0.2)).tap() }
        }
        enter("windmill"); app.buttons["windmillCharge"].tap()
        let clock=app.staticTexts.matching(NSPredicate(format:"label MATCHES '^[0-9]+ seconds$'")).firstMatch
        XCTAssertTrue(clock.waitForExistence(timeout:5))
        let before=try XCTUnwrap(Int(clock.label.components(separatedBy:" ")[0]))
        app.buttons["activityRestart"].tap()
        XCTAssertTrue(app.buttons["Restart · no life cost"].waitForExistence(timeout:5))
        capture("restart-decision-windmill")
        // Longer than the full 24-second route: thinking in a modal must not lose it.
        Thread.sleep(forTimeInterval:26)
        cancelRestart()
        XCTAssertTrue(app.buttons["windmillCharge"].waitForExistence(timeout:5),"Cancelling a restart must retain the running attempt")
        XCTAssertFalse(app.staticTexts["activityResult"].exists)
        let after=try XCTUnwrap(Int(clock.label.components(separatedBy:" ")[0]))
        XCTAssertGreaterThanOrEqual(after,before-3,"The decision must not consume workshop time")
        capture("restart-cancel-retained-workshop")
        app.buttons["activityPause"].tap();app.buttons["activityRestart"].tap()
        cancelRestart()
        XCTAssertTrue(app.buttons["activityResume"].exists,"Cancelling while already paused must keep it paused")
        app.buttons["activityRestart"].tap();app.buttons["Restart · no life cost"].tap()
        XCTAssertTrue(app.buttons["windmillCharge"].waitForExistence(timeout:5))
        XCTAssertEqual(app.buttons["windmillCharge"].label,"Start windmill")
        XCTAssertFalse(app.buttons["activityResume"].exists)
        XCTAssertEqual(clock.label,"24 seconds")
        capture("restart-confirm-fresh-workshop")
        app.buttons["activityExit"].tap()
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
    }
    private func collect(_ title:String,room:String) {
        XCTAssertTrue(app.staticTexts["activityResult"].waitForExistence(timeout:5));XCTAssertEqual(app.staticTexts["activityResult"].label,title)
        fits(app.buttons["activityCollect"]);capture("build17-\(room)-victory");app.buttons["activityCollect"].tap();XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
    }
    func testRestartDecisionInterruptsFireflyPlaybackWithoutAMistakeOrRewardLoss() throws {
        let before=try coins()
        enter("fireflies");app.buttons["fireflyWatch"].tap();app.buttons["activityRestart"].tap()
        XCTAssertTrue(app.buttons["Restart · no life cost"].waitForExistence(timeout:5))
        Thread.sleep(forTimeInterval:4)
        if app.buttons["Keep playing"].exists { app.buttons["Keep playing"].tap() }
        else { app.coordinate(withNormalizedOffset:CGVector(dx:0.1,dy:0.2)).tap() }
        XCTAssertEqual(app.staticTexts["fireflyStatus"].label,"Ready to watch")
        XCTAssertTrue(app.buttons["fireflyWatch"].isEnabled)
        capture("restart-cancel-fireflies-ready-to-replay")
        try repeatFireflies();collect("The island hears your signal!",room:"fireflies")
        XCTAssertEqual(try coins(),before+25)
        XCTAssertTrue(element("sharedWater").label.contains("14"))
        XCTAssertTrue(element("sharedStars").label.hasPrefix("1 restoration stars"))
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
    }
    func testEightDirectActivitiesHaveClearExitsAndNoRoomDirectory() {
        for id in ["openBloom","openFarm","openRace","openCanal","openFireflies","openWindmill","openObservatory","openShuttle","playLevel","openTasks"] { fits(app.buttons[id]) }
        XCTAssertFalse(app.buttons["openIslandHub"].exists);XCTAssertFalse(app.staticTexts["Moonseed meadow"].exists);XCTAssertEqual(app.scrollViews.count,0)
        for id in ["sharedWater","sharedSeeds","sharedCompost","sharedCargo","sharedStars","restorationCount"] { XCTAssertTrue(element(id).exists) }
        capture("build18-island-equal-activities")
        app.buttons["openIslandStory"].tap();fits(app.buttons["closeIslandStory"]);capture("build18-connected-story")
        let pages=element("gardenStoryPages")
        for title in ["Farm Terraces","Harvest Rally","Canal Weave","Firefly Trail","Windmill Works","Moon Observatory","Sky Shuttle"] {
            pages.swipeLeft();XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout:3))
        }
        app.buttons["closeIslandStory"].tap()
        for (room,surface) in [("canal","canalBoard"),("fireflies","fireflyStatus"),("windmill","windmillDial"),("observatory","observatoryBoard"),("shuttle","shuttleBus")] {
            enter(room);XCTAssertTrue(element(surface).waitForExistence(timeout:5));fits(app.buttons["activityExit"]);capture("build17-\(room)-game")
            app.buttons["activityExit"].tap();XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
        }
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
    }
    func testFiveSkillGamesWinThroughRealInputAndSaveAcrossRelaunch() throws {
        let before=try coins()
        enter("canal");try solveCanal();collect("Water reaches the garden!",room:"canal")
        enter("fireflies");try repeatFireflies();collect("The island hears your signal!",room:"fireflies")
        enter("windmill");chargeWindmill();collect("The workshop has power!",room:"windmill")
        enter("observatory");try solveObservatory();collect("A new route is in the stars!",room:"observatory")
        enter("shuttle");try solveShuttle();XCTAssertTrue(app.buttons["activitySaveResult"].waitForExistence(timeout:5));capture("build17-shuttle-full-winning-plan");app.buttons["activitySaveResult"].tap()
        XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5));XCTAssertEqual(try coins(),before+125)
        XCTAssertTrue(element("sharedWater").label.contains("22"));XCTAssertTrue(element("sharedStars").label.hasPrefix("5 restoration stars"))
        for id in ["openCanal","openFireflies","openWindmill","openObservatory","openShuttle"] { XCTAssertTrue((app.buttons[id].value as? String ?? "").hasPrefix("2 next challenge")) }
        app.buttons["restoreProject"].tap();XCTAssertEqual(element("restorationCount").label,"1 of 6 island projects restored")
        XCTAssertTrue(element("sharedStars").label.hasPrefix("3 restoration stars"));capture("build18-five-games-restored-one-garden")
        XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
        app.terminate();app.launchArguments=["--uitesting","--keep-progress"];app.launch();XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:15))
        XCTAssertEqual(try coins(),before+125)
        XCTAssertEqual(element("restorationCount").label,"1 of 6 island projects restored");XCTAssertTrue(element("sharedWater").label.contains("22"))
        enter("shuttle");XCTAssertEqual(app.staticTexts["activityTitle"].label,"Sky Shuttle, challenge 2");capture("build17-shuttle-saved-progression")
    }
    func testMaximumTextKeepsActivityIconsSeatsAndHelpUsable() {
        app.terminate();app.launchArguments=["--uitesting","-UIPreferredContentSizeCategoryName","UICTContentSizeCategoryAccessibilityXXXL"];app.launch()
        XCTAssertTrue(app.buttons["openShuttle"].waitForExistence(timeout:15));capture("build17-island-maximum-text")
        for room in ["canal","fireflies","windmill","observatory","shuttle"] {
            enter(room);for id in ["activityExit","activityRestart","activityPause"] { fits(app.buttons[id]) }
            app.buttons["activityRestart"].tap();fits(app.buttons["Restart · no life cost"])
            capture("build21-\(room)-restart-maximum-text")
            if app.buttons["Keep playing"].exists { app.buttons["Keep playing"].tap() }
            // The native maximum-text popover widens: use its outside screen edge.
            else { app.coordinate(withNormalizedOffset:CGVector(dx:0.005,dy:0.5)).tap() }
            XCTAssertFalse(app.buttons["Restart · no life cost"].exists)
            if room == "shuttle" { for i in 0..<12 { fits(app.buttons["shuttleSeat\(i)"]);fits(app.buttons["passenger\(i)"]) };capture("build17-shuttle-maximum-text") }
            else { fits(app.buttons["activityHelp"]);app.buttons["activityHelp"].tap();fits(app.buttons["activityHelpDone"]);capture("build17-\(room)-help");app.buttons["activityHelpDone"].tap() }
            app.buttons["activityExit"].tap();XCTAssertTrue(app.buttons["openFarm"].waitForExistence(timeout:5))
        }
        XCTAssertEqual(app.scrollViews.count,0)
    }
    func testThreeRealSkillWinsOpenSecondFarmFieldAndPersistItsCrop() throws {
        app.buttons["openFarm"].tap()
        let map=element("farmRoomMap"),locked=element("lockedFarmField")
        map.swipeLeft();XCTAssertTrue(locked.waitForExistence(timeout:5))
        XCTAssertTrue(locked.label.contains("0 wins so far"));XCTAssertFalse(app.buttons["plot6"].exists)
        capture("build19-farm-before-adventure-wins");app.buttons["returnWorld"].tap()
        enter("canal");try solveCanal();collect("Water reaches the garden!",room:"canal")
        enter("fireflies");try repeatFireflies();collect("The island hears your signal!",room:"fireflies")
        enter("windmill");chargeWindmill();collect("The workshop has power!",room:"windmill")
        app.buttons["openFarm"].tap();map.swipeLeft()
        fits(app.buttons["plot6"]);XCTAssertFalse(locked.exists)
        app.buttons["cropapple"].tap();app.buttons["plot6"].tap()
        XCTAssertTrue((app.buttons["plot6"].value as? String ?? "").contains("Moon apple"))
        capture("build19-farm-opened-by-three-skill-games")
        map.swipeLeft();XCTAssertTrue(locked.waitForExistence(timeout:5))
        XCTAssertTrue(locked.label.contains("3 wins so far"));XCTAssertFalse(app.buttons["plot12"].exists)
        capture("build19-farm-third-field-progress")
        app.buttons["returnWorld"].tap();app.terminate()
        app.launchArguments=["--uitesting","--keep-progress"];app.launch()
        XCTAssertTrue(app.buttons["openFarm"].waitForExistence(timeout:15))
        app.buttons["openFarm"].tap();map.swipeLeft();fits(app.buttons["plot6"])
        XCTAssertTrue((app.buttons["plot6"].value as? String ?? "").contains("Moon apple"))
        capture("build19-farm-unlock-and-crop-after-relaunch")
    }
    func testLastMoveShuttleDepartureAtMaximumTextSavesTheSharedGarden() throws {
        app.terminate();app.launchArguments=["--uitesting","-UIPreferredContentSizeCategoryName","UICTContentSizeCategoryAccessibilityXXXL"];app.launch()
        XCTAssertTrue(app.buttons["openShuttle"].waitForExistence(timeout:15))
        let before=try coins();enter("shuttle")
        let budget=try XCTUnwrap(Int(element("shuttleMoves").label.components(separatedBy:" ")[0]))
        try solveShuttle(extraMoves:budget-12)
        fits(app.buttons["activitySaveResult"]);capture("build22-shuttle-final-move-victory")
        app.buttons["activitySaveResult"].tap();XCTAssertTrue(app.buttons["playLevel"].waitForExistence(timeout:5))
        XCTAssertEqual(try coins(),before+25);XCTAssertTrue(element("sharedStars").label.hasPrefix("1 restoration stars"))
        XCTAssertTrue(element("sharedWater").label.contains("14"));XCTAssertTrue(app.buttons["lifeBalance"].label.hasPrefix("5 lives"))
        capture("build22-shuttle-last-move-shared-garden")
        app.terminate();app.launchArguments=["--uitesting","--keep-progress"];app.launch()
        XCTAssertTrue(app.buttons["openShuttle"].waitForExistence(timeout:15));XCTAssertEqual(try coins(),before+25)
        enter("shuttle");XCTAssertEqual(app.staticTexts["activityTitle"].label,"Sky Shuttle, challenge 2")
        capture("build22-shuttle-final-move-progress-after-relaunch")
    }
    private func solveShuttle(extraMoves:Int=0) throws {
        struct Ticket { let deck:Int;let window:Bool;let front:Bool;let mate:Int? }
        var tickets:[Ticket]=[]
        for id in 0..<12 {
            let label=app.buttons["passenger\(id)"].label
            let mate=label.components(separatedBy:"beside traveller ").dropFirst().first.flatMap(Int.init).map { $0-1 }
            tickets.append(Ticket(deck:label.contains("upper deck") ? 1 : 0,window:label.contains("window seat"),front:label.contains("front row"),mate:mate))
        }
        var plan=Array(repeating:-1,count:12),used:Set<Int>=[]
        func search(_ seat:Int)->Bool {
            if seat == 12 { return true }
            for id in 0..<12 where !used.contains(id) {
                let t=tickets[id]
                guard seat/6 == t.deck, !t.window || seat%3 != 1, !t.front || seat%6 < 3 else { continue }
                if let mate=t.mate,let other=plan.firstIndex(of:mate), (other/3 != seat/3 || abs(other%3-seat%3) != 1) { continue }
                plan[seat]=id;used.insert(id)
                if search(seat+1) { return true }
                used.remove(id);plan[seat] = -1
            };return false
        }
        XCTAssertTrue(search(0),"The visible tickets must admit a plan without knowing the game's seed")
        for move in 0..<extraMoves { app.buttons["passenger\(plan[0])"].tap();app.buttons["shuttleSeat\(1+move%2)"].tap() }
        for (seat,id) in plan.enumerated() { app.buttons["passenger\(id)"].tap();app.buttons["shuttleSeat\(seat)"].tap();XCTAssertEqual(app.buttons["shuttleSeat\(seat)"].value as? String,"Traveller \(id+1)") }
        if extraMoves > 0 {
            XCTAssertEqual(element("shuttleMoves").label,"0 moves remaining. All seated; depart to check the final plan")
            XCTAssertFalse(app.buttons["shuttleSeat0"].isEnabled);XCTAssertFalse(app.buttons["passenger\(plan[0])"].isEnabled)
            capture("build22-shuttle-zero-moves-valid-plan")
        }
        capture("build17-shuttle-tickets-seated");fits(app.buttons["shuttleDepart"]);app.buttons["shuttleDepart"].tap()
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
            XCTAssertEqual(seen.count, 4 + round, "Observe every real lantern demonstration before answering")
            for light in seen { app.buttons["fireflyLight\(light - 1)"].tap() }
        }
    }

    private func chargeWindmill() {
        app.buttons["windmillCharge"].tap()
        let dial = element("windmillDial")
        let charge = app.buttons["windmillCharge"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        for _ in 0..<6 {
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
