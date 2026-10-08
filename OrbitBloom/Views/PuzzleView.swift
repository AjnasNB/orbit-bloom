import SwiftUI

struct PuzzleView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    var body: some View {
        ZStack {
            VStack(spacing:0) {
                GameHUD()
                ScrollView {
                    VStack(spacing:15) {
                        HStack {
                            Button { game.paused = true; game.effect("tap") } label: { Image(systemName:"pause.fill").frame(width:44,height:44).background(Palette.deep,in:Circle()) }.foregroundStyle(Palette.cream).accessibilityLabel("Pause garden").accessibilityIdentifier("pauseGame")
                            Spacer()
                            VStack(spacing:4) { SectionEyebrow(text:"Bloom circuit \(game.engine?.level.id ?? 1)"); Text(game.engine?.level.title ?? "Garden").font(.system(.headline,design:.rounded)).foregroundStyle(Palette.cream) }
                            Spacer()
                            VStack(spacing:2) { Text("\(game.moves)").font(.system(size:28,weight:.black,design:.rounded)).foregroundStyle(Palette.gold).accessibilityIdentifier("movesCounter"); Text("TURNS").font(.system(size:8,weight:.bold)).tracking(2).foregroundStyle(Palette.mint) }.frame(width:44)
                        }
                        goals
                        board
                        Text(game.message).font(.system(size:12,weight:.semibold,design:.rounded)).multilineTextAlignment(.center).foregroundStyle(Palette.mint).frame(minHeight:30)
                        if !game.hintText.isEmpty { Text(game.hintText).font(.system(size:10,design:.rounded)).foregroundStyle(Palette.gold).accessibilityIdentifier("hintInstruction") }
                        HStack(spacing:8) {
                            ForEach(GardenTool.allCases) { tool in
                                Button { game.selectTool(tool) } label: {
                                    VStack(spacing:4) { SpriteView(index:tool.sprite).frame(height:43); Text(tool.title).font(.system(size:10,weight:.bold,design:.rounded)); Text("×\(game.ecosystem.tools[tool,default:0])").font(.system(size:11,weight:.bold,design:.rounded)).foregroundStyle(Palette.gold) }.foregroundStyle(Palette.cream).frame(maxWidth:.infinity).padding(.vertical,8).background(game.pendingTool == tool ? Palette.mint.opacity(0.25) : Palette.deep,in:RoundedRectangle(cornerRadius:17)).overlay(RoundedRectangle(cornerRadius:17).stroke(game.pendingTool == tool ? Palette.gold : .clear,lineWidth:2))
                                }.disabled(game.busy).accessibilityLabel("\(tool.title), \(game.ecosystem.tools[tool,default:0]) available. \(tool.detail)").accessibilityIdentifier("tool\(tool.rawValue)")
                            }
                        }
                        HStack(spacing:12) {
                            utility("Hint","lightbulb.fill",id:"hintButton") { game.hint() }
                            utility(game.charged ? "Burst ready" : "Cross burst","sparkles",id:"burstButton") { game.toggleBurst() }.accessibilityLabel(game.charged ? "Ready! Cross burst" : "Cross burst")
                            utility("Shuffle","shuffle",id:"shuffleButton") { game.engine?.shuffle(); game.sync(); game.save(); game.effect("tap") }
                        }
                        Text("2+ connected pieces collect a circuit. Groups of 4 / 6 / 8 / 10 craft stronger tools.").font(.system(size:10,design:.rounded)).foregroundStyle(Palette.muted).multilineTextAlignment(.center)
                    }.padding(.horizontal,20).padding(.bottom,20).frame(maxWidth:550).frame(maxWidth:.infinity)
                }.scrollIndicators(.hidden)
            }.disabled(game.result != nil || game.paused).accessibilityHidden(game.result != nil || game.paused)
            if let won = game.result { resultView(won) }
            if game.paused { pauseView }
        }
    }
    var goals: some View {
        VStack(spacing:12) {
            HStack(spacing:14) {
                ForEach((game.engine?.level.goals.keys.sorted(by:{$0.rawValue < $1.rawValue})) ?? [],id:\.rawValue) { gem in
                    HStack(spacing:5) { GemView(gem:gem).frame(width:27,height:29); Text("\(min(game.collected[gem,default:0],game.engine?.level.goals[gem] ?? 0))/\(game.engine?.level.goals[gem] ?? 0)").font(.system(size:12,weight:.bold,design:.rounded)).foregroundStyle(Palette.cream) }.accessibilityElement(children:.combine).accessibilityLabel("\(gem.name), \(game.collected[gem,default:0]) collected, target \(game.engine?.level.goals[gem] ?? 0)")
                }
                Spacer(minLength:0)
                if !game.frost.isEmpty { Label("\(game.frost.count)",systemImage:"snowflake").font(.caption.bold()).foregroundStyle(.cyan) }
            }
            HStack(spacing:10) {
                GeometryReader { geo in RoundedRectangle(cornerRadius:4).fill(.white.opacity(0.1)).overlay(alignment:.leading) { RoundedRectangle(cornerRadius:4).fill(LinearGradient(colors:[Palette.mint,Palette.gold],startPoint:.leading,endPoint:.trailing)).frame(width:geo.size.width*min(1,CGFloat(game.score)/CGFloat(game.engine?.level.target ?? 1))) } }.frame(height:6)
                Text("\(game.score)/\(game.engine?.level.target ?? 0)").font(.system(size:10,weight:.semibold,design:.rounded)).foregroundStyle(Palette.muted)
            }
        }.padding(16).background(Palette.deep.opacity(0.7),in:RoundedRectangle(cornerRadius:20))
    }
    var board: some View {
        GeometryReader { geo in
            let gap:CGFloat = 3, inset:CGFloat = 9
            let side = (geo.size.width-inset*2-gap*6)/7
            ZStack(alignment:.topLeading) {
                RoundedRectangle(cornerRadius:23).fill(LinearGradient(colors:[Color(hex:0x45654E),Color(hex:0x203E32)],startPoint:.topLeading,endPoint:.bottomTrailing)).overlay(RoundedRectangle(cornerRadius:23).stroke(Color(hex:0x8BA77A),lineWidth:2))
                ForEach(game.cells) { cell in
                    let key = cell.key
                    Button { game.tap(key) } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius:10).fill(LinearGradient(colors:[Color(hex:0xDDE9C9),Color(hex:0xAABD91)],startPoint:.topLeading,endPoint:.bottomTrailing)).shadow(color:.black.opacity(0.3),radius:1,y:3)
                            GemView(gem:cell.gem).padding(side*0.05)
                            if game.frost.contains(key) { RoundedRectangle(cornerRadius:10).fill(.cyan.opacity(0.24)).overlay(RoundedRectangle(cornerRadius:10).stroke(.cyan.opacity(0.8),lineWidth:2)); Image(systemName:"snowflake").font(.system(size:10)).foregroundStyle(.white).offset(x:side*0.3,y:-side*0.3) }
                            if game.hinted.contains(key) || game.pendingTool != nil || game.burstMode { RoundedRectangle(cornerRadius:10).stroke(Palette.gold,lineWidth:3) }
                        }.frame(width:side,height:side).scaleEffect(game.clearing.contains(key) && !reduceMotion ? 0.04 : 1).opacity(game.clearing.contains(key) ? 0 : 1)
                    }.buttonStyle(.plain).disabled(game.busy).accessibilityLabel("\(cell.gem.name), row \(7-cell.row), column \(cell.column+1)\(game.frost.contains(key) ? ", frozen" : "")").accessibilityHint("Tap to collect a connected group, or target your selected tool").accessibilityIdentifier("tile\(key)").position(x:inset+CGFloat(cell.column)*(side+gap)+side/2,y:inset+CGFloat(6-cell.row)*(side+gap)+side/2)
                }
                if let key = game.blastKey {
                    BlastParticles().id(game.blastID).frame(width:side*4,height:side*4).position(x:inset+CGFloat(key%7)*(side+gap)+side/2,y:inset+CGFloat(6-key/7)*(side+gap)+side/2).allowsHitTesting(false)
                }
            }.clipped()
        }.aspectRatio(1,contentMode:.fit)
    }
    func utility(_ title:String,_ icon:String,id:String,action:@escaping ()->Void) -> some View {
        Button(action:action) { Label(title,systemImage:icon).font(.system(size:11,weight:.bold,design:.rounded)).frame(maxWidth:.infinity,minHeight:44).background(Palette.deep,in:Capsule()).foregroundStyle(Palette.gold) }.disabled(game.busy).accessibilityIdentifier(id)
    }
    func resultView(_ won:Bool) -> some View {
        ZStack {
            Palette.night.opacity(0.97).ignoresSafeArea()
            VStack(spacing:20) {
                GameHUD()
                Spacer()
                SpriteView(index:won ? 10 : 5).frame(height:150)
                SectionEyebrow(text:won ? "A thriving little circuit" : "Another chance to grow")
                Text(won ? "Beautifully grown!" : "Let's try again.").font(.system(size:32,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream).multilineTextAlignment(.center).accessibilityIdentifier(won ? "winTitle" : "loseTitle")
                Text(won ? "Dew goes to your farm. Coins go to your wallet. Your life is returned." : "A new garden life returns every 30 minutes. Farming and racing are still open.").font(.system(.body,design:.rounded)).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
                if won { HStack { ResourcePill(symbol:"star.fill",value:game.firstWin ? "+1" : "Replay"); ResourcePill(symbol:"circle.inset.filled",value:game.firstWin ? "+120" : "+30") } }
                Spacer()
                if won, let level = game.engine?.level, level.id < 12 {
                    PrimaryButton(title:"Next garden circuit",id:"nextLevel") { game.start(Level.campaign[level.id]) }
                } else if !won { PrimaryButton(title:"Try again · 1 life",symbol:"arrow.clockwise",id:"retryLevel") { if let level = game.engine?.level { game.start(level) } } }
                PrimaryButton(title:"Return to your world",symbol:"globe",id:"backToGarden") { game.gardenAfterWin() }
            }.padding(26).frame(maxWidth:500)
        }.accessibilityElement(children:.contain)
    }
    var pauseView: some View {
        ZStack {
            Palette.night.opacity(0.97).ignoresSafeArea()
            VStack(spacing:22) {
                PipCompanion().frame(height:130)
                Text("A little breather.").font(.system(size:32,weight:.bold,design:.rounded)).foregroundStyle(Palette.cream)
                Text("Tap 2+ touching pieces. Use tools to clear frost. Bomb: 3×3. TNT: cross. Mega: 5×5. Rainbow: all of one kind.").font(.body).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
                PrimaryButton(title:"Keep growing",id:"resumeGame") { game.paused = false }
                Button("Restart · spend another life") { if let level = game.engine?.level { game.start(level) } }.foregroundStyle(Palette.gold).frame(minHeight:44).accessibilityIdentifier("restartLevel")
                Button("Leave circuit · keep world progress") { game.leave() }.foregroundStyle(Palette.muted).frame(minHeight:44).accessibilityIdentifier("leaveLevel")
            }.padding(28).frame(maxWidth:500)
        }.accessibilityElement(children:.contain)
    }
}

struct BlastParticles: View {
    @State private var burst = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle().stroke(Palette.gold,lineWidth:burst ? 0 : 8).scaleEffect(burst ? 1.5 : 0.1).opacity(burst ? 0 : 0.9)
                ForEach(0..<14) { i in
                    Circle().fill(i%2 == 0 ? Palette.gold : Palette.coral).frame(width:8,height:8).offset(x:burst ? cos(Double(i) * Double.pi / 7)*geo.size.width/2 : 0,y:burst ? sin(Double(i) * Double.pi / 7)*geo.size.height/2 : 0).opacity(burst ? 0 : 1)
                }
            }.frame(width:geo.size.width,height:geo.size.height).onAppear { withAnimation(.easeOut(duration:reduceMotion ? 0.1 : 0.65)) { burst = true } }
        }.accessibilityHidden(true)
    }
}
