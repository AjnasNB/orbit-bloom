import SwiftUI

struct ShopView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
    @State private var page = 0
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text(page == 0 ? "Your garden supplies" : StorePack.all[page-1].title).font(.system(size:28,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night)
            Text("Earn coins by playing. Apple purchases are optional.").font(.system(.subheadline,design:.rounded)).foregroundStyle(Palette.mint)
            if page == 0 {
                lifePanel
                Spacer(minLength:0)
                SpriteView(index:11).frame(height:115).frame(maxWidth:.infinity)
                PrimaryButton(title:"Explore coin packs",subtitle:"Swipe supplies",symbol:"bag.fill",id:"explorePacks") { withAnimation { page = 1 } }
            } else {
                SpriteView(index:StorePack.all[page-1].grant.coins > 0 ? 11 : 3).frame(height:125).frame(maxWidth:.infinity).shadow(color:Palette.mint.opacity(0.2),radius:3,y:8)
                packRow(StorePack.all[page-1])
                Text("Consumable coins and lives never expire. Spent packs are not restored. Extra lives stay in reserve.").font(.caption).foregroundStyle(Palette.mint)
                Spacer(minLength:4)
            }
            if let status = purchases.status { Text(status).font(.caption).foregroundStyle(Palette.night).accessibilityIdentifier("purchaseStatus") }
            HStack { Button("Refresh shop") { Task { await purchases.load() } }.disabled(purchases.loading || purchases.purchasing).accessibilityIdentifier("refreshShop"); Spacer(); Button("Restore purchases") { Task { await purchases.restore() } }.disabled(purchases.purchasing).accessibilityIdentifier("restorePurchases") }.font(.caption.bold()).foregroundStyle(Palette.night).frame(minHeight:44)
            Text("Swipe supplies · \(page+1) of \(StorePack.all.count+1)").font(.caption.bold()).foregroundStyle(Palette.mint).frame(maxWidth:.infinity).accessibilityIdentifier("supplyPage")
        }.padding(.horizontal,22).padding(.bottom,12).frame(maxHeight:.infinity).contentShape(Rectangle())
        .simultaneousGesture(DragGesture(minimumDistance:35).onEnded { value in
            guard abs(value.translation.width) > abs(value.translation.height) else { return }
            withAnimation { page = min(StorePack.all.count,max(0,page+(value.translation.width < 0 ? 1 : -1))) }; game.effect("tap")
        }).accessibilityElement(children:.contain).accessibilityIdentifier("suppliesScene")
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
                if pack.once { Text("STARTER").font(.system(size:8,weight:.black)).padding(7).background(Palette.sunlight,in:Capsule()).foregroundStyle(Palette.night) }
            }
            if pack.once { Text("50% more coins than the 400-coin pack, plus 3 extra lives, at the same intended price.").font(.caption).foregroundStyle(Palette.gold) }
            HStack {
                if let product { Text(product.displayPrice).font(.headline).foregroundStyle(Palette.gold) }
                else { Text("Planned ₹\(pack.intendedINR)").font(.system(.caption,design:.rounded)).foregroundStyle(Palette.muted) }
                Spacer()
                Button { Task { await purchases.purchase(pack.id) } } label: { Text(owned ? "Owned" : product == nil ? "Unavailable" : purchases.purchasing ? "Connecting…" : "Buy with Apple").font(.system(.caption,design:.rounded,weight:.bold)).foregroundStyle(product == nil || owned ? Palette.muted : Palette.night).padding(.horizontal,18).frame(height:44).background(product == nil || owned ? Palette.night : Palette.sunlight,in:Capsule()) }.disabled(product == nil || owned || purchases.purchasing).accessibilityIdentifier("buy_\(pack.id)")
            }
        }.padding(16).background(Palette.deep.opacity(0.65),in:RoundedRectangle(cornerRadius:22)).overlay(RoundedRectangle(cornerRadius:22).stroke(pack.once ? Palette.gold.opacity(0.4) : Palette.mint.opacity(0.12)))
    }
}

struct SettingsView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var account: PlayerAccount
    @Environment(\.dismiss) var dismiss
    @State private var showCredits = false
    @State private var resetConfirmation = false
    var body: some View {
        NavigationStack {
            Form {
                Section("Keep your garden") {
                    NavigationLink { PlayerAccountView() } label: {
                        Label("Player & saved garden", systemImage: "person.crop.circle")
                    }.accessibilityIdentifier("playerAccount")
                    Text(account.status).font(.footnote).foregroundStyle(.secondary)
                }
                Section("Your quiet corner") {
                    Toggle("Sound effects", isOn: $game.progress.sound)
                    Toggle("Background music",isOn:$game.ecosystem.music).onChange(of:game.ecosystem.music) { _,_ in game.updateMusic(); game.save() }
                    Toggle("Gentle haptics", isOn: $game.progress.haptics)
                    Text("Progress is saved on this device. You can play every puzzle offline.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("How to play") {
                    Label("Swipe neighboring pieces to match three, or tap a connected group.", systemImage: "hand.tap")
                    Label("Meet every resource goal and fill the score bar.", systemImage: "leaf")
                    Label("Match frozen pieces to melt the frost.", systemImage: "snowflake")
                    Label("4 in line makes Bomb; L/T makes TNT; a 7-piece cross makes Mega; 5 in line makes Rainbow.", systemImage: "sparkles")
                    Label("Use two stars to restore a garden project.", systemImage: "star")
                }.font(.subheadline)
                Section("Privacy & credits") {
                    Text("No ads, tracking, or analytics. Optional Game Center sign-in and iCloud backup are handled by Apple. Purchases are processed by Apple.").font(.subheadline)
                    Button("Open-source licenses & artwork") { showCredits = true }.accessibilityIdentifier("creditsButton")
                    Text("Orbit Bloom 1.0 · build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "6")").font(.caption).foregroundStyle(.secondary)
                }
                Section {
                    Button("Reset local game progress", role: .destructive) { resetConfirmation = true }
                } footer: { Text("Resets this device's puzzles, coins, farm, lives and projects and pauses cloud backup. Existing cloud gardens are kept. Apple does not restore spent consumable coins and lives.") }
            }.tint(Palette.mint).navigationTitle("Settings").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { game.save(); dismiss() } } }
                .onChange(of: game.progress.sound) { _, _ in game.save() }.onChange(of: game.progress.haptics) { _, _ in game.save() }
                .confirmationDialog("Reset all local game progress?", isPresented: $resetConfirmation, titleVisibility: .visible) {
                    Button("Reset game", role: .destructive) { account.setEnabled(false); game.leave(); game.progress = Progress(); game.ecosystem = Ecosystem(); game.assistance = Assistance(); game.progress.hasSeenIntro = true; game.save(); dismiss() }
                }
                .sheet(isPresented: $showCredits) {
                    NavigationStack {
                        ScrollView { Text(Bundle.main.url(forResource: "ThirdPartyNotices", withExtension: "txt").flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? "Match3Kit — MIT License, Copyright 2020 Alexey Oleynik.").font(.system(.footnote, design: .monospaced)).padding() }.navigationTitle("Credits").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showCredits = false } } }
                    }
                }
        }
    }
}
