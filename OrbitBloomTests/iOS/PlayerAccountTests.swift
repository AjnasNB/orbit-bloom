import XCTest
@testable import OrbitBloom

@MainActor final class MemoryGardenCloud: GardenCloudTransport {
    var gardens: [CloudGarden] = []
    var writes: [SavedGarden] = []
    var names: [String] = []
    var fetchFails = false
    var writeFails = false
    func fetch(playerKey: String) async throws -> [CloudGarden] {
        if fetchFails { throw URLError(.notConnectedToInternet) }
        return gardens.filter { $0.save.playerKey == playerKey }
    }
    func write(_ save: SavedGarden, name: String) async throws {
        if writeFails { throw URLError(.notConnectedToInternet) }
        writes.append(save); names.append(name)
    }
}

@MainActor final class PlayerAccountTests: XCTestCase {
    func defaults() -> UserDefaults { UserDefaults(suiteName: "orbitbloom.accounts.\(UUID())")! }
    func testLegacyWalletMigrationAndCorruptCheckpointRecovery() throws {
        let prefs = defaults()
        let game = GameModel(defaults: prefs)
        game.progress.coins = 703; game.save(); game.save()
        prefs.set(Data("broken".utf8), forKey: "orbitBloom.wallet.v2")
        let recovered = GameModel(defaults: prefs)
        XCTAssertEqual(recovered.progress.coins, 703)
        XCTAssertEqual(recovered.ecosystem.lives.total, 5)
    }
    func testAccountSwitchPreservesSeparateGardensAndPurchaseIdempotency() {
        let game = GameModel(defaults: defaults())
        game.progress.finish(level: 1, score: 500); game.useSaveAccount("alice")
        XCTAssertTrue(game.applyTransaction(productID: "com.orbitbloom.coins400", transactionID: "paid-a"))
        let aliceCoins = game.progress.coins
        game.useSaveAccount("bob")
        XCTAssertEqual(game.progress.coins, 160); XCTAssertEqual(game.progress.completed.count, 0)
        XCTAssertTrue(game.applyTransaction(productID: "com.orbitbloom.coins400", transactionID: "paid-a"))
        XCTAssertEqual(game.progress.coins, 160, "Changing Game Center accounts must not grant the same transaction twice")
        game.progress.coins = 199; game.save(); game.useSaveAccount("alice")
        XCTAssertEqual(game.progress.coins, aliceCoins); XCTAssertEqual(game.progress.completed.count, 1)
        game.useSaveAccount("bob"); XCTAssertEqual(game.progress.coins, 199)
    }
    func testCorruptAccountSaveAndUndoNeverExposeAnotherPlayersWallet() throws {
        let prefs = defaults()
        let profileGame = GameModel(defaults: prefs)
        profileGame.useSaveAccount("alice"); profileGame.progress.coins = 999; profileGame.save()
        XCTAssertTrue(profileGame.restoreWallet(GardenWallet()))
        XCTAssertTrue(profileGame.hasRestoreCheckpoint)
        profileGame.useSaveAccount("bob"); profileGame.progress.coins = 55; profileGame.save(); profileGame.save()
        XCTAssertFalse(profileGame.hasRestoreCheckpoint)
        prefs.set(Data("broken".utf8), forKey: "orbitBloom.player.bob")
        let recovered = GameModel(defaults: prefs)
        XCTAssertEqual(recovered.progress.coins, 55); XCTAssertEqual(recovered.saveAccount, "bob")
        XCTAssertFalse(recovered.hasRestoreCheckpoint)
        recovered.useSaveAccount("alice")
        prefs.set(Data("broken again".utf8), forKey: "orbitBloom.player.bob")
        recovered.useSaveAccount("bob")
        XCTAssertEqual(recovered.progress.coins, 55, "Switching accounts must also recover that player's own checkpoint")
        XCTAssertFalse(recovered.hasRestoreCheckpoint)
    }
    func testAppleCallbackTimeoutIgnoresLateReply() async {
        var completion: ((String?, Error?) -> Void)?
        do {
            let _: String = try await appleRequest(timeout: .milliseconds(10)) { completion = $0 }
            XCTFail("An unresponsive Apple request must time out")
        } catch { XCTAssertEqual((error as? URLError)?.code, .timedOut) }
        completion?("late save", nil)
        await Task.yield()
    }
    func testAppleCallbackCompletesOnceEvenIfDeliveredTwice() async throws {
        let value: String = try await appleRequest { completion in
            completion("saved", nil); completion("duplicate", nil)
        }
        XCTAssertEqual(value, "saved")
        await Task.yield()
    }
    func testNewPlayerBacksUpFullWalletAndDistinctDeviceFile() async {
        let prefs = defaults(), cloud = MemoryGardenCloud(), game = GameModel(defaults: defaults())
        game.progress.finish(level: 1, score: 800)
        let account = PlayerAccount(game: game, defaults: prefs, transport: cloud, deviceID: "iphone-one")
        account.enabled = true; await account.connect(playerID: "player-a", nickname: "Gardener")
        XCTAssertEqual(cloud.writes.count, 1)
        XCTAssertEqual(cloud.writes.first?.wallet.progress.completed.count, 1)
        XCTAssertTrue(cloud.names[0].hasSuffix("-iphone-one"))
        XCTAssertNotNil(account.lastBackup); XCTAssertEqual(account.status, "Backed up to iCloud")
    }
    func testOtherDeviceNeedsChoiceAndRestoreRetainsPuzzleAndCheckpoint() async throws {
        let prefs = defaults(), cloud = MemoryGardenCloud(), game = GameModel(defaults: defaults())
        let account = PlayerAccount(game: game, defaults: prefs, transport: cloud, deviceID: "new-iphone")
        account.enabled = true; await account.connect(playerID: "player-a", nickname: "Gardener")
        cloud.writes = []
        var wallet = GardenWallet(); wallet.progress.coins = 777
        wallet.session = GameEngine(level: Level.campaign[0], seed: 101).snapshot
        let remote = CloudGarden(save: SavedGarden(playerKey: try XCTUnwrap(account.playerKey), wallet: wallet), modified: Date(), deviceName: "iPad")
        cloud.gardens = [remote]; await account.checkSaves()
        XCTAssertEqual(account.choices.count, 1); XCTAssertTrue(cloud.writes.isEmpty)
        XCTAssertEqual(game.progress.coins, 160)
        await account.restore(remote)
        XCTAssertEqual(game.progress.coins, 777); XCTAssertEqual(game.engine?.moves, 10)
        XCTAssertTrue(account.choices.isEmpty); XCTAssertEqual(cloud.writes.count, 1)
        XCTAssertNotNil(game.wallet.session)
        XCTAssertTrue(game.hasRestoreCheckpoint)
        account.setEnabled(false)
        XCTAssertTrue(game.undoCloudRestore())
        XCTAssertEqual(game.progress.coins, 160); XCTAssertNil(game.engine)
        XCTAssertFalse(game.hasRestoreCheckpoint)
    }
    func testMissingPurchaseBackupCannotReplaceDeviceWallet() async throws {
        let prefs = defaults(), cloud = MemoryGardenCloud(), game = GameModel(defaults: defaults())
        let account = PlayerAccount(game: game, defaults: prefs, transport: cloud)
        account.enabled = true; await account.connect(playerID: "player-a", nickname: "Gardener")
        XCTAssertTrue(game.applyTransaction(productID: "com.orbitbloom.lives5", transactionID: "paid-life"))
        let remote = CloudGarden(save: SavedGarden(playerKey: try XCTUnwrap(account.playerKey), wallet: GardenWallet()), modified: Date(), deviceName: "iPad")
        cloud.gardens = [remote]; await account.checkSaves(); let before = cloud.writes.count
        await account.restore(remote)
        XCTAssertEqual(game.ecosystem.lives.reserve, 5); XCTAssertEqual(cloud.writes.count, before)
        XCTAssertTrue(account.status.contains("missing a purchase")); XCTAssertEqual(account.choices.count, 1)
        await account.keepDeviceGarden(); XCTAssertTrue(account.choices.isEmpty)
        XCTAssertEqual(cloud.writes.last?.wallet.ecosystem.lives.reserve, 5)
    }
    func testOfflineFetchNeverOverwritesUnknownCloudGarden() async {
        let cloud = MemoryGardenCloud(), game = GameModel(defaults: defaults())
        cloud.fetchFails = true
        let account = PlayerAccount(game: game, defaults: defaults(), transport: cloud)
        account.enabled = true; await account.connect(playerID: "player-a", nickname: "Gardener")
        await account.keepDeviceGarden(); await account.backup()
        XCTAssertTrue(cloud.writes.isEmpty); XCTAssertNil(account.lastBackup)
        XCTAssertEqual(game.progress.coins, 160); XCTAssertFalse(account.working)
        cloud.fetchFails = false; await account.checkSaves()
        XCTAssertEqual(cloud.writes.count, 1); XCTAssertNotNil(account.lastBackup)
    }
    func testFailedUploadShowsPendingAndRetryDoesNotDuplicateRewards() async {
        let cloud = MemoryGardenCloud(), game = GameModel(defaults: defaults())
        cloud.writeFails = true
        let account = PlayerAccount(game: game, defaults: defaults(), transport: cloud)
        account.enabled = true; await account.connect(playerID: "player-a", nickname: "Gardener")
        XCTAssertNil(account.lastBackup); XCTAssertTrue(account.status.contains("Backup waiting"))
        game.progress.coins = 123; game.save()
        cloud.writeFails = false; await account.backup()
        XCTAssertEqual(cloud.writes.last?.wallet.progress.coins, 123)
        XCTAssertEqual(game.progress.coins, 123); XCTAssertNotNil(account.lastBackup)
        account.setEnabled(false); game.save(); await account.backup()
        XCTAssertEqual(cloud.writes.count, 1)
    }
}
