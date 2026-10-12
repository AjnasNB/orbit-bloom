import SwiftUI

/// The island's doors are pictures; their complete names and rules remain available to VoiceOver.
struct ActivityEmblem: View {
    let room: IslandRoom
    var body: some View {
        ZStack {
            Circle().fill(room.accent.opacity(0.35)).offset(y:4)
            Circle().fill(LinearGradient(colors:[.white,room.accent.opacity(0.30)],startPoint:.topLeading,endPoint:.bottomTrailing))
                .overlay(Circle().stroke(.white.opacity(0.9),lineWidth:2))
            Group {
                switch room {
                case .bloom: SpriteView(index:3).overlay(alignment:.bottomTrailing) { SpriteView(index:2).frame(width:24,height:24) }
                case .farm: SickleIcon().overlay(alignment:.bottomLeading) { SpriteView(index:0).frame(width:25,height:25) }
                case .rally: Image("RallyRover").resizable().scaledToFit()
                case .fireflies: Image(systemName:"lightbulb.max.fill").symbolRenderingMode(.palette).foregroundStyle(Color(hex:0xFFD678),Color(hex:0x637F45))
                case .canal: Image(systemName:"water.waves").symbolRenderingMode(.palette).foregroundStyle(Color(hex:0x369EBA),Color(hex:0xAECBC0))
                case .windmill: Image(systemName:"fan.fill").foregroundStyle(Color(hex:0x3A9788))
                case .observatory: Image(systemName:"moon.stars.fill").symbolRenderingMode(.palette).foregroundStyle(Color(hex:0xFFD678),Color(hex:0x7460A1))
                case .shuttle: Image(systemName:"bus.doubledecker.fill").symbolRenderingMode(.palette).foregroundStyle(Color(hex:0x3D7885),Color(hex:0xF1B85F))
                }
            }.font(.system(size:29,weight:.bold)).padding(10).shadow(color:room.accent.opacity(0.3),radius:1,y:3)
        }.accessibilityHidden(true)
    }
}

struct SickleIcon: View {
    var body: some View {
        Canvas { context,size in
            let s=min(size.width,size.height)
            var blade=Path(); blade.move(to:CGPoint(x:s*0.70,y:s*0.68))
            blade.addCurve(to:CGPoint(x:s*0.24,y:s*0.15),control1:CGPoint(x:s*0.16,y:s*0.80),control2:CGPoint(x:s*0.04,y:s*0.13))
            blade.addCurve(to:CGPoint(x:s*0.70,y:s*0.68),control1:CGPoint(x:s*0.03,y:s*0.52),control2:CGPoint(x:s*0.46,y:s*0.71))
            context.fill(blade,with:.linearGradient(Gradient(colors:[.white,Color(hex:0x5E8897)]),startPoint:.zero,endPoint:CGPoint(x:s,y:s)))
            context.stroke(blade,with:.color(Color(hex:0x446779)),lineWidth:1)
            var handle=Path(); handle.move(to:CGPoint(x:s*0.64,y:s*0.62)); handle.addLine(to:CGPoint(x:s*0.85,y:s*0.94))
            context.stroke(handle,with:.color(Color(hex:0xA47744)),style:StrokeStyle(lineWidth:s*0.13,lineCap:.round))
        }.accessibilityHidden(true)
    }
}

struct ObstacleArtwork: View {
    let obstacle:BoardObstacle
    var body:some View {
        GeometryReader { geo in
            let s=geo.size.width
            ZStack {
                switch obstacle.kind {
                case .ice:
                    RoundedRectangle(cornerRadius:s*0.17).fill(.cyan.opacity(0.30)).overlay(RoundedRectangle(cornerRadius:s*0.17).stroke(.white.opacity(0.85),lineWidth:2))
                    Image(systemName:obstacle.remaining == 2 ? "snowflake" : "bolt.slash.fill").foregroundStyle(.white).font(.system(size:s*0.30)).offset(x:s*0.24,y:-s*0.25)
                case .rope:
                    ForEach(0..<obstacle.remaining,id:\.self) { i in
                        RoundedRectangle(cornerRadius:2).fill(Color(hex:0xB88743)).frame(height:s*0.12).rotationEffect(.degrees(i == 0 ? 35 : -35)).overlay(RoundedRectangle(cornerRadius:2).stroke(Color(hex:0xFFF0AF),lineWidth:1).frame(height:s*0.12).rotationEffect(.degrees(i == 0 ? 35 : -35)))
                    }
                    Circle().fill(Color(hex:0xD0A362)).frame(width:s*0.22,height:s*0.22).overlay(Circle().stroke(Color(hex:0x816034),lineWidth:2))
                case .mud:
                    RoundedRectangle(cornerRadius:s*0.23).fill(LinearGradient(colors:[Color(hex:0xBF9259),Color(hex:0x795233)],startPoint:.top,endPoint:.bottom)).padding(2)
                    SpriteView(index:Gem.crystal.rawValue).padding(s*0.12).opacity(obstacle.remaining == 2 ? 0.45 : 0.9)
                    Image(systemName:"sparkle").foregroundStyle(Color(hex:0xEDD7A0)).offset(x:-s*0.27,y:s*0.24)
                case .sack:
                    RoundedRectangle(cornerRadius:s*0.25).fill(LinearGradient(colors:[Color(hex:0xE8C988),Color(hex:0xA17541)],startPoint:.topLeading,endPoint:.bottomTrailing)).padding(3)
                    Image(systemName:"leaf.fill").foregroundStyle(Color(hex:0x55754C)).font(.system(size:s*0.42))
                    Capsule().fill(Color(hex:0x775439)).frame(width:s*0.6,height:5).offset(y:-s*0.27)
                case .tube:
                    Capsule().fill(Color(hex:0x48A8BC).opacity(0.83)).frame(width:s*0.45).padding(.vertical,3).overlay(Capsule().stroke(.white.opacity(0.8),lineWidth:2).frame(width:s*0.45).padding(.vertical,3))
                    Image(systemName:"drop.fill").font(.system(size:s*0.30)).foregroundStyle(Color(hex:0xD5F7FF))
                    ForEach([-0.34,0.34],id:\.self) { y in Capsule().fill(Color(hex:0x96C7D4)).frame(width:s*0.63,height:s*0.11).offset(y:s*y) }
                }
                HStack(spacing:2) { ForEach(0..<obstacle.remaining,id:\.self) { _ in Circle().fill(.white).frame(width:5,height:5).shadow(color:.black.opacity(0.4),radius:1) } }.offset(y:s*0.35)
            }
        }.allowsHitTesting(false).accessibilityHidden(true)
    }
}

struct GameLoadoutView: View {
    @EnvironmentObject var game:GameModel
    @Environment(\.dismiss) private var dismiss
    let level:Level
    var body:some View {
        VStack(spacing:18) {
            HStack {
                Button { game.upcomingLevel=nil; game.loadout=[]; dismiss() } label: { Image(systemName:"xmark").frame(width:48,height:48) }.accessibilityLabel("Cancel start. Keep your lives and supplies").accessibilityIdentifier("cancelLoadout")
                Spacer()
                Label("\(level.id)",systemImage:"flag.fill").font(.system(size:26,weight:.black,design:.rounded)).accessibilityLabel("Level \(level.id)")
                Spacer(); DifficultyBadge(level:level)
            }
            Image("KeeperLio").resizable().scaledToFit().frame(height:90).accessibilityHidden(true)
            HStack(spacing:20) {
                ForEach(0..<3) { slot in
                    ZStack {
                        Circle().fill(Palette.deep.opacity(0.12)).overlay(Circle().stroke(Palette.mint.opacity(0.3),style:StrokeStyle(lineWidth:2,dash:[4,5])))
                        if game.loadout.indices.contains(slot) { SpriteView(index:game.loadout[slot].sprite).padding(5) }
                        else { Image(systemName:"plus").foregroundStyle(Palette.mint.opacity(0.5)) }
                    }.frame(width:66,height:66)
                }
            }.accessibilityElement(children:.ignore).accessibilityLabel("\(game.loadout.count) of 3 starting power-up slots selected").accessibilityIdentifier("loadoutSlots")
            if level.isOneShot { Text("One move. Find the winning swipe. Your supplies stay saved.").multilineTextAlignment(.center) }
            else {
                HStack(spacing:12) {
                    ForEach(GardenTool.allCases) { tool in
                        let free=game.availableStreakKit.contains(tool)
                        let count=game.ecosystem.tools[tool,default:0]
                        Button { game.toggleLoadout(tool) } label: {
                            VStack(spacing:3) {
                                SpriteView(index:tool.sprite).frame(height:55)
                                HStack(spacing:3) { if free { Image(systemName:"gift.fill") }; Text(free ? "1" : "\(count)").monospacedDigit() }
                            }.frame(maxWidth:.infinity,minHeight:90).background(game.loadout.contains(tool) ? Palette.sunlight : Palette.paper,in:RoundedRectangle(cornerRadius:18))
                                .overlay(RoundedRectangle(cornerRadius:18).stroke(game.loadout.contains(tool) ? Palette.gold : .clear,lineWidth:3))
                        }.disabled(!free && count == 0).buttonStyle(PressStyle()).accessibilityLabel("\(tool.title). \(free ? "Free win-streak power" : "\(count) in supplies"). \(game.loadout.contains(tool) ? "Selected" : "Not selected")").accessibilityIdentifier("loadout\(tool.rawValue)")
                    }
                }
                Text("Choose up to 3. Wins grow your free kit; losing or abandoning resets it.").font(.system(.subheadline,design:.rounded)).multilineTextAlignment(.center)
                Button { game.unlockCompanion() } label: {
                    HStack { PipCompanion().frame(width:46,height:54); Image(systemName:game.momentum.companion ? "checkmark.seal.fill" : "lightbulb.fill"); Text(game.momentum.companion ? "1 hint per new level" : "200"); if !game.momentum.companion { SpriteView(index:11).frame(width:26,height:26) } }.frame(maxWidth:.infinity,minHeight:60).background(Palette.paper,in:Capsule())
                }.disabled(game.momentum.companion).accessibilityLabel(game.momentum.companion ? "Pip companion unlocked. One hint per new level, only once" : "Unlock Pip companion for 200 game coins. One hint per new level, only once").accessibilityIdentifier("unlockCompanion")
            }
            Spacer(minLength:0)
            PrimaryButton(title:"Play",subtitle:"1 life · \(level.moves) \(level.moves == 1 ? "move" : "moves")",symbol:"play.fill",id:"confirmLoadout") { if game.beginPreparedAttempt() { dismiss() } }
        }.foregroundStyle(Palette.night).padding(24).frame(maxWidth:650,maxHeight:.infinity).background(Palette.sky.ignoresSafeArea()).dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
