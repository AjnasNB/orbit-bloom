import SwiftUI

struct DeliveryLobby: View {
    @EnvironmentObject var game: GameModel
    var body: some View {
        VStack(alignment:.leading,spacing:20) {
            SectionEyebrow(text:"Race / Harvest rally")
            Text("Fresh cargo.\nOpen road.").font(.system(size:36,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream)
            ZStack {
                Image("LivingGarden").resizable().scaledToFill().frame(height:260).clipped().opacity(0.5)
                SpriteView(index:9).frame(height:200).rotationEffect(.degrees(-12)).shadow(color:.black.opacity(0.5),radius:12,y:12)
            }.clipShape(RoundedRectangle(cornerRadius:26))
            Text("Swipe left or right to steer your rover through three lanes. Dodge stone barriers, collect coins, and deliver your harvest in 22 seconds.").font(.system(.body,design:.rounded)).foregroundStyle(Palette.mint)
            HStack { Label("3 shield points",systemImage:"shield.fill"); Spacer(); Label("No life cost",systemImage:"heart.fill") }.font(.caption).foregroundStyle(Palette.gold)
            Text(game.ecosystem.produce > 0 ? "\(game.ecosystem.produce) cargo ready · +40 delivery bonus" : "No cargo? You can still race for coins. Farm a harvest for a delivery bonus.").font(.system(.subheadline,design:.rounded)).foregroundStyle(Palette.cream)
            PrimaryButton(title:"Start harvest rally",subtitle:"440 m",symbol:"flag.checkered",id:"startRace") { game.raceActive = true; game.effect("tap") }
            Text("Best: \(game.ecosystem.raceBest) m · Deliveries: \(game.ecosystem.deliveries)").font(.caption).foregroundStyle(Palette.muted)
        }.padding(24)
    }
}

struct DeliveryRaceView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var run = DeliveryRun()
    @State private var paused = false
    @State private var rewarded = false
    @State private var flash = false
    private let timer = Timer.publish(every:0.05,on:.main,in:.common).autoconnect()
    var body: some View {
        VStack(spacing:12) {
            GameHUD()
            HStack {
                Button { paused.toggle() } label: { Image(systemName:paused ? "play.fill" : "pause.fill").frame(width:44,height:44).background(Palette.deep,in:Circle()) }.accessibilityLabel(paused ? "Resume race" : "Pause race").accessibilityIdentifier("pauseRace")
                VStack(alignment:.leading,spacing:4) { SectionEyebrow(text:"Harvest rally"); Text("\(run.distance) / 440 m").font(.system(.headline,design:.rounded)).accessibilityIdentifier("raceDistance") }
                Spacer()
                Text(String(repeating:"♥",count:max(0,run.health))).foregroundStyle(Palette.coral).font(.title3).accessibilityLabel("\(run.health) shield points")
                Text("\(run.collected)").foregroundStyle(Palette.gold).font(.headline)
            }.foregroundStyle(Palette.cream).padding(.horizontal,22)
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius:28).fill(Color(hex:0x42714F))
                    Canvas { ctx,size in
                        let road = CGRect(x:size.width*0.12,y:0,width:size.width*0.76,height:size.height)
                        ctx.fill(Path(roundedRect:road,cornerRadius:15),with:.color(Color(hex:0xB6A27A)))
                        for line in 1...2 {
                            for dash in 0..<12 {
                                let y = (CGFloat(dash)*60+CGFloat(run.elapsed*100)).truncatingRemainder(dividingBy:size.height+60)-60
                                ctx.fill(Path(roundedRect:CGRect(x:size.width*(0.12+Double(line)*0.76/3)-1,y:y,width:3,height:28),cornerRadius:2),with:.color(Palette.cream.opacity(0.55)))
                            }
                        }
                        for i in 0..<12 {
                            let y = (CGFloat(i)*69+CGFloat(run.elapsed*70)).truncatingRemainder(dividingBy:size.height+50)-30
                            let x:CGFloat = i%2 == 0 ? size.width*0.05 : size.width*0.95
                            ctx.fill(Path(ellipseIn:CGRect(x:x-14,y:y,width:28,height:35)),with:.color(Color(hex:i%3 == 0 ? 0xDE8F83 : 0x254D35)))
                        }
                    }
                    ForEach(0..<10) { id in
                        let crossing = Double(id)*2+2
                        let y = geo.size.height*0.78 + CGFloat((run.elapsed-crossing)*110)
                        if y > -60 && y < geo.size.height+60 && !run.passed.contains(id) {
                            ZStack { RoundedRectangle(cornerRadius:11).fill(LinearGradient(colors:[Color(hex:0x8F8D82),Color(hex:0x575E53)],startPoint:.topLeading,endPoint:.bottomTrailing)).frame(width:61,height:42).shadow(color:.black.opacity(0.3),radius:1,y:6); Image(systemName:"exclamationmark.triangle.fill").foregroundStyle(Palette.gold.opacity(0.8)) }.position(x:laneX(run.obstacleLane(id),width:geo.size.width),y:y)
                            SpriteView(index:11).frame(width:27,height:27).position(x:laneX((run.obstacleLane(id)+1)%3,width:geo.size.width),y:y-45)
                        }
                    }
                    SpriteView(index:9).frame(width:76,height:104).rotationEffect(.degrees(flash ? 10 : 0)).position(x:laneX(run.lane,width:geo.size.width),y:geo.size.height*0.78).animation(reduceMotion ? nil : .spring(response:0.2),value:run.lane)
                    if flash { Color.red.opacity(0.2).clipShape(RoundedRectangle(cornerRadius:28)).allowsHitTesting(false) }
                    if paused { Text("Race paused").font(.title2.bold()).foregroundStyle(Palette.cream).padding(24).background(Palette.night,in:Capsule()) }
                }.clipped().clipShape(RoundedRectangle(cornerRadius:28)).contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance:20).onEnded { value in
                    guard !run.finished, !paused else { return }
                    run.lane = min(2,max(0,run.lane+(value.translation.width < 0 ? -1 : 1))); game.effect("tap")
                }).accessibilityElement(children:.contain).accessibilityLabel("Harvest rally road. Swipe to steer.").accessibilityValue("Lane \(run.lane+1) of 3").accessibilityIdentifier("raceTrack")
                .accessibilityAdjustableAction { direction in if direction == .increment { run.lane = min(2,run.lane+1) } else if direction == .decrement { run.lane = max(0,run.lane-1) } }
                .overlay { if run.finished { finish } }
            }.padding(.horizontal,20)
            Label("Swipe the road to steer",systemImage:"hand.draw.fill").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.mint).frame(minHeight:44)
            Button("Return to world") { game.raceActive = false; game.tab = 0 }.font(.system(.caption,design:.rounded,weight:.bold)).foregroundStyle(Palette.mint).frame(minHeight:44).accessibilityIdentifier("leaveRace")
        }
        .onReceive(timer) { _ in
            guard !paused, scenePhase == .active, !run.finished else { return }
            let event = run.tick(0.05)
            if event.hit { flash = true; game.effect("collision"); game.feedback(.heavy); Task { try? await Task.sleep(for:.milliseconds(200)); flash = false } }
            if event.pickup { game.effect("coin") }
            if run.finished && !rewarded { rewarded = true; game.completeDelivery(run) }
        }
    }
    func laneX(_ lane:Int,width:CGFloat) -> CGFloat { width*(0.12+0.76*(CGFloat(lane)+0.5)/3) }
    var finish: some View {
        VStack(spacing:18) {
            Image(systemName:run.won ? "flag.checkered" : "wrench.adjustable.fill").font(.system(size:38)).foregroundStyle(Palette.gold)
            Text(run.won ? "Delivery complete!" : "Time for a tune-up").font(.system(size:24,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream).multilineTextAlignment(.center).accessibilityIdentifier("raceResult")
            Text(run.won ? "Your harvest made it home. Coins are in your wallet." : "Your collected coin reward is safe. Try another route.").font(.subheadline).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
            PrimaryButton(title:"Back to the world",symbol:"globe",id:"raceDone") { game.raceActive = false; game.tab = 0 }
        }.padding(24).background(Palette.night.opacity(0.97),in:RoundedRectangle(cornerRadius:25)).padding(22)
    }
}
