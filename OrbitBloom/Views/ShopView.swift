import SwiftUI

struct ShopView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            SectionEyebrow(text: "Little extras for your little world")
            Text("Make it yours.").font(.system(size: 34, weight: .bold, design: .rounded)).tracking(-1).foregroundStyle(Palette.cream)
            Text("The whole 12-level story is free to play.\nA little extra magic is completely optional.").font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.muted)
            VStack(alignment: .leading, spacing: 18) {
                GardenScene(restored: Set(0..<6), aurora: true).frame(height: 220).clipShape(RoundedRectangle(cornerRadius: 23))
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        SectionEyebrow(text: "Garden atmosphere")
                        Text("Aurora Nights").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(Palette.cream)
                    }
                    Spacer()
                    Image(systemName: "moon.stars.fill").accessibilityHidden(true).font(.system(size: 25)).foregroundStyle(Palette.mint)
                }
                Text("Paint your garden in a soft aurora glow. A cosmetic atmosphere, yours forever with one purchase.").font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.muted)
                if purchases.ownsAurora {
                    Toggle("Use Aurora Nights", isOn: $game.progress.auroraTheme).tint(Palette.mint).font(.system(.headline, design: .rounded)).foregroundStyle(Palette.cream).onChange(of: game.progress.auroraTheme) { _, _ in game.save() }.accessibilityIdentifier("auroraToggle")
                    Label("Purchased · available on your devices", systemImage: "checkmark.seal.fill").font(.system(.caption, design: .rounded)).foregroundStyle(Palette.mint).accessibilityIdentifier("purchasedLabel")
                } else {
                    PrimaryButton(title: purchases.purchasing ? "Connecting…" : purchases.product.map { "Unlock · \($0.displayPrice)" } ?? (purchases.loading ? "Loading shop…" : "Shop unavailable"), symbol: "moon.stars.fill", id: "buyAurora") { Task { await purchases.purchase() } }.disabled(purchases.product == nil || purchases.purchasing)
                    Text("One-time purchase. No subscription.").font(.system(.caption, design: .rounded)).foregroundStyle(Palette.muted)
                }
                if let status = purchases.status { Text(status).font(.system(.caption, design: .rounded)).foregroundStyle(Palette.cream).accessibilityIdentifier("purchaseStatus") }
                HStack {
                    Button("Restore purchases") { Task { await purchases.restore() } }.disabled(purchases.purchasing).accessibilityIdentifier("restorePurchases")
                    Spacer()
                    Button("Refresh shop") { Task { await purchases.load() } }.disabled(purchases.loading || purchases.purchasing)
                }.font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(Palette.mint).frame(minHeight: 44)
                #if DEBUG
                Text("Development build · StoreKit local testing when launched through Xcode. No real charge in the test environment.").font(.system(size: 10, design: .rounded)).foregroundStyle(Palette.muted)
                #endif
            }.padding(18).background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 28)).overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.08), lineWidth: 1))
            HStack(spacing: 16) {
                Image(systemName: "sparkles").accessibilityHidden(true).font(.system(size: 30)).foregroundStyle(Palette.gold).frame(width: 56)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Starlight burst").font(.system(.headline, design: .rounded)).foregroundStyle(Palette.cream)
                    Text("Clear a row and column.\nUse the coins you earn by playing.").font(.system(.caption, design: .rounded)).foregroundStyle(Palette.muted)
                }
                Spacer(minLength: 0)
                Button {
                    if game.progress.buyBooster() { game.save(); game.showToast("A starlight burst is ready for your next puzzle.") }
                    else { game.showToast("Win a puzzle to earn more coins.") }
                } label: { Text("80 coins").font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(Palette.night).padding(.horizontal, 14).frame(height: 45).background(Palette.gold, in: Capsule()) }.accessibilityIdentifier("buyBooster")
            }.padding(.vertical, 14)
        }.padding(.horizontal, 24).padding(.bottom, 30)
    }
}

struct SettingsView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.dismiss) var dismiss
    @State private var showCredits = false
    @State private var resetConfirmation = false
    var body: some View {
        NavigationStack {
            Form {
                Section("Your quiet corner") {
                    Toggle("Puzzle sounds", isOn: $game.progress.sound)
                    Toggle("Gentle haptics", isOn: $game.progress.haptics)
                    Text("Progress is saved on this device. You can play every puzzle offline.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("How to play") {
                    Label("Tap two neighboring pieces, or swipe, to match three.", systemImage: "hand.tap")
                    Label("Meet every resource goal and fill the score bar.", systemImage: "leaf")
                    Label("Match frozen pieces to melt the frost.", systemImage: "snowflake")
                    Label("Match four or more to earn a starlight burst.", systemImage: "sparkles")
                    Label("Use two stars to restore a garden project.", systemImage: "star")
                }.font(.subheadline)
                Section("Privacy & credits") {
                    Text("No accounts, ads, tracking, or analytics. Game progress stays on your device. Purchases are processed by Apple.").font(.subheadline)
                    Button("Open-source licenses & artwork") { showCredits = true }.accessibilityIdentifier("creditsButton")
                    Text("Orbit Bloom 0.1 · playable development build").font(.caption).foregroundStyle(.secondary)
                }
                Section {
                    Button("Reset local game progress", role: .destructive) { resetConfirmation = true }
                } footer: { Text("Resets puzzles, coins, and garden projects. Your Apple purchase can be restored.") }
            }.tint(Palette.mint).navigationTitle("Settings").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { game.save(); dismiss() } } }
                .onChange(of: game.progress.sound) { _, _ in game.save() }.onChange(of: game.progress.haptics) { _, _ in game.save() }
                .confirmationDialog("Reset all local game progress?", isPresented: $resetConfirmation, titleVisibility: .visible) {
                    Button("Reset game", role: .destructive) { game.leave(); game.progress = Progress(); game.progress.hasSeenIntro = true; game.save(); dismiss() }
                }
                .sheet(isPresented: $showCredits) {
                    NavigationStack {
                        ScrollView { Text(Bundle.main.url(forResource: "ThirdPartyNotices", withExtension: "txt").flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? "Match3Kit — MIT License, Copyright 2020 Alexey Oleynik.").font(.system(.footnote, design: .monospaced)).padding() }.navigationTitle("Credits").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showCredits = false } } }
                    }
                }
        }
    }
}
