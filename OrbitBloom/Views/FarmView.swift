import SwiftUI

struct FarmView: View {
    @EnvironmentObject var game: GameModel
    @State private var selected: Crop = .rose
    @State private var page = 0
    @State private var plotPoints: [CGPoint] = []
    @State private var interaction: FarmFieldInteraction?
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        TimelineView(.periodic(from:.now,by:1)) { timeline in
            VStack(spacing:10) {
                HStack(alignment:.center) {
                    VStack(alignment:.leading,spacing:4) {
                        Text(page == 0 ? "Moonseed farm" : "The tool shed").font(.system(size:27,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night)
                        Text(page == 0 ? "Your orchard & rose field" : "Inside Farm room · craft powers with compost.").font(.system(size:12,design:.rounded)).foregroundStyle(Palette.mint)
                    }
                    Spacer(); PipCompanion().frame(width:56,height:70)
                }
                HStack(spacing:10) { meter("Seeds",game.ecosystem.seeds,"leaf.fill"); meter("Water",game.ecosystem.water,"drop.fill"); meter("Compost",game.ecosystem.compost,"shippingbox.fill") }.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
                            FarmFieldScene(plots: game.ecosystem.plots, now: timeline.date, interaction: interaction) { points in
                                if plotPoints != points { plotPoints = points }
                            }.allowsHitTesting(false).accessibilityHidden(true)
                            ForEach(game.ecosystem.plots) { plot in
                                if plotPoints.indices.contains(plot.id) {
                                    plotButton(plot, now: timeline.date)
                                        .frame(width: min(textSize.isAccessibilitySize ? 140 : 124, geometry.size.width * 0.34))
                                        .position(x: plotPoints[plot.id].x * geometry.size.width,
                                                  y: plotPoints[plot.id].y * geometry.size.height)
                                }
                            }
                        }.accessibilityElement(children:.contain).accessibilityLabel("Living farm. Six numbered patches in an orchard and rose field. Tap a patch to plant, water or harvest.").accessibilityIdentifier("farmRoomMap")
                    }.frame(minHeight: 220, maxHeight:.infinity)
                    Text("Plant: 1 seed + 2 water. Tap a growing crop to water.").font(.system(size:11,design:.rounded)).foregroundStyle(Palette.mint)
                    Button { withAnimation { page = 1 }; game.effect("tap") } label: { Label("Enter the tool shed",systemImage:"house.lodge.fill").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(Palette.night).frame(maxWidth:.infinity,minHeight:48).background(Palette.paper,in:Capsule()) }.dynamicTypeSize(...DynamicTypeSize.xxxLarge).accessibilityIdentifier("openToolShed")
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
                Text("Harvested: \(game.ecosystem.harvested) · Cargo: \(game.ecosystem.produce)").font(.caption.bold()).foregroundStyle(Palette.night).dynamicTypeSize(...DynamicTypeSize.xxxLarge).accessibilityIdentifier("farmTotals")
                HStack(spacing:5) { Circle().fill(page == 0 ? Palette.mint : Palette.mint.opacity(0.2)); Circle().fill(page == 1 ? Palette.mint : Palette.mint.opacity(0.2)) }.frame(width:21,height:7)
            }.padding(.horizontal, 16).padding(.bottom, 10).contentShape(Rectangle())
            .simultaneousGesture(DragGesture(minimumDistance:35).onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                withAnimation { page = value.translation.width < 0 ? 1 : 0 }; game.effect("tap")
            }).accessibilityElement(children:.contain).accessibilityIdentifier("farmScene")
        }
    }
    func meter(_ title:String,_ value:Int,_ symbol:String) -> some View {
        VStack(spacing:4) { Label("\(value)",systemImage:symbol).font(.headline).foregroundStyle(Palette.gold); Text(title).font(.system(size:10,design:.rounded)).foregroundStyle(Palette.mint) }.frame(maxWidth:.infinity).padding(.vertical,10).background(Palette.deep,in:RoundedRectangle(cornerRadius:14)).accessibilityElement(children:.ignore).accessibilityLabel("\(title): \(value)").accessibilityIdentifier("farmMeter\(title)")
    }
    func plotButton(_ plot: FarmPlot, now: Date) -> some View {
        let ready = plot.ready(at: now)
        let remaining = max(0, Int(ceil((plot.readyAt ?? now).timeIntervalSince(now))))
        let harvesting = game.harvestingPlots.contains(plot.id)
        let title = harvesting ? "Harvested" : plot.crop == nil ? "Plant" : ready ? "Harvest" : "Water"
        let state = plot.stage(at: now)
        return Button {
            let previous = plot
            let waterBefore = game.ecosystem.water
            game.farmAction(plot.id, crop: selected)
            if previous.crop != nil && game.ecosystem.plots[plot.id].crop == nil {
                interaction = FarmFieldInteraction(plot: plot.id, kind: .harvest)
            } else if previous.crop == nil && game.ecosystem.plots[plot.id].crop != nil {
                interaction = FarmFieldInteraction(plot: plot.id, kind: .plant)
            } else if game.ecosystem.water < waterBefore {
                interaction = FarmFieldInteraction(plot: plot.id, kind: .water)
            }
        } label: {
            VStack(spacing: 2) {
                Label("\(plot.id + 1) · \(title)", systemImage: harvesting ? "checkmark" : plot.crop == nil ? "plus" : ready ? "basket.fill" : "drop.fill")
                    .font(.system(.caption, design: .rounded, weight: .heavy))
                if plot.crop != nil && !ready {
                    Text("\(state == .sprout ? "Sprouting" : state == .leafy ? "Leafing" : "Blooming") · \(remaining)s")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                }
            }.foregroundStyle(Palette.night).padding(.horizontal, 9).padding(.vertical, 7)
                .frame(maxWidth: .infinity, minHeight: 48).contentShape(Rectangle())
                .background(ready || harvesting ? Palette.sunlight : Palette.paper.opacity(0.96), in: Capsule())
                .shadow(color: Palette.night.opacity(0.15), radius: 3, y: 3)
                .frame(maxWidth: .infinity, minHeight: 48)
        }.buttonStyle(PressStyle()).disabled(harvesting).dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .accessibilityLabel("Plot \(plot.id + 1), \(harvesting ? "empty, harvest collected" : plot.crop == nil ? "empty, plant" : ready ? "ready, harvest" : "growing, water")")
            .accessibilityValue(harvesting ? "Harvest collected. This patch will be ready to plant in a moment." : plot.crop.map { "\($0.title). \(state.rawValue). \(ready ? "Ready to harvest" : "\(remaining) seconds until harvest")" } ?? "Choose a crop, then plant with 1 seed and 2 water")
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
