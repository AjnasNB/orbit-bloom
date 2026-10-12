import XCTest
@testable import OrbitBloom

@MainActor final class ProgressionKitTests:XCTestCase {
    private var suites:[String]=[]
    override func tearDownWithError() throws { for name in suites { UserDefaults.standard.removePersistentDomain(forName:name) } }
    private func model() throws -> GameModel {
        let name="orbitbloom.kit.\(UUID().uuidString)"; suites.append(name)
        return GameModel(defaults:try XCTUnwrap(UserDefaults(suiteName:name)))
    }
    func testCancelLoadoutSpendsNothingAndThreePaidPowersAreSavedAtomically() throws {
        let game=try model(),before=game.wallet
        game.prepareStart(Level.campaign[0]); game.toggleLoadout(.bomb); game.toggleLoadout(.tnt); game.toggleLoadout(.rainbow); game.toggleLoadout(.mega)
        XCTAssertEqual(game.loadout.count,3); XCTAssertNil(game.engine)
        XCTAssertEqual(game.ecosystem,before.ecosystem)
        game.upcomingLevel=nil; game.loadout=[]
        XCTAssertEqual(game.ecosystem,before.ecosystem)
        game.prepareStart(Level.campaign[0]); game.toggleLoadout(.bomb); game.toggleLoadout(.tnt); game.toggleLoadout(.rainbow)
        var saved:[GardenWallet]=[]
        game.onSave={ saved.append(game.wallet) }
        XCTAssertTrue(game.beginPreparedAttempt())
        XCTAssertEqual(game.engine?.powers.count,3); XCTAssertEqual(game.ecosystem.lives.total,4)
        XCTAssertEqual(game.ecosystem.tools[.bomb],before.ecosystem.tools[.bomb]!-1)
        XCTAssertEqual(game.ecosystem.tools[.tnt],before.ecosystem.tools[.tnt]!-1)
        XCTAssertEqual(game.ecosystem.tools[.rainbow],before.ecosystem.tools[.rainbow]!-1)
        XCTAssertEqual(saved.count,1,"The saved board and consumed powers must be one checkpoint")
        XCTAssertEqual(saved[0].ecosystem,game.ecosystem)
        XCTAssertFalse(game.beginPreparedAttempt(),"Duplicate confirmation cannot spend another life")
    }
    func testFreeWinKitNeverConsumesInventoryAndAbandonClearsIt() throws {
        let game=try model(); game.momentum.wins=3
        let stock=game.ecosystem.tools
        game.prepareStart(Level.campaign[0]); XCTAssertEqual(game.loadout,[.bomb,.tnt,.rainbow])
        XCTAssertTrue(game.beginPreparedAttempt()); XCTAssertEqual(game.ecosystem.tools,stock)
        XCTAssertTrue(game.availableStreakKit.isEmpty,"An unfinished board cannot mint a second free kit")
        game.abandonCircuit(); XCTAssertEqual(game.momentum.wins,0)
        XCTAssertEqual(game.ecosystem.lives.total,4); XCTAssertEqual(game.ecosystem.tools,stock)
    }
    func testCompanionUsesGameCoinsOnceAndCannotFarmHintsByRestarting() throws {
        let game=try model(); game.progress.coins=240
        game.unlockCompanion(); game.unlockCompanion()
        XCTAssertEqual(game.progress.coins,40); XCTAssertTrue(game.momentum.companion)
        let hints=game.assistance.freeHints
        XCTAssertTrue(game.start(Level.campaign[0])); XCTAssertEqual(game.assistance.freeHints,hints+1)
        XCTAssertTrue(game.start(Level.campaign[0])); XCTAssertEqual(game.assistance.freeHints,hints+1)
        let cloud=SavedGarden(playerKey:"test-player",wallet:game.wallet)
        XCTAssertEqual(cloud.schema,4)
        let restored=try XCTUnwrap(SavedGarden.decode(try cloud.encoded(),playerKey:"test-player"))
        XCTAssertEqual(restored.wallet.momentum,game.momentum)
        XCTAssertEqual(restored.wallet.session?.obstacles,game.engine?.obstacles)
        XCTAssertEqual(restored.wallet.ecosystem,game.ecosystem)
    }
    func testNoLifeAndInvalidLoadoutsKeepWalletUnchanged() throws {
        let game=try model(); game.ecosystem.lives.hearts=0; game.ecosystem.lives.nextAt=Date().addingTimeInterval(1800)
        let before=game.wallet
        game.prepareStart(Level.campaign[0]); game.toggleLoadout(.bomb)
        XCTAssertFalse(game.beginPreparedAttempt()); XCTAssertNil(game.engine)
        XCTAssertEqual(game.ecosystem,before.ecosystem); XCTAssertEqual(game.progress,before.progress)
        game.ecosystem.lives.hearts=5
        game.loadout=[.bomb,.bomb]
        XCTAssertFalse(game.beginPreparedAttempt()); XCTAssertEqual(game.ecosystem.lives.hearts,5)
    }
    func testRallyStartsHardAndTightensAfterThreeAndSixSuccessfulDeliveries() throws {
        let game=try model()
        for (deliveries,expected) in [(0,2),(2,2),(3,3),(5,3),(6,4),(100,4)] {
            game.ecosystem.deliveries=deliveries
            XCTAssertEqual(game.rallyDifficulty,expected)
            var run=DeliveryRun(difficulty:game.rallyDifficulty)
            for _ in 0..<500 where !run.finished { if let traffic=run.nextTraffic { run.lane=traffic.coinLane }; _=run.tick(0.05) }
            XCTAssertTrue(run.won);XCTAssertEqual(run.health,3);XCTAssertEqual(run.collected,run.obstacleCount)
        }
    }
    func testThreeFarmFieldsUnlockInOrderAndSaveIndependentCrops() throws {
        let game=try model(); let initial=game.ecosystem
        XCTAssertEqual(game.farmFieldCount,1)
        game.farmAction(6,crop:.apple); XCTAssertEqual(game.ecosystem,initial)
        game.ecosystem.harvested=3; XCTAssertEqual(game.farmFieldCount,2)
        game.farmAction(6,crop:.apple); XCTAssertEqual(game.ecosystem.plot(6)?.crop,.apple)
        let second=game.ecosystem
        game.farmAction(12,crop:.rose); XCTAssertEqual(game.ecosystem,second)
        game.ecosystem.harvested=9; XCTAssertEqual(game.farmFieldCount,3)
        game.farmAction(12,crop:.rose); XCTAssertEqual(game.ecosystem.plot(12)?.crop,.rose)
        XCTAssertNil(game.ecosystem.plots[0].crop)
        XCTAssertTrue(game.wallet.isValid)
        let cloud=SavedGarden(playerKey:"farmer",wallet:game.wallet)
        let restored=try XCTUnwrap(SavedGarden.decode(try cloud.encoded(),playerKey:"farmer"))
        XCTAssertEqual(restored.wallet.ecosystem,game.ecosystem)
    }
}
