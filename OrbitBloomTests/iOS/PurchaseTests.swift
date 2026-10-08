import XCTest
import StoreKit
import StoreKitTest
@testable import OrbitBloom

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
    func testPurchaseAndRestoreNonConsumable() async throws {
        let store = try await loadedStore()
        XCTAssertEqual(store.product?.id, PurchaseStore.productID)
        XCTAssertFalse(store.ownsAurora)
        await store.purchase()
        XCTAssertTrue(store.ownsAurora)
        let relaunchedStore = PurchaseStore()
        await relaunchedStore.load()
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
        await store.refreshEntitlements()
        XCTAssertFalse(store.ownsAurora)
    }
    func testPendingAskToBuyDoesNotUnlockBeforeApproval() async throws {
        session.askToBuyEnabled = true
        let store = try await loadedStore(); await store.purchase()
        XCTAssertFalse(store.ownsAurora)
        XCTAssertTrue(store.status?.contains("approval") == true)
        let pending = try XCTUnwrap(session.allTransactions().first)
        try session.approveAskToBuyTransaction(identifier: pending.identifier)
        await store.refreshEntitlements()
        XCTAssertTrue(store.ownsAurora)
    }
}

@MainActor final class SessionTests: XCTestCase {
    func testInProgressPuzzleResumesAfterModelRecreation() async throws {
        let suite = "orbitbloom.test.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let model = GameModel(defaults: defaults)
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
}
