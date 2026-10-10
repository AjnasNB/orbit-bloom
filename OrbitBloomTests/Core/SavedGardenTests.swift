import XCTest
@testable import OrbitBloomCore

final class SavedGardenTests: XCTestCase {
    func testDifficultyUpdatePreservesLegacySessionsAndRejectsFutureRules() throws {
        let old = GameEngine(level:Level.legacyCampaign[79],seed:8080)
        var snapshot = old.snapshot; snapshot.rulesVersion = nil
        let restored = try XCTUnwrap(GameEngine(snapshot:snapshot))
        XCTAssertEqual(restored.level.rulesVersion,1)
        XCTAssertEqual(restored.level.moves,16)
        XCTAssertEqual(restored.level.goals,old.level.goals)
        XCTAssertEqual(restored.cells.map(\.id),old.cells.map(\.id))
        XCTAssertFalse(restored.level.isOneShot)
        var wallet = GardenWallet()
        for id in 1..<80 { _ = wallet.progress.finish(level:id,score:500) }
        wallet.session = snapshot
        XCTAssertTrue(wallet.isValid,"An old 16-turn save must survive the new one-turn stage definition")
        XCTAssertNotNil(SavedGarden.decode(try SavedGarden(playerKey:"player",wallet:wallet).encoded(),playerKey:"player"))
        wallet.session = GameEngine(level:Level.campaign[79],seed:8080).snapshot
        XCTAssertTrue(wallet.isValid)
        var newCloud = SavedGarden(playerKey:"player",wallet:wallet)
        XCTAssertEqual(newCloud.schema,2)
        XCTAssertNotNil(SavedGarden.decode(try newCloud.encoded(),playerKey:"player"))
        newCloud.schema = 1
        XCTAssertNil(SavedGarden.decode(try newCloud.encoded(),playerKey:"player"),"New active rules cannot masquerade as an older cloud format")
        let current = try XCTUnwrap(GameEngine(snapshot:try XCTUnwrap(wallet.session)))
        XCTAssertTrue(current.level.isOneShot); XCTAssertEqual(current.moves,1)
        snapshot.rulesVersion = 999; wallet.session = snapshot
        XCTAssertFalse(wallet.isValid); XCTAssertNil(GameEngine(snapshot:snapshot))
        snapshot.rulesVersion = 2; wallet.session = snapshot
        XCTAssertFalse(wallet.isValid,"Changing a legacy marker cannot grant excess turns to a one-shot stage")
    }
    func testMalformedTimersAreRejectedBeforeRestoring() throws {
        var wallet = GardenWallet()
        wallet.ecosystem.lives.hearts = 0
        wallet.ecosystem.lives.nextAt = Date(timeIntervalSince1970: -1e100)
        XCTAssertFalse(wallet.isValid)
        wallet.ecosystem.lives.nextAt = nil
        wallet.ecosystem.plots[0].crop = .apple
        wallet.ecosystem.plots[0].readyAt = Date(timeIntervalSince1970: 1e100)
        XCTAssertFalse(wallet.isValid)
        XCTAssertNil(SavedGarden.decode(try SavedGarden(playerKey: "player-a", wallet: wallet).encoded(), playerKey: "player-a"))
        wallet.ecosystem.plots[0].readyAt = nil
        XCTAssertFalse(wallet.isValid, "A planted crop must have a valid timer")
        wallet.ecosystem.plots[0] = FarmPlot(id: 0)
        var save = SavedGarden(playerKey: "player-a", wallet: wallet)
        save.savedAt = Date(timeIntervalSince1970: 1e100)
        XCTAssertNil(SavedGarden.decode(try save.encoded(), playerKey: "player-a"))
    }
    func testOversizedScoresAndCollectionsAreRejected() {
        var wallet = GardenWallet()
        wallet.progress.completed[1] = Int.max
        XCTAssertFalse(wallet.isValid)
        wallet.progress.completed = [:]
        var session = GameEngine(level: Level.campaign[0], seed: 101).snapshot
        session = .init(levelID: session.levelID, grid: session.grid, score: 0, moves: session.moves,
                        collected: [.leaf: Int.max], frost: session.frost, specials: session.specials)
        wallet.session = session
        XCTAssertFalse(wallet.isValid)
    }
    func testCompleteWalletSurvivesCloudEncoding() throws {
        var wallet = GardenWallet()
        wallet.progress.finish(level: 1, score: 500)
        wallet.ecosystem.plant(0, crop: .apple, at: Date(timeIntervalSince1970: 1000))
        wallet.ecosystem.lives.reserve = 7
        wallet.ecosystem.creditedTransactions = ["purchase-123"]
        wallet.assistance?.freeHints = 8
        let engine = GameEngine(level: Level.campaign[1], seed: 202)
        _ = engine.swap(try XCTUnwrap(engine.bestMove()).0, try XCTUnwrap(engine.bestMove()).1)
        wallet.session = engine.snapshot; wallet.charged = true
        let save = SavedGarden(playerKey: "player-a", wallet: wallet)
        let restored = try XCTUnwrap(SavedGarden.decode(save.encoded(), playerKey: "player-a"))
        XCTAssertEqual(restored.id, save.id)
        XCTAssertEqual(restored.wallet.progress, wallet.progress)
        XCTAssertEqual(restored.wallet.ecosystem, wallet.ecosystem)
        XCTAssertEqual(restored.wallet.assistance, wallet.assistance)
        XCTAssertEqual(restored.wallet.session?.moves, engine.moves)
        XCTAssertEqual(restored.wallet.charged, true)
    }
    func testForeignCorruptAndFutureSavesAreRejected() throws {
        var save = SavedGarden(playerKey: "player-a", wallet: GardenWallet())
        XCTAssertNil(SavedGarden.decode(try save.encoded(), playerKey: "player-b"))
        XCTAssertNil(SavedGarden.decode(Data("broken".utf8), playerKey: "player-a"))
        save.schema = 4
        XCTAssertNil(SavedGarden.decode(try save.encoded(), playerKey: "player-a"))
        save.schema = 1; save.wallet.progress.coins = -10
        XCTAssertNil(SavedGarden.decode(try save.encoded(), playerKey: "player-a"))
        save.wallet = GardenWallet(); save.wallet.ecosystem.plots = []
        XCTAssertNil(SavedGarden.decode(try save.encoded(), playerKey: "player-a"))
    }
    func testRestoreCannotRemovePaidReceiptsOrSumResources() {
        var current = GardenWallet(), cloud = GardenWallet()
        current.ecosystem.creditedTransactions = ["paid-a"]
        current.progress.coins = 90; cloud.progress.coins = 20
        XCTAssertFalse(cloud.canReplace(current))
        cloud.ecosystem.creditedTransactions = ["paid-a", "paid-b"]
        XCTAssertTrue(cloud.canReplace(current))
        XCTAssertEqual(cloud.progress.coins, 20)
    }
}
