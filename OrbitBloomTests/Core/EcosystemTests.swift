import XCTest
@testable import OrbitBloomCore

final class EcosystemTests: XCTestCase {
    let now = Date(timeIntervalSince1970:100_000)
    func testExtremeLifeClockCannotOverflowAndStillCapsRegeneration() {
        var lives = LifeBank(); lives.hearts = 0
        lives.nextAt = Date(timeIntervalSince1970: -1e100)
        lives.refresh(at: now)
        XCTAssertEqual(lives.hearts, 5); XCTAssertNil(lives.nextAt)
        lives.nextAt = Date(timeIntervalSince1970: 1e100)
        XCTAssertEqual(lives.remaining(at: now), Int.max / 2)
        lives.nextAt = Date(timeIntervalSince1970: .infinity)
        XCTAssertEqual(lives.remaining(at: now), 0)
    }
    func testLivesRegenerateAtThirtyMinuteBoundaryAndPersistOffline() throws {
        var lives = LifeBank()
        for _ in 0..<5 { XCTAssertTrue(lives.spend(at:now)) }
        XCTAssertFalse(lives.spend(at:now))
        lives.refresh(at:now.addingTimeInterval(1799)); XCTAssertEqual(lives.hearts,0)
        lives.refresh(at:now.addingTimeInterval(1800)); XCTAssertEqual(lives.hearts,1)
        XCTAssertEqual(lives.remaining(at:now.addingTimeInterval(1800)),1800)
        var restored = try JSONDecoder().decode(LifeBank.self,from:JSONEncoder().encode(lives))
        restored.refresh(at:now.addingTimeInterval(1800*12)); XCTAssertEqual(restored.hearts,5); XCTAssertNil(restored.nextAt)
    }
    func testPurchasedReserveDoesNotExpireOrGetClampedAndClockRollbackGrantsNothing() {
        var lives = LifeBank(); lives.reserve = 15
        for _ in 0..<5 { _ = lives.spend(at:now) }
        lives.refresh(at:now.addingTimeInterval(-9000)); XCTAssertEqual(lives.hearts,0)
        XCTAssertTrue(lives.spend(at:now)); XCTAssertEqual(lives.reserve,14)
        lives.refresh(at:now.addingTimeInterval(90_000)); XCTAssertEqual(lives.total,19)
    }
    func testFarmRequiresResourcesAndCanHarvestExactlyOnceAfterOfflineGrowth() throws {
        var eco = Ecosystem()
        XCTAssertTrue(eco.plant(0,crop:.rose,at:now)); XCTAssertFalse(eco.plant(0,crop:.apple,at:now))
        XCTAssertNil(eco.harvest(0,at:now.addingTimeInterval(29)))
        var restored = try JSONDecoder().decode(Ecosystem.self,from:JSONEncoder().encode(eco))
        XCTAssertEqual(restored.harvest(0,at:now.addingTimeInterval(30)),35)
        XCTAssertNil(restored.harvest(0,at:now.addingTimeInterval(31)))
        XCTAssertEqual(restored.compost,1); XCTAssertEqual(restored.produce,2)
        XCTAssertTrue(restored.plant(0,crop:.apple,at:now)); XCTAssertTrue(restored.waterPlot(0,at:now))
        XCTAssertEqual(restored.plots[0].readyAt,now.addingTimeInterval(35))
        restored.water = 0; XCTAssertFalse(restored.plant(1,crop:.rose,at:now))
    }
    func testCraftingAndTransactionIdempotency() {
        var eco = Ecosystem(); XCTAssertFalse(eco.craft(.rainbow)); eco.compost = 6
        XCTAssertTrue(eco.craft(.rainbow)); XCTAssertEqual(eco.tools[.rainbow],2); XCTAssertEqual(eco.compost,0)
        XCTAssertTrue(eco.credit(.init(coins:400,lives:5),transaction:"Apple-123"))
        XCTAssertFalse(eco.credit(.init(coins:400,lives:5),transaction:"Apple-123")); XCTAssertEqual(eco.lives.reserve,5)
    }
    func testAllToolShapesAndRainbowTargetTheCorrectCells() {
        for tool in GardenTool.allCases {
            let game = GameEngine(level:Level.campaign[11],seed:71)
            let gems = game.cells; let selected = gems.first(where:{$0.key == 24})!.gem
            let turn = game.activate(tool,at:24)
            let cleared = turn.cascades.first!.cleared
            switch tool {
            case .bomb: XCTAssertEqual(cleared.count,9)
            case .tnt: XCTAssertEqual(cleared.count,13)
            case .mega: XCTAssertEqual(cleared.count,25)
            case .rainbow: XCTAssertEqual(cleared,Set(gems.filter{$0.gem == selected}.map(\.key)))
            }
            XCTAssertEqual(game.moves,game.level.moves)
        }
    }
    func testConnectedCircuitModeCanFinishTheWholeCampaign() {
        for attempt in 0..<5 {
            var eco = Ecosystem()
            for level in Level.opening {
                let game = GameEngine(level:level,seed:UInt64(level.id*101+attempt))
                var charge = false
                var turns = 0
                while !game.won && !game.lost {
                    if charge { _ = game.burst(at:game.frost.min() ?? 24); charge = false }
                    if let frozen = game.frost.min(), let tool = GardenTool.allCases.first(where:{eco.tools[$0,default:0]>0}) {
                        eco.tools[tool,default:0] -= 1; _ = game.activate(tool,at:frozen)
                    }
                    guard !game.won, let key = game.bestCluster() else { break }
                    let turn = game.harvestCluster(at:key); XCTAssertTrue(turn.accepted); turns += 1
                    charge = turn.earnedCharge
                }
                XCTAssertTrue(game.won,"Circuit \(level.id), seed set \(attempt) failed after \(turns) turns; frost \(game.frost.count)")
            }
        }
    }
    func testRaceCollisionsPickupsPauseAndFinishAreDeterministic() {
        var safe = DeliveryRun(); safe.lane = 0
        for _ in 0..<440 { _ = safe.tick(0.05) }
        if !safe.finished { _ = safe.tick(0.05) }
        XCTAssertTrue(safe.won); XCTAssertEqual(safe.health,1); XCTAssertEqual(safe.distance,440)
        let reward = safe.reward; _ = safe.tick(0.2); XCTAssertEqual(safe.reward,reward)
        var crash = DeliveryRun(); crash.lane = 1
        for _ in 0..<1000 { _ = crash.tick(0.05) }
        XCTAssertTrue(crash.finished); XCTAssertFalse(crash.won); XCTAssertEqual(crash.health,0)
    }
}
