import XCTest
import Match3Kit
@testable import OrbitBloomCore

final class GameEngineTests: XCTestCase {
    func testBoardsStartStableAndAlwaysOfferAValidMove() {
        for seed in 1...100 {
            let game = GameEngine(level: Level.campaign[3], seed: UInt64(seed))
            XCTAssertEqual(game.cells.count, 49)
            XCTAssertTrue(game.board.findAllMatches().isEmpty, "seed \(seed)")
            XCTAssertNotNil(game.hint, "seed \(seed)")
        }
    }
    func testSeedReproducesOpeningAndRefill() throws {
        let a = GameEngine(level: Level.campaign[4], seed: 441)
        let b = GameEngine(level: Level.campaign[4], seed: 441)
        for _ in 0..<5 {
            XCTAssertEqual(a.cells.map(\.gem), b.cells.map(\.gem))
            let move = try XCTUnwrap(a.bestMove())
            _ = a.swap(move.0, move.1); _ = b.swap(move.0, move.1)
        }
        XCTAssertEqual(a.cells.map(\.gem), b.cells.map(\.gem))
        XCTAssertEqual(a.score, b.score)
    }
    func testInvalidSwapDoesNotSpendMoveOrChangeBoard() {
        let game = GameEngine(level: Level.campaign[0], seed: 101)
        let before = game.snapshot
        XCTAssertFalse(game.swap(0, 48).accepted)
        XCTAssertFalse(game.swap(-1, 4).accepted)
        XCTAssertFalse(game.swap(49, 50).accepted)
        XCTAssertEqual(game.moves, before.moves)
        XCTAssertEqual(game.cells.map(\.gem), before.grid.allIndices().map { before.grid[$0].filling })
        XCTAssertEqual(game.score, 0)
    }
    func testSwapsCascadeCollectAndLeavePlayableBoard() {
        let game = GameEngine(level: Level.campaign[11], seed: 1212)
        for _ in 0..<15 {
            guard !game.won, !game.lost, let move = game.bestMove() else { break }
            let before = game.moves
            let turn = game.swap(move.0, move.1)
            XCTAssertTrue(turn.accepted)
            XCTAssertEqual(game.moves, before - 1)
            XCTAssertGreaterThanOrEqual(turn.cascades.reduce(0) { $0 + $1.points }, 90)
            XCTAssertTrue(game.board.findAllMatches().isEmpty)
            XCTAssertNotNil(game.hint)
            XCTAssertEqual(game.cells.count, 49)
        }
        XCTAssertGreaterThan(game.collected.values.reduce(0, +), 0)
    }
    func testBurstClearsCrossAndFrostWithoutSpendingMove() {
        let game = GameEngine(level: Level.campaign[11], seed: 901)
        let frozen = game.frost.first!
        let before = game.moves
        let turn = game.burst(at: frozen)
        XCTAssertTrue(turn.accepted)
        XCTAssertEqual(turn.cascades.first?.cleared.count, 13)
        XCTAssertFalse(game.frost.contains(frozen))
        XCTAssertEqual(game.moves, before)
    }
    func testSessionRoundTripRetainsBoardGoalsMovesAndFrost() throws {
        let game = GameEngine(level: Level.campaign[7], seed: 431)
        let move = try XCTUnwrap(game.bestMove())
        _ = game.swap(move.0, move.1)
        let data = try JSONEncoder().encode(game.snapshot)
        let snapshot = try JSONDecoder().decode(GameEngine.Snapshot.self, from: data)
        let restored = try XCTUnwrap(GameEngine(snapshot: snapshot))
        XCTAssertEqual(restored.cells.map(\.id), game.cells.map(\.id))
        XCTAssertEqual(restored.cells.map(\.gem), game.cells.map(\.gem))
        XCTAssertEqual(restored.score, game.score)
        XCTAssertEqual(restored.moves, game.moves)
        XCTAssertEqual(restored.collected, game.collected)
        XCTAssertEqual(restored.frost, game.frost)
    }
    func testCampaignCanBeCompletedWithNormalMovesAndEarnedBursts() {
        var progress = Progress()
        var totalTurns = 0
        var totalRetries = 0
        for level in Level.campaign {
            var won = false
            for attempt in 0..<20 {
                let game = GameEngine(level: level, seed: UInt64(level.id * 101 + attempt))
                var charge = false
                while !game.won && !game.lost {
                    if charge {
                        let target = game.frost.first ?? game.cells.first(where: { game.collected[$0.gem, default: 0] < level.goals[$0.gem, default: 0] })?.key ?? 24
                        _ = game.burst(at: target)
                        charge = false
                    } else {
                        guard let move = game.bestMove() else { XCTFail("No legal move"); break }
                        let turn = game.swap(move.0, move.1)
                        XCTAssertTrue(turn.accepted)
                        charge = turn.earnedCharge
                        totalTurns += 1
                    }
                }
                if game.won {
                    XCTAssertTrue(progress.finish(level: level.id, score: game.score))
                    won = true; break
                }
                totalRetries += 1
            }
            XCTAssertTrue(won, "Level \(level.id) could not be won in 20 legal attempts")
        }
        XCTAssertTrue(progress.chapterComplete)
        for task in GardenTask.all { XCTAssertTrue(progress.restore(task.id)) }
        XCTAssertTrue(progress.gardenComplete)
        XCTAssertEqual(progress.stars, Level.total - 12)
        print("CAMPAIGN REPORT: all \(Level.total) levels and 6 garden projects complete; \(totalTurns) legal swaps, \(totalRetries) retries, no paid items or extra moves.")
    }
    func testLossRetryAndFreeShuffle() {
        let game = GameEngine(level: Level.campaign[11], seed: 12)
        let moves = game.moves
        game.shuffle()
        XCTAssertEqual(game.moves, moves)
        XCTAssertTrue(game.board.findAllMatches().isEmpty)
        XCTAssertNotNil(game.hint)
        // Spend all moves while deliberately avoiding the resource/frost-aware solver.
        while game.moves > 0 && !game.won {
            guard let move = game.hint else { return XCTFail("Unexpected dead board") }
            _ = game.swap(move.0, move.1)
        }
        XCTAssertTrue(game.won || game.lost)
        XCTAssertFalse(game.swap(0, 1).accepted)
        let retry = GameEngine(level: game.level, seed: 13)
        XCTAssertEqual(retry.score, 0)
        XCTAssertEqual(retry.moves, game.level.moves)
    }
}

final class ProgressTests: XCTestCase {
    func testFirstWinAwardsOneStarAndReplaysNeverDuplicateIt() {
        var progress = Progress()
        XCTAssertTrue(progress.finish(level: 1, score: 500))
        XCTAssertEqual(progress.stars, 1)
        XCTAssertEqual(progress.coins, 280)
        XCTAssertFalse(progress.finish(level: 1, score: 400))
        XCTAssertEqual(progress.stars, 1)
        XCTAssertEqual(progress.completed[1], 500)
        XCTAssertEqual(progress.coins, 310)
    }
    func testRestorationRequiresStarsAndOrderedProjects() {
        var progress = Progress()
        XCTAssertFalse(progress.restore(0))
        _ = progress.finish(level: 1, score: 500)
        _ = progress.finish(level: 2, score: 800)
        XCTAssertFalse(progress.restore(1))
        XCTAssertTrue(progress.restore(0))
        XCTAssertFalse(progress.restore(0))
        XCTAssertEqual(progress.stars, 0)
        XCTAssertEqual(progress.restored, [0])
    }
    func testCoinPurchaseCannotOverdrawBalance() {
        var progress = Progress()
        XCTAssertTrue(progress.buyBooster())
        XCTAssertTrue(progress.buyBooster())
        XCTAssertFalse(progress.buyBooster())
        XCTAssertEqual(progress.coins, 0)
        XCTAssertEqual(progress.boosters, 4)
    }
    func testProgressRoundTrip() throws {
        var progress = Progress()
        _ = progress.finish(level: 1, score: 500)
        _ = progress.finish(level: 2, score: 900)
        _ = progress.restore(0)
        XCTAssertEqual(try JSONDecoder().decode(Progress.self, from: JSONEncoder().encode(progress)), progress)
    }
}
