import SwiftUI

struct ShuttleRoomView:View {
    let level:Int
    let paused:Bool
    let complete:(Int)->Void
    @EnvironmentObject private var game:GameModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var run:ShuttleRun
    @State private var selected:Int?
    @State private var help=false
    init(level:Int,paused:Bool,complete:@escaping(Int)->Void) {
        self.level=level; self.paused=paused; self.complete=complete
        _run=State(initialValue:ShuttleRun(level:level))
    }
    var body:some View {
        GeometryReader { geo in
            let compact=geo.size.height < 600
            VStack(spacing:compact ? 6 : 12) {
                HStack {
                    Label("\(run.seated)/12",systemImage:"person.fill").accessibilityLabel("\(run.seated) of 12 travellers seated")
                    Spacer()
                    Label("\(max(0,run.moveLimit-run.moves))",systemImage:run.canSeat ? "arrow.triangle.swap" : "flag.checkered")
                        .accessibilityLabel("\(max(0,run.moveLimit-run.moves)) moves remaining\(!run.canSeat && !run.finished ? ". All seated; depart to check the final plan" : "")").accessibilityIdentifier("shuttleMoves")
                    Button { help=true } label: { Image(systemName:"questionmark.circle.fill").frame(width:48,height:48) }.accessibilityLabel("Shuttle seating rules").accessibilityIdentifier("shuttleHelp")
                }.font(.system(size:18,weight:.heavy,design:.rounded))
                bus.frame(maxWidth:540,maxHeight:.infinity).layoutPriority(1)
                if !run.finished {
                    LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:8),count:6),spacing:compact ? 5 : 9) {
                        ForEach(run.queue,id:\.self) { id in
                            Button { selected=id; game.effect("tap") } label: {
                                passenger(run.passengers[id],small:true).opacity(run.seats.contains(id) ? 0.25 : 1)
                                    .frame(maxWidth:.infinity,minHeight:compact ? 60 : 76)
                                    .background(selected == id ? Palette.sunlight : .white.opacity(0.9),in:RoundedRectangle(cornerRadius:14))
                                    .overlay(RoundedRectangle(cornerRadius:14).stroke(selected == id ? Palette.gold : .clear,lineWidth:3))
                            }.buttonStyle(PressStyle()).accessibilityLabel(ticket(run.passengers[id]))
                                .accessibilityValue(selected == id ? "Selected. Tap a seat" : run.seats.contains(id) ? "Already seated. Select to move" : "Waiting")
                                .accessibilityIdentifier("passenger\(id)")
                        }
                    }.frame(maxWidth:700).disabled(paused || !run.canSeat)
                    Button {
                        if run.depart() { game.effect("win") } else { game.effect("collision") }
                    } label: {
                        Image(systemName:"flag.checkered").font(.system(size:26,weight:.bold)).frame(maxWidth:.infinity,minHeight:54).background(Palette.sunlight,in:Capsule())
                    }.buttonStyle(PressStyle()).disabled(run.seated != 12 || paused).accessibilityLabel("Depart. Check all twelve tickets").accessibilityHint("A complete final-move plan can still depart. A wrong check costs one move, or ends the attempt at zero").accessibilityIdentifier("shuttleDepart")
                } else {
                    HStack(spacing:16) {
                        Image(systemName:run.won ? "checkmark.seal.fill" : "arrow.counterclockwise.circle.fill").font(.system(size:38)).foregroundStyle(run.won ? Palette.mint : Palette.coral)
                        Button {
                            if run.won { complete(run.score) } else { run=ShuttleRun(level:level); selected=nil }
                        } label: { Image(systemName:run.won ? "globe.europe.africa.fill" : "arrow.counterclockwise").font(.system(size:28)).frame(maxWidth:.infinity,minHeight:60).background(Palette.sunlight,in:Capsule()) }
                            .accessibilityLabel(run.won ? "Save result and return to island. One star, 25 coins and 2 water for a new clear" : "Retry seating puzzle. No life cost").accessibilityIdentifier(run.won ? "activitySaveResult" : "activityRetry")
                    }.accessibilityElement(children:.contain).accessibilityIdentifier("shuttleResult").accessibilityLabel(run.won ? "Every ticket fits. Shuttle ready" : "Move budget used. Try another seating plan")
                }
            }.foregroundStyle(Palette.night).padding(.horizontal,6).animation(reduceMotion ? nil : .spring(response:0.3,dampingFraction:0.8),value:run.seats)
        }.sheet(isPresented:$help) {
            VStack(spacing:20) {
                ActivityEmblem(room:.shuttle).frame(width:90,height:90)
                Text("Arrange the shuttle").font(.title2.bold())
                Text("Select a traveller, then a seat. Ticket arrows choose upper or lower deck; the window icon needs an outside seat; the flag needs the front row. Travellers with the same linked color must sit side by side in one row. Tap a seated traveller to move them. Filling an occupied seat sends its traveller back to the queue.")
                Text("Depart checks every ticket. Marked seats need another plan; each move and wrong departure uses one turn. There is always a valid plan. No puzzle life is spent. Leaving discards this unfinished plan; save a win to keep its reward.")
                Button("Done") { help=false }.frame(minHeight:48)
            }.multilineTextAlignment(.center).padding(28).foregroundStyle(Palette.night).presentationDetents([.large])
        }
    }
    private var bus:some View {
        VStack(spacing:7) {
            HStack { Image(systemName:"steeringwheel"); Spacer(); Image(systemName:"arrow.up"); Image(systemName:"flag.checkered") }.padding(.horizontal,22).font(.system(size:22,weight:.bold)).foregroundStyle(Palette.cream)
            ForEach([1,0],id:\.self) { deck in
                HStack(spacing:7) {
                    Image(systemName:deck == 1 ? "arrow.up" : "arrow.down").frame(width:22).foregroundStyle(.white).accessibilityHidden(true)
                    LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:8),count:3),spacing:8) {
                        ForEach(deck*6..<(deck+1)*6,id:\.self) { position in
                            Button {
                                guard !paused,run.canSeat else { return }
                                if let id=selected { if run.seat(id,at:position) { game.effect("tap"); game.feedback(.light); selected=nil } }
                                else if let id=run.seats[position] { selected=id }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius:14).fill(LinearGradient(colors:[Color(hex:0xD1F0F0),Color(hex:0x8AC1C4)],startPoint:.top,endPoint:.bottom))
                                    RoundedRectangle(cornerRadius:14).stroke(run.rejected.contains(position) ? Palette.coral : .white.opacity(0.8),lineWidth:run.rejected.contains(position) ? 4 : 2)
                                    if let id=run.seats[position] { passenger(run.passengers[id],small:false).id(id).transition(.scale.combined(with:.opacity)) }
                                    else { Image(systemName:"chair.lounge.fill").font(.system(size:22)).foregroundStyle(Color(hex:0x507E88)) }
                                    if position%3 != 1 { Image(systemName:"rectangle.split.1x2.fill").font(.system(size:9)).foregroundStyle(.white).offset(x:position%3 == 0 ? -28 : 28,y:-18) }
                                }.frame(minHeight:52,maxHeight:100)
                            }.buttonStyle(PressStyle()).disabled(paused || !run.canSeat)
                                .accessibilityLabel("Seat \(position+1), \(deck == 1 ? "upper" : "lower") deck, \(position%6 < 3 ? "front" : "back") row, \(position%3 == 1 ? "aisle" : "window")")
                                .accessibilityValue(run.seats[position].map { "Traveller \($0+1)\(run.rejected.contains(position) ? ", ticket not satisfied" : "")" } ?? "Empty")
                                .accessibilityIdentifier("shuttleSeat\(position)")
                        }
                    }
                }.padding(.horizontal,12)
            }
            HStack { Circle().fill(Color(hex:0x364C4A)).frame(width:40,height:40).overlay(Circle().stroke(Color(hex:0x90A9A3),lineWidth:5)); Spacer(); Image(systemName:"leaf.fill").foregroundStyle(Palette.cream); Spacer(); Circle().fill(Color(hex:0x364C4A)).frame(width:40,height:40).overlay(Circle().stroke(Color(hex:0x90A9A3),lineWidth:5)) }.padding(.horizontal,30)
        }.padding(.vertical,13).background(LinearGradient(colors:[Color(hex:0x4A9FAA),Color(hex:0x27616D)],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:35))
            .overlay(RoundedRectangle(cornerRadius:35).stroke(Color(hex:0xF3CA78),lineWidth:5)).shadow(color:Palette.night.opacity(0.22),radius:0,y:7)
            .accessibilityElement(children:.contain).accessibilityIdentifier("shuttleBus")
    }
    private func passenger(_ person:ShuttlePassenger,small:Bool)->some View {
        VStack(spacing:2) {
            ZStack {
                TravellerAvatar(color:colors[person.color%colors.count],variant:person.id).frame(width:small ? 34 : 38,height:small ? 34 : 38)
                Text("\(person.id+1)").font(.system(size:9,weight:.black,design:.rounded)).foregroundStyle(Palette.night).padding(2).background(.white,in:Circle()).offset(x:12,y:9)
            }
            HStack(spacing:3) {
                Image(systemName:person.deck == 1 ? "arrow.up" : "arrow.down")
                if person.window { Image(systemName:"rectangle.split.1x2.fill") }
                if person.front { Image(systemName:"flag.fill") }
                if person.group != nil { Image(systemName:"link").foregroundStyle(colors[person.color%colors.count]) }
            }.font(.system(size:10,weight:.black)).foregroundStyle(Palette.night)
        }.accessibilityHidden(true)
    }
    private let colors=[Color(hex:0xD76D7F),Color(hex:0xD6A83A),Color(hex:0x699348),Color(hex:0x7970BE),Color(hex:0x4788B3),Color(hex:0xBF804A)]
    private func ticket(_ p:ShuttlePassenger)->String {
        "Traveller \(p.id+1), \(p.deck == 1 ? "upper" : "lower") deck\(p.window ? ", window seat" : "")\(p.front ? ", front row" : "")" + (p.group.map { group in ", beside traveller \((run.passengers.first { $0.group == group && $0.id != p.id }?.id ?? 0)+1)" } ?? "")
    }
}

/// Original miniature travellers, shaded and drawn at their final device resolution.
private struct TravellerAvatar:View {
    let color:Color
    let variant:Int
    var body:some View {
        Canvas { context,size in
            let s=min(size.width,size.height)
            func oval(_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat)->Path { Path(ellipseIn:CGRect(x:x*s,y:y*s,width:w*s,height:h*s)) }
            context.fill(oval(0.06,0.64,0.88,0.34),with:.linearGradient(Gradient(colors:[color.opacity(0.8),color]),startPoint:.zero,endPoint:CGPoint(x:s,y:s)))
            context.fill(oval(0.38,0.51,0.24,0.25),with:.color(Color(hex:0xC89666)))
            context.fill(oval(0.19,0.24,0.15,0.25),with:.color(Color(hex:0xEAC496)))
            context.fill(oval(0.66,0.24,0.15,0.25),with:.color(Color(hex:0xEAC496)))
            context.fill(oval(0.25,0.10,0.50,0.58),with:.linearGradient(Gradient(colors:[Color(hex:0xFFF0CA),Color(hex:0xDCA674)]),startPoint:.zero,endPoint:CGPoint(x:s,y:s)))
            let hair=[Color(hex:0x765339),Color(hex:0x3B4944),Color(hex:0xA17947)][variant%3]
            context.fill(oval(0.23,0.03,0.54,0.25),with:.color(hair))
            context.fill(oval(0.32,0.31,0.055,0.07),with:.color(Color(hex:0x314940)))
            context.fill(oval(0.60,0.31,0.055,0.07),with:.color(Color(hex:0x314940)))
            var smile=Path();smile.move(to:CGPoint(x:s*0.41,y:s*0.48));smile.addQuadCurve(to:CGPoint(x:s*0.59,y:s*0.48),control:CGPoint(x:s*0.50,y:s*0.57))
            context.stroke(smile,with:.color(Color(hex:0x946A4D)),style:StrokeStyle(lineWidth:s*0.035,lineCap:.round))
            context.fill(oval(0.43,0.75,0.14,0.1),with:.color(.white.opacity(0.75)))
        }.shadow(color:.black.opacity(0.12),radius:1,y:2).accessibilityHidden(true)
    }
}
