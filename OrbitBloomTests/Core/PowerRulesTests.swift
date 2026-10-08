import XCTest
@testable import OrbitBloomCore

final class PowerRulesTests:XCTestCase {
    func testFixedFormationRules() {
        XCTAssertNil(PowerRules.tool(for:[0,1,2]))
        XCTAssertNil(PowerRules.tool(for:[0,1,2,28,35,42]))
        XCTAssertEqual(PowerRules.tool(for:[0,1,2,3]),.bomb)
        XCTAssertEqual(PowerRules.tool(for:[0,1,2,3,4]),.rainbow)
        XCTAssertEqual(PowerRules.tool(for:[0,7,14,15,16]),.tnt)
        XCTAssertEqual(PowerRules.tool(for:[3,10,17,24,16,18,15]),.mega)
    }
    func testSwipeMakesVisibleBoardPowerAndSaveKeepsIt() throws {
        let game = GameEngine(level:Level.campaign[11],seed:42)
        for col in [0,1,3] { _ = game.board.spawn(filling:.leaf,at:.init(column:col,row:0)) }
        _ = game.board.spawn(filling:.water,at:.init(column:2,row:0))
        _ = game.board.spawn(filling:.water,at:.init(column:4,row:0))
        _ = game.board.spawn(filling:.leaf,at:.init(column:2,row:1))
        let before = game.moves
        let turn = game.swap(9,2)
        XCTAssertTrue(turn.accepted); XCTAssertNotNil(turn.swappedCells)
        XCTAssertEqual(game.moves,before-1); XCTAssertEqual(game.powers[2],.bomb)
        let saved = try JSONDecoder().decode(GameEngine.Snapshot.self,from:JSONEncoder().encode(game.snapshot))
        let restored = try XCTUnwrap(GameEngine(snapshot:saved))
        XCTAssertEqual(restored.powers[2],.bomb)
        let count = restored.powers.count; restored.shuffle(); XCTAssertEqual(restored.powers.count,count)
    }
    func testBombTriggersNearbyTNTAndConsumesBothExactlyOnce() throws {
        let game = GameEngine(level:Level.campaign[11],seed:77)
        var saved = game.snapshot
        let center = try XCTUnwrap(game.cells.first(where:{$0.key == 24})), neighbor = try XCTUnwrap(game.cells.first(where:{$0.key == 25}))
        saved.specials = [center.id:.bomb,neighbor.id:.tnt]
        let restored = try XCTUnwrap(GameEngine(snapshot:saved))
        let turn = restored.detonate(at:24)
        XCTAssertTrue(turn.accepted); XCTAssertGreaterThan(turn.cascades[0].cleared.count,9)
        XCTAssertFalse(restored.specials.keys.contains(center.id)); XCTAssertFalse(restored.specials.keys.contains(neighbor.id))
        XCTAssertEqual(restored.moves,game.moves-1)
    }
    func testTenFreeHintsThenCoinsAndTaskRewardsCannotBeClaimedTwice() throws {
        var assistance = Assistance(), coins = 6
        for _ in 0..<10 { XCTAssertTrue(assistance.spendHint(coins:&coins)) }
        XCTAssertEqual(coins,6); XCTAssertEqual(assistance.freeHints,0)
        XCTAssertTrue(assistance.spendHint(coins:&coins)); XCTAssertEqual(coins,3)
        XCTAssertTrue(assistance.spendHint(coins:&coins)); XCTAssertFalse(assistance.spendHint(coins:&coins))
        var eco = Ecosystem(); eco.harvested = 3
        let task = try XCTUnwrap(FieldTask.all.first(where:{$0.id == "harvest3"})), before = eco.tools[.tnt,default:0]
        XCTAssertTrue(task.claim(progress:Progress(),ecosystem:&eco,assistance:&assistance))
        XCTAssertFalse(task.claim(progress:Progress(),ecosystem:&eco,assistance:&assistance))
        XCTAssertEqual(eco.tools[.tnt],before+1); XCTAssertEqual(assistance.shuffles,5)
    }
    func testLateExpeditionAndAssistBalancesSurviveSerialization() throws {
        XCTAssertEqual(Level.campaign.count,1020); XCTAssertEqual(Set(Level.campaign.map(\.id)).count,1020)
        let game = GameEngine(level:Level.campaign[1019],seed:1020)
        let restored = try XCTUnwrap(GameEngine(snapshot:JSONDecoder().decode(GameEngine.Snapshot.self,from:JSONEncoder().encode(game.snapshot))))
        XCTAssertEqual(restored.level.id,1020)
        var progress = Progress(); XCTAssertTrue(progress.finish(level:1019,score:2000)); XCTAssertEqual(progress.nextLevel,1020)
        var assistance = Assistance(); assistance.freeHints = 0; assistance.claimed = ["harvest3"]
        XCTAssertEqual(try JSONDecoder().decode(Assistance.self,from:JSONEncoder().encode(assistance)),assistance)
    }
}
