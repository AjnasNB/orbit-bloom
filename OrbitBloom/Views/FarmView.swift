import SwiftUI

struct FarmView:View {
    @EnvironmentObject var game:GameModel
    @State private var selected:Crop = .rose
    @State private var page=0
    @State private var shed=false
    @State private var plotPoints:[CGPoint]=[]
    @State private var interaction:FarmFieldInteraction?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var unlocked:Bool { page < game.farmFieldCount }
    var body:some View {
        TimelineView(.periodic(from:.now,by:1)) { timeline in
            VStack(spacing:6) {
                HStack(spacing:8) { meter("Seeds",game.ecosystem.seeds,"leaf.fill"); meter("Water",game.ecosystem.water,"drop.fill"); meter("Compost",game.ecosystem.compost,"shippingbox.fill") }
                if shed { toolShed }
                else {
                    HStack(spacing:10) {
                        ForEach(Crop.allCases) { crop in
                            Button { selected=crop; game.effect("tap") } label: {
                                HStack(spacing:4) { SpriteView(index:crop.sprite).frame(width:40,height:40); Image(systemName:"clock"); Text("\(Int(crop.duration))"); SpriteView(index:11).frame(width:22,height:22); Text("\(crop.coins)") }.font(.system(size:12,weight:.bold,design:.rounded)).frame(maxWidth:.infinity,minHeight:50).background(selected == crop ? Palette.sunlight : Palette.paper,in:Capsule()).overlay(Capsule().stroke(selected == crop ? Palette.gold : .clear,lineWidth:2))
                            }.buttonStyle(PressStyle()).accessibilityLabel("Choose \(crop.title), \(Int(crop.duration)) seconds, \(crop.coins) coins per harvest. Plant costs one seed and two water").accessibilityIdentifier("crop\(crop.rawValue)")
                        }
                    }
                    GeometryReader { geo in
                        ZStack {
                            FarmFieldScene(plots:localPlots,now:timeline.date,interaction:interaction,variant:page) { points in if plotPoints != points { plotPoints=points } }.id(page).allowsHitTesting(false).accessibilityHidden(true)
                            if unlocked {
                                ForEach(game.ecosystem.field(page)) { plot in
                                    if plotPoints.indices.contains(plot.id%6) {
                                        plotButton(plot,now:timeline.date).frame(width:min(116,geo.size.width*0.30)).anchorPreference(key:WalletFlightAnchors.self,value:.bounds) { ["plot\(plot.id)":$0] }.position(x:plotPoints[plot.id%6].x*geo.size.width,y:plotPoints[plot.id%6].y*geo.size.height)
                                    }
                                }
                            } else {
                                VStack(spacing:18) {
                                    Image(systemName:"lock.fill").font(.system(size:55)).foregroundStyle(Palette.mint)
                                    HStack { Image(systemName:"basket.fill"); Text(page == 1 ? "3" : "9"); Image(systemName:"arrow.left.arrow.right"); Image(systemName:"flag.fill"); Text(page == 1 ? "3" : "9") }.font(.system(size:22,weight:.bold))
                                }.padding(28).background(Palette.paper.opacity(0.95),in:RoundedRectangle(cornerRadius:28)).accessibilityElement(children:.ignore).accessibilityLabel("Field \(page+1) locked. Complete \(page == 1 ? 3 : 9) harvests or puzzle levels to open it").accessibilityIdentifier("lockedFarmField")
                            }
                        }.accessibilityElement(children:.contain).accessibilityLabel("Farm field \(page+1) of three, \(unlocked ? "open with six saved patches" : "locked"). Swipe horizontally to change field").accessibilityIdentifier("farmRoomMap")
                    }.frame(minHeight:220,maxHeight:.infinity)
                }
                HStack(spacing:12) {
                    Label("\(game.ecosystem.harvested)",systemImage:"basket.fill"); Label("\(game.ecosystem.produce)",systemImage:"shippingbox.fill")
                    Spacer()
                    ForEach(0..<3) { i in Image(systemName:i < game.farmFieldCount ? "circle.fill" : "lock.fill").font(.system(size:i == page ? 15 : 10)).foregroundStyle(i == page ? Palette.gold : Palette.mint.opacity(0.5)) }
                    Button { withAnimation(reduceMotion ? nil : .easeOut(duration:0.2)) { shed.toggle() }; game.effect("tap") } label: { Image(systemName:shed ? "leaf.fill" : "house.lodge.fill").font(.system(size:24)).frame(width:48,height:48).background(Palette.paper,in:Circle()) }.accessibilityLabel(shed ? "Back to the fields" : "Enter tool shed").accessibilityIdentifier(shed ? "backToTerraces" : "openToolShed")
                }.font(.system(size:15,weight:.heavy,design:.rounded)).accessibilityElement(children:.contain).accessibilityIdentifier("farmTotals")
            }.foregroundStyle(Palette.night).padding(.horizontal,12).padding(.bottom,6).contentShape(Rectangle())
                .simultaneousGesture(DragGesture(minimumDistance:35).onEnded { value in
                    guard !shed,abs(value.translation.width) > abs(value.translation.height) else { return }
                    changeField(value.translation.width < 0 ? 1 : -1)
                }).accessibilityElement(children:.contain).accessibilityIdentifier("farmScene")
                .accessibilityAction(named:"Next farm field") { changeField(1) }.accessibilityAction(named:"Previous farm field") { changeField(-1) }
        }
    }
    private var localPlots:[FarmPlot] { game.ecosystem.field(page).map { plot in var local=FarmPlot(id:plot.id%6); local.crop=plot.crop; local.readyAt=plot.readyAt; return local } }
    private func changeField(_ step:Int) {
        let next=min(2,max(0,page+step)); guard next != page else { return }
        interaction=nil; plotPoints=[]
        withAnimation(reduceMotion ? nil : .easeOut(duration:0.25)) { page=next }; game.effect("tap")
    }
    private func meter(_ title:String,_ value:Int,_ symbol:String)->some View {
        HStack(spacing:5) { if title == "Seeds" { SpriteView(index:0).frame(width:27,height:27) } else if title == "Water" { SpriteView(index:1).frame(width:27,height:27) } else { Image(systemName:symbol).foregroundStyle(Palette.gold) }; Text("\(value)").monospacedDigit() }.font(.system(size:18,weight:.heavy,design:.rounded)).frame(maxWidth:.infinity,minHeight:44).background(Palette.paper,in:Capsule()).accessibilityElement(children:.ignore).accessibilityLabel("\(title): \(value)").accessibilityIdentifier("farmMeter\(title)")
    }
    private var toolShed:some View {
        LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:20) {
            ForEach(GardenTool.allCases) { tool in
                Button { game.craft(tool) } label: {
                    VStack(spacing:10) {
                        SpriteView(index:tool.sprite).frame(height:90)
                        Text("×\(game.ecosystem.tools[tool,default:0])").font(.system(size:22,weight:.black,design:.rounded))
                        HStack { Image(systemName:"shippingbox.fill"); Text("\(tool.compostCost)"); Image(systemName:"hammer.fill") }.font(.system(size:18,weight:.bold)).frame(maxWidth:.infinity,minHeight:48).background(Palette.sunlight,in:Capsule())
                    }.padding(15).background(Palette.paper,in:RoundedRectangle(cornerRadius:26)).shadow(color:Palette.mint.opacity(0.15),radius:0,y:5)
                }.buttonStyle(PressStyle()).accessibilityLabel("Craft \(tool.title) for \(tool.compostCost) compost. \(game.ecosystem.tools[tool,default:0]) in supplies").accessibilityIdentifier("craft\(tool.rawValue)")
            }
        }.frame(maxWidth:650,maxHeight:.infinity)
    }
    private func plotButton(_ plot:FarmPlot,now:Date)->some View {
        let ready=plot.ready(at:now), harvesting=game.harvestingPlots.contains(plot.id)
        let remaining=max(0,Int(ceil((plot.readyAt ?? now).timeIntervalSince(now))))
        return Button {
            let previous=plot, waterBefore=game.ecosystem.water
            game.farmAction(plot.id,crop:selected)
            let after=game.ecosystem.plot(plot.id)!
            if previous.crop != nil && after.crop == nil { interaction=FarmFieldInteraction(plot:plot.id%6,kind:.harvest) }
            else if previous.crop == nil && after.crop != nil { interaction=FarmFieldInteraction(plot:plot.id%6,kind:.plant) }
            else if game.ecosystem.water < waterBefore { interaction=FarmFieldInteraction(plot:plot.id%6,kind:.water) }
        } label: {
            HStack(spacing:4) {
                Text("\(plot.id%6+1)").font(.system(size:11,weight:.black,design:.rounded))
                if ready { SickleIcon().frame(width:28,height:28) }
                else { Image(systemName:harvesting ? "checkmark" : plot.crop == nil ? "plus" : "drop.fill").font(.system(size:17,weight:.bold)) }
                if plot.crop != nil && !ready { Text("\(remaining)s").font(.system(size:11,weight:.bold,design:.rounded)).monospacedDigit() }
            }.foregroundStyle(Palette.night).frame(minWidth:76,minHeight:48).padding(.horizontal,6).background(ready || harvesting ? Palette.sunlight : Palette.paper.opacity(0.94),in:Capsule()).shadow(color:Palette.night.opacity(0.17),radius:2,y:3)
        }.buttonStyle(PressStyle()).disabled(harvesting)
            .accessibilityLabel("Plot \(plot.id+1), \(harvesting ? "empty, harvest collected" : plot.crop == nil ? "empty, plant" : ready ? "ready, harvest" : "growing, water")")
            .accessibilityValue(harvesting ? "Harvest collected, ready to plant in a moment" : plot.crop.map { "\($0.title), \(plot.stage(at:now).rawValue), \(ready ? "ready" : "\(remaining) seconds until harvest")" } ?? "Choose a crop, plant with one seed and two water")
            .accessibilityIdentifier("plot\(plot.id)")
    }
}

struct PipCompanion: View {
    @State private var up = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    var body: some View {
        SpriteView(index:10).offset(y:up ? -5 : 0).rotationEffect(.degrees(up ? 2 : -2)).onAppear { if !reduceMotion { withAnimation(.easeInOut(duration:2).repeatForever(autoreverses:true)) { up = true } } }.accessibilityLabel("Pip the gardening robot")
    }
}
