import SwiftUI

struct FarmView: View {
    @EnvironmentObject var game: GameModel
    @State private var selected: Crop = .rose
    @State private var page = 0
    var body: some View {
        TimelineView(.periodic(from:.now,by:1)) { timeline in
            VStack(spacing:10) {
                HStack(alignment:.center) {
                    VStack(alignment:.leading,spacing:4) {
                        Text(page == 0 ? "Farm room" : "The tool shed").font(.system(size:27,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night)
                        Text(page == 0 ? "Terrace map · 6 plots. Plant, water, harvest." : "Inside Farm room · craft powers with compost.").font(.system(size:12,design:.rounded)).foregroundStyle(Palette.mint)
                    }
                    Spacer(); PipCompanion().frame(width:56,height:70)
                }
                HStack(spacing:10) { meter("Seeds",game.ecosystem.seeds,"leaf.fill"); meter("Water",game.ecosystem.water,"drop.fill"); meter("Compost",game.ecosystem.compost,"shippingbox.fill") }
                if page == 0 {
                    HStack(spacing:12) {
                        ForEach(Crop.allCases) { crop in
                            Button { selected = crop; game.effect("tap") } label: {
                                HStack(spacing:5) { SpriteView(index:crop.sprite).frame(width:36,height:36); VStack(alignment:.leading,spacing:3) { Text(crop.title).font(.system(size:12,weight:.bold,design:.rounded)); Text("\(Int(crop.duration))s · \(crop.coins) coins").font(.system(size:10,design:.rounded)) } }.foregroundStyle(Palette.night).padding(8).frame(maxWidth:.infinity).background(selected == crop ? Color(hex:0xD1E6B3) : Palette.paper,in:RoundedRectangle(cornerRadius:16)).overlay(RoundedRectangle(cornerRadius:16).stroke(selected == crop ? Palette.mint : .clear,lineWidth:2))
                            }.accessibilityIdentifier("crop\(crop.rawValue)")
                        }
                    }
                    GeometryReader { geometry in
                        ZStack {
                            ActivityRoomScene(kind:.farm,detailed:true).allowsHitTesting(false).accessibilityHidden(true)
                            ForEach(game.ecosystem.plots) { plot in
                                plotButton(plot,now:timeline.date)
                                    .frame(width:min(174,geometry.size.width*0.42))
                                    .position(x:geometry.size.width*(plot.id%2 == 0 ? 0.27 : 0.73),y:geometry.size.height*(0.17+CGFloat(plot.id/2)*0.33))
                            }
                        }.accessibilityElement(children:.contain).accessibilityLabel("Farm room terrace map. Six numbered plots.").accessibilityIdentifier("farmRoomMap")
                    }.frame(maxHeight:.infinity)
                    Text("Plant: 1 seed + 2 water. Tap a growing crop to water.").font(.system(size:11,design:.rounded)).foregroundStyle(Palette.mint)
                    Button { withAnimation { page = 1 }; game.effect("tap") } label: { Label("Enter the tool shed",systemImage:"house.lodge.fill").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.night).frame(maxWidth:.infinity,minHeight:48).background(Palette.paper,in:Capsule()) }.accessibilityIdentifier("openToolShed")
                } else {
                    LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:14) {
                        ForEach(GardenTool.allCases) { tool in
                            VStack(spacing:9) {
                                SpriteView(index:tool.sprite).frame(height:78).shadow(color:Palette.night.opacity(0.18),radius:3,y:5)
                                Text(tool.title).font(.system(.headline,design:.rounded)).foregroundStyle(Palette.night)
                                Text("\(game.ecosystem.tools[tool,default:0]) ready for your board").font(.caption).foregroundStyle(Palette.mint)
                                Button { game.craft(tool) } label: { Text("Craft · \(tool.compostCost)").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.night).frame(maxWidth:.infinity,minHeight:44).background(Palette.sunlight,in:Capsule()) }.accessibilityLabel("Craft \(tool.title) for \(tool.compostCost) compost").accessibilityIdentifier("craft\(tool.rawValue)")
                            }.padding(12).background(Palette.paper,in:RoundedRectangle(cornerRadius:24)).compositingGroup().shadow(color:Palette.mint.opacity(0.16),radius:0,y:6)
                        }
                    }.frame(maxHeight:.infinity)
                    Button { withAnimation { page = 0 }; game.effect("tap") } label: { Label("Back to the terraces",systemImage:"leaf.fill").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.night).frame(minHeight:48) }.accessibilityIdentifier("backToTerraces")
                }
                Text("Harvested: \(game.ecosystem.harvested) · Cargo: \(game.ecosystem.produce)").font(.caption.bold()).foregroundStyle(Palette.night).accessibilityIdentifier("farmTotals")
                HStack(spacing:5) { Circle().fill(page == 0 ? Palette.mint : Palette.mint.opacity(0.2)); Circle().fill(page == 1 ? Palette.mint : Palette.mint.opacity(0.2)) }.frame(width:21,height:7)
            }.padding(.horizontal,22).padding(.bottom,12).contentShape(Rectangle())
            .simultaneousGesture(DragGesture(minimumDistance:35).onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                withAnimation { page = value.translation.width < 0 ? 1 : 0 }; game.effect("tap")
            }).accessibilityElement(children:.contain).accessibilityIdentifier("farmScene")
        }
    }
    func meter(_ title:String,_ value:Int,_ symbol:String) -> some View {
        VStack(spacing:4) { Label("\(value)",systemImage:symbol).font(.headline).foregroundStyle(Palette.gold); Text(title).font(.system(size:10,design:.rounded)).foregroundStyle(Palette.mint) }.frame(maxWidth:.infinity).padding(.vertical,10).background(Palette.deep,in:RoundedRectangle(cornerRadius:14)).accessibilityElement(children:.ignore).accessibilityLabel("\(title): \(value)").accessibilityIdentifier("farmMeter\(title)")
    }
    func plotButton(_ plot:FarmPlot,now:Date) -> some View {
        let ready = plot.ready(at:now)
        let remaining = max(0,Int(ceil((plot.readyAt ?? now).timeIntervalSince(now))))
        return Button { game.farmAction(plot.id,crop:selected) } label: {
            VStack(spacing:4) {
                ZStack {
                    RoundedRectangle(cornerRadius:18).fill(LinearGradient(colors:[Color(hex:0x77593B),Color(hex:0x3D3527)],startPoint:.topLeading,endPoint:.bottomTrailing)).frame(height:52).rotation3DEffect(.degrees(25),axis:(x:1,y:0,z:0)).overlay(RoundedRectangle(cornerRadius:18).stroke(Color(hex:0xA28254),lineWidth:3)).shadow(color:Palette.night.opacity(0.25),radius:2,y:6)
                    ForEach(0..<3) { row in Capsule().fill(.black.opacity(0.2)).frame(height:3).offset(y:CGFloat(row*14-14)) }
                    if let crop = plot.crop {
                        SpriteView(index:ready || remaining < Int(crop.duration/2) ? crop.sprite : 0).frame(width:ready ? 56 : 44,height:52).offset(y:-7).shadow(color:Palette.gold.opacity(ready ? 0.4 : 0),radius:12)
                    } else { Image(systemName:"plus").font(.system(size:28,weight:.light)).foregroundStyle(.white.opacity(0.8)) }
                    if ready { Image(systemName:"sparkles").foregroundStyle(Palette.gold).offset(x:47,y:-35) }
                }
                Text(plot.crop == nil ? "Plant here" : ready ? "Harvest!" : "Growing · \(remaining)s").font(.system(size:13,weight:.bold,design:.rounded)).foregroundStyle(ready ? Color(hex:0x426735) : Palette.night)
                Text("Plot \(plot.id+1) · \(plot.crop == nil ? "1 seed" : ready ? "+compost" : "tap to water")").font(.system(size:10,weight:.semibold,design:.rounded)).foregroundStyle(Palette.mint)
            }.padding(6).background(Palette.paper.opacity(0.86),in:RoundedRectangle(cornerRadius:18))
        }.buttonStyle(PressStyle()).accessibilityLabel("Plot \(plot.id+1), \(plot.crop == nil ? "empty, plant" : ready ? "ready, harvest" : "growing, water")").accessibilityIdentifier("plot\(plot.id)")
    }
}

struct PipCompanion: View {
    @State private var up = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    var body: some View {
        SpriteView(index:10).offset(y:up ? -5 : 0).rotationEffect(.degrees(up ? 2 : -2)).onAppear { if !reduceMotion { withAnimation(.easeInOut(duration:2).repeatForever(autoreverses:true)) { up = true } } }.accessibilityLabel("Pip the gardening robot")
    }
}
