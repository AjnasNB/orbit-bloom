import XCTest
@testable import OrbitBloomCore

final class IslandActivitiesTests: XCTestCase {
    func testFourRoomsHaveStableSaveIdentifiersAndDifferentMechanics() throws {
        XCTAssertEqual(Set(IslandActivityKind.allCases.map(\.rawValue)), ["canal", "fireflies", "windmill", "observatory"])
        for kind in IslandActivityKind.allCases {
            XCTAssertEqual(try JSONDecoder().decode(IslandActivityKind.self, from: JSONEncoder().encode(kind)), kind)
            XCTAssertFalse(kind.title.isEmpty); XCTAssertFalse(kind.subtitle.isEmpty)
        }
    }

    func testEveryCanalLayoutHasAFreeSolutionWithinItsMoveBudget() {
        for level in 1...1_000 {
            var run = CanalWorksRun(level: level)
            XCTAssertFalse(run.won, "Stage \(level) must require play")
            for index in run.pipes.indices {
                while !run.finished && run.pipes[index] != run.solution[index] { XCTAssertTrue(run.turnPipe(at: index)) }
            }
            XCTAssertTrue(run.won, "Canal stage \(level) is not solvable")
            XCTAssertTrue(run.connectedCells.contains(run.outlet))
            XCTAssertGreaterThan(run.score, 0); XCTAssertLessThanOrEqual(run.score, 20_000)
            let savedMoves = run.moves
            XCTAssertFalse(run.turnPipe(at: 0)); XCTAssertEqual(run.moves, savedMoves)
        }
    }

    func testCanalLimitsTurnsAndIgnoresOutOfBoundsInputs() {
        var run = CanalWorksRun(level: 18)
        XCTAssertFalse(run.turnPipe(at: -1)); XCTAssertFalse(run.turnPipe(at: run.pipes.count))
        XCTAssertEqual(run.moves, 0)
        // Rotating a pipe away from the entrance cannot reach the final outlet.
        while !run.finished { XCTAssertTrue(run.turnPipe(at: run.outlet)) }
        XCTAssertFalse(run.won); XCTAssertEqual(run.movesRemaining, 0); XCTAssertEqual(run.score, 0)
        XCTAssertFalse(run.turnPipe(at: 0))
        XCTAssertGreaterThan(CanalWorksRun(level: 18).pipes.count, CanalWorksRun(level: 1).pipes.count)
    }

    func testFireflySequencesAdvanceOnlyAfterCorrectAnswersAndSurviveInterruptedPlayback() {
        var run = FireflySignalRun(level: 18)
        XCTAssertFalse(run.selectLight(0)); XCTAssertEqual(run.mistakes, 0)
        XCTAssertTrue(run.beginPlayback()); XCTAssertFalse(run.beginPlayback())
        let firstSequence = run.sequence
        run.interruptPlayback(); XCTAssertEqual(run.phase, .ready); XCTAssertEqual(run.sequence, firstSequence)
        for round in 0..<run.rounds {
            XCTAssertEqual(run.round, round); XCTAssertTrue(run.beginPlayback()); run.finishPlayback()
            let sequence = run.sequence
            XCTAssertEqual(sequence.count, run.initialLength + round)
            for light in sequence { XCTAssertTrue(run.selectLight(light)) }
        }
        XCTAssertTrue(run.won); XCTAssertGreaterThan(run.score, 0)
        let score = run.score
        XCTAssertFalse(run.selectLight(0)); XCTAssertFalse(run.beginPlayback()); XCTAssertEqual(run.score, score)
    }

    func testFireflyMistakesHaveFiniteRecoveryAndNoInvalidInputPenalty() {
        var run = FireflySignalRun(level: 1)
        for mistake in 1...2 {
            XCTAssertTrue(run.beginPlayback()); run.finishPlayback()
            XCTAssertFalse(run.selectLight(-1)); XCTAssertFalse(run.selectLight(4))
            XCTAssertEqual(run.mistakes, mistake - 1)
            XCTAssertFalse(run.selectLight((run.sequence[0] + 1) % 4))
            XCTAssertEqual(run.mistakes, mistake)
        }
        XCTAssertEqual(run.phase, .lost); XCTAssertFalse(run.won); XCTAssertEqual(run.score, 0)
        XCTAssertFalse(run.beginPlayback())
        XCTAssertGreaterThan(FireflySignalRun(level: 18).lights.count, FireflySignalRun(level: 1).lights.count)
    }

    func testWindmillTimingWindowsAllowEveryDifficultyToFinishWithoutPurchases() {
        for level in [1, 14, 15, 30, 100, 1_000] {
            var run = WindmillRhythmRun(level: level)
            XCTAssertFalse(run.charge()); run.start()
            for _ in 0..<4_000 {
                if run.finished { break }
                if run.inWindow { XCTAssertTrue(run.charge()) } else { run.tick(0.01) }
            }
            XCTAssertTrue(run.won, "Windmill stage \(level) did not have enough time")
            XCTAssertGreaterThan(run.score, 0); XCTAssertLessThanOrEqual(run.score, 20_000)
            let elapsed = run.elapsed, hits = run.hits
            run.tick(0.2); XCTAssertFalse(run.charge(guided: true))
            XCTAssertEqual(run.elapsed, elapsed); XCTAssertEqual(run.hits, hits)
        }
        XCTAssertLessThan(WindmillRhythmRun(level: 30).targetHalfWidth, WindmillRhythmRun(level: 1).targetHalfWidth)
        XCTAssertGreaterThan(WindmillRhythmRun(level: 15).targetHits, WindmillRhythmRun(level: 1).targetHits)
    }

    func testWindmillTimeoutMissesAndInvalidClockInputsCannotGrantPower() {
        var run = WindmillRhythmRun(level: 1)
        run.tick(0.2); XCTAssertEqual(run.elapsed, 0)
        run.start()
        for delta in [Double.nan, Double.infinity, -1, 0] { run.tick(delta) }
        XCTAssertEqual(run.elapsed, 0)
        run.tick(10_000); XCTAssertEqual(run.elapsed, 0.2)
        for _ in 0..<200 { run.tick(0.2) }
        XCTAssertTrue(run.finished); XCTAssertFalse(run.won); XCTAssertFalse(run.charge(guided: true))
        var missed = WindmillRhythmRun(level: 1); missed.start()
        for _ in 0..<3 { XCTAssertFalse(missed.charge()) }
        XCTAssertTrue(missed.finished); XCTAssertEqual(missed.misses, 3)
        var guided = WindmillRhythmRun(level: 30); guided.start()
        for _ in 0..<guided.targetHits { XCTAssertTrue(guided.charge(guided: true)) }
        XCTAssertTrue(guided.won)
    }

    func testAllObservatoryBoardsAreSolvableBySlidingWithinTheirBudgets() {
        for level in 1...1_000 {
            var run = ObservatoryRun(level: level)
            XCTAssertFalse(run.won); XCTAssertLessThan(run.aligned, run.goalCount)
            for tile in run.scrambleHistory.reversed() where !run.finished { XCTAssertTrue(run.slide(tile: tile)) }
            XCTAssertTrue(run.won, "Observatory stage \(level) could not reverse its legal scramble")
            XCTAssertEqual(run.tiles, Array(1..<(run.width * run.width)) + [0])
            XCTAssertGreaterThan(run.score, 0); XCTAssertLessThanOrEqual(run.score, 20_000)
            let savedMoves = run.moves
            XCTAssertFalse(run.slide(tile: 1)); XCTAssertEqual(run.moves, savedMoves)
        }
    }

    func testObservatoryOnlyMovesAdjacentStarsInTheSwipeDirectionAndEnforcesBudget() {
        var run = ObservatoryRun(level: 20)
        let neighbours = ObservatoryRun.neighbours(of: run.gap, width: run.width)
        let nonNeighbour = run.tiles.indices.first { !neighbours.contains($0) && run.tiles[$0] != 0 }!
        XCTAssertFalse(run.slide(tile: run.tiles[nonNeighbour])); XCTAssertEqual(run.moves, 0)
        XCTAssertFalse(run.slide(tile: -1)); XCTAssertFalse(run.slide(tile: 0)); XCTAssertFalse(run.slide(tile: Int.max))
        let index = neighbours[0], tile = run.tiles[index]
        let correct: IslandSwipeDirection
        if run.gap == index - run.width { correct = .up }
        else if run.gap == index + run.width { correct = .down }
        else if run.gap == index - 1 { correct = .left }
        else { correct = .right }
        let wrong: IslandSwipeDirection = correct == .left ? .right : .left
        XCTAssertFalse(run.slide(tile: tile, direction: wrong)); XCTAssertEqual(run.moves, 0)
        XCTAssertTrue(run.slide(tile: tile, direction: correct)); XCTAssertEqual(run.moves, 1)
        XCTAssertGreaterThan(ObservatoryRun(level: 20).tiles.count, ObservatoryRun(level: 1).tiles.count)

        var exhausted = ObservatoryRun(level: 20)
        let bouncingTile = exhausted.tiles[ObservatoryRun.neighbours(of: exhausted.gap, width: exhausted.width)[0]]
        while !exhausted.finished { XCTAssertTrue(exhausted.slide(tile: bouncingTile)) }
        XCTAssertFalse(exhausted.won); XCTAssertEqual(exhausted.movesRemaining, 0); XCTAssertEqual(exhausted.score, 0)
        XCTAssertFalse(exhausted.slide(tile: bouncingTile))
    }

    func testActivityLevelsClampUntrustedValuesBeforeBuildingBoardsOrScores() {
        for value in [Int.min, -1, 0, Int.max] {
            let expected = value <= 0 ? 1 : 1_000
            XCTAssertEqual(CanalWorksRun(level: value).level, expected)
            XCTAssertEqual(FireflySignalRun(level: value).level, expected)
            XCTAssertEqual(WindmillRhythmRun(level: value).level, expected)
            XCTAssertEqual(ObservatoryRun(level: value).level, expected)
        }
    }
}
