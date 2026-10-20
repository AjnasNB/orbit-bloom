import XCTest
@testable import OrbitBloomCore

final class IslandJourneyTests: XCTestCase {
    func testRallyAttemptIdentitySurvivesValueCopiesAndDiffersForEachNewRun() {
        var original=DeliveryRun(difficulty:2)
        let copy=original
        _=original.tick(0.25)
        XCTAssertEqual(original.id,copy.id)
        XCTAssertNotEqual(original.id,DeliveryRun(difficulty:2).id)
        XCTAssertEqual(copy.elapsed,0);XCTAssertEqual(original.elapsed,0.25)
    }
    func testRallyTrafficIncreasesWithTierAndEveryTierIsPlayable() {
        XCTAssertEqual(DeliveryRun(difficulty:-100).difficulty,2)
        XCTAssertEqual(DeliveryRun(difficulty:Int.max).difficulty,4)
        for tier in 0...4 {
            var run = DeliveryRun(difficulty:tier)
            XCTAssertEqual(run.obstacleCount,10+max(2,tier)*2)
            for index in 0..<run.obstacleCount {
                run.lane = (run.obstacleLane(index)+1)%3
                let crossing = run.crossingTime(index)
                while run.elapsed < crossing { _ = run.tick(min(0.05,crossing-run.elapsed)) }
            }
            while !run.finished { _ = run.tick(0.05) }
            XCTAssertTrue(run.won); XCTAssertEqual(run.health,3)
            XCTAssertEqual(run.collected,run.obstacleCount)
            XCTAssertEqual(run.distance,440)
            let reward = run.reward
            XCTAssertFalse(run.tick(100).pickup); XCTAssertEqual(run.reward,reward)
        }
        var invalid = DeliveryRun()
        _ = invalid.tick(.nan); _ = invalid.tick(.infinity)
        XCTAssertEqual(invalid.elapsed,0)
    }
    func testFirstClearsAdvanceInOrderAndCannotBeCreditedTwice() {
        var journey = IslandJourney()
        XCTAssertFalse(journey.complete(room:"canal",level:2,score:500))
        XCTAssertTrue(journey.complete(room:"canal",level:1,score:300))
        XCTAssertFalse(journey.complete(room:"canal",level:1,score:900))
        XCTAssertTrue(journey.complete(room:"canal",level:2,score:200))
        XCTAssertEqual(journey.levels["canal"],2); XCTAssertEqual(journey.bestScores["canal"],300)
        XCTAssertFalse(journey.complete(room:"unknown",level:1,score:100))
        XCTAssertFalse(journey.complete(room:"fireflies",level:1,score:Int.max))
        XCTAssertTrue(journey.isValid)
    }
    func testWorldwideScheduleUsesExactStartEndAndAutomaticGaps() throws {
        let boundary = Date(timeIntervalSince1970:21_600 * 100_000)
        let windows = WorldEvent.windows(at:boundary)
        let skill = windows[0]
        XCTAssertEqual(skill.id,"skills:100000")
        XCTAssertEqual(skill.room,"canal")
        XCTAssertEqual(windows.count,4)
        let shuttle = try XCTUnwrap(windows.first { $0.id == "shuttle:100000" })
        XCTAssertEqual(shuttle.room,"shuttle")
        XCTAssertEqual(shuttle.title,"Sky Shuttle relay")
        XCTAssertEqual(shuttle.tool,.bomb)
        XCTAssertTrue(shuttle.isActive(at:boundary))
        XCTAssertTrue(shuttle.isActive(at:shuttle.ends.addingTimeInterval(-0.001)))
        XCTAssertFalse(shuttle.isActive(at:shuttle.ends))
        XCTAssertTrue(skill.isActive(at:boundary))
        XCTAssertTrue(skill.isActive(at:skill.ends.addingTimeInterval(-0.001)))
        XCTAssertFalse(skill.isActive(at:skill.ends))
        let next = WorldEvent.windows(at:skill.ends)[0]
        XCTAssertFalse(next.isActive(at:skill.ends))
        XCTAssertEqual(next.starts.timeIntervalSince(boundary),21_600)
        XCTAssertEqual(next.room,"fireflies")
        XCTAssertEqual(WorldEvent.windows(at:Date(timeIntervalSince1970:boundary.timeIntervalSince1970)),WorldEvent.windows(at:boundary))
        XCTAssertTrue(WorldEvent.windows(at:Date(timeIntervalSince1970:-1)).isEmpty)
        XCTAssertTrue(WorldEvent.windows(at:Date(timeIntervalSince1970:1e100)).isEmpty)
    }

    func testShuttleEventProgressAndClaimsUseVersionedReceipts() throws {
        let now = Date(timeIntervalSince1970:21_600 * 100_000 + 10)
        let windows = WorldEvent.windows(at:now)
        let shuttle = try XCTUnwrap(windows.first { $0.room == "shuttle" })
        XCTAssertTrue(WorldEvent.validID(shuttle.id))
        var journey = IslandJourney()
        journey.record(room:"canal",at:now)
        XCTAssertEqual(journey.events["skills:100000"],1,"The existing event and rotation keep their original key")
        journey.record(room:"shuttle",at:now)
        journey.record(room:"shuttle",at:now)
        journey.record(room:"shuttle",at:now)
        XCTAssertEqual(journey.events[shuttle.id],3)
        XCTAssertTrue(journey.claim(shuttle,at:now))
        XCTAssertFalse(journey.claim(shuttle,at:now))
        XCTAssertTrue(journey.hasShuttleEventReceipts)
        XCTAssertTrue(journey.isValid)

        let save = try SavedGarden(playerKey:"shuttle",wallet:GardenWallet(journey:journey))
        XCTAssertEqual(save.schema,5)
        let decoded = try XCTUnwrap(SavedGarden.decode(save.encoded(),playerKey:"shuttle"))
        XCTAssertEqual(decoded.wallet.journey,journey)
        var previousBuild = save
        previousBuild.schema = 4
        XCTAssertNil(SavedGarden.decode(try previousBuild.encoded(),playerKey:"shuttle"),
            "Older builds must reject the new receipt format instead of dropping a claimed reward")
    }
    func testEventsCountCorrectRoomAndClaimOnlyOnceDuringActiveWindow() {
        let now = Date(timeIntervalSince1970:21_600 * 100_000 + 10)
        let event = WorldEvent.windows(at:now)[0]
        var journey = IslandJourney()
        journey.record(room:"rally",at:now)
        XCTAssertEqual(journey.events[event.id],nil)
        XCTAssertFalse(journey.claim(event,at:now))
        for _ in 0..<9 { journey.record(room:event.room,at:now) }
        XCTAssertEqual(journey.events[event.id],3)
        XCTAssertTrue(journey.claim(event,at:now))
        XCTAssertFalse(journey.claim(event,at:now))
        XCTAssertFalse(journey.claim(event,at:event.ends))
        journey.record(room:event.room,at:event.ends)
        XCTAssertNil(journey.events[event.id]); XCTAssertFalse(journey.claim(event,at:event.ends))
        XCTAssertTrue(journey.isValid)
    }
    func testAllJourneyDataSurvivesLocalAndCloudAndOldSchemasCannotEraseIt() throws {
        var journey = IslandJourney()
        _ = journey.complete(room:"observatory",level:1,score:500)
        let now = Date(timeIntervalSince1970:21_600 * 100_000 + 10)
        journey.record(room:"canal",at:now)
        var wallet = GardenWallet(journey:journey)
        let local = try JSONDecoder().decode(GardenWallet.self,from:JSONEncoder().encode(wallet))
        XCTAssertEqual(local.journey,journey)
        var cloud = SavedGarden(playerKey:"keeper",wallet:wallet)
        XCTAssertEqual(cloud.schema,3)
        XCTAssertEqual(SavedGarden.decode(try cloud.encoded(),playerKey:"keeper")?.wallet.journey,journey)
        cloud.schema = 2
        XCTAssertNil(SavedGarden.decode(try cloud.encoded(),playerKey:"keeper"))
        wallet.journey?.levels["canal"] = -1
        XCTAssertFalse(wallet.isValid)
        wallet.journey = IslandJourney(); wallet.journey?.claimedEvents = ["broken"]
        XCTAssertFalse(wallet.isValid)
        let legacy = GardenWallet()
        XCTAssertNil(try JSONDecoder().decode(GardenWallet.self,from:JSONEncoder().encode(legacy)).journey)
        XCTAssertNotNil(SavedGarden.decode(try SavedGarden(playerKey:"keeper",wallet:legacy).encoded(),playerKey:"keeper"))
    }
}
