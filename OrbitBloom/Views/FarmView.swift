import SwiftUI

struct FarmView: View {
    @EnvironmentObject var game: GameModel
    @State private var selected: Crop = .rose
    var body: some View {
        TimelineView(.periodic(from:.now,by:1)) { timeline in
            VStack(alignment:.leading,spacing:18) {
                SectionEyebrow(text:"Farm / Living terraces")
                HStack(alignment:.top) {
                    VStack(alignment:.leading,spacing:8) {
                        Text("Good things\ntake root.").font(.system(size:34,weight:.heavy,design:.rounded)).foregroundStyle(Palette.cream)
                        Text("Plant · water · harvest · craft").font(.system(.subheadline,design:.rounded)).foregroundStyle(Palette.mint)
                    }
                    Spacer(); PipCompanion().frame(width:92,height:112)
                }
                HStack(spacing:12) {
                    meter("Seeds",game.ecosystem.seeds,"leaf.fill")
                    meter("Water",game.ecosystem.water,"drop.fill")
                    meter("Compost",game.ecosystem.compost,"shippingbox.fill")
                }
                HStack(spacing:12) {
                    ForEach(Crop.allCases) { crop in
                        Button { selected = crop; game.effect("tap") } label: {
                            HStack(spacing:7) { SpriteView(index:crop.sprite).frame(width:36,height:36); VStack(alignment:.leading,spacing:3) { Text(crop.title).font(.system(size:12,weight:.bold,design:.rounded)); Text("\(Int(crop.duration))s · \(crop.coins) coins").font(.system(size:10,design:.rounded)) } }.foregroundStyle(selected == crop ? Palette.night : Palette.cream).padding(10).frame(maxWidth:.infinity).background(selected == crop ? Palette.mint : Palette.deep,in:RoundedRectangle(cornerRadius:16))
                        }.accessibilityIdentifier("crop\(crop.rawValue)")
                    }
                }
                LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:14) {
                    ForEach(game.ecosystem.plots) { plot in
                        plotButton(plot,now:timeline.date)
                    }
                }
                Text("Empty plot: plant for 1 seed + 2 water. Growing plot: spend 1 water to save 10 seconds. A harvest returns your seed, coins, 1 compost and 1 delivery cargo. Crops keep growing while you're away.").font(.system(.caption,design:.rounded)).foregroundStyle(Palette.mint).fixedSize(horizontal:false,vertical:true)
                Text("The tool shed").font(.system(size:24,weight:.bold,design:.rounded)).foregroundStyle(Palette.cream)
                ForEach(GardenTool.allCases) { tool in
                    HStack {
                        SpriteView(index:tool.sprite).frame(width:52,height:52)
                        VStack(alignment:.leading,spacing:4) { Text(tool.title).font(.headline); Text(tool.detail).font(.caption).foregroundStyle(Palette.mint) }
                        Spacer()
                        Button { game.craft(tool) } label: { Text("Craft · \(tool.compostCost)").font(.system(.caption,design:.rounded,weight:.bold)).foregroundStyle(Palette.night).padding(13).background(Palette.gold,in:Capsule()) }.accessibilityLabel("Craft \(tool.title) for \(tool.compostCost) compost").accessibilityIdentifier("craft\(tool.rawValue)")
                    }.foregroundStyle(Palette.cream).padding(.vertical,5)
                }
                Text("Harvested: \(game.ecosystem.harvested) · Cargo: \(game.ecosystem.produce)").font(.caption).foregroundStyle(Palette.gold).accessibilityIdentifier("farmTotals")
            }.padding(24)
        }
    }
    func meter(_ title:String,_ value:Int,_ symbol:String) -> some View {
        VStack(spacing:4) { Label("\(value)",systemImage:symbol).font(.headline).foregroundStyle(Palette.gold); Text(title).font(.system(size:10,design:.rounded)).foregroundStyle(Palette.mint) }.frame(maxWidth:.infinity).padding(.vertical,10).background(Palette.deep,in:RoundedRectangle(cornerRadius:14))
    }
    func plotButton(_ plot:FarmPlot,now:Date) -> some View {
        let ready = plot.ready(at:now)
        let remaining = max(0,Int(ceil((plot.readyAt ?? now).timeIntervalSince(now))))
        return Button { game.farmAction(plot.id,crop:selected) } label: {
            VStack(spacing:6) {
                ZStack {
                    RoundedRectangle(cornerRadius:22).fill(LinearGradient(colors:[Color(hex:0x77593B),Color(hex:0x3D3527)],startPoint:.topLeading,endPoint:.bottomTrailing)).frame(height:90).rotation3DEffect(.degrees(20),axis:(x:1,y:0,z:0)).overlay(RoundedRectangle(cornerRadius:22).stroke(Color(hex:0xA28254),lineWidth:3))
                    ForEach(0..<4) { row in Capsule().fill(.black.opacity(0.2)).frame(height:4).offset(y:CGFloat(row*16-24)) }
                    if let crop = plot.crop {
                        SpriteView(index:ready || remaining < Int(crop.duration/2) ? crop.sprite : 0).frame(width:ready ? 84 : 58,height:82).offset(y:-6).shadow(color:Palette.gold.opacity(ready ? 0.4 : 0),radius:12)
                    } else { Image(systemName:"plus").font(.system(size:28,weight:.light)).foregroundStyle(Palette.cream.opacity(0.5)) }
                    if ready { Image(systemName:"sparkles").foregroundStyle(Palette.gold).offset(x:47,y:-35) }
                }
                Text(plot.crop == nil ? "Plant here" : ready ? "Harvest!" : "Growing · \(remaining)s").font(.system(.subheadline,design:.rounded,weight:.bold)).foregroundStyle(ready ? Palette.gold : Palette.cream)
                Text(plot.crop == nil ? "Plot \(plot.id+1)" : ready ? "+coins · +compost" : "Tap to water").font(.system(size:10,design:.rounded)).foregroundStyle(Palette.mint)
            }.padding(12).background(Palette.deep.opacity(0.6),in:RoundedRectangle(cornerRadius:22))
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
