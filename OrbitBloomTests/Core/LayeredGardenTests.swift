import XCTest
@testable import OrbitBloomCore

final class LayeredGardenTests:XCTestCase {
    func testObstaclesNeedSeparateActionsEvenWhenBlastsCascade() throws {
        for kind in ObstacleKind.allCases {
            let fresh=GameEngine(level:Level.campaign[0],seed:18)
            var snapshot=fresh.snapshot
            snapshot.obstacles=[24:BoardObstacle(kind)]
            let game=try XCTUnwrap(GameEngine(snapshot:snapshot))
            var seedRewards=0
            for hit in 1...kind.hits {
                let turn=game.activate(.mega,at:24)
                XCTAssertTrue(turn.accepted)
                seedRewards += turn.cascades.reduce(0) { $0+$1.seeds }
                if hit < kind.hits { XCTAssertEqual(game.obstacles[24]?.remaining,kind.hits-hit,"A cascade must not bypass a layer") }
                else { XCTAssertNil(game.obstacles[24]) }
            }
            XCTAssertEqual(seedRewards,kind == .sack ? 1 : 0)
            let restored=try XCTUnwrap(GameEngine(snapshot:game.snapshot))
            XCTAssertEqual(restored.obstacles,game.obstacles)
            XCTAssertEqual(restored.collected,game.collected)
        }
    }
    func testNearbyMatchDamagesLayersWithoutARequiredPaidPower() throws {
        let fresh=GameEngine(level:Level.campaign[0],seed:101)
        let move=try XCTUnwrap(fresh.bestMove())
        let cleared=try XCTUnwrap(fresh.swap(move.0,move.1).cascades.first?.cleared.first)
        let neighbour=cleared%7 < 6 ? cleared+1 : cleared-1
        var snapshot=GameEngine(level:Level.campaign[0],seed:101).snapshot
        snapshot.obstacles=[neighbour:BoardObstacle(.ice)]
        let game=try XCTUnwrap(GameEngine(snapshot:snapshot))
        XCTAssertTrue(game.swap(move.0,move.1).accepted)
        XCTAssertEqual(game.obstacles[neighbour]?.remaining,1)
        let intermediate=try XCTUnwrap(GameEngine(snapshot:game.snapshot))
        XCTAssertEqual(intermediate.obstacles[neighbour]?.remaining,1)
        var bad=game.snapshot; bad.obstacles?[neighbour]?.remaining=0
        XCTAssertNil(GameEngine(snapshot:bad))
        bad.obstacles=[49:BoardObstacle(.ice)]
        XCTAssertNil(GameEngine(snapshot:bad))
        bad=game.snapshot; bad.obstacles=nil
        XCTAssertNil(GameEngine(snapshot:bad))
    }
    func testOneNearbyMatchReleasesABuriedDiamondAndCannotPayItTwice() throws {
        let fresh=GameEngine(level:Level.campaign[0],seed:101)
        let move=try XCTUnwrap(fresh.bestMove())
        let cleared=try XCTUnwrap(fresh.swap(move.0,move.1).cascades.first?.cleared.first)
        let neighbour=cleared%7 < 6 ? cleared+1 : cleared-1
        var snapshot=GameEngine(level:Level.campaign[0],seed:101).snapshot
        snapshot.obstacles=[neighbour:BoardObstacle(.mud)]
        let game=try XCTUnwrap(GameEngine(snapshot:snapshot))
        XCTAssertTrue(game.swap(move.0,move.1).accepted);XCTAssertNil(game.obstacles[neighbour])
        XCTAssertGreaterThan(game.collected[.crystal,default:0],0)
        let restored=try XCTUnwrap(GameEngine(snapshot:game.snapshot))
        XCTAssertEqual(restored.collected,game.collected);XCTAssertNil(restored.obstacles[neighbour])
    }
    func testStartingPowersHaveThreeSlotsAndNeverChangeOneShotRules() {
        let game=GameEngine(level:Level.campaign[0],seed:101)
        game.seedPowers([.bomb,.tnt,.rainbow,.mega])
        XCTAssertEqual(game.powers.count,3)
        XCTAssertEqual(Set(game.powers.values),[.bomb,.tnt,.rainbow])
        let one=GameEngine(level:Level.campaign[29],seed:1),before=one.snapshot
        one.seedPowers([.mega,.rainbow])
        XCTAssertEqual(one.snapshot.specials,before.specials); XCTAssertEqual(one.moves,1)
    }
    func testMomentumCapsRewardsAndHelperIsOncePerLevel() {
        var momentum=GardenMomentum()
        for _ in 0..<7 { momentum.won(firstClear:true) }
        XCTAssertEqual(momentum.kit,[.bomb,.tnt,.rainbow]); XCTAssertEqual(momentum.wins,3)
        momentum.failed(); momentum.won(firstClear:false)
        XCTAssertTrue(momentum.kit.isEmpty)
        XCTAssertFalse(momentum.claimHelper(level:1))
        momentum.companion=true
        XCTAssertTrue(momentum.claimHelper(level:1)); XCTAssertFalse(momentum.claimHelper(level:1))
        XCTAssertFalse(momentum.claimHelper(level:0)); XCTAssertFalse(momentum.claimHelper(level:1021))
    }
    func testThreeFieldsPersistIndependentCropsAndRejectCorruptExtraSlots() throws {
        var eco=Ecosystem(); let now=Date(timeIntervalSince1970:100_000)
        for id in [0,6,17] { XCTAssertTrue(eco.plant(id,crop:id == 6 ? .rose : .apple,at:now)) }
        XCTAssertEqual(eco.field(0).count,6); XCTAssertEqual(eco.field(2).count,6)
        let restored=try JSONDecoder().decode(Ecosystem.self,from:JSONEncoder().encode(eco))
        XCTAssertEqual(restored,eco)
        XCTAssertEqual(eco.harvest(6,at:now.addingTimeInterval(31)),35)
        XCTAssertNil(eco.plot(6)?.crop); XCTAssertEqual(eco.plot(17)?.crop,.apple)
        var wallet=GardenWallet(ecosystem:eco)
        let cloud=SavedGarden(playerKey:"garden",wallet:wallet)
        XCTAssertEqual(cloud.schema,4)
        XCTAssertNotNil(SavedGarden.decode(try cloud.encoded(),playerKey:"garden"))
        var disguised=cloud; disguised.schema=3
        XCTAssertNil(SavedGarden.decode(try disguised.encoded(),playerKey:"garden"))
        wallet.ecosystem.extraPlots?.removeLast(); XCTAssertFalse(wallet.isValid)
    }
    func testNewCampaignIsHardAndOldActiveBoardsKeepTheirOriginalRules() throws {
        XCTAssertTrue(Level.campaign.allSatisfy { $0.isOneShot || ($0.difficulty != .simple && (10...16).contains($0.moves)) })
        for version in [1,2] {
            let old=version == 1 ? Level.legacyCampaign[0] : Level.versionTwoCampaign[0]
            let game=GameEngine(level:old,seed:101)
            let restored=try XCTUnwrap(GameEngine(snapshot:game.snapshot))
            XCTAssertEqual(restored.level.moves,old.moves); XCTAssertEqual(restored.level.goals,old.goals)
            XCTAssertEqual(restored.cells.map(\.id),game.cells.map(\.id)); XCTAssertTrue(restored.obstacles.isEmpty)
        }
    }
    func testAllThousandShuttlesHaveValidPlansAndFiniteTurnBudgets() {
        for level in 1...1000 {
            var run=ShuttleRun(level:level)
            XCTAssertEqual(Set(run.solution).count,12)
            for (position,id) in run.solution.enumerated() { XCTAssertTrue(run.seat(id,at:position)) }
            XCTAssertTrue(run.depart(),"Level \(level) must be solvable")
            XCTAssertEqual(run.rejected,[]); XCTAssertGreaterThan(run.score,0); XCTAssertLessThanOrEqual(run.score,20000)
            let moves=run.moves; XCTAssertFalse(run.seat(0,at:0)); XCTAssertEqual(run.moves,moves)
            var last=ShuttleRun(level:level)
            for move in 0..<(last.moveLimit-12) { XCTAssertTrue(last.seat(last.solution[0],at:1+move%2)) }
            for (seat,id) in last.solution.enumerated() { XCTAssertTrue(last.seat(id,at:seat)) }
            XCTAssertEqual(last.moves,last.moveLimit);XCTAssertFalse(last.canSeat)
            XCTAssertFalse(last.finished);XCTAssertTrue(last.depart(),"Final-seat ticket check at level \(level)")
        }
    }
    func testShuttleChecksDeckWindowFrontAndPairsAndAllowsCorrections() {
        var run=ShuttleRun(level:20)
        XCTAssertFalse(run.seat(-1,at:0)); XCTAssertFalse(run.seat(0,at:12)); XCTAssertEqual(run.moves,0)
        for (position,id) in run.solution.enumerated() { _=run.seat(id,at:(position+6)%12) }
        XCTAssertFalse(run.depart()); XCTAssertEqual(run.rejected.count,12)
        var fixed=ShuttleRun(level:20)
        for (position,id) in fixed.solution.enumerated() { _=fixed.seat(id,at:position) }
        let window=fixed.passengers.first { $0.window }!
        XCTAssertFalse(fixed.validSeat(window.deck*6+1,passenger:window))
        let front=fixed.passengers.first { $0.front }!
        XCTAssertFalse(fixed.validSeat(front.deck*6+3,passenger:front))
        let paired=fixed.passengers.first { $0.group != nil }!
        let actual=fixed.seats.firstIndex { $0 == paired.id }!
        XCTAssertTrue(fixed.validSeat(actual,passenger:paired))
        XCTAssertFalse(fixed.validSeat(paired.deck*6+(actual%6 < 3 ? 3 : 0),passenger:paired))
        XCTAssertTrue(fixed.depart())
    }
    func testShuttleMayValidateItsLastSeatWithoutAnotherPlacement() {
        for level in [1,20,1000] {
            var run=ShuttleRun(level:level)
            for move in 0..<(run.moveLimit-12) { XCTAssertTrue(run.seat(run.solution[0],at:1+move%2)) }
            for (seat,id) in run.solution.enumerated() { XCTAssertTrue(run.seat(id,at:seat)) }
            XCTAssertEqual(run.moves,run.moveLimit)
            XCTAssertFalse(run.finished,"A full plan on the final move still deserves its ticket check")
            let plan=run.seats
            XCTAssertFalse(run.seat(run.solution[0],at:1));XCTAssertEqual(run.seats,plan)
            XCTAssertTrue(run.depart(),"A correct final-move plan must depart")
            XCTAssertTrue(run.won)
        }
    }
    func testWrongFinalMoveShuttlePlanAndIncompleteBudgetCannotGetExtraMoves() {
        for level in [1,20,1000] {
            var wrong=ShuttleRun(level:level)
            for move in 0..<(wrong.moveLimit-12) { XCTAssertTrue(wrong.seat(wrong.solution[0],at:1+move%2)) }
            for (seat,id) in wrong.solution.enumerated() { XCTAssertTrue(wrong.seat(id,at:(seat+6)%12)) }
            XCTAssertFalse(wrong.finished);XCTAssertFalse(wrong.canSeat)
            XCTAssertFalse(wrong.depart());XCTAssertTrue(wrong.finished);XCTAssertFalse(wrong.won)
            XCTAssertEqual(wrong.moves,wrong.moveLimit);XCTAssertEqual(wrong.rejected.count,12)
            XCTAssertFalse(wrong.depart());XCTAssertFalse(wrong.seat(wrong.solution[0],at:0))
            var incomplete=ShuttleRun(level:level)
            for move in 0..<incomplete.moveLimit { XCTAssertTrue(incomplete.seat(0,at:move%2)) }
            XCTAssertTrue(incomplete.finished);XCTAssertFalse(incomplete.canSeat);XCTAssertFalse(incomplete.depart())
        }
    }
}
