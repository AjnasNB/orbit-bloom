import StoreKit
import SwiftUI

@MainActor final class PurchaseStore: ObservableObject {
    static let productID = "com.orbitbloom.aurora"
    @Published var products: [String:Product] = [:]
    var product: Product? { products[Self.productID] }
    @Published var ownsAurora = false
    @Published var ownsStarter = false
    @Published var loading = false
    @Published var purchasing = false
    @Published var status: String?
    weak var game: GameModel?
    private var request = UUID()
    private var updates: Task<Void,Never>?
    init() {
        updates = Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result { await self.deliver(transaction); await self.refreshEntitlements() }
            }
        }
        Task { await load() }
    }
    deinit { updates?.cancel() }
    func load() async {
        let id = UUID(); request = id; loading = true
        let timeout = Task { [weak self] in
            try? await Task.sleep(for:.seconds(8))
            guard !Task.isCancelled, let self, self.request == id else { return }
            self.loading = false; self.status = "Apple's shop is taking longer to connect. Your farm and race remain open. Refresh later."
        }
        defer { timeout.cancel(); if request == id { loading = false } }
        do {
            let list = try await Product.products(for:StorePack.all.map(\.id)+[Self.productID])
            guard request == id else { return }
            products = Dictionary(uniqueKeysWithValues:list.map { ($0.id,$0) })
            status = list.isEmpty ? "Apple purchases are unavailable. Earn coins by farming and racing, or retry the shop." : nil
        } catch { if request == id { status = "Could not connect to Apple's shop. Please try again." } }
        await refreshEntitlements(); await recoverUnfinished()
    }
    func recoverUnfinished() async {
        for await result in StoreKit.Transaction.unfinished { if case .verified(let transaction) = result { await deliver(transaction) } }
    }
    private func deliver(_ transaction: StoreKit.Transaction) async {
        guard transaction.revocationDate == nil else { return }
        if transaction.productID == Self.productID { ownsAurora = true; await transaction.finish(); return }
        guard let game else { return }
        if game.applyTransaction(productID:transaction.productID,transactionID:String(transaction.id)) { await transaction.finish() }
    }
    func refreshEntitlements() async {
        var aurora = false, starter = false
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.revocationDate == nil {
                if transaction.productID == Self.productID { aurora = true }
                if transaction.productID == "com.orbitbloom.starter" { starter = true }
            }
        }
        ownsAurora = aurora; ownsStarter = starter
    }
    func purchase(_ id: String = "com.orbitbloom.aurora") async {
        guard !purchasing, let selected = products[id] else { status = "This product is not available from Apple yet. Refresh the shop later."; return }
        purchasing = true; status = nil
        defer { purchasing = false }
        do {
            switch try await selected.purchase() {
            case .success(let verification):
                guard case .verified(let transaction) = verification else { status = "Apple could not verify this purchase. No rewards were granted."; return }
                await deliver(transaction); await refreshEntitlements()
                status = "Purchase verified by Apple. Your rewards are saved."
            case .pending: status = "Waiting for purchase approval. Rewards arrive after Apple approves the transaction."
            case .userCancelled: status = "Purchase cancelled. Your balance is unchanged."
            @unknown default: status = "The purchase did not complete. Please try again."
            }
        } catch { status = "The purchase could not complete. Please try again." }
    }
    func restore() async {
        guard !purchasing else { return }
        purchasing = true; defer { purchasing = false }
        do { try await AppStore.sync(); await refreshEntitlements(); await recoverUnfinished(); status = "Restorable purchases checked. Spent coin and life packs are consumable and are not restored by Apple." }
        catch { status = "Could not restore purchases. Please try again." }
    }
}
