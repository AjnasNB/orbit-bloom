import SwiftUI
import SceneKit

struct RootView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var loading = true
    @State private var selectedHubRoom: IslandRoom?
    private let clock = Timer.publish(every:1,on:.main,in:.common).autoconnect()
    var body: some View {
        ZStack {
            SpaceBackdrop()
            if game.raceActive { DeliveryRaceView() }
            else if let activity = game.activity {
                VStack(spacing:0) {
                    GameHUD()
                    IslandActivityView(kind:activity,level:game.activityLevel,onComplete: { score in
                        game.completeActivity(score); game.exitActivity()
                    },onExit:game.exitActivity)
                }.frame(maxWidth:650).frame(maxWidth:.infinity)
            }
            else if game.engine != nil { PuzzleView().id(game.engine?.level.id) }
            else {
                VStack(spacing:0) {
                    if game.tab != 0 && game.tab != 1 { GameHUD() }
                    if game.tab == 2 || game.tab == 3 {
                        RoomExitHeader(kind:game.tab == 2 ? .farm : .rally) { game.tab = 0; game.effect("tap") }
                            .frame(maxWidth:650)
                    } else if game.tab != 0 && game.tab != 1 && game.tab != 5 {
                        Button { game.tab = 0; game.effect("tap") } label: {
                            Label("Back to your island",systemImage:"arrow.uturn.backward").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.night).frame(maxWidth:.infinity,minHeight:44,alignment:.leading)
                        }.padding(.horizontal,24).accessibilityIdentifier("returnWorld")
                    }
                    Group {
                        switch game.tab {
                        case 2: FarmView()
                        case 3: DeliveryLobby()
                        case 4: ShopView()
                        case 5: IslandHubView(stars:game.progress.stars,completedProjects:game.progress.restored.count,
                            activityLevels:game.journey.levels.mapValues { min(1000,$0+1) }.merging(["bloom":game.progress.nextLevel]) { _,new in new },
                            initialRoom:selectedHubRoom,onChoose:chooseRoom,onExit:{ game.tab = 0 })
                        default: GardenView()
                        }
                    }.id(game.tab).transition(.opacity).frame(maxWidth:game.tab == 0 || game.tab == 1 ? .infinity : 650).frame(maxWidth:.infinity,maxHeight:.infinity)
                }.accessibilityHidden(loading)
                    .animation(reduceMotion ? nil : .easeInOut(duration:0.2),value:game.tab)
            }
            if loading { loadingScreen.transition(.opacity) }
            if let flight = game.coinFlight { CoinFlightView(amount:game.lastCoinAward).id(flight).allowsHitTesting(false) }
            if let toast = game.toast {
                VStack { Spacer(); Text(toast).font(.system(.subheadline,design:.rounded,weight:.semibold)).multilineTextAlignment(.center).foregroundStyle(Palette.night).padding(16).background(Palette.paper,in:RoundedRectangle(cornerRadius:20)).padding(.horizontal,24).padding(.bottom,80) }.allowsHitTesting(false)
            }
        }
        .sheet(isPresented:$game.showSettings) { SettingsView() }
        .sheet(isPresented:$game.showTasks) { FieldJournalView() }
        .sheet(isPresented:$game.showWorldEvents) { WorldEventsView(clock:game.eventClock,onChoose:chooseRoom) }
        .sheet(isPresented:$game.showRoomRecords) { RoomRecordsView() }
        .task { try? await Task.sleep(for:.milliseconds(game.testing ? 120 : 1000)); game.progress.hasSeenIntro = true; game.save(); withAnimation(.easeOut(duration:0.35)) { loading = false } }
        .onAppear { purchases.game = game; game.updateMusic(); Task { await purchases.recoverUnfinished() } }
        .task {
            while !Task.isCancelled {
                await game.eventClock.refresh()
                try? await Task.sleep(for:.seconds(600))
            }
        }
        .onChange(of:game.tab) { _,_ in game.updateMusic() }
        .onChange(of:game.engine != nil) { _,_ in game.updateMusic() }
        .onChange(of:game.raceActive) { _,_ in game.updateMusic() }
        .onReceive(clock) { _ in game.refreshClock() }
    }
    private func chooseRoom(_ room:IslandRoom) {
        game.showWorldEvents = false
        selectedHubRoom = room
        switch room {
        case .bloom: game.tab = 0
        case .farm: game.tab = 2
        case .rally: game.tab = 3
        default: if let kind = IslandActivityKind(rawValue:room.rawValue) { game.enterActivity(kind) }
        }
        game.effect("tap")
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
            Button { game.tab = 4 } label: { HStack(spacing:4) { Image(systemName:"heart.fill").foregroundStyle(Palette.coral); Text("\(game.ecosystem.lives.total)").foregroundStyle(Palette.cream) }.font(.system(size:15,weight:.bold,design:.rounded)).frame(minWidth:48,minHeight:44) }.accessibilityLabel("\(game.ecosystem.lives.total) lives. Open refill shop").accessibilityIdentifier("lifeBalance").disabled(game.activity != nil || game.engine != nil)
            Button { game.tab = 4; game.effect("tap") } label: { HStack(spacing:3) { SpriteView(index:11).frame(width:24,height:24); Text(game.progress.coins.formatted()).monospacedDigit().contentTransition(.numericText()).font(.system(size:15,weight:.bold,design:.rounded)).foregroundStyle(Palette.night) }.frame(minHeight:44) }.accessibilityLabel("Coins, \(game.progress.coins). Open supplies").accessibilityIdentifier("openShop").disabled(game.activity != nil || game.engine != nil)
            Button { game.showSettings = true } label: { Image(systemName:"gearshape.fill").font(.system(size:20,weight:.bold)).foregroundStyle(Palette.muted).frame(width:44,height:44) }.accessibilityLabel("Settings").accessibilityIdentifier("settings")
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
        GeometryReader { geometry in
            let wide = geometry.size.width > geometry.size.height
            ZStack {
                GardenMapScene(page:page,selected:chosen,topInset:wide ? 154 : 142,bottomInset:wide ? 172 : 210) { chosen = $0 }
                    .contentShape(Rectangle())
                    .simultaneousGesture(DragGesture(minimumDistance:35).onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        turnPage(value.translation.width < 0 ? 1 : -1)
                    }).accessibilityElement(children:.contain).accessibilityIdentifier("gardenMap")
                    .accessibilityAction(named:"Next island") { turnPage(1) }
                    .accessibilityAction(named:"Previous island") { turnPage(-1) }
                VStack(spacing:8) {
                    GameHUD().background(Palette.paper.opacity(0.96),in:Capsule()).padding(.horizontal,12)
                    HStack(alignment:.top,spacing:8) {
                        VStack(alignment:.leading,spacing:3) {
                            Text("AURORA ATOLL").font(.system(size:10,weight:.black,design:.rounded)).tracking(2)
                            Text(region.title).font(.system(size:22,weight:.heavy,design:.rounded)).lineLimit(1).minimumScaleFactor(0.8)
                            Text("District \(page+1)/\(GardenRegion.all.count) · Swipe to explore").font(.system(size:11,weight:.bold,design:.rounded))
                        }.foregroundStyle(Palette.night).padding(.horizontal,14).padding(.vertical,8).background(Palette.paper.opacity(0.94),in:RoundedRectangle(cornerRadius:18))
                        Spacer(minLength:0)
                        mapButton("Field tasks and power patterns",symbol:"book.closed.fill",id:"openTasks") { game.showTasks = true }
                    }.padding(.horizontal,16)
                    Spacer(minLength:0)
                    gardenDock(wide:wide)
                }.padding(.top,4).padding(.bottom,8)
            }.frame(maxWidth:.infinity,maxHeight:.infinity)
        }.onAppear { openCurrent() }.onChange(of:game.progress.nextLevel) { _,_ in openCurrent() }
    }
    private func gardenDock(wide:Bool)->some View {
        VStack(spacing:8) {
            HStack(spacing:8) {
                if let task=nextTask {
                    Button { game.restore(task); game.effect("craft") } label: {
                        Label("\(task.title) · 2 ★",systemImage:task.icon).font(.system(size:11,weight:.heavy,design:.rounded)).lineLimit(1)
                            .foregroundStyle(Palette.night).padding(.horizontal,12).frame(minHeight:44).background(Palette.paper,in:Capsule())
                    }.buttonStyle(PressStyle()).accessibilityLabel("Restore \(task.title) for 2 stars").accessibilityIdentifier("restoreProject")
                }
                Spacer(minLength:0)
                Label("\(game.progress.stars)",systemImage:"star.fill").font(.system(size:14,weight:.black,design:.rounded)).foregroundStyle(Palette.gold)
                    .padding(.horizontal,12).frame(height:44).background(Palette.paper,in:Capsule()).accessibilityLabel("\(game.progress.stars) restoration stars")
            }
            HStack(spacing:8) {
                roomDoor("Farm",symbol:"leaf.fill",id:"openFarm",label:"Enter Farm room. Plant & harvest. No life cost.") { game.tab = 2 }
                roomDoor("Rally",symbol:"car.fill",id:"openRace",label:"Enter Rally room. Drive & deliver. No life cost.") { game.tab = 3 }
                roomDoor("7 rooms",symbol:"door.left.hand.open",id:"openIslandHub",label:"Explore all seven game rooms") { game.tab = 5 }
                mapButton("Worldwide timed events",symbol:"globe.europe.africa.fill",id:"openWorldEvents") { game.showWorldEvents = true }
                mapButton("Room records and Game Center leaderboard",symbol:"trophy.fill",id:"openRoomRecords") { game.showRoomRecords = true }
            }
            if game.progress.isUnlocked(chosen) {
                HStack(spacing:8) {
                    VStack(alignment:.leading,spacing:4) {
                        Text("LEVEL \(chosen)").font(.system(size:12,weight:.black,design:.rounded)).foregroundStyle(Palette.night)
                        DifficultyBadge(level:Level.campaign[chosen-1]).accessibilityIdentifier("selectedDifficulty")
                    }.frame(minWidth:102)
                    PrimaryButton(title:"Play",subtitle:"\(Level.campaign[chosen-1].moves) \(Level.campaign[chosen-1].moves == 1 ? "turn" : "turns")",symbol:"leaf.fill",id:"playLevel") { game.start(Level.campaign[chosen-1]) }
                }
            } else {
                Button { openCurrent() } label: {
                    VStack(spacing:3) {
                        Text("District locked · complete level \(game.progress.nextLevel)").font(.system(size:12,weight:.heavy,design:.rounded))
                        Label("Return to your open district",systemImage:"arrow.uturn.backward").font(.system(size:13,weight:.bold,design:.rounded))
                    }.frame(maxWidth:.infinity,minHeight:60).foregroundStyle(Palette.night).background(Palette.sunlight,in:RoundedRectangle(cornerRadius:18))
                }.buttonStyle(PressStyle()).accessibilityIdentifier("openCurrentIsland")
            }
        }.padding(10).frame(maxWidth:wide ? 660 : 600).background(Palette.sky.opacity(0.93),in:RoundedRectangle(cornerRadius:26))
            .overlay(RoundedRectangle(cornerRadius:26).stroke(.white.opacity(0.8),lineWidth:2)).padding(.horizontal,12)
    }
    private func roomDoor(_ title:String,symbol:String,id:String,label:String,action:@escaping()->Void)->some View {
        Button { action(); game.effect("tap") } label: {
            VStack(spacing:2) { Image(systemName:symbol).font(.system(size:17,weight:.heavy)); Text(title).font(.system(size:11,weight:.heavy,design:.rounded)).lineLimit(1) }
                .foregroundStyle(Palette.night).frame(maxWidth:.infinity,minHeight:48).background(Palette.paper,in:RoundedRectangle(cornerRadius:14))
        }.buttonStyle(PressStyle()).accessibilityLabel(label).accessibilityHint("Opens a separate room with a clear exit back to the island").accessibilityIdentifier(id)
    }
    private func mapButton(_ label:String,symbol:String,id:String,action:@escaping()->Void)->some View {
        Button { action(); game.effect("tap") } label: {
            Image(systemName:symbol).font(.system(size:20,weight:.bold)).foregroundStyle(Palette.night).frame(width:48,height:48)
                .background(Palette.paper,in:RoundedRectangle(cornerRadius:16))
        }.buttonStyle(PressStyle()).accessibilityLabel(label).accessibilityIdentifier(id)
    }
    private func turnPage(_ step:Int) {
        let target=min(GardenRegion.all.count-1,max(0,page+step))
        guard target != page else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration:0.35)) { page=target }
        let first=target*10+1
        chosen=game.progress.isUnlocked(first) ? min(game.progress.nextLevel,first+9) : first
        game.effect("tap")
    }
    func openCurrent() { page=(game.progress.nextLevel-1)/10; chosen=game.progress.nextLevel }
}

struct GardenMapScene: View {
    @EnvironmentObject var game:GameModel
    let page:Int,selected:Int
    let topInset:CGFloat,bottomInset:CGFloat
    let select:(Int)->Void
    private let xs:[CGFloat]=[0.29,0.65,0.80,0.50,0.22,0.60,0.80,0.48,0.22,0.62]
    private func point(_ stop:Int,_ size:CGSize)->CGPoint {
        let height=max(220,size.height-topInset-bottomInset)
        if size.width > size.height {
            let column=stop < 5 ? stop : 9-stop
            return CGPoint(x:size.width*(0.18+CGFloat(column)*0.16),y:topInset+height*(stop < 5 ? 0.78 : 0.20))
        }
        return CGPoint(x:size.width*xs[stop],y:topInset+height*(0.92-CGFloat(stop)*0.092))
    }
    var body:some View {
        GeometryReader { geo in
            ZStack {
                LivingIslandView(variant:page,restored:game.progress.restored.count).ignoresSafeArea().allowsHitTesting(false).accessibilityHidden(true)
                Canvas { context,size in
                    var path=Path()
                    let start=point(0,size),end=point(9,size)
                    path.move(to:CGPoint(x:start.x,y:size.height+40)); path.addLine(to:start)
                    for stop in 1..<10 {
                        let a=point(stop-1,size),b=point(stop,size)
                        path.addCurve(to:b,control1:CGPoint(x:a.x,y:(a.y+b.y)/2),control2:CGPoint(x:b.x,y:(a.y+b.y)/2))
                    }
                    path.addLine(to:CGPoint(x:end.x,y:-40))
                    context.stroke(path,with:.color(Color(hex:0x709960).opacity(0.5)),style:StrokeStyle(lineWidth:30,lineCap:.round))
                    context.stroke(path,with:.color(Color(hex:0xFFF0C8)),style:StrokeStyle(lineWidth:23,lineCap:.round))
                    context.stroke(path,with:.color(Color(hex:0xCEA878).opacity(0.7)),style:StrokeStyle(lineWidth:2,lineCap:.round,dash:[1,9]))
                }.allowsHitTesting(false).accessibilityHidden(true)
                ForEach(GardenRegion.all[page].levels) { level in
                    let unlocked=game.progress.isUnlocked(level.id),completed=game.progress.completed[level.id] != nil
                    Button { select(level.id); game.effect("tap") } label: {
                        ZStack {
                            Circle().fill(unlocked ? Color(hex:0xCF892A) : Color(hex:0x758B7D)).offset(y:5)
                            Circle().fill(LinearGradient(colors:unlocked ? [Color(hex:0xFFF7DC),Color(hex:0xFFCF69)] : [Color(hex:0xE8EEE1),Color(hex:0xADC7B2)],startPoint:.topLeading,endPoint:.bottomTrailing))
                                .overlay(Circle().stroke(.white,lineWidth:selected == level.id ? 4 : 2))
                            if !unlocked { Image(systemName:"lock.fill").font(.system(size:18,weight:.bold)).foregroundStyle(Palette.mint) }
                            else { Text("\(level.id)").font(.system(size:level.id > 99 ? 15 : 21,weight:.black,design:.rounded)).foregroundStyle(Color(hex:0x7B4816)) }
                            if completed { Image(systemName:"star.fill").font(.system(size:17)).foregroundStyle(Palette.gold).offset(x:20,y:-20) }
                            if selected == level.id && unlocked { Image(systemName:"arrowtriangle.down.fill").font(.system(size:18)).foregroundStyle(Color(hex:0xD2556D)).offset(y:-36) }
                        }.frame(width:54,height:54).compositingGroup().shadow(color:Palette.night.opacity(0.25),radius:3,y:4)
                    }.buttonStyle(PressStyle()).disabled(!unlocked).position(point((level.id-1)%10,geo.size))
                        .accessibilityLabel("Level \(level.id), \(level.difficulty.title), \(GardenRegion.all[page].placeName(for:level.id)), \(completed ? "completed" : unlocked ? "open" : "locked")").accessibilityIdentifier("level\(level.id)")
                }
                Text("\(GardenRegion.all[page].levels.first!.id)–\(GardenRegion.all[page].levels.last!.id)").font(.system(size:11,weight:.black,design:.rounded))
                    .foregroundStyle(Palette.night).padding(10).background(Palette.paper,in:Capsule()).position(x:48,y:topInset+20).accessibilityIdentifier("islandRange")
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

// A continuous original garden. Only this district and its two neighbors are built,
// keeping the 102-page campaign bounded instead of loading 1,020 scenery groups.
final class GardenSceneView: SCNView {
    var gardenCamera:SCNCamera?
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0,bounds.height > 0 else { return }
        gardenCamera?.orthographicScale=max(9.4,10.5*Double(bounds.height/bounds.width)/2)
    }
}
struct LivingIslandView: UIViewRepresentable {
    let variant:Int,restored:Int
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    func makeUIView(context:Context)->GardenSceneView {
        let view=GardenSceneView(); view.backgroundColor=UIColor(red:0.72,green:0.86,blue:0.62,alpha:1)
        view.antialiasingMode = .multisampling4X; view.preferredFramesPerSecond=30
        view.allowsCameraControl=false; view.isUserInteractionEnabled=false
        view.isAccessibilityElement=false; view.accessibilityElementsHidden=true; view.autoenablesDefaultLighting=false
        return view
    }
    func updateUIView(_ view:GardenSceneView,context:Context) {
        let key="\(variant)-\(restored)-\(reduceMotion)"
        guard view.accessibilityIdentifier != key else { return }
        view.accessibilityIdentifier=key; view.scene=scene(); view.isPlaying=false
        view.gardenCamera=view.scene?.rootNode.childNode(withName:"gardenCamera",recursively:false)?.camera
        view.setNeedsLayout()
    }
    static func dismantleUIView(_ view:GardenSceneView,coordinator:()) { view.isPlaying=false; view.gardenCamera=nil; view.scene=nil }
    private func scene()->SCNScene {
        let scene=SCNScene(),root=scene.rootNode
        let camera=SCNNode(); camera.name="gardenCamera"; camera.camera=SCNCamera(); camera.camera?.usesOrthographicProjection=true
        camera.camera?.orthographicScale=9.4; camera.position=SCNVector3(0,22,16); camera.look(at:SCNVector3(0,0,0)); root.addChildNode(camera)
        let sun=SCNNode(); sun.light=SCNLight(); sun.light?.type = .directional; sun.light?.intensity=1150
        sun.light?.castsShadow=true; sun.light?.shadowRadius=5; sun.light?.shadowColor=UIColor.black.withAlphaComponent(0.16)
        sun.position=SCNVector3(-8,18,8); sun.look(at:SCNVector3Zero); root.addChildNode(sun)
        let ambient=SCNNode(); ambient.light=SCNLight(); ambient.light?.type = .ambient; ambient.light?.intensity=550; root.addChildNode(ambient)
        root.addChildNode(mesh(SCNBox(width:55,height:0.3,length:65,chamferRadius:0),0xB9DC9E,SCNVector3(0,-0.2,0)))
        // River and a walking promenade continue through all streamed districts.
        root.addChildNode(mesh(SCNBox(width:2.1,height:0.10,length:65,chamferRadius:0.06),0x6ABBCB,SCNVector3(4.4,0.01,0)))
        root.addChildNode(mesh(SCNBox(width:0.55,height:0.12,length:65,chamferRadius:0.03),0xEFE4BA,SCNVector3(5.85,0.02,0)))
        for offset in -1...1 {
            let district=variant+offset
            guard district >= 0,district < GardenRegion.all.count else { continue }
            let group=SCNNode(); group.position.z=Float(offset)*18; root.addChildNode(group)
            districtScenery(group,index:district)
        }
        return scene
    }
    private func districtScenery(_ group:SCNNode,index:Int) {
        for i in 0..<18 {
            let side:Float=i%2 == 0 ? -1 : 1
            let tree=SCNNode(); tree.position=SCNVector3(side*(3.2+Float((i+index)%3)*0.6),0,Float(i/2)*1.9-8)
            tree.addChildNode(mesh(SCNCylinder(radius:0.12,height:0.95),0xA9794C,SCNVector3(0,0.5,0)))
            let colors:[UInt32]=[0x71AB62,0x7FBB6F,0x98C878,0xEDABB9]
            for puff in 0..<3 {
                let crown=mesh(SCNSphere(radius:0.52),colors[(i+index)%4],SCNVector3(Float(puff-1)*0.25,1.1+Float(puff%2)*0.3,0))
                crown.scale=SCNVector3(1,1.15,1); tree.addChildNode(crown)
            }
            if i%4 == 0 { for fruit in 0..<3 { tree.addChildNode(mesh(SCNSphere(radius:0.12),0xE76C58,SCNVector3(Float(fruit-1)*0.32,1.3,0.48))) } }
            group.addChildNode(tree)
        }
        // Each neighboring district retains its seeded landmark and flower beds.
        let house=SCNNode(); house.position=SCNVector3(-3.2,0,-5.5)
        house.addChildNode(mesh(SCNBox(width:2.1,height:1.4,length:1.7,chamferRadius:0.12),0xFFF4D8,SCNVector3(0,0.8,0)))
        house.addChildNode(mesh(SCNPyramid(width:2.6,height:1,length:2.2),index%2 == 0 ? 0xD97D68 : 0x6AA796,SCNVector3(0,1.55,0)))
        house.addChildNode(mesh(SCNBox(width:0.45,height:0.8,length:0.08,chamferRadius:0.08),0x966443,SCNVector3(0,0.5,0.88)))
        for side:Float in [-1,1] { house.addChildNode(mesh(SCNBox(width:0.42,height:0.45,length:0.07,chamferRadius:0.05),0x7FC8DD,SCNVector3(side*0.68,1,0.89))) }
        group.addChildNode(house)
        let pool=mesh(SCNCylinder(radius:1.05,height:0.22),0xF1DCAF,SCNVector3(2.3,0.18,-2.5)); group.addChildNode(pool)
        group.addChildNode(mesh(SCNCylinder(radius:0.85,height:0.24),0x69C3D0,SCNVector3(2.3,0.24,-2.5)))
        group.addChildNode(mesh(SCNCylinder(radius:0.13,height:0.85),0xEEE8CC,SCNVector3(2.3,0.68,-2.5)))
        group.addChildNode(mesh(SCNSphere(radius:0.33),restored > 0 ? 0xF1C460 : 0xB8C7A5,SCNVector3(2.3,1.15,-2.5)))
        // Bridge, trimmed hedges and garden beds give the map an inhabited scale.
        group.addChildNode(mesh(SCNBox(width:3.4,height:0.2,length:1.3,chamferRadius:0.10),0xDDAD76,SCNVector3(4.4,0.15,4)))
        for z:Float in [3.3,4.7] { group.addChildNode(mesh(SCNBox(width:3.4,height:0.25,length:0.10,chamferRadius:0.04),0xFFF1CD,SCNVector3(4.4,0.5,z))) }
        for i in 0..<8 {
            let x:Float=i%2 == 0 ? -2.8 : 2.6,z=Float(i/2)*2.7-1
            group.addChildNode(mesh(SCNBox(width:1.2,height:0.28,length:0.62,chamferRadius:0.17),0x578F61,SCNVector3(x,0.16,z)))
            for flower in 0..<4 {
                let bloom=SCNNode(); bloom.position=SCNVector3(x+Float(flower)*0.26-0.4,0.32,z)
                bloom.addChildNode(mesh(SCNCylinder(radius:0.025,height:0.25),0x50894D,SCNVector3(0,0.10,0)))
                for petal in 0..<5 {
                    let angle=Float(petal)*Float.pi*2/5
                    let leaf=mesh(SCNSphere(radius:0.11),i%2 == 0 ? 0xF7CE63 : 0xE782AC,SCNVector3(cos(angle)*0.10,0.27,sin(angle)*0.10)); leaf.scale.y=0.4; bloom.addChildNode(leaf)
                }
                bloom.addChildNode(mesh(SCNSphere(radius:0.055),0xFFEAA1,SCNVector3(0,0.30,0))); group.addChildNode(bloom)
            }
        }
    }
    private func mesh(_ geometry:SCNGeometry,_ hex:UInt32,_ position:SCNVector3)->SCNNode {
        let material=SCNMaterial(); material.diffuse.contents=UIColor(red:CGFloat((hex>>16)&255)/255,green:CGFloat((hex>>8)&255)/255,blue:CGFloat(hex&255)/255,alpha:1)
        material.roughness.contents=0.85; material.lightingModel = .physicallyBased; geometry.materials=[material]
        let node=SCNNode(geometry:geometry); node.position=position; return node
    }
}
