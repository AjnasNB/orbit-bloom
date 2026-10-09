import SwiftUI

@main struct OrbitBloomApp: App {
    @StateObject private var game = GameModel()
    @StateObject private var purchases = PurchaseStore()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(game).environmentObject(purchases).preferredColorScheme(.light)
                .onChange(of: scenePhase) { _, value in if value != .active { game.save(); AudioDirector.shared.suspend() } else { game.refreshClock(); game.updateMusic() } }
        }
    }
}
