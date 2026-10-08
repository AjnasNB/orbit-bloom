import SwiftUI

struct ShopView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
    var body: some View {
        VStack(alignment:.leading,spacing:20) {
            SectionEyebrow(text:"Shop / Your garden supplies")
            Text("A little extra\ngrowing power.").font(.system(size:34,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream)
            lifePanel
            Text("Coin packs").font(.system(size:25,weight:.bold,design:.rounded)).foregroundStyle(Palette.cream)
            Text("Coins can also be earned through play. All purchases are optional, processed by Apple, and have no subscription.").font(.system(.subheadline,design:.rounded)).foregroundStyle(Palette.mint)
            ForEach(StorePack.all) { pack in packRow(pack) }
            if let status = purchases.status { Text(status).font(.system(.caption,design:.rounded)).foregroundStyle(Palette.gold).accessibilityIdentifier("purchaseStatus") }
            HStack {
                Button("Refresh shop") { Task { await purchases.load() } }.disabled(purchases.loading || purchases.purchasing).accessibilityIdentifier("refreshShop")
                Spacer()
                Button("Restore purchases") { Task { await purchases.restore() } }.disabled(purchases.purchasing).accessibilityIdentifier("restorePurchases")
            }.font(.system(.caption,design:.rounded,weight:.bold)).foregroundStyle(Palette.mint).frame(minHeight:44)
            Text("Prices labeled Planned are development targets, not live offers. Available products display Apple's localized price. Consumable coins and lives do not expire, but spent packs are not restored. Farm and race remain playable with zero garden lives.").font(.system(.caption,design:.rounded)).foregroundStyle(Palette.muted)
        }.padding(24)
    }
    var lifePanel: some View {
        TimelineView(.periodic(from:.now,by:1)) { time in
            VStack(alignment:.leading,spacing:12) {
                HStack { Label("\(game.ecosystem.lives.hearts)/5 lives",systemImage:"heart.fill").font(.system(size:22,weight:.bold,design:.rounded)).foregroundStyle(Palette.coral); Spacer(); Text("+\(game.ecosystem.lives.reserve) extra").font(.caption.bold()).foregroundStyle(Palette.gold) }
                let seconds = game.ecosystem.lives.remaining(at:time.date)
                Text(game.ecosystem.lives.hearts == 5 ? "Your garden lives are full." : String(format:"Next life in %02d:%02d · one every 30 minutes",seconds/60,seconds%60)).font(.system(.subheadline,design:.rounded)).foregroundStyle(Palette.mint).accessibilityIdentifier("lifeTimer")
                Text("Starting a circuit uses a life. A win returns it. Purchased extra lives stay in reserve and never expire.").font(.caption).foregroundStyle(Palette.muted)
                PrimaryButton(title:"Refill to 5",subtitle:"100 coins",symbol:"heart.fill",id:"refillLives") { game.refillLives() }.disabled(game.ecosystem.lives.hearts == 5)
            }.padding(18).background(Palette.deep,in:RoundedRectangle(cornerRadius:24))
        }
    }
    func packRow(_ pack:StorePack) -> some View {
        let product = purchases.products[pack.id]
        let owned = pack.once && purchases.ownsStarter
        return VStack(alignment:.leading,spacing:12) {
            HStack(spacing:12) {
                SpriteView(index:pack.grant.coins > 0 ? 11 : 3).frame(width:53,height:57)
                VStack(alignment:.leading,spacing:5) { Text(pack.title).font(.system(.headline,design:.rounded)).foregroundStyle(Palette.cream); Text(pack.detail).font(.system(.caption,design:.rounded)).foregroundStyle(Palette.mint).fixedSize(horizontal:false,vertical:true) }
                Spacer(minLength:0)
                if pack.once { Text("STARTER").font(.system(size:8,weight:.black)).padding(7).background(Palette.gold,in:Capsule()).foregroundStyle(Palette.night) }
            }
            if pack.once { Text("50% more coins than the 400-coin pack, plus 3 extra lives, at the same intended price.").font(.caption).foregroundStyle(Palette.gold) }
            HStack {
                if let product { Text(product.displayPrice).font(.headline).foregroundStyle(Palette.gold) }
                else { Text("Planned ₹\(pack.intendedINR)").font(.system(.caption,design:.rounded)).foregroundStyle(Palette.muted) }
                Spacer()
                Button { Task { await purchases.purchase(pack.id) } } label: { Text(owned ? "Owned" : product == nil ? "Unavailable" : purchases.purchasing ? "Connecting…" : "Buy with Apple").font(.system(.caption,design:.rounded,weight:.bold)).foregroundStyle(product == nil || owned ? Palette.muted : Palette.night).padding(.horizontal,18).frame(height:44).background(product == nil || owned ? Palette.night : Palette.gold,in:Capsule()) }.disabled(product == nil || owned || purchases.purchasing).accessibilityIdentifier("buy_\(pack.id)")
            }
        }.padding(16).background(Palette.deep.opacity(0.65),in:RoundedRectangle(cornerRadius:22)).overlay(RoundedRectangle(cornerRadius:22).stroke(pack.once ? Palette.gold.opacity(0.4) : Palette.mint.opacity(0.12)))
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
                    Toggle("Sound effects", isOn: $game.progress.sound)
                    Toggle("Background music",isOn:$game.ecosystem.music).onChange(of:game.ecosystem.music) { _,_ in game.updateMusic(); game.save() }
                    Toggle("Gentle haptics", isOn: $game.progress.haptics)
                    Text("Progress is saved on this device. You can play every puzzle offline.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("How to play") {
                    Label("Tap connected groups of two or more botanical pieces.", systemImage: "hand.tap")
                    Label("Meet every resource goal and fill the score bar.", systemImage: "leaf")
                    Label("Match frozen pieces to melt the frost.", systemImage: "snowflake")
                    Label("Groups of 4 / 6 / 8 / 10 craft bomb / TNT / mega / rainbow tools.", systemImage: "sparkles")
                    Label("Use two stars to restore a garden project.", systemImage: "star")
                }.font(.subheadline)
                Section("Privacy & credits") {
                    Text("No accounts, ads, tracking, or analytics. Game progress stays on your device. Purchases are processed by Apple.").font(.subheadline)
                    Button("Open-source licenses & artwork") { showCredits = true }.accessibilityIdentifier("creditsButton")
                    Text("Orbit Bloom 0.2 · connected garden arcade").font(.caption).foregroundStyle(.secondary)
                }
                Section {
                    Button("Reset local game progress", role: .destructive) { resetConfirmation = true }
                } footer: { Text("Resets local puzzles, coins, farm, lives and projects. Consumable coins and lives are not restorable. Permanent purchases can be restored.") }
            }.tint(Palette.mint).navigationTitle("Settings").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { game.save(); dismiss() } } }
                .onChange(of: game.progress.sound) { _, _ in game.save() }.onChange(of: game.progress.haptics) { _, _ in game.save() }
                .confirmationDialog("Reset all local game progress?", isPresented: $resetConfirmation, titleVisibility: .visible) {
                    Button("Reset game", role: .destructive) { game.leave(); game.progress = Progress(); game.ecosystem = Ecosystem(); game.progress.hasSeenIntro = true; game.save(); dismiss() }
                }
                .sheet(isPresented: $showCredits) {
                    NavigationStack {
                        ScrollView { Text(Bundle.main.url(forResource: "ThirdPartyNotices", withExtension: "txt").flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? "Match3Kit — MIT License, Copyright 2020 Alexey Oleynik.").font(.system(.footnote, design: .monospaced)).padding() }.navigationTitle("Credits").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showCredits = false } } }
                    }
                }
        }
    }
}
