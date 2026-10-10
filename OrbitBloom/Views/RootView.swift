import SwiftUI
import SceneKit

struct RootView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
    @State private var loading = true
    private let clock = Timer.publish(every:1,on:.main,in:.common).autoconnect()
    var body: some View {
        ZStack {
            SpaceBackdrop()
            if game.raceActive { DeliveryRaceView() }
            else if game.engine != nil { PuzzleView().id(game.engine?.level.id) }
            else {
                VStack(spacing:0) {
                    GameHUD()
                    if game.tab != 0 && game.tab != 1 {
                        Button { game.tab = 0; game.effect("tap") } label: {
                            Label("Back to your island",systemImage:"arrow.uturn.backward").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.night).frame(maxWidth:.infinity,minHeight:44,alignment:.leading)
                        }.padding(.horizontal,24).accessibilityIdentifier("returnWorld")
                    }
                    Group {
                        switch game.tab {
                        case 2: FarmView()
                        case 3: DeliveryLobby()
                        case 4: ShopView()
                        default: GardenView()
                        }
                    }.frame(maxWidth:650).frame(maxWidth:.infinity,maxHeight:.infinity)
                }.accessibilityHidden(loading)
            }
            if loading { loadingScreen.transition(.opacity) }
            if let flight = game.coinFlight { CoinFlightView(amount:game.lastCoinAward).id(flight).allowsHitTesting(false) }
            if let toast = game.toast {
                VStack { Spacer(); Text(toast).font(.system(.subheadline,design:.rounded,weight:.semibold)).multilineTextAlignment(.center).foregroundStyle(Palette.night).padding(16).background(Palette.paper,in:RoundedRectangle(cornerRadius:20)).padding(.horizontal,24).padding(.bottom,80) }.allowsHitTesting(false)
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
    var loadingScreen: some View {
        ZStack {
            Palette.sky.ignoresSafeArea()
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
            Button { game.tab = 4; game.effect("tap") } label: { HStack(spacing:3) { SpriteView(index:11).frame(width:24,height:24); Text(game.progress.coins.formatted()).monospacedDigit().contentTransition(.numericText()).font(.system(size:15,weight:.bold,design:.rounded)).foregroundStyle(Palette.night) }.frame(minHeight:44) }.accessibilityLabel("Coins, \(game.progress.coins). Open supplies").accessibilityIdentifier("openShop")
            Button { game.showSettings = true } label: { Image(systemName:"gearshape.fill").foregroundStyle(Palette.muted).frame(width:44,height:44) }.accessibilityLabel("Settings").accessibilityIdentifier("settings")
        }.padding(.horizontal,18).padding(.vertical,6)
    }
}

struct GardenView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var page = 0
    @State private var chosen = 1
    var region: GardenRegion { GardenRegion.all[page] }
    var nextTask: GardenTask? { GardenTask.all.first { !game.progress.restored.contains($0.id) } }
    var body: some View {
        VStack(spacing:8) {
            HStack(alignment:.center) {
                VStack(alignment:.leading,spacing:3) {
                    Text(game.progress.gardenComplete ? "A world in bloom." : region.title).font(.system(size:27,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night)
                    Text("Island \(page+1) of \(GardenRegion.all.count) · \(game.progress.restored.count)/6 restored").font(.system(size:12,weight:.semibold,design:.rounded)).foregroundStyle(Palette.mint)
                }
                Spacer(minLength:4)
                Button { game.showTasks = true; game.effect("tap") } label: { Image(systemName:"book.closed.fill").font(.system(size:23)).foregroundStyle(Palette.night).frame(width:48,height:48).background(Palette.paper,in:Circle()).shadow(color:Palette.mint.opacity(0.15),radius:0,y:4) }.accessibilityLabel("Field tasks and power patterns").accessibilityIdentifier("openTasks")
            }.padding(.horizontal,22)
            GardenMapScene(page:page,selected:chosen) { level in chosen = level }
                .overlay(alignment:.bottom) {
                    HStack {
                        sceneGate("Farm & craft",sprite:3,id:"openFarm") { game.tab = 2 }
                        Spacer()
                        sceneGate("Harvest rally",sprite:9,id:"openRace") { game.tab = 3 }
                    }.padding(.horizontal,28).padding(.bottom,4)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(DragGesture(minimumDistance:35).onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    let target = min(GardenRegion.all.count-1,max(0,page+(value.translation.width < 0 ? 1 : -1)))
                    withAnimation(reduceMotion ? nil : .spring(response:0.4,dampingFraction:0.85)) { page = target }
                    let first = target*GardenRegion.stopsPerPage+1
                    chosen = game.progress.isUnlocked(first) ? min(game.progress.nextLevel,first+9) : first
                    game.effect("tap")
                }).accessibilityElement(children:.contain).accessibilityIdentifier("gardenMap")
                .accessibilityAction(named:"Next island") { page = min(GardenRegion.all.count-1,page+1); chosen = page*10+1 }
                .accessibilityAction(named:"Previous island") { page = max(0,page-1); chosen = min(game.progress.nextLevel,page*10+1) }
            VStack(spacing:8) {
                Text("Swipe across the island to explore").font(.system(size:11,weight:.semibold,design:.rounded)).foregroundStyle(Palette.mint)
                if game.progress.isUnlocked(chosen) {
                    DifficultyBadge(level:Level.campaign[chosen-1]).accessibilityIdentifier("selectedDifficulty")
                    PrimaryButton(title:"Bloom circuits",subtitle:"Level \(chosen) · \(Level.campaign[chosen-1].moves) \(Level.campaign[chosen-1].moves == 1 ? "turn" : "turns")",symbol:"leaf.fill",id:"playLevel") { game.start(Level.campaign[chosen-1]) }
                } else {
                    Text("Finish level \(game.progress.nextLevel) to open this island").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.mint).frame(minHeight:60).frame(maxWidth:.infinity).background(Palette.paper,in:RoundedRectangle(cornerRadius:22))
                    Button("Return to your open island") { openCurrent() }.font(.subheadline.bold()).foregroundStyle(Palette.night).frame(minHeight:44).accessibilityIdentifier("openCurrentIsland")
                }
                if let task = nextTask {
                    HStack(spacing:10) {
                        Image(systemName:task.icon).font(.title2).foregroundStyle(Palette.mint)
                        VStack(alignment:.leading,spacing:3) { Text(task.title).font(.system(size:13,weight:.bold,design:.rounded)); Text("\(game.progress.restored.count)/6 restored").font(.caption).foregroundStyle(Palette.mint) }
                        Spacer(minLength:4)
                        Button { game.restore(task); game.effect("craft") } label: { Label("2",systemImage:"star.fill").font(.headline).padding(12).background(Palette.sunlight,in:Capsule()) }.accessibilityLabel("Restore \(task.title) for 2 stars").accessibilityIdentifier("restoreProject")
                    }.foregroundStyle(Palette.night).padding(12).background(Palette.paper,in:RoundedRectangle(cornerRadius:20))
                } else { Text("6/6 restored").font(.caption.bold()).foregroundStyle(Palette.mint) }
            }.padding(.horizontal,22).padding(.bottom,8)
        }.onAppear { openCurrent() }.onChange(of:game.progress.nextLevel) { _,_ in openCurrent() }
    }
    func openCurrent() { page = (game.progress.nextLevel-1)/10; chosen = game.progress.nextLevel }
    func sceneGate(_ title:String,sprite:Int,id:String,action:@escaping ()->Void) -> some View {
        Button { action(); game.effect("tap") } label: {
            VStack(spacing:0) { SpriteView(index:sprite).frame(width:65,height:64).shadow(color:Palette.night.opacity(0.25),radius:2,y:5); Text(title).font(.system(size:12,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night).padding(.horizontal,10).padding(.vertical,7).background(Palette.paper,in:Capsule()).compositingGroup().shadow(color:Palette.mint.opacity(0.2),radius:0,y:3) }
        }.buttonStyle(PressStyle()).accessibilityIdentifier(id)
    }
}

struct GardenMapScene: View {
    @EnvironmentObject var game:GameModel
    let page:Int
    let selected:Int
    let select:(Int)->Void
    let xs:[CGFloat] = [0.33,0.64,0.74,0.44,0.23,0.56,0.79,0.49,0.22,0.57]
    func point(_ stop:Int,_ size:CGSize)->CGPoint { CGPoint(x:size.width*xs[stop],y:size.height*(0.79-CGFloat(stop)*0.068)) }
    var body:some View {
        GeometryReader { geo in
            ZStack {
                LivingIslandView(variant:page,restored:game.progress.restored.count).allowsHitTesting(false).accessibilityHidden(true)
                Canvas { context,size in
                    var path = Path(); path.move(to:point(0,size))
                    for stop in 1..<10 { let a = point(stop-1,size), b = point(stop,size); path.addCurve(to:b,control1:CGPoint(x:a.x,y:(a.y+b.y)/2),control2:CGPoint(x:b.x,y:(a.y+b.y)/2)) }
                    context.stroke(path,with:.color(.white.opacity(0.85)),style:StrokeStyle(lineWidth:11,lineCap:.round))
                    context.stroke(path,with:.color(Palette.gold.opacity(0.6)),style:StrokeStyle(lineWidth:3,lineCap:.round,dash:[2,9]))
                }.allowsHitTesting(false)
                ForEach(GardenRegion.all[page].levels) { level in
                    let unlocked = game.progress.isUnlocked(level.id)
                    let completed = game.progress.completed[level.id] != nil
                    Button { select(level.id); game.effect("tap") } label: {
                        ZStack {
                            Circle().fill(Color(hex:0x719965)).offset(y:5)
                            Circle().fill(LinearGradient(colors:unlocked ? [Palette.paper,Color(hex:0xFFE0A0)] : [Color(hex:0xD8E2D3),Color(hex:0x9EBAAA)],startPoint:.topLeading,endPoint:.bottomTrailing)).overlay(Circle().stroke(.white.opacity(0.95),lineWidth:selected == level.id ? 4 : 2))
                            if !unlocked { Image(systemName:"lock.fill").font(.system(size:15,weight:.bold)).foregroundStyle(Palette.mint) }
                            else { Text("\(level.id)").font(.system(size:level.id > 99 ? 13 : 17,weight:.black,design:.rounded)).foregroundStyle(Palette.night) }
                            if completed { Image(systemName:"star.fill").font(.system(size:13)).foregroundStyle(Palette.gold).offset(x:17,y:-17) }
                            if selected == level.id && unlocked { Image(systemName:"arrowtriangle.down.fill").font(.system(size:16)).foregroundStyle(Palette.coral).offset(y:-33) }
                        }.frame(width:46,height:46).shadow(color:Palette.night.opacity(0.18),radius:2,y:3)
                    }.buttonStyle(PressStyle()).disabled(!unlocked).position(point((level.id-1)%10,geo.size)).accessibilityLabel("Level \(level.id), \(level.difficulty.title), \(GardenRegion.all[page].placeName(for:level.id)), \(completed ? "completed" : unlocked ? "open" : "locked")").accessibilityIdentifier("level\(level.id)")
                }
                VStack { HStack { Text("\(GardenRegion.all[page].levels.first!.id)–\(GardenRegion.all[page].levels.last!.id)").font(.system(size:11,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night).padding(9).background(Palette.paper.opacity(0.9),in:Capsule()).accessibilityIdentifier("islandRange"); Spacer() }; Spacer() }.padding(.horizontal,22).padding(.top,8).allowsHitTesting(false)
            }
        }
    }
}

struct FieldJournalView: View {
    @EnvironmentObject var game:GameModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // Retain the selected entry when rotation or text size changes page capacity.
    @State private var selectedEntry = 0

    var body:some View {
        NavigationStack {
            GeometryReader { geometry in
                let cramped = geometry.size.height < 650 || textSize >= .xxLarge
                let oneAtATime = geometry.size.height < 500 || textSize.isAccessibilitySize
                let tasksPerPage = oneAtATime ? 1 : cramped ? 2 : 3
                let powersPerPage = oneAtATime ? 1 : cramped ? 2 : 4
                let taskCount = FieldTask.all.count
                let starts = Array(stride(from:0,to:taskCount,by:tasksPerPage)) + Array(stride(from:taskCount,to:taskCount+GardenTool.allCases.count,by:powersPerPage))
                let position = starts.lastIndex(where: { $0 <= selectedEntry }) ?? 0
                let start = starts[position]
                let rewards = start < taskCount
                VStack(alignment:.leading,spacing:12) {
                    if !textSize.isAccessibilitySize {
                        Text(rewards ? "Good things grow together." : "Patterns make power.")
                            .font(.system(.title2,design:.rounded,weight:.heavy)).foregroundStyle(Palette.night)
                            .fixedSize(horizontal:false,vertical:true)
                    }
                    Text(rewards ? "Permanent milestones. Your first ten hints are free. More hints cost 3 coins; a shuffle costs 15." : "Make a formation to grow its power inside the board. Tap it to blast and chain nearby powers.")
                        .font(.subheadline).foregroundStyle(Palette.mint).fixedSize(horizontal:false,vertical:true)
                        .accessibilityIdentifier("journalInstructions")
                    if rewards {
                        ForEach(Array(FieldTask.all.dropFirst(start).prefix(tasksPerPage))) { task in
                            taskCard(task)
                        }
                    } else {
                        ForEach(Array(GardenTool.allCases.enumerated()).dropFirst(start-taskCount).prefix(powersPerPage),id:\.offset) { item in
                            HStack(alignment:.top,spacing:14) {
                                PatternDiagram(tool:item.element).frame(width:77,height:77)
                                VStack(alignment:.leading,spacing:4) {
                                    Text(item.element.title).font(.headline).foregroundStyle(Palette.night)
                                    Text(["4 in a line, or a 4-piece circuit", "L or T of 5, or a 6-piece circuit", "A 7-piece cross, or an 8-piece circuit", "5 in a line, or a 10-piece circuit"][item.offset]).font(.caption).foregroundStyle(Palette.mint)
                                    Text(item.element.detail).font(.caption2).foregroundStyle(Palette.muted)
                                }.fixedSize(horizontal:false,vertical:true)
                            }.accessibilityElement(children:.combine).accessibilityIdentifier("journalPower_\(item.element.rawValue)")
                        }
                    }
                    Spacer(minLength:4)
                    Button(rewards ? "Power patterns" : "Field rewards") {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration:0.2)) { selectedEntry = rewards ? taskCount : 0 }
                    }.font(.headline).foregroundStyle(Palette.night).frame(maxWidth:.infinity,minHeight:44).accessibilityIdentifier("journalPatterns")
                    Text("Swipe pages · \(position+1) of \(starts.count)").font(.caption.bold()).foregroundStyle(Palette.mint).frame(maxWidth:.infinity)
                        .accessibilityIdentifier("journalPageCount").accessibilityLabel("Journal pages")
                        .accessibilityValue("Page \(position+1) of \(starts.count)")
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: turnPage(1,position:position,starts:starts)
                            case .decrement: turnPage(-1,position:position,starts:starts)
                            @unknown default: break
                            }
                        }
                }.padding(.horizontal,20).padding(.vertical,16).frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.topLeading)
                    .background(Palette.sky).contentShape(Rectangle())
                    .simultaneousGesture(DragGesture(minimumDistance:35).onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        turnPage(value.translation.width < 0 ? 1 : -1,position:position,starts:starts)
                    }).accessibilityElement(children:.contain).accessibilityIdentifier("journalPages")
            }
            .navigationTitle("Field journal").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.confirmationAction) { Button("Done") { dismiss() } } }
        }
    }

    private func turnPage(_ offset:Int,position:Int,starts:[Int]) {
        let next = min(starts.count-1,max(0,position+offset))
        guard next != position else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration:0.2)) { selectedEntry = starts[next] }
    }

    private func taskCard(_ task:FieldTask) -> some View {
        let value = task.value(progress:game.progress,ecosystem:game.ecosystem,assistance:game.assistance)
        let claimed = game.assistance.claimed.contains(task.id)
        let reward = "\(min(value,task.target))/\(task.target) · \(task.tool.title)" + (task.hints > 0 ? " + \(task.hints) hints" : "") + (task.shuffles > 0 ? " + \(task.shuffles) shuffles" : "")
        return VStack(alignment:.leading,spacing:8) {
            HStack(alignment:.center,spacing:12) {
                SpriteView(index:task.tool.sprite).frame(width:55,height:64)
                VStack(alignment:.leading,spacing:5) {
                    Text(task.title).font(.headline).foregroundStyle(Palette.night)
                    Text(reward).font(.caption).foregroundStyle(Palette.mint)
                }.fixedSize(horizontal:false,vertical:true).frame(maxWidth:.infinity,alignment:.leading)
                if !textSize.isAccessibilitySize { claimButton(task,value:value,claimed:claimed) }
            }
            if textSize.isAccessibilitySize { claimButton(task,value:value,claimed:claimed).frame(maxWidth:.infinity,alignment:.trailing) }
        }.padding(14).background(Palette.paper,in:RoundedRectangle(cornerRadius:22)).accessibilityElement(children:.contain).accessibilityIdentifier("journalTask_\(task.id)")
    }

    private func claimButton(_ task:FieldTask,value:Int,claimed:Bool) -> some View {
        Button(claimed ? "Claimed" : value >= task.target ? "Claim" : "Growing") { game.claim(task) }
            .font(.caption.bold()).foregroundStyle(Palette.night).frame(minWidth:55,minHeight:44)
            .disabled(claimed || value < task.target).accessibilityIdentifier("claim_\(task.id)")
            .accessibilityLabel("\(claimed ? "Claimed" : value >= task.target ? "Claim" : "Growing") reward for \(task.title)")
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

// Original live 3D scenery; the numbered controls above it remain native and accessible.
struct LivingIslandView: UIViewRepresentable {
    let variant:Int
    let restored:Int
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    func makeUIView(context:Context)->SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 30
        view.allowsCameraControl = false
        view.isUserInteractionEnabled = false
        view.autoenablesDefaultLighting = false
        return view
    }
    func updateUIView(_ view:SCNView,context:Context) {
        let key = "\(variant)-\(restored)-\(reduceMotion)"
        guard view.accessibilityIdentifier != key else { return }
        view.accessibilityIdentifier = key
        view.scene = makeScene()
        view.isPlaying = !reduceMotion
    }
    func makeScene()->SCNScene {
        let scene = SCNScene()
        let camera = SCNNode(); camera.camera = SCNCamera(); camera.camera?.usesOrthographicProjection = true; camera.camera?.orthographicScale = 5.6
        camera.position = SCNVector3(0,12,9); camera.look(at:SCNVector3(0,0,0)); scene.rootNode.addChildNode(camera)
        let sun = SCNNode(); sun.light = SCNLight(); sun.light?.type = .directional; sun.light?.intensity = 1100; sun.position = SCNVector3(-5,10,5); sun.look(at:SCNVector3Zero); scene.rootNode.addChildNode(sun)
        let ambient = SCNNode(); ambient.light = SCNLight(); ambient.light?.type = .ambient; ambient.light?.intensity = 650; ambient.light?.color = UIColor(red:0.89,green:0.96,blue:1,alpha:1); scene.rootNode.addChildNode(ambient)
        let greens:[UInt32] = [0xB4D993,0xD4DE9B,0x9CCEA0,0xA8D9CB,0xB9D8AD,0xB8CFE1,0xD5DEA0,0xCEE2BF,0xAAD3B0,0xC6CAE1,0xCADB92,0xBDCFE6]
        let soil = node(SCNBox(width:7.5,height:0.9,length:9.4,chamferRadius:1.1),0xB8A282,SCNVector3(0,-0.55,0)); scene.rootNode.addChildNode(soil)
        scene.rootNode.addChildNode(node(SCNBox(width:7.6,height:0.3,length:9.5,chamferRadius:1),greens[variant%12],SCNVector3(0,0,0)))
        for i in 0..<14 {
            let side:Float = i%2 == 0 ? -1 : 1
            let z = Float(i/2)*1.22-3.7
            let x = side*(2.7+Float((i+variant)%3)*0.16)
            let tree = SCNNode(); tree.position = SCNVector3(x,0.2,z)
            tree.addChildNode(node(SCNCylinder(radius:0.10,height:0.60),0xAC815D,SCNVector3(0,0.3,0)))
            let crown = node(SCNSphere(radius:0.39+Double((i+variant)%3)*0.08),i%3 == 0 ? 0xEEB7BA : 0x79AE83,SCNVector3(0,0.8,0))
            crown.scale = SCNVector3(1,1.18,1); tree.addChildNode(crown)
            if !reduceMotion { crown.runAction(.repeatForever(.sequence([.rotateBy(x:0,y:0,z:0.035,duration:2.2),.rotateBy(x:0,y:0,z:-0.035,duration:2.2)]))) }
            scene.rootNode.addChildNode(tree)
        }
        // Glass greenhouse and a small pond anchor the scenery to familiar garden places.
        let house = node(SCNBox(width:1,height:0.75,length:1.1,chamferRadius:0.09),0xF6ECD0,SCNVector3(-2.1,0.48,-3.15)); scene.rootNode.addChildNode(house)
        let roof = node(SCNPyramid(width:1.3,height:0.65,length:1.35),restored > 0 ? 0x8DC4BD : 0xD3B49A,SCNVector3(-2.1,1.15,-3.15)); scene.rootNode.addChildNode(roof)
        let pond = node(SCNCylinder(radius:0.8,height:0.07),0x78C5DA,SCNVector3(1.95,0.2,-3.35)); pond.scale = SCNVector3(1,1,1.4); scene.rootNode.addChildNode(pond)
        for i in 0..<9 {
            let x = Float((i*19+variant*7)%61)/10-3
            let z = Float((i*11+variant*3)%70)/10-3.5
            let flower = SCNNode(); flower.position = SCNVector3(x,0.25,z)
            flower.addChildNode(node(SCNCylinder(radius:0.035,height:0.25),0x6C9871,SCNVector3(0,0.12,0)))
            for petal in 0..<5 {
                let a = Float(petal)*Float.pi*2/5
                let leaf = node(SCNSphere(radius:0.13),i%2 == 0 ? 0xF3D176 : 0xECA9BE,SCNVector3(cos(a)*0.12,0.29,sin(a)*0.12)); leaf.scale.y = 0.4; flower.addChildNode(leaf)
            }
            scene.rootNode.addChildNode(flower)
        }
        for i in 0..<4 {
            let cloud = SCNNode(); cloud.position = SCNVector3(i%2 == 0 ? -3.5 : 3.5,2.2,Float(i)*2.8-4.5)
            for puff in 0..<3 { let n = node(SCNSphere(radius:0.48),0xFFFFFF,SCNVector3(Float(puff)*0.42,Float(puff%2)*0.12,0)); n.opacity = 0.78; cloud.addChildNode(n) }
            if !reduceMotion { cloud.runAction(.repeatForever(.sequence([.moveBy(x:0.3,y:0,z:0,duration:5),.moveBy(x:-0.3,y:0,z:0,duration:5)]))) }
            scene.rootNode.addChildNode(cloud)
        }
        return scene
    }
    func node(_ geometry:SCNGeometry,_ hex:UInt32,_ position:SCNVector3)->SCNNode {
        let material = SCNMaterial(); material.diffuse.contents = UIColor(red:CGFloat((hex>>16)&255)/255,green:CGFloat((hex>>8)&255)/255,blue:CGFloat(hex&255)/255,alpha:1); material.roughness.contents = 0.8; material.lightingModel = .physicallyBased; geometry.materials = [material]
        let n = SCNNode(geometry:geometry); n.position = position; return n
    }
}
