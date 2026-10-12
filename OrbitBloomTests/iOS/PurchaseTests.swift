import XCTest
import StoreKit
import StoreKitTest
import UIKit
@testable import OrbitBloom

@MainActor final class SpriteAssetTests: XCTestCase {
    func testFarmFieldRendersTheActualSavedSpeciesAndGrowthStage() throws {
        let now = Date(timeIntervalSince1970: 100_000)
        var eco = Ecosystem()
        XCTAssertTrue(eco.plant(0, crop: .apple, at: now))
        XCTAssertTrue(eco.plant(1, crop: .rose, at: now))
        let field = FarmFieldWorld()
        field.update(plots: eco.plots, now: now, interaction: nil, reducedMotion: true)
        XCTAssertNotNil(field.scene.rootNode.childNode(withName: "crop-0-apple-sprout", recursively: false))
        XCTAssertNotNil(field.scene.rootNode.childNode(withName: "crop-1-rose-sprout", recursively: false))
        field.update(plots: eco.plots, now: now.addingTimeInterval(46), interaction: nil, reducedMotion: true)
        let apple = try XCTUnwrap(field.scene.rootNode.childNode(withName: "crop-0-apple-ripe", recursively: false))
        XCTAssertEqual(apple.childNodes.filter { $0.name == "ripe-apple" }.count, 7)
        XCTAssertNotNil(field.scene.rootNode.childNode(withName: "crop-1-rose-ripe", recursively: false))
        XCTAssertEqual(eco.harvest(0, at: now.addingTimeInterval(46)), 50)
        field.update(plots: eco.plots, now: now.addingTimeInterval(46), interaction: nil, reducedMotion: true)
        XCTAssertNil(field.scene.rootNode.childNode(withName: "crop-0-apple-ripe", recursively: false))
        XCTAssertNotNil(field.scene.rootNode.childNode(withName: "crop-1-rose-ripe", recursively: false))
        XCTAssertEqual(eco.harvested, 1)
    }
    func testCartoonAtlasHasTwelveVisibleSpritesWithTransparentGutters() throws {
        XCTAssertEqual(BotanicalSprites.images.count,12)
        for (index,image) in BotanicalSprites.images.enumerated() {
            let sprite = try XCTUnwrap(image.cgImage,"Missing sprite \(index)")
            XCTAssertGreaterThanOrEqual(sprite.width,256)
            XCTAssertGreaterThanOrEqual(sprite.height,256)
            let side=64
            var pixels=[UInt8](repeating:0,count:side*side*4)
            try pixels.withUnsafeMutableBytes { bytes in
                let context = try XCTUnwrap(CGContext(data:bytes.baseAddress,width:side,height:side,
                    bitsPerComponent:8,bytesPerRow:side*4,space:CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue))
                context.draw(sprite,in:CGRect(x:0,y:0,width:side,height:side))
            }
            let visible=(0..<side*side).filter { pixels[$0*4+3] > 16 }
            XCTAssertGreaterThan(visible.count,side*side/5,"Sprite \(index) must be visible")
            for key in visible {
                XCTAssertTrue(key%side > 0 && key%side < side-1 && key/side > 0 && key/side < side-1,
                    "Sprite \(index) crosses its gutter and could bleed into another tool")
            }
        }
        for name in ["KeeperLio","RallyRover","PocketApple"] {
            let image=try XCTUnwrap(UIImage(named:name)?.cgImage,"Missing \(name)")
            XCTAssertGreaterThanOrEqual(image.width,512)
            XCTAssertTrue([CGImageAlphaInfo.last,.first,.premultipliedLast,.premultipliedFirst].contains(image.alphaInfo),
                "\(name) must retain transparency")
        }
    }
}

@MainActor final class PurchaseTests: XCTestCase {
    var session: SKTestSession!
    override func setUpWithError() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "OrbitBloom", withExtension: "storekit"))
        session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState(); session.clearTransactions(); session.disableDialogs = true
    }
    func loadedStore() async throws -> PurchaseStore {
        let store = PurchaseStore()
        for _ in 0..<80 {
            if store.product != nil { return store }
            try await Task.sleep(for: .milliseconds(100))
        }
        throw XCTSkip("Installed StoreKit test service cannot load the local product (SKInternalErrorDomain 3 on iOS 26.5). Rerun on a working runtime or signed sandbox device.")
    }
    func waitForAurora(_ store:PurchaseStore,owned:Bool) async throws {
        for _ in 0..<50 {
            await store.refreshEntitlements()
            if store.ownsAurora == owned { return }
            try await Task.sleep(for:.milliseconds(100))
        }
        XCTAssertEqual(store.ownsAurora,owned,"Apple entitlement updates must arrive within five seconds")
    }
    func testAppleConsumableCreditsCoinsAndDoesNotDoubleCredit() async throws {
        let store = try await loadedStore()
        let defaults = UserDefaults(suiteName:"orbitbloom.purchase.\(UUID().uuidString)")!
        let model = GameModel(defaults:defaults); store.game = model
        let before = model.progress.coins
        guard store.products["com.orbitbloom.coins400"] != nil else { throw XCTSkip("Apple local consumable product did not load") }
        await store.purchase("com.orbitbloom.coins400")
        XCTAssertEqual(model.progress.coins,before+400)
        await store.recoverUnfinished(); XCTAssertEqual(model.progress.coins,before+400)
    }
    func testAppleLivesAndStarterCreditsPersistWithoutDuplicateRestore() async throws {
        let store = try await loadedStore()
        let suite = "orbitbloom.purchase.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let model = GameModel(defaults:defaults); store.game = model
        await store.purchase("com.orbitbloom.lives5")
        XCTAssertEqual(model.ecosystem.lives.reserve,5)
        let before = model.progress.coins
        await store.purchase("com.orbitbloom.starter")
        XCTAssertEqual(model.progress.coins,before+600)
        XCTAssertEqual(model.ecosystem.lives.reserve,8)
        let restored = GameModel(defaults:defaults); store.game = restored
        await store.restore(); await store.recoverUnfinished()
        XCTAssertEqual(restored.progress.coins,before+600)
        XCTAssertEqual(restored.ecosystem.lives.reserve,8)
    }
    func testPurchaseAndRestoreNonConsumable() async throws {
        let store = try await loadedStore()
        XCTAssertEqual(store.product?.id, PurchaseStore.productID)
        XCTAssertFalse(store.ownsAurora)
        await store.purchase()
        XCTAssertTrue(store.ownsAurora)
        let relaunchedStore = PurchaseStore()
        await relaunchedStore.load()
        try await waitForAurora(relaunchedStore,owned:true)
        XCTAssertTrue(relaunchedStore.ownsAurora, "A new app instance must read the Apple entitlement")
        await relaunchedStore.restore()
        XCTAssertTrue(relaunchedStore.ownsAurora)
        XCTAssertEqual(session.allTransactions().count, 1)
    }
    func testCancelledPurchaseDoesNotUnlockAnything() async throws {
        let store = try await loadedStore()
        try await session.setSimulatedError(.generic(.userCancelled), forAPI: .purchase)
        await store.purchase()
        XCTAssertFalse(store.ownsAurora)
        XCTAssertFalse(store.purchasing)
        XCTAssertNotNil(store.status)
        try await session.setSimulatedError(nil, forAPI: .purchase)
    }
    func testRefundRevokesEntitlement() async throws {
        let store = try await loadedStore(); await store.purchase()
        XCTAssertTrue(store.ownsAurora)
        let transaction = try XCTUnwrap(session.allTransactions().first)
        try session.refundTransaction(identifier: transaction.identifier)
        try await waitForAurora(store,owned:false)
        XCTAssertFalse(store.ownsAurora)
    }
    func testPendingAskToBuyDoesNotUnlockBeforeApproval() async throws {
        session.askToBuyEnabled = true
        let store = try await loadedStore(); await store.purchase()
        XCTAssertFalse(store.ownsAurora)
        XCTAssertTrue(store.status?.contains("approval") == true)
        let pending = try XCTUnwrap(session.allTransactions().first)
        try session.approveAskToBuyTransaction(identifier: pending.identifier)
        try await waitForAurora(store,owned:true)
        XCTAssertTrue(store.ownsAurora)
    }
}

@MainActor final class SessionTests: XCTestCase {
    func testRepeatedHarvestCannotReplantOrSpendTheSavedResources() async throws {
        let name = "farm-harvest-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let game = GameModel(defaults: defaults)
        XCTAssertTrue(game.ecosystem.plant(0, crop: .rose, at: Date().addingTimeInterval(-31)))
        let coins = game.progress.coins
        let seeds = game.ecosystem.seeds
        let water = game.ecosystem.water
        game.farmAction(0, crop: .rose)
        let harvested = game.wallet
        func sameHarvest(_ wallet: GardenWallet) {
            XCTAssertEqual(wallet.progress, harvested.progress)
            XCTAssertEqual(wallet.ecosystem, harvested.ecosystem)
            XCTAssertEqual(wallet.assistance, harvested.assistance)
            XCTAssertEqual(wallet.journey, harvested.journey)
            XCTAssertEqual(wallet.charged, harvested.charged)
            XCTAssertNil(wallet.session)
        }
        game.farmAction(0, crop: .rose)
        XCTAssertNil(game.ecosystem.plots[0].crop, "A repeated harvest must leave the soil empty")
        XCTAssertEqual(game.ecosystem.seeds, seeds + 1)
        XCTAssertEqual(game.ecosystem.water, water, "A repeated tap must not silently spend planting water")
        XCTAssertEqual(game.progress.coins, coins + Crop.rose.coins)
        sameHarvest(game.wallet)
        let restored = GameModel(defaults: defaults)
        sameHarvest(restored.wallet)
        XCTAssertTrue(restored.harvestingPlots.isEmpty, "Animation state must never enter the saved wallet")
    }
    func testHarvestProtectionIsPerPatchAndAllowsDeliberateReplanting() async throws {
        let name = "farm-harvest-flow-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let game = GameModel(defaults: defaults)
        let coins = game.progress.coins
        XCTAssertTrue(game.ecosystem.plant(0, crop: .apple, at: Date().addingTimeInterval(-46)))
        XCTAssertTrue(game.ecosystem.plant(1, crop: .rose, at: Date().addingTimeInterval(-31)))
        game.farmAction(0, crop: .apple); game.farmAction(1, crop: .rose)
        XCTAssertEqual(game.ecosystem.harvested, 2)
        XCTAssertEqual(game.progress.coins, coins + Crop.apple.coins + Crop.rose.coins)
        game.farmAction(2, crop: .apple); game.farmAction(2, crop: .apple)
        XCTAssertEqual(game.ecosystem.plots[2].crop, .apple)
        XCTAssertEqual(game.ecosystem.water, 5, "Other patches can plant and water during a harvest")
        let water = game.ecosystem.water
        let seeds = game.ecosystem.seeds
        game.farmAction(-1, crop: .rose); game.farmAction(6, crop: .rose)
        game.farmAction(0, crop: .rose)
        XCTAssertEqual(game.ecosystem.water, water); XCTAssertEqual(game.ecosystem.seeds, seeds)
        try await Task.sleep(for: .milliseconds(1250))
        XCTAssertTrue(game.harvestingPlots.isEmpty)
        game.farmAction(0, crop: .rose)
        XCTAssertEqual(game.ecosystem.plots[0].crop, .rose)
        XCTAssertEqual(game.ecosystem.water, water - 2); XCTAssertEqual(game.ecosystem.seeds, seeds - 1)
        XCTAssertEqual(GameModel(defaults: defaults).ecosystem, game.ecosystem)
    }
    func testAnimatedShuffleBlocksMovingTargetsAndSavesOneSpentShuffle() async throws {
        try XCTSkipIf(UIAccessibility.isReduceMotionEnabled,"This case checks the animated input window")
        let suite = "orbitbloom.shuffle.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let model = GameModel(defaults:defaults)
        model.start(Level.campaign[0])
        let moves=model.moves,coins=model.progress.coins,lives=model.ecosystem.lives.total
        let shuffles=model.assistance.shuffles
        model.shuffle()
        XCTAssertTrue(model.busy)
        let arrangement=model.cells.map(\.id)
        model.tap(24); model.swipe(24,dx:32,dy:0); model.shuffle()
        XCTAssertEqual(model.cells.map(\.id),arrangement)
        XCTAssertEqual(model.moves,moves)
        XCTAssertEqual(model.assistance.shuffles,shuffles-1)
        XCTAssertEqual(model.progress.coins,coins); XCTAssertEqual(model.ecosystem.lives.total,lives)
        let recovered=GameModel(defaults:defaults)
        XCTAssertEqual(recovered.cells.map(\.id),arrangement)
        XCTAssertEqual(recovered.assistance.shuffles,shuffles-1)
        for _ in 0..<30 {
            if !model.busy { break }
            try await Task.sleep(for:.milliseconds(50))
        }
        XCTAssertFalse(model.busy)
        let move=try XCTUnwrap(model.engine?.bestMove())
        model.swipe(move.0,dx:CGFloat(move.1%7-move.0%7)*32,dy:CGFloat(move.0/7-move.1/7)*32)
        XCTAssertEqual(model.engine?.moves,moves-1,"The completed shuffle must reopen actual gameplay")
        for _ in 0..<100 {
            if !model.busy { break }
            try await Task.sleep(for:.milliseconds(50))
        }
        XCTAssertFalse(model.busy)
    }
    func testAbandonKeepsExactlyTheStartedLifeSpentAndSurvivesRelaunch() throws {
        let suite = "orbitbloom.abandon.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let model = GameModel(defaults:defaults), coins = model.progress.coins
        model.start(Level.campaign[0]); let board = model.cells.map(\.id)
        XCTAssertEqual(model.ecosystem.lives.total,4)
        model.paused = true; model.paused = false
        XCTAssertEqual(model.cells.map(\.id),board); XCTAssertEqual(model.ecosystem.lives.total,4)
        model.tab = 4; model.abandonCircuit(); model.abandonCircuit()
        XCTAssertNil(model.engine); XCTAssertEqual(model.tab,0)
        XCTAssertEqual(model.ecosystem.lives.total,4,"Leaving must not charge a second life")
        XCTAssertEqual(model.progress.coins,coins)
        let restored = GameModel(defaults:defaults)
        XCTAssertNil(restored.engine); XCTAssertEqual(restored.ecosystem.lives.total,4)
        restored.start(Level.campaign[0]); XCTAssertEqual(restored.ecosystem.lives.total,3)
        restored.start(Level.campaign[0]); XCTAssertEqual(restored.ecosystem.lives.total,2,"Restarting starts another paid-in-life attempt")
        restored.abandonCircuit(); XCTAssertEqual(restored.ecosystem.lives.total,2)
    }
    func testOneShotBlockedAssistanceKeepsEveryInventoryBalance() throws {
        let suite = "orbitbloom.oneshot.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let model = GameModel(defaults:defaults)
        for id in 1..<30 { _ = model.progress.finish(level:id,score:500) }
        model.start(Level.campaign[29])
        let tools = model.ecosystem.tools, boosters = model.progress.boosters, assistance = model.assistance, coins = model.progress.coins
        model.selectTool(.tnt); model.toggleBurst(); model.shuffle()
        XCTAssertNil(model.pendingTool); XCTAssertFalse(model.burstMode)
        XCTAssertEqual(model.ecosystem.tools,tools); XCTAssertEqual(model.progress.boosters,boosters)
        XCTAssertEqual(model.assistance,assistance); XCTAssertEqual(model.progress.coins,coins)
        XCTAssertEqual(model.moves,1)
    }
    func testLockedCircuitCannotSpendLifeOrReplaceSession() throws {
        let suite = "orbitbloom.lock.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let model = GameModel(defaults:defaults)
        let lives = model.ecosystem.lives.total
        model.start(Level.campaign[1])
        XCTAssertNil(model.engine); XCTAssertEqual(model.ecosystem.lives.total,lives)
        model.start(Level.campaign[0]); let ids = model.cells.map(\.id)
        model.start(Level.campaign[2])
        XCTAssertEqual(model.engine?.level.id,1); XCTAssertEqual(model.cells.map(\.id),ids)
        XCTAssertEqual(model.ecosystem.lives.total,lives-1)
    }
    func testPuzzleWaterPersistsBeforeAnimationAndIsNotCreditedTwice() async throws {
        let suite = "orbitbloom.water.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let model = GameModel(defaults:defaults)
        model.start(Level.campaign[0])
        let before = model.ecosystem.water
        let prediction = try XCTUnwrap(GameEngine(snapshot:try XCTUnwrap(model.engine).snapshot))
        let turn = prediction.activate(.tnt,at:24)
        let dew = turn.cascades.reduce(0) { $0 + $1.collected[.water,default:0] }
        XCTAssertGreaterThan(dew,0,"The actual board must collect water for this interruption regression")

        model.selectTool(.tnt); model.tap(24)
        XCTAssertTrue(model.busy,"Verify the save before the animation finishes")
        let interrupted = GameModel(defaults:defaults)
        XCTAssertEqual(interrupted.ecosystem.water,before+dew)
        XCTAssertEqual(interrupted.cells.map(\.id),try XCTUnwrap(model.engine).cells.map(\.id))
        XCTAssertEqual(interrupted.ecosystem.tools[.tnt],1)

        for _ in 0..<100 {
            if !model.busy { break }
            try await Task.sleep(for:.milliseconds(50))
        }
        XCTAssertFalse(model.busy)
        XCTAssertEqual(model.ecosystem.water,before+dew,"Finishing animation must not grant water again")
        XCTAssertEqual(GameModel(defaults:defaults).ecosystem.water,before+dew)
    }
    func testInProgressPuzzleResumesAfterModelRecreation() async throws {
        let suite = "orbitbloom.test.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let model = GameModel(defaults: defaults)
        for level in 1...3 { _ = model.progress.finish(level:level,score:500) }
        model.start(Level.campaign[3])
        model.engine?.shuffle(); model.sync(); model.charged = true; model.save()
        let restored = GameModel(defaults: defaults)
        XCTAssertEqual(restored.cells.map(\.id), model.cells.map(\.id))
        XCTAssertEqual(restored.moves, model.moves)
        XCTAssertEqual(restored.frost, model.frost)
        XCTAssertTrue(restored.charged)
    }
    func testWonSessionRecoversRewardAfterInterruptedAnimation() throws {
        let suite = "orbitbloom.test.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let engine = GameEngine(level: Level.campaign[0], seed: 101)
        while !engine.won && !engine.lost { let move = try XCTUnwrap(engine.bestMove()); _ = engine.swap(move.0, move.1) }
        XCTAssertTrue(engine.won)
        defaults.set(try JSONEncoder().encode(engine.snapshot), forKey: "orbitBloom.session.v1")
        let recovered = GameModel(defaults: defaults)
        XCTAssertEqual(recovered.result, true)
        XCTAssertEqual(recovered.progress.stars, 1)
        let relaunched = GameModel(defaults: defaults)
        XCTAssertNil(relaunched.engine)
        XCTAssertEqual(relaunched.progress.stars, 1)
    }
    func testWalletTransactionAndLifeAreDurableAndIdempotent() throws {
        let suite = "orbitbloom.wallet.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite)); defer { defaults.removePersistentDomain(forName:suite) }
        let model = GameModel(defaults:defaults)
        model.start(Level.campaign[0]); XCTAssertEqual(model.ecosystem.lives.hearts,4)
        XCTAssertTrue(model.applyTransaction(productID:"com.orbitbloom.starter",transactionID:"verified-unit-fixture"))
        let restored = GameModel(defaults:defaults)
        XCTAssertEqual(restored.progress.coins,760); XCTAssertEqual(restored.ecosystem.lives.reserve,3)
        XCTAssertTrue(restored.applyTransaction(productID:"com.orbitbloom.starter",transactionID:"verified-unit-fixture"))
        XCTAssertEqual(restored.progress.coins,760); XCTAssertEqual(restored.ecosystem.lives.reserve,3)
    }
    func testHintBalancePersistsAndOlderWalletReceivesFreeAssistance() throws {
        let suite = "orbitbloom.assistance.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let model = GameModel(defaults:defaults); model.start(Level.campaign[0])
        for _ in 0..<5 { model.hint() }
        XCTAssertEqual(model.assistance.freeHints,5)
        XCTAssertFalse(model.hintText.isEmpty)
        XCTAssertEqual(GameModel(defaults:defaults).assistance.freeHints,5)
        var oldWallet = try XCTUnwrap(JSONSerialization.jsonObject(with:try XCTUnwrap(defaults.data(forKey:"orbitBloom.wallet.v2"))) as? [String:Any])
        oldWallet.removeValue(forKey:"assistance")
        defaults.set(try JSONSerialization.data(withJSONObject:oldWallet),forKey:"orbitBloom.wallet.v2")
        XCTAssertEqual(GameModel(defaults:defaults).assistance.freeHints,10)
    }
    func testAudioAndSpritesAreActuallyBundled() {
        for name in ["music-garden","music-farm","music-puzzle","music-race","sfx-tap","sfx-match","sfx-cascade","sfx-harvest","sfx-plant","sfx-water","sfx-collision","sfx-blast","sfx-coin","sfx-craft","sfx-win"] {
            XCTAssertNotNil(Bundle.main.url(forResource:name,withExtension:"m4a"),name)
        }
        XCTAssertEqual(BotanicalSprites.images.count,12)
    }

}
