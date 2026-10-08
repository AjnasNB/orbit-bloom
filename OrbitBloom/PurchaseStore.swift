import StoreKit
import SwiftUI

@MainActor final class PurchaseStore: ObservableObject {
    static let productID = "com.orbitbloom.aurora"
    @Published var product: Product?
    @Published var ownsAurora = false
    @Published var loading = false
    @Published var purchasing = false
    @Published var status: String?
    private var loadRequest = UUID()
    private var updates: Task<Void, Never>?
    init() {
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await self.refreshEntitlements()
                    await transaction.finish()
                }
            }
        }
        Task { await load() }
    }
    deinit { updates?.cancel() }
    func load() async {
        let request = UUID(); loadRequest = request
        loading = true
        let timeout = Task { [weak self] in
            try? await Task.sleep(for: .seconds(8))
            guard !Task.isCancelled, let self, self.loadRequest == request, self.loading else { return }
            self.loading = false
            self.status = "The shop is taking longer to connect. Keep playing and refresh it later."
        }
        defer { timeout.cancel(); if loadRequest == request { loading = false } }
        do {
            let loaded = try await Product.products(for: [Self.productID]).first
            guard loadRequest == request else { return }
            product = loaded
            status = loaded == nil ? "Purchases are unavailable right now. Your whole garden adventure is still free to play." : nil
        } catch { if loadRequest == request { status = "The shop could not connect. Please try again." } }
        await refreshEntitlements()
    }
    func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID, transaction.revocationDate == nil { owned = true }
        }
        ownsAurora = owned
    }
    func purchase() async {
        guard !purchasing, let product else { status = "Purchases are unavailable. Try again when the shop is connected."; return }
        purchasing = true; status = nil
        defer { purchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                guard case .verified(let transaction) = verification else { status = "This purchase could not be verified. No content was unlocked."; return }
                await refreshEntitlements(); await transaction.finish()
                status = "Aurora Nights is yours. Choose your garden atmosphere below."
            case .userCancelled: status = "Purchase cancelled. Your garden is right where you left it."
            case .pending: status = "Waiting for purchase approval. It will unlock automatically once approved."
            @unknown default: status = "The purchase did not finish. Please try again."
            }
        } catch { status = "The purchase could not finish. Please try again." }
    }
    func restore() async {
        guard !purchasing else { return }
        purchasing = true
        defer { purchasing = false }
        do {
            try await AppStore.sync(); await refreshEntitlements()
            status = ownsAurora ? "Your Aurora Nights purchase is restored." : "No previous Aurora Nights purchase was found."
        } catch { status = "Could not restore purchases. Check your connection and try again." }
    }
}
