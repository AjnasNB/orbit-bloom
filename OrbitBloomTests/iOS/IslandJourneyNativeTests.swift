import XCTest
@testable import OrbitBloom

@MainActor private final class JourneyTestCloud: GardenCloudTransport {
    var gardens: [CloudGarden] = []
    var writes: [SavedGarden] = []
    func fetch(playerKey: String) async throws -> [CloudGarden] { gardens.filter { $0.save.playerKey == playerKey } }
    func write(_ save: SavedGarden, name: String) async throws { writes.append(save) }
}

@MainActor final class IslandJourneyNativeTests: XCTestCase {
    private enum PlayError: Error { case didNotFinish }
    private var suites: [String] = []

    override func tearDownWithError() throws {
        for name in suites { UserDefaults.standard.removePersistentDomain(forName: name) }
        suites.removeAll()
    }

    private func preferences() throws -> UserDefaults {
        let name = "orbitbloom.journey.tests.\(UUID().uuidString)"
        suites.append(name)
        return try XCTUnwrap(UserDefaults(suiteName: name))
    }

    /// Drive each real engine through legal input, then pass its winning score to the model.
    private func winningScore(_ kind: IslandActivityKind, level: Int) throws -> Int {
        switch kind {
        case .canal:
            var run = CanalWorksRun(level: level)
            for index in run.pipes.indices {
                for _ in 0..<4 where !run.finished && run.pipes[index] != run.solution[index] {
                    XCTAssertTrue(run.turnPipe(at: index))
                }
            }
            guard run.won else { XCTFail("Legal pipe rotations must finish this canal"); throw PlayError.didNotFinish }
            return run.score
        case .fireflies:
            var run = FireflySignalRun(level: level)
            for _ in 0..<run.rounds {
                XCTAssertTrue(run.beginPlayback()); run.finishPlayback()
                for light in run.sequence { XCTAssertTrue(run.selectLight(light)) }
            }
            guard run.won else { XCTFail("Repeating every demonstrated light must win"); throw PlayError.didNotFinish }
            return run.score
        case .windmill:
            var run = WindmillRhythmRun(level: level); run.start()
            for _ in 0..<2_000 where !run.finished {
                run.tick(0.02)
                if run.inWindow { XCTAssertTrue(run.charge()) }
            }
            guard run.won else { XCTFail("Charging in real timing windows must win"); throw PlayError.didNotFinish }
            return run.score
        case .observatory:
            var run = ObservatoryRun(level: level)
            for tile in run.scrambleHistory.reversed() where !run.won { XCTAssertTrue(run.slide(tile: tile)) }
            guard run.won else { XCTFail("Legal slides must restore this chart"); throw PlayError.didNotFinish }
            return run.score
        }
    }

    func testAllFourRealActivityWinsGrantEachFirstClearExactlyOnce() throws {
        let game = GameModel(defaults: try preferences())
        let initialCoins = game.progress.coins, initialStars = game.progress.stars
        let initialWater = game.ecosystem.water, initialLives = game.ecosystem.lives
        for (index, kind) in IslandActivityKind.allCases.enumerated() {
            game.enterActivity(kind)
            XCTAssertEqual(game.activity, kind); XCTAssertEqual(game.activityLevel, 1)
            let score = try winningScore(kind, level: game.activityLevel)
            XCTAssertGreaterThan(score, 0); game.completeActivity(score)
            XCTAssertEqual(game.journey.levels[kind.rawValue], 1)
            XCTAssertEqual(game.journey.bestScores[kind.rawValue], score)
            XCTAssertEqual(game.progress.coins, initialCoins + (index + 1) * 25)
            XCTAssertEqual(game.progress.stars, initialStars + index + 1)
            XCTAssertEqual(game.ecosystem.water, initialWater + (index + 1) * 2)
            for _ in 0..<3 { game.completeActivity(score + 100) }
            XCTAssertEqual(game.progress.coins, initialCoins + (index + 1) * 25, "Repeated result callbacks must not mint coins")
            XCTAssertEqual(game.progress.stars, initialStars + index + 1, "Repeated result callbacks must not mint stars")
            XCTAssertEqual(game.journey.bestScores[kind.rawValue], score)
            game.exitActivity()
        }
        XCTAssertEqual(game.ecosystem.lives, initialLives, "These four rooms must not charge puzzle lives")
        XCTAssertTrue(game.wallet.isValid)
    }

    func testNextChallengeAdvancesOnlyAfterWinningAndInvalidResultsMintNothing() throws {
        let game = GameModel(defaults: try preferences()), initial = Progress()
        game.completeActivity(500)
        XCTAssertEqual(game.progress, initial, "A detached callback without an active room must have no effect")
        game.enterActivity(.canal)
        game.completeActivity(-1); game.completeActivity(100_001)
        XCTAssertTrue(game.journey.levels.isEmpty); XCTAssertEqual(game.progress, initial)
        game.exitActivity(); game.enterActivity(.canal)
        XCTAssertEqual(game.activityLevel, 1, "Abandoning must retain the same unfinished challenge")
        game.completeActivity(try winningScore(.canal, level: 1))
        game.exitActivity(); game.enterActivity(.canal)
        XCTAssertEqual(game.activityLevel, 2)
        game.completeActivity(try winningScore(.canal, level: 2))
        XCTAssertEqual(game.journey.levels["canal"], 2)
        XCTAssertEqual(game.progress.stars, 2); XCTAssertEqual(game.progress.coins, initial.coins + 50)
    }

    func testCompletedJourneyAndResourcesSurviveLocalRelaunchAndCloudEncoding() throws {
        let prefs = try preferences(), game = GameModel(defaults: prefs)
        for kind in IslandActivityKind.allCases {
            game.enterActivity(kind); game.completeActivity(try winningScore(kind, level: 1)); game.exitActivity()
        }
        let expectedJourney = game.journey, expectedProgress = game.progress, expectedEcosystem = game.ecosystem
        let relaunched = GameModel(defaults: prefs)
        XCTAssertNil(relaunched.activity)
        XCTAssertEqual(relaunched.journey, expectedJourney)
        XCTAssertEqual(relaunched.progress, expectedProgress); XCTAssertEqual(relaunched.ecosystem, expectedEcosystem)
        let cloud = SavedGarden(playerKey: "player-one", wallet: relaunched.wallet)
        XCTAssertEqual(cloud.schema, 3)
        let decoded = try XCTUnwrap(SavedGarden.decode(cloud.encoded(), playerKey: "player-one"))
        XCTAssertEqual(decoded.wallet.journey, expectedJourney)
        XCTAssertEqual(decoded.wallet.progress, expectedProgress)
        XCTAssertEqual(decoded.wallet.ecosystem, expectedEcosystem)
        XCTAssertNil(SavedGarden.decode(try cloud.encoded(), playerKey: "another-player"))
    }

    func testFirstAppleAccountAdoptsGuestJourneyAndOtherPlayersStayIsolated() throws {
        let prefs = try preferences(), game = GameModel(defaults: prefs)
        game.enterActivity(.canal); game.completeActivity(try winningScore(.canal, level: 1)); game.exitActivity()
        let guestCoins = game.progress.coins
        game.useSaveAccount("alice")
        XCTAssertEqual(game.journey.levels["canal"], 1, "First sign-in must keep the guest's completed rooms")
        game.useSaveAccount("bob")
        XCTAssertTrue(game.journey.levels.isEmpty); XCTAssertEqual(game.progress.coins, 160)
        game.enterActivity(.fireflies); game.completeActivity(try winningScore(.fireflies, level: 1)); game.exitActivity()
        let relaunched = GameModel(defaults: prefs)
        XCTAssertEqual(relaunched.saveAccount, "bob")
        XCTAssertEqual(relaunched.journey.levels, ["fireflies": 1])
        relaunched.useSaveAccount("alice")
        XCTAssertEqual(relaunched.journey.levels, ["canal": 1]); XCTAssertEqual(relaunched.progress.coins, guestCoins)
        relaunched.useSaveAccount("bob")
        XCTAssertEqual(relaunched.journey.levels, ["fireflies": 1])
        XCTAssertEqual(relaunched.progress.stars, 1)
    }

    func testLocalRestoreCannotReplaceAnActiveRoomAndWorksAfterExit() throws {
        let game = GameModel(defaults: try preferences())
        var remote = GardenWallet(); remote.progress.coins = 777
        game.enterActivity(.observatory)
        let generation = game.saveGeneration
        XCTAssertFalse(game.restoreWallet(remote))
        XCTAssertEqual(game.activity, .observatory); XCTAssertEqual(game.progress.coins, 160)
        XCTAssertEqual(game.saveGeneration, generation); XCTAssertFalse(game.hasRestoreCheckpoint)
        game.exitActivity(); XCTAssertTrue(game.restoreWallet(remote))
        XCTAssertEqual(game.progress.coins, 777); XCTAssertNil(game.activity); XCTAssertTrue(game.hasRestoreCheckpoint)
    }

    func testAppleRestoreKeepsOfferedBackupDuringActivityAndExplainsTheBlock() async throws {
        let game = GameModel(defaults: try preferences()), cloud = JourneyTestCloud()
        let account = PlayerAccount(game: game, defaults: try preferences(), transport: cloud)
        account.enabled = true; await account.connect(playerID: "activity-player", nickname: "Keeper")
        var wallet = GardenWallet(); wallet.progress.coins = 777
        let remote = CloudGarden(save: SavedGarden(playerKey: try XCTUnwrap(account.playerKey), wallet: wallet), modified: Date(), deviceName: "iPad")
        cloud.gardens = [remote]; await account.checkSaves()
        let writeCount = cloud.writes.count
        game.enterActivity(.windmill); await account.restore(remote)
        XCTAssertEqual(account.choices.count, 1); XCTAssertEqual(cloud.writes.count, writeCount)
        XCTAssertEqual(game.activity, .windmill); XCTAssertEqual(game.progress.coins, 160)
        XCTAssertTrue(account.status.contains("Finish this action"), "An active room must be described as active gameplay, not a missing purchase")
        game.exitActivity(); await account.restore(remote)
        XCTAssertEqual(game.progress.coins, 777); XCTAssertTrue(account.choices.isEmpty)
        XCTAssertEqual(cloud.writes.last?.wallet.progress.coins, 777)
    }

    func testOldWalletWithoutJourneyKeepsPuzzleFarmPurchasesAndProgress() throws {
        let prefs = try preferences()
        var progress = Progress()
        for id in 1..<5 { progress.finish(level: id, score: 900 + id) }
        progress.coins = 843; progress.stars = 6; progress.restored = [0]
        var ecosystem = Ecosystem()
        ecosystem.lives.hearts = 3; ecosystem.lives.reserve = 5
        ecosystem.lives.nextAt = Date().addingTimeInterval(900)
        ecosystem.creditedTransactions = ["old-paid-transaction"]
        XCTAssertTrue(ecosystem.plant(2, crop: .apple, at: Date().addingTimeInterval(600)))
        let oldEngine = GameEngine(level: Level.legacyCampaign[4], seed: 1_021)
        var oldSession = oldEngine.snapshot; oldSession.rulesVersion = nil
        var assistance = Assistance(); assistance.freeHints = 7
        let old = GardenWallet(progress: progress, ecosystem: ecosystem, session: oldSession, charged: true, assistance: assistance)
        XCTAssertNil(old.journey); XCTAssertTrue(old.isValid)
        let data = try JSONEncoder().encode(old)
        XCTAssertNil((try JSONSerialization.jsonObject(with: data) as? [String: Any])?["journey"])
        prefs.set(data, forKey: "orbitBloom.wallet.v2")
        let restored = GameModel(defaults: prefs)
        XCTAssertEqual(restored.progress, progress); XCTAssertEqual(restored.ecosystem, ecosystem)
        XCTAssertEqual(restored.assistance, assistance); XCTAssertTrue(restored.charged)
        XCTAssertTrue(restored.journey.levels.isEmpty)
        let session = try XCTUnwrap(restored.engine?.snapshot)
        XCTAssertEqual(session.levelID, oldSession.levelID); XCTAssertEqual(session.moves, oldSession.moves)
        XCTAssertEqual(session.score, oldSession.score); XCTAssertEqual(session.collected, oldSession.collected)
        XCTAssertEqual(session.frost, oldSession.frost); XCTAssertEqual(session.grid.columns, oldSession.grid.columns)
        XCTAssertEqual(restored.engine?.level.rulesVersion, 1)
        restored.save()
        let again = GameModel(defaults: prefs)
        XCTAssertEqual(again.progress, progress); XCTAssertEqual(again.ecosystem, ecosystem)
        XCTAssertEqual(again.engine?.moves, oldSession.moves)
        XCTAssertEqual(again.wallet.journey, IslandJourney())
    }
}
