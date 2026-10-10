import SwiftUI

struct PuzzleView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @GestureState private var pieceDragActive = false
    private enum ExitChoice { case abandon, restart }
    @State private var exitChoice: ExitChoice?
    var oneShot: Bool { game.engine?.level.isOneShot == true }
    var body: some View {
        GeometryReader { geometry in
          let landscape = geometry.size.width > geometry.size.height && geometry.size.width >= 700
          let compact = geometry.size.height < 750
          ZStack {
            PuzzleCourtyard()
            VStack(spacing:compact ? 4 : 8) {
                puzzleHeader
                if landscape {
                    landscapeTable(size:geometry.size)
                } else {
                    portraitTable(size:geometry.size,compact:compact)
                }
            }.padding(.horizontal,8).padding(.vertical,6)
                .disabled(game.result != nil || game.paused)
                .accessibilityHidden(game.result != nil || game.paused)
            if let won = game.result { resultView(won) }
            if game.paused && exitChoice == nil { pauseView }
            if let choice = exitChoice { exitConfirmation(choice) }
          }
        }
    }
    private var puzzleHeader:some View {
        HStack(spacing:6) {
            Button { requestExit(.abandon) } label: {
                Image(systemName:"arrow.uturn.backward").accessibilityHidden(true).frame(width:44,height:44)
            }.accessibilityLabel("Back to island").accessibilityHint("Confirm abandoning this attempt and its spent life").accessibilityIdentifier("backFromPuzzle")
            Button { game.paused = true; game.effect("tap") } label: {
                Image(systemName:"pause.fill").accessibilityHidden(true).frame(width:44,height:44)
            }.accessibilityLabel("Pause garden").accessibilityIdentifier("pauseGame")
            Text("LEVEL \(game.engine?.level.id ?? 1)").font(.system(size:12,weight:.black,design:.rounded)).lineLimit(1)
            Spacer(minLength:0)
            Button {} label: {
                HStack(spacing:3) { Image(systemName:"heart.fill").accessibilityHidden(true).foregroundStyle(Color(hex:0xDF536A)); Text("\(game.ecosystem.lives.total)") }.frame(minWidth:44,minHeight:44)
            }.disabled(true).accessibilityLabel("\(game.ecosystem.lives.total) lives. This attempt already spent one life").accessibilityIdentifier("lifeBalance")
            Button {} label: {
                HStack(spacing:2) { SpriteView(index:11).frame(width:22,height:22); Text(game.progress.coins.formatted()).monospacedDigit() }.frame(minHeight:44)
            }.disabled(true).accessibilityLabel("Coins, \(game.progress.coins)").accessibilityIdentifier("openShop")
        }.font(.system(size:14,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night)
            .padding(.horizontal,8).background(Palette.paper,in:Capsule()).disabled(game.busy)
            .frame(maxWidth:1100).frame(maxWidth:.infinity)
    }
    private func portraitTable(size:CGSize,compact:Bool)->some View {
        let side = max(1,min(size.width-16,size.height-(compact ? 294 : 316),820))
        return VStack(spacing:compact ? 4 : 7) {
            if !compact {
                HStack {
                    Text(game.engine?.level.title ?? "Garden").font(.system(size:16,weight:.heavy,design:.rounded)).foregroundStyle(.white)
                    Spacer()
                    if let level=game.engine?.level { DifficultyBadge(level:level).accessibilityIdentifier("puzzleDifficulty") }
                }
                .frame(height:30).frame(maxWidth:820)
            }
            HStack(spacing:6) {
                Image("KeeperLio").resizable().scaledToFit().frame(width:compact ? 34 : 48,height:compact ? 44 : 56).accessibilityHidden(true)
                goals(vertical:false)
                turns
            }.frame(height:compact ? 48 : 60).frame(maxWidth:820).accessibilityElement(children:.contain).accessibilityIdentifier("puzzleMission")
            if compact, let level=game.engine?.level {
                DifficultyBadge(level:level).accessibilityIdentifier("puzzleDifficulty").frame(height:18)
            }
            board.frame(width:side,height:side).accessibilityElement(children:.contain).accessibilityIdentifier("puzzleBoard")
            instruction.frame(height:compact ? 14 : 24)
            HStack(spacing:7) { ForEach(GardenTool.allCases) { tool in toolButton(tool,compact:compact) } }
                .frame(height:compact ? 48 : 64).frame(maxWidth:820)
            utilities.frame(height:44).frame(maxWidth:820)
            if !compact { scoreProgress.frame(height:16).frame(maxWidth:820) }
            Spacer(minLength:0)
        }.frame(maxWidth:.infinity)
    }
    private func landscapeTable(size:CGSize)->some View {
        let side = max(1,min(size.height-100,size.width-324,820))
        return HStack(spacing:14) {
            VStack(spacing:12) {
                Image("KeeperLio").resizable().scaledToFit().frame(height:min(150,size.height*0.18)).accessibilityHidden(true)
                Text(game.engine?.level.title ?? "Garden").font(.system(.headline,design:.rounded,weight:.heavy)).multilineTextAlignment(.center).foregroundStyle(.white)
                if let level=game.engine?.level { DifficultyBadge(level:level).accessibilityIdentifier("puzzleDifficulty") }
                goals(vertical:true)
                turns
                scoreProgress
                Spacer(minLength:0)
            }.frame(width:164).padding(.vertical,12)
            VStack(spacing:8) {
                board.frame(width:side,height:side).accessibilityElement(children:.contain).accessibilityIdentifier("puzzleBoard")
                instruction.frame(height:28)
            }.frame(maxWidth:.infinity,maxHeight:.infinity)
            VStack(spacing:8) {
                ForEach(GardenTool.allCases) { tool in toolButton(tool,compact:false).frame(height:78) }
                utilities.vertical.frame(height:164)
                Spacer(minLength:0)
            }.frame(width:104).padding(.vertical,12)
        }.frame(maxWidth:1200).frame(maxWidth:.infinity,maxHeight:.infinity)
    }
    private var turns:some View {
        VStack(spacing:0) {
            Text("\(game.moves)").font(.system(size:30,weight:.black,design:.rounded)).foregroundStyle(Color(hex:0x784506)).accessibilityIdentifier("movesCounter")
            Text(game.moves == 1 ? "TURN" : "TURNS").font(.system(size:9,weight:.black,design:.rounded))
        }.foregroundStyle(Palette.night).frame(minWidth:56,minHeight:48).background(Color(hex:0xFFDE89),in:RoundedRectangle(cornerRadius:15))
            .accessibilityElement(children:.contain)
    }
    private var goalGems:[Gem] { (game.engine?.level.goals.keys.sorted(by:{$0.rawValue < $1.rawValue})) ?? [] }
    private func goals(vertical:Bool)->some View {
        Group {
            if vertical { VStack(spacing:8) { ForEach(goalGems,id:\.rawValue) { gem in goalChip(gem) }; frostGoal } }
            else { HStack(spacing:5) { ForEach(goalGems,id:\.rawValue) { gem in goalChip(gem) }; frostGoal } }
        }.frame(maxWidth:.infinity).accessibilityElement(children:.contain)
    }
    private func goalChip(_ gem:Gem)->some View {
        let target=game.engine?.level.goals[gem] ?? 0
        let done=min(game.collected[gem,default:0],target)
        return HStack(spacing:3) {
            GemView(gem:gem).frame(width:30,height:34)
            VStack(spacing:1) {
                Text(done == target ? "✓" : "\(done)/\(target)").font(.system(size:14,weight:.black,design:.rounded)).monospacedDigit()
                Text(done == target ? "DONE" : "COLLECT").font(.system(size:7,weight:.black,design:.rounded)).tracking(0.4)
            }
        }.foregroundStyle(Palette.night).padding(.horizontal,6).frame(maxWidth:.infinity,minHeight:46)
            .background(done == target ? Color(hex:0xC6EDB3) : Palette.paper,in:RoundedRectangle(cornerRadius:14))
            .accessibilityElement(children:.ignore).accessibilityLabel("\(gem.name), \(done) collected, target \(target)\(done == target ? ", complete" : "")")
            .accessibilityIdentifier("goal\(gem.rawValue)")
    }
    @ViewBuilder private var frostGoal:some View {
        if !game.frost.isEmpty {
            VStack(spacing:2) {
                Image(systemName:"snowflake").accessibilityHidden(true)
                Text("\(game.frost.count)").font(.system(size:13,weight:.black,design:.rounded))
            }.foregroundStyle(Color(hex:0x12628D)).frame(minWidth:34,minHeight:46)
                .background(Color(hex:0xC8EDFF),in:RoundedRectangle(cornerRadius:13))
                .accessibilityElement(children:.ignore).accessibilityLabel("\(game.frost.count) frozen tiles remaining")
        }
    }
    private var scoreProgress:some View {
        HStack(spacing:6) {
            GeometryReader { geo in
                Capsule().fill(.black.opacity(0.15)).overlay(alignment:.leading) {
                    Capsule().fill(Color(hex:0xFFE494)).frame(width:geo.size.width*min(1,CGFloat(game.score)/CGFloat(game.engine?.level.target ?? 1)))
                }
            }.frame(height:6)
            Text("\(game.score)/\(game.engine?.level.target ?? 0)").font(.system(size:10,weight:.bold,design:.rounded)).foregroundStyle(.white)
        }.accessibilityElement(children:.combine).accessibilityLabel("Score \(game.score), target \(game.engine?.level.target ?? 0)")
    }
    private var instruction:some View {
        Text(game.hintText.isEmpty ? (game.message.isEmpty ? "Swipe neighboring pieces · tap a power to blast" : game.message) : game.hintText)
            .font(.system(size:11,weight:.semibold,design:.rounded)).foregroundStyle(.white).multilineTextAlignment(.center)
            .lineLimit(2).accessibilityIdentifier("hintInstruction")
    }
    private func toolButton(_ tool:GardenTool,compact:Bool)->some View {
        Button { game.selectTool(tool) } label: {
            HStack(spacing:1) {
                SpriteView(index:tool.sprite).frame(width:compact ? 32 : 40,height:compact ? 36 : 48)
                VStack(spacing:3) {
                    Text(tool.title).font(.system(size:9,weight:.black,design:.rounded)).lineLimit(1).minimumScaleFactor(0.8)
                    Text("×\(game.ecosystem.tools[tool,default:0])").font(.system(size:14,weight:.black,design:.rounded)).monospacedDigit()
                }
            }.foregroundStyle(Palette.night).frame(maxWidth:.infinity,maxHeight:.infinity)
                .background(game.pendingTool == tool ? Color(hex:0xFFE49C) : Palette.paper,in:RoundedRectangle(cornerRadius:15))
                .overlay(RoundedRectangle(cornerRadius:15).stroke(game.pendingTool == tool ? Color(hex:0xEA9C2D) : .white,lineWidth:game.pendingTool == tool ? 3 : 1))
                .compositingGroup().shadow(color:Color(hex:0x134F78).opacity(0.35),radius:0,y:4)
        }.buttonStyle(PressStyle()).disabled(game.busy || oneShot)
            .accessibilityLabel("\(tool.title), \(game.ecosystem.tools[tool,default:0]) available. \(tool.detail)\(oneShot ? ". Kept in supplies during one-shot circuits" : "")")
            .accessibilityIdentifier("tool\(tool.rawValue)")
    }
    private var utilities:PuzzleUtilityRow {
        PuzzleUtilityRow(hint:game.assistance.freeHints > 0 ? "Hint · \(game.assistance.freeHints) free" : "Hint · 3 coins",
            burst:game.charged ? "Burst ready" : "Cross burst",shuffle:game.assistance.shuffles > 0 ? "Shuffle · \(game.assistance.shuffles)" : "Shuffle · 15",
            busy:game.busy,oneShot:oneShot,charged:game.charged,onHint:game.hint,onBurst:game.toggleBurst,onShuffle:game.shuffle)
    }
    var board: some View {
        GeometryReader { geo in
            let gap:CGFloat = 2, inset:CGFloat = 8
            let side = (geo.size.width-inset*2-gap*6)/7
            ZStack(alignment:.topLeading) {
                RoundedRectangle(cornerRadius:24).fill(LinearGradient(colors:[Color(hex:0xFFEBC1),Color(hex:0xE8B777)],startPoint:.topLeading,endPoint:.bottomTrailing))
                    .overlay(RoundedRectangle(cornerRadius:24).stroke(Color(hex:0xFFF6DB),lineWidth:4))
                ForEach(game.cells) { cell in
                    let key = cell.key
                    Button { game.tap(key) } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius:side*0.18).fill(Color(hex:(cell.row+cell.column)%2 == 0 ? 0xF5DDB2 : 0xEDD0A0))
                                .overlay(alignment:.top) { RoundedRectangle(cornerRadius:side*0.18).stroke(.white.opacity(0.3),lineWidth:1) }
                            if let power = cell.power { SpriteView(index:power.sprite).padding(side*0.04) }
                            else { GemView(gem:cell.gem).padding(side*0.015) }
                            if game.frost.contains(key) { RoundedRectangle(cornerRadius:10).fill(.cyan.opacity(0.24)).overlay(RoundedRectangle(cornerRadius:10).stroke(.cyan.opacity(0.8),lineWidth:2)); Image(systemName:"snowflake").font(.system(size:10)).foregroundStyle(.white).offset(x:side*0.3,y:-side*0.3) }
                            if game.hinted.contains(key) || game.pendingTool != nil || game.burstMode { RoundedRectangle(cornerRadius:10).stroke(Palette.gold,lineWidth:3).allowsHitTesting(false).accessibilityHidden(true) }
                        }.frame(width:side,height:side).contentShape(Rectangle()).scaleEffect(game.clearing.contains(key) && !reduceMotion ? 0.04 : 1).opacity(game.clearing.contains(key) ? 0 : 1)
                    }.buttonStyle(.plain).contentShape(Rectangle()).highPriorityGesture(DragGesture(minimumDistance:0).updating($pieceDragActive) { _,active,_ in active = true }.onEnded { value in
                        if max(abs(value.translation.width),abs(value.translation.height)) >= 16 { game.swipe(key,dx:value.translation.width,dy:value.translation.height) }
                        else { game.tap(key) }
                    }).disabled(game.busy).accessibilityLabel("\(cell.power?.title ?? cell.gem.name), row \(7-cell.row), column \(cell.column+1)\(game.frost.contains(key) ? ", frozen" : "")").accessibilityHint("Swipe to swap neighbors. Tap a group, board power-up or tool target").accessibilityIdentifier("tile\(key)").position(x:inset+CGFloat(cell.column)*(side+gap)+side/2,y:inset+CGFloat(6-cell.row)*(side+gap)+side/2)
                }
                if let key = game.blastKey {
                    BlastParticles().id(game.blastID).frame(width:side*4,height:side*4).position(x:inset+CGFloat(key%7)*(side+gap)+side/2,y:inset+CGFloat(6-key/7)*(side+gap)+side/2).allowsHitTesting(false)
                }
            }.clipped().shadow(color:Color(hex:0x15456A).opacity(0.5),radius:0,y:7)
        }.aspectRatio(1,contentMode:.fit)
    }
    func resultView(_ won:Bool) -> some View {
        ZStack {
            Palette.paper.opacity(0.98).ignoresSafeArea()
            VStack(spacing:20) {
                GameHUD()
                Spacer()
                SpriteView(index:won ? 10 : 5).frame(height:150)
                SectionEyebrow(text:won ? "A thriving little circuit" : "Another chance to grow")
                Text(won ? "Beautifully grown!" : "Let's try again.").font(.system(size:32,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream).multilineTextAlignment(.center).accessibilityIdentifier(won ? "winTitle" : "loseTitle")
                Text(won ? "Dew goes to your farm. Coins go to your wallet. Your life is returned." : "A new garden life returns every 30 minutes. Farming and racing are still open.").font(.system(.body,design:.rounded)).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
                if won { HStack { ResourcePill(symbol:"star.fill",value:game.firstWin ? "+1" : "Replay"); ResourcePill(symbol:"circle.inset.filled",value:game.firstWin ? "+120" : "+30") } }
                Spacer()
                if won, let level = game.engine?.level, level.id < Level.total {
                    PrimaryButton(title:"Next garden circuit",id:"nextLevel") { game.start(Level.campaign[level.id]) }
                } else if !won { PrimaryButton(title:"Try again · 1 life",symbol:"arrow.clockwise",id:"retryLevel") { if let level = game.engine?.level { game.start(level) } } }
                PrimaryButton(title:"Return to your world",symbol:"globe",id:"backToGarden") { game.gardenAfterWin() }
            }.padding(26).frame(maxWidth:500)
        }.accessibilityElement(children:.contain)
    }
    var pauseView: some View {
        ZStack {
            Palette.paper.opacity(0.98).ignoresSafeArea()
            VStack(spacing:22) {
                PipCompanion().frame(height:130)
                Text("A little breather.").font(.system(size:32,weight:.bold,design:.rounded)).foregroundStyle(Palette.cream)
                Text("Swipe neighbors for 3 in a row, or tap 2+ touching pieces. 4 in line makes a Bomb, L/T makes TNT, a 7-piece cross makes Mega, and 5 in line makes Rainbow. Tap power-ups to chain blasts.").font(.body).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
                PrimaryButton(title:"Keep growing",id:"resumeGame") { game.paused = false }
                Button("Restart · spend another life") { requestExit(.restart) }.foregroundStyle(Palette.gold).frame(minHeight:44).accessibilityIdentifier("restartLevel")
                Button("Back to island · abandon attempt") { requestExit(.abandon) }.foregroundStyle(Palette.muted).frame(minHeight:44).accessibilityIdentifier("leaveLevel")
                Text("Pausing keeps your puzzle. Abandoning keeps this attempt's life spent.").font(.caption).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
            }.padding(28).frame(maxWidth:500)
        }.accessibilityElement(children:.contain)
    }
    private func requestExit(_ choice:ExitChoice) {
        guard !game.busy, game.result == nil else { return }
        game.paused = true; exitChoice = choice; game.effect("tap")
    }
    private func exitConfirmation(_ choice:ExitChoice) -> some View {
        ZStack {
            Palette.paper.opacity(0.98).ignoresSafeArea()
            VStack(spacing:22) {
                Image(systemName:"heart.fill").font(.system(size:60)).foregroundStyle(Palette.coral).accessibilityHidden(true)
                Text(choice == .abandon ? "Leave this circuit?" : "Restart this circuit?").font(.system(.title,design:.rounded,weight:.heavy)).foregroundStyle(Palette.night).multilineTextAlignment(.center)
                Text(choice == .abandon ? "This attempt used one life. Leaving won't return it or charge another. Your completed levels, crops, coins and purchases stay saved." : "This attempt's life stays spent. Restarting spends one more life and resets this puzzle. Your world progress stays saved.").font(.body).foregroundStyle(Palette.mint).multilineTextAlignment(.center).fixedSize(horizontal:false,vertical:true).accessibilityIdentifier("abandonExplanation")
                PrimaryButton(title:choice == .abandon ? "Abandon · lose 1 life" : "Restart · 1 more life",symbol:"arrow.uturn.backward",id:choice == .abandon ? "confirmAbandon" : "confirmRestart") {
                    exitChoice = nil
                    if choice == .abandon { game.abandonCircuit() }
                    else if let level = game.engine?.level { game.start(level) }
                }
                Button { exitChoice = nil; game.paused = false } label: {
                    Text("Keep playing").font(.headline).foregroundStyle(Palette.night)
                        .frame(maxWidth:.infinity,minHeight:48).contentShape(Rectangle())
                        .background(Palette.deep,in:RoundedRectangle(cornerRadius:16))
                }.buttonStyle(PressStyle()).accessibilityIdentifier("cancelAbandon")
            }.padding(28).frame(maxWidth:500)
        }.accessibilityElement(children:.contain)
    }
}

private struct PuzzleUtilityRow:View {
    let hint:String,burst:String,shuffle:String
    let busy:Bool,oneShot:Bool,charged:Bool
    let onHint:()->Void,onBurst:()->Void,onShuffle:()->Void
    var body:some View { HStack(spacing:7) { buttons } }
    var vertical:some View { VStack(spacing:7) { buttons } }
    @ViewBuilder private var buttons:some View {
        button(hint,"lightbulb.fill","hintButton",onHint)
        button(burst,"sparkles","burstButton",onBurst).accessibilityLabel(charged ? "Ready! Cross burst" : "Cross burst").disabled(oneShot)
        button(shuffle,"shuffle","shuffleButton",onShuffle).disabled(oneShot)
    }
    private func button(_ title:String,_ icon:String,_ id:String,_ action:@escaping()->Void)->some View {
        Button(action:action) { Label(title,systemImage:icon).font(.system(size:10,weight:.heavy,design:.rounded))
            .frame(maxWidth:.infinity,minHeight:44).foregroundStyle(Palette.night).background(Palette.paper,in:RoundedRectangle(cornerRadius:13))
        }.buttonStyle(PressStyle()).disabled(busy).accessibilityIdentifier(id)
    }
}

/// Original code-drawn courtyard. Decoration never covers a tile or handles input.
private struct PuzzleCourtyard:View {
    var body:some View {
        ZStack {
            LinearGradient(colors:[Color(hex:0x47B7D9),Color(hex:0x247CB6),Color(hex:0x286899)],startPoint:.topLeading,endPoint:.bottomTrailing)
            Canvas { context,size in
                for row in 0..<Int(size.height/56)+1 {
                    for column in 0..<Int(size.width/68)+1 {
                        let rect=CGRect(x:CGFloat(column)*68+(row%2 == 0 ? 0 : -34),y:CGFloat(row)*56,width:64,height:52)
                        context.stroke(Path(roundedRect:rect,cornerRadius:10),with:.color(.white.opacity(0.10)),lineWidth:2)
                    }
                }
            }
        }.ignoresSafeArea().accessibilityHidden(true)
    }
}

struct DifficultyBadge: View {
    let level: Level
    var tint: Color { switch level.difficulty { case .simple: return Palette.mint; case .hard: return Palette.gold; case .superHard: return Palette.coral; case .oneShot: return Color(hex:0x685291) } }
    var body: some View {
        Label(level.difficulty.title,systemImage:level.difficulty.symbol).font(.system(size:11,weight:.heavy,design:.rounded)).foregroundStyle(tint).padding(.horizontal,10).padding(.vertical,4).background(Palette.paper,in:Capsule())
            .accessibilityElement(children:.ignore).accessibilityLabel("\(level.difficulty.title)\(level.isOneShot ? ", ultra super hard, one move, hints allowed" : " difficulty")")
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
