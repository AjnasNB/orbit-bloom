import SwiftUI

struct RootView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
    @State private var loading = true
    private let clock = Timer.publish(every:1,on:.main,in:.common).autoconnect()
    var body: some View {
        ZStack {
            SpaceBackdrop()
            if game.raceActive { DeliveryRaceView() }
            else if game.engine != nil { PuzzleView() }
            else {
                VStack(spacing:0) {
                    GameHUD()
                    ScrollView {
                        Group {
                            switch game.tab {
                            case 1: JourneyView()
                            case 2: FarmView()
                            case 3: DeliveryLobby()
                            case 4: ShopView()
                            default: GardenView()
                            }
                        }.frame(maxWidth:600).frame(maxWidth:.infinity)
                    }.id(game.tab).scrollIndicators(.hidden)
                    .simultaneousGesture(DragGesture(minimumDistance:35).onEnded { value in
                        guard game.tab != 1, abs(value.translation.width) > abs(value.translation.height)*1.5 else { return }
                        withAnimation(.easeInOut(duration:0.25)) { game.tab = min(4,max(0,game.tab+(value.translation.width < 0 ? 1 : -1))) }
                    })
                    navigation
                }.accessibilityHidden(loading)
            }
            if loading { loadingScreen.transition(.opacity) }
            if let flight = game.coinFlight { CoinFlightView(amount:game.lastCoinAward).id(flight).allowsHitTesting(false) }
            if let toast = game.toast {
                VStack { Spacer(); Text(toast).font(.system(.subheadline,design:.rounded,weight:.semibold)).multilineTextAlignment(.center).foregroundStyle(Palette.night).padding(16).background(Palette.cream,in:RoundedRectangle(cornerRadius:20)).padding(.horizontal,24).padding(.bottom,80) }.allowsHitTesting(false)
            }
        }
        .sheet(isPresented:$game.showSettings) { SettingsView() }
        .sheet(isPresented:$game.showTasks) { FieldJournalView() }
        .task { try? await Task.sleep(for:.milliseconds(game.testing ? 120 : 1000)); game.progress.hasSeenIntro = true; game.save(); withAnimation(.easeOut(duration:0.35)) { loading = false } }
        .onAppear { purchases.game = game; game.updateMusic(); Task { await purchases.recoverUnfinished() } }
        .onChange(of:game.tab) { _,_ in game.updateMusic() }
        .onChange(of:game.engine != nil) { _,_ in game.updateMusic() }
        .onChange(of:game.raceActive) { _,_ in game.updateMusic() }
        .onReceive(clock) { _ in game.refreshClock() }
    }
    var navigation: some View {
        HStack(spacing:0) {
            nav(0,"World","globe.europe.africa.fill")
            nav(1,"Garden","leaf.fill")
            nav(2,"Farm","carrot.fill")
            nav(3,"Race","flag.checkered")
            nav(4,"Shop","bag.fill")
        }.padding(.vertical,10).background(Palette.night.opacity(0.98)).overlay(alignment:.top) { Rectangle().fill(Palette.mint.opacity(0.2)).frame(height:1) }
    }
    func nav(_ id: Int,_ title: String,_ icon: String) -> some View {
        Button { game.tab = id; game.effect("tap") } label: {
            VStack(spacing:5) { Image(systemName:icon).font(.system(size:20)); Text(title).font(.system(size:10,weight:.bold,design:.rounded)) }.foregroundStyle(game.tab == id ? Palette.gold : Palette.muted).frame(maxWidth:.infinity).frame(minHeight:44)
        }.accessibilityIdentifier("tab\(title)").accessibilityAddTraits(game.tab == id ? .isSelected : [])
    }
    var loadingScreen: some View {
        ZStack {
            Palette.night.ignoresSafeArea()
            Image("LivingGarden").resizable().scaledToFill().ignoresSafeArea().opacity(0.22)
            VStack(spacing:24) {
                Image("BloomLogo").resizable().scaledToFit().frame(width:132,height:132).clipShape(RoundedRectangle(cornerRadius:33))
                Text("ORBIT BLOOM").font(.system(size:28,weight:.black,design:.rounded)).tracking(3).foregroundStyle(Palette.cream)
                Text("Your next little adventure is growing.").font(.system(.subheadline,design:.rounded)).foregroundStyle(Palette.mint)
                ProgressView().tint(Palette.gold).accessibilityLabel("Loading your garden")
            }.padding(24)
        }.accessibilityIdentifier("loadingScreen")
    }

}

struct GameHUD: View {
    @EnvironmentObject var game: GameModel
    var body: some View {
        HStack(spacing:8) {
            Image("BloomLogo").resizable().frame(width:38,height:38).clipShape(RoundedRectangle(cornerRadius:11)).accessibilityHidden(true)
            VStack(alignment:.leading,spacing:1) { Text("ORBIT").tracking(2); Text("BLOOM").tracking(1.5) }.font(.system(size:12,weight:.black,design:.rounded)).foregroundStyle(Palette.cream).accessibilityLabel("Orbit Bloom")
            Spacer(minLength:2)
            Button { game.tab = 4 } label: { HStack(spacing:4) { Image(systemName:"heart.fill").foregroundStyle(Palette.coral); Text("\(game.ecosystem.lives.total)").foregroundStyle(Palette.cream) }.font(.system(size:15,weight:.bold,design:.rounded)).frame(minWidth:48,minHeight:44) }.accessibilityLabel("\(game.ecosystem.lives.total) lives. Open refill shop").accessibilityIdentifier("lifeBalance")
            HStack(spacing:3) { SpriteView(index:11).frame(width:24,height:24); Text(game.progress.coins.formatted()).monospacedDigit().contentTransition(.numericText()).font(.system(size:15,weight:.bold,design:.rounded)).foregroundStyle(Palette.gold) }.accessibilityElement(children:.ignore).accessibilityLabel("Coins, \(game.progress.coins)").accessibilityIdentifier("coinBalance")
            Button { game.showSettings = true } label: { Image(systemName:"gearshape.fill").foregroundStyle(Palette.muted).frame(width:44,height:44) }.accessibilityLabel("Settings").accessibilityIdentifier("settings")
        }.padding(.horizontal,18).padding(.vertical,6)
    }
}

struct GardenView: View {
    @EnvironmentObject var game: GameModel
    @State private var arrived = false
    var nextTask: GardenTask? { GardenTask.all.first { !game.progress.restored.contains($0.id) } }
    var body: some View {
        VStack(alignment:.leading,spacing:18) {
            ZStack(alignment:.bottomLeading) {
                Image("LivingGarden").resizable().scaledToFill().frame(height:330).clipped()
                LinearGradient(colors:[.clear,Palette.night.opacity(0.98)],startPoint:.center,endPoint:.bottom)
                VStack(alignment:.leading,spacing:8) {
                    SectionEyebrow(text:"Your botanical moon / Chapter 01")
                    Text(game.progress.gardenComplete ? "A world in bloom." : "Welcome to\nyour wild side.").font(.system(size:35,weight:.heavy,design:.rounded)).tracking(-1).foregroundStyle(Palette.cream)
                    Text("\(game.progress.restored.count)/6 restored").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.gold)
                }.padding(24)
            }.clipShape(RoundedRectangle(cornerRadius:28)).scaleEffect(arrived ? 1 : 0.96).opacity(arrived ? 1 : 0).onAppear { withAnimation(.spring(response:0.7,dampingFraction:0.8)) { arrived = true } }
            HStack(spacing:12) {
                SpriteView(index:10).frame(width:68,height:72)
                VStack(alignment:.leading,spacing:5) { Text("Pip's field notes").font(.system(.headline,design:.rounded)).foregroundStyle(Palette.cream); Text("Dew feeds your farm. Harvests craft tools. Deliveries earn coins. Let's make something grow.").font(.system(.caption,design:.rounded)).foregroundStyle(Palette.mint) }
            }
            PrimaryButton(title:"Bloom circuits",subtitle:"Level \(game.progress.nextLevel)",symbol:"leaf.fill",id:"playLevel") { game.start(Level.campaign[game.progress.nextLevel-1]) }
            HStack(spacing:12) {
                activity("Farm & craft","\(game.ecosystem.produce) cargo ready",sprite:3,tab:2,id:"openFarm")
                activity("Harvest rally","22-second delivery",sprite:9,tab:3,id:"openRace")
            }
            Button { game.showTasks = true; game.effect("tap") } label: {
                HStack { SpriteView(index:6).frame(width:49,height:49); VStack(alignment:.leading,spacing:5) { Text("Field tasks & power patterns").font(.headline); Text("Earn TNT, hints and shuffles by playing.").font(.caption).foregroundStyle(Palette.mint) }; Spacer(); Image(systemName:"sparkles") }.foregroundStyle(Palette.gold).padding(18).background(Palette.deep,in:RoundedRectangle(cornerRadius:22))
            }.buttonStyle(PressStyle()).accessibilityIdentifier("openTasks")
            if let task = nextTask {
                HStack(spacing:12) {
                    Image(systemName:task.icon).foregroundStyle(Palette.mint).font(.title2)
                    VStack(alignment:.leading,spacing:4) { Text(task.title).font(.system(.subheadline,design:.rounded,weight:.bold)); Text(task.detail).font(.system(.caption,design:.rounded)).foregroundStyle(Palette.muted) }
                    Spacer(minLength:0)
                    Button { game.restore(task); game.effect("craft") } label: { Label("2",systemImage:"star.fill").font(.headline).padding(13).background(Palette.gold,in:Capsule()).foregroundStyle(Palette.night) }.accessibilityLabel("Restore \(task.title) for 2 stars").accessibilityIdentifier("restoreProject")
                }.foregroundStyle(Palette.cream).padding(16).background(Palette.deep,in:RoundedRectangle(cornerRadius:20))
            } else { Text("Every little corner is alive again.").foregroundStyle(Palette.mint).font(.headline) }
        }.padding(.horizontal,20).padding(.bottom,24)
    }
    func activity(_ title:String,_ detail:String,sprite:Int,tab:Int,id:String) -> some View {
        Button { game.tab = tab; game.effect("tap") } label: {
            VStack(alignment:.leading,spacing:7) { SpriteView(index:sprite).frame(height:75).frame(maxWidth:.infinity); Text(title).font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.cream); Text(detail).font(.system(size:10,design:.rounded)).foregroundStyle(Palette.mint) }.padding(14).frame(maxWidth:.infinity,alignment:.leading).background(Palette.deep,in:RoundedRectangle(cornerRadius:22)).overlay(RoundedRectangle(cornerRadius:22).stroke(Palette.mint.opacity(0.12)))
        }.buttonStyle(PressStyle()).accessibilityIdentifier(id)
    }
}

struct GardenScene: View {
    let restored: Set<Int>
    let aurora: Bool
    var body: some View {
        Image("LivingGarden").resizable().scaledToFill().overlay(aurora ? Palette.mint.opacity(0.2) : .clear).clipped().accessibilityLabel("Botanical moon, \(restored.count) areas restored")
    }
}

struct JourneyView: View {
    @EnvironmentObject var game: GameModel
    @State private var page = 0
    var body: some View {
        LazyVStack(alignment:.leading,spacing:18) {
            SectionEyebrow(text:"Garden / 1,020 bloom trails")
            Text("Clear. Collect.\nBring it to life.").font(.system(size:33,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream)
            Text("Swipe neighbors for 3 in a row, or tap 2+ touching pieces. Form power patterns. Swipe this trail list to explore regions.").font(.system(.subheadline,design:.rounded)).foregroundStyle(Palette.mint)
            Picker("Garden region",selection:$page) { ForEach(0..<51) { region in Text("Region \(region+1) · \(region*20+1)–\(min(Level.total,(region+1)*20))").tag(region) } }.tint(Palette.gold)
            ForEach(Array(Level.campaign.dropFirst(page*20).prefix(20))) { level in
                let unlocked = level.id <= game.progress.nextLevel
                Button { game.start(level) } label: {
                    HStack(spacing:14) {
                        Text(String(format:"%02d",level.id)).font(.system(size:21,weight:.black,design:.rounded)).foregroundStyle(Palette.gold).frame(width:44)
                        VStack(alignment:.leading,spacing:4) { Text(level.title).font(.system(.headline,design:.rounded)).foregroundStyle(Palette.cream); Text("\(level.moves) turns · \(level.frost) frost patches").font(.caption).foregroundStyle(Palette.mint) }
                        Spacer(); Image(systemName:game.progress.completed[level.id] != nil ? "star.fill" : unlocked ? "play.fill" : "lock.fill").foregroundStyle(Palette.gold)
                    }.padding(18).background(Palette.deep,in:RoundedRectangle(cornerRadius:20)).opacity(unlocked ? 1 : 0.5)
                }.disabled(!unlocked).accessibilityIdentifier("level\(level.id)")
            }
        }.padding(24).onAppear { page = (game.progress.nextLevel-1)/20 }
        .simultaneousGesture(DragGesture(minimumDistance:40).onEnded { value in
            guard abs(value.translation.width) > abs(value.translation.height)*1.5 else { return }
            page = min(50,max(0,page+(value.translation.width < 0 ? 1 : -1)))
        })
    }
}

struct FieldJournalView: View {
    @EnvironmentObject var game:GameModel
    @Environment(\.dismiss) var dismiss
    var body:some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:20) {
                    Text("Good things grow together.").font(.system(size:30,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream)
                    Text("Permanent field tasks, with no daily deadline. Your first ten hints are free; earn more here. After free supplies, a hint costs 3 coins and a shuffle costs 15.").font(.subheadline).foregroundStyle(Palette.mint)
                    ForEach(FieldTask.all) { task in
                        let value = task.value(progress:game.progress,ecosystem:game.ecosystem,assistance:game.assistance)
                        let claimed = game.assistance.claimed.contains(task.id)
                        HStack(spacing:16) {
                            SpriteView(index:task.tool.sprite).frame(width:58,height:62)
                            VStack(alignment:.leading,spacing:5) { Text(task.title).font(.headline).foregroundStyle(Palette.cream); Text("\(min(value,task.target))/\(task.target) · \(task.tool.title)" + (task.hints > 0 ? " + \(task.hints) hints" : "") + (task.shuffles > 0 ? " + \(task.shuffles) shuffles" : "")).font(.caption).foregroundStyle(Palette.mint) }
                            Spacer()
                            Button(claimed ? "Claimed" : value >= task.target ? "Claim" : "Growing") { game.claim(task) }.font(.caption.bold()).foregroundStyle(value >= task.target || claimed ? Palette.gold : Palette.muted).frame(minWidth:55,minHeight:44).disabled(claimed || value < task.target).accessibilityIdentifier("claim_\(task.id)")
                        }.padding(16).background(Palette.deep,in:RoundedRectangle(cornerRadius:22))
                    }
                    Text("Patterns make power.").font(.title2.bold()).foregroundStyle(Palette.cream)
                    ForEach(Array(GardenTool.allCases.enumerated()),id:\.offset) { item in
                        HStack(spacing:18) {
                            PatternDiagram(tool:item.element).frame(width:100,height:100)
                            VStack(alignment:.leading,spacing:5) { Text(item.element.title).font(.headline).foregroundStyle(Palette.gold); Text(["4 in a line, or a 4-piece circuit", "L or T of 5, or a 6-piece circuit", "A 7-piece cross, or an 8-piece circuit", "5 in a line, or a 10-piece circuit"][item.offset]).font(.subheadline).foregroundStyle(Palette.mint); Text(item.element.detail).font(.caption).foregroundStyle(Palette.muted) }
                        }
                    }
                }.padding(24)
            }.background(Palette.night).navigationTitle("Field journal").toolbar { ToolbarItem(placement:.confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}
struct PatternDiagram:View {
    let tool:GardenTool
    var keys:Set<Int> { switch tool { case .bomb: return [10,11,12,13]; case .tnt: return [2,7,12,13,14]; case .mega: return [2,7,10,11,12,13,17]; case .rainbow: return [10,11,12,13,14] } }
    var body:some View { LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:2),count:5),spacing:2) { ForEach(0..<25) { key in ZStack { RoundedRectangle(cornerRadius:3).fill(Palette.deep); if keys.contains(key) { SpriteView(index:3).padding(1) } }.aspectRatio(1,contentMode:.fit) } }.accessibilityElement(children:.ignore).accessibilityLabel("\(tool.title) formation") }
}

struct CoinFlightView: View {
    let amount: Int
    @State private var flying = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<8) { i in
                    SpriteView(index:11).frame(width:25,height:25)
                        .position(x:flying ? geo.size.width*0.76 : geo.size.width*0.5+CGFloat(i%4-2)*18,y:flying ? 29 : geo.size.height*0.67+CGFloat(i/4)*20)
                        .scaleEffect(flying ? 0.45 : 1).opacity(flying ? 0 : 1)
                        .animation(reduceMotion ? .linear(duration:0.1) : .easeInOut(duration:0.8).delay(Double(i)*0.05),value:flying)
                }
                Text("+\(amount)").font(.system(size:30,weight:.heavy,design:.rounded)).foregroundStyle(Palette.gold).position(x:geo.size.width/2,y:geo.size.height*0.61).opacity(flying ? 0 : 1).animation(.easeOut(duration:1),value:flying)
            }.onAppear { flying = true }
        }.accessibilityHidden(true)
    }
}
