import XCTest
@testable import OrbitBloomCore

final class SavedGardenTests: XCTestCase {
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
        save.schema = 2
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
