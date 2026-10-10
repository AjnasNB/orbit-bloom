import SwiftUI

@main struct OrbitBloomApp: App {
    @StateObject private var game: GameModel
    @StateObject private var account: PlayerAccount
    @StateObject private var purchases = PurchaseStore()
    @Environment(\.scenePhase) private var scenePhase
    init() {
        let model = GameModel()
        _game = StateObject(wrappedValue: model)
        _account = StateObject(wrappedValue: PlayerAccount(game: model))
    }
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(game).environmentObject(purchases).environmentObject(account).preferredColorScheme(.light)
                .onChange(of: scenePhase) { _, value in if value != .active { game.save(); AudioDirector.shared.suspend() } else { game.refreshClock(); game.updateMusic(); account.resume(); Task { await game.eventClock.refresh() } } }
        }
    }
}
