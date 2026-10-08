import SwiftUI

struct RootView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
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
                    }.scrollIndicators(.hidden)
                    navigation
                }.accessibilityHidden(!game.progress.hasSeenIntro)
            }
            if !game.progress.hasSeenIntro { intro }
            if let flight = game.coinFlight { CoinFlightView(amount:game.lastCoinAward).id(flight).allowsHitTesting(false) }
            if let toast = game.toast {
                VStack { Spacer(); Text(toast).font(.system(.subheadline,design:.rounded,weight:.semibold)).multilineTextAlignment(.center).foregroundStyle(Palette.night).padding(16).background(Palette.cream,in:RoundedRectangle(cornerRadius:20)).padding(.horizontal,24).padding(.bottom,80) }.allowsHitTesting(false)
            }
        }
        .sheet(isPresented:$game.showSettings) { SettingsView() }
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
    var intro: some View {
        ZStack {
            Image("LivingGarden").resizable().scaledToFill().ignoresSafeArea().overlay(LinearGradient(colors:[.clear,Palette.night,Palette.night],startPoint:.top,endPoint:.bottom))
            VStack(spacing:18) {
                Spacer()
                Image("BloomLogo").resizable().scaledToFit().frame(width:100,height:100).clipShape(RoundedRectangle(cornerRadius:25))
                SectionEyebrow(text:"One world. Many ways to play.")
                Text("Grow a little\nextraordinary.").font(.system(size:39,weight:.heavy,design:.rounded)).tracking(-1).multilineTextAlignment(.center).foregroundStyle(Palette.cream)
                Text("Clear bloom circuits. Farm living gardens. Race your harvest home. Everything you play helps your world grow.").font(.system(.body,design:.rounded)).multilineTextAlignment(.center).foregroundStyle(Palette.mint)
                PrimaryButton(title:"Enter your world",symbol:"leaf.fill",id:"introStart") { game.progress.hasSeenIntro = true; game.save(); game.effect("win") }
                Text("5 garden lives · one returns every 30 minutes\nFarming and racing are always open.").font(.system(.caption,design:.rounded)).multilineTextAlignment(.center).foregroundStyle(Palette.muted)
            }.padding(28).padding(.bottom,24).frame(maxWidth:500)
        }.accessibilityElement(children:.contain)
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
    var nextTask: GardenTask? { GardenTask.all.first { !game.progress.restored.contains($0.id) } }
    var body: some View {
        VStack(alignment:.leading,spacing:18) {
            ZStack(alignment:.bottomLeading) {
                Image("LivingGarden").resizable().scaledToFill().frame(height:330).clipped()
                LinearGradient(colors:[.clear,Palette.night.opacity(0.98)],startPoint:.center,endPoint:.bottom)
                VStack(alignment:.leading,spacing:8) {
                    SectionEyebrow(text:"Your botanical moon / Chapter 01")
                    Text(game.progress.gardenComplete ? "A world in bloom." : "A world worth\ngrowing.").font(.system(size:35,weight:.heavy,design:.rounded)).tracking(-1).foregroundStyle(Palette.cream)
                    Text("\(game.progress.restored.count)/6 restored").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.gold)
                }.padding(24)
            }.clipShape(RoundedRectangle(cornerRadius:28))
            HStack(spacing:12) {
                SpriteView(index:10).frame(width:68,height:72)
                VStack(alignment:.leading,spacing:5) { Text("Pip's field notes").font(.system(.headline,design:.rounded)).foregroundStyle(Palette.cream); Text("Dew feeds your farm. Harvests craft tools. Deliveries earn coins. Let's make something grow.").font(.system(.caption,design:.rounded)).foregroundStyle(Palette.mint) }
            }
            PrimaryButton(title:"Bloom circuits",subtitle:"Level \(game.progress.nextLevel)",symbol:"leaf.fill",id:"playLevel") { game.start(Level.campaign[game.progress.nextLevel-1]) }
            HStack(spacing:12) {
                activity("Farm & craft","\(game.ecosystem.produce) cargo ready",sprite:3,tab:2,id:"openFarm")
                activity("Harvest rally","22-second delivery",sprite:9,tab:3,id:"openRace")
            }
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
    var body: some View {
        VStack(alignment:.leading,spacing:18) {
            SectionEyebrow(text:"Garden / Bloom circuits")
            Text("Clear. Collect.\nBring it to life.").font(.system(size:33,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream)
            Text("Tap groups of 2+ touching pieces. Larger groups create tools. Collect dew for the farm and stars for the world.").font(.system(.subheadline,design:.rounded)).foregroundStyle(Palette.mint)
            ForEach(Level.campaign) { level in
                let unlocked = level.id <= game.progress.nextLevel
                Button { game.start(level) } label: {
                    HStack(spacing:14) {
                        Text(String(format:"%02d",level.id)).font(.system(size:21,weight:.black,design:.rounded)).foregroundStyle(Palette.gold).frame(width:44)
                        VStack(alignment:.leading,spacing:4) { Text(level.title).font(.system(.headline,design:.rounded)).foregroundStyle(Palette.cream); Text("\(level.moves) turns · \(level.frost) frost patches").font(.caption).foregroundStyle(Palette.mint) }
                        Spacer(); Image(systemName:game.progress.completed[level.id] != nil ? "star.fill" : unlocked ? "play.fill" : "lock.fill").foregroundStyle(Palette.gold)
                    }.padding(18).background(Palette.deep,in:RoundedRectangle(cornerRadius:20)).opacity(unlocked ? 1 : 0.5)
                }.disabled(!unlocked).accessibilityIdentifier("level\(level.id)")
            }
        }.padding(24)
    }
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
