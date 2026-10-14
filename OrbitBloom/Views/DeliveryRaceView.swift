import SwiftUI

struct DeliveryLobby:View {
    @EnvironmentObject var game:GameModel
    var body:some View {
        ZStack {
            RallyRoomMap().ignoresSafeArea()
            VStack {
                HStack { Label("\(game.ecosystem.produce)",systemImage:"shippingbox.fill"); Spacer(); Label("\(game.rallyDifficulty+1)",systemImage:"flame.fill") }.font(.system(size:22,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night).padding(18).background(Palette.paper.opacity(0.94),in:Capsule()).padding(12).accessibilityElement(children:.ignore).accessibilityLabel("Route tier \(game.rallyDifficulty+1), \(game.ecosystem.produce) cargo. Traffic tightens every three deliveries").accessibilityIdentifier("rallyDifficulty")
                Spacer()
                Image("RallyRover").resizable().scaledToFit().frame(height:180).shadow(color:Palette.night.opacity(0.2),radius:8,y:12).accessibilityHidden(true)
                HStack(spacing:18) { Image(systemName:"hand.draw.fill"); Image(systemName:"arrow.left.arrow.right"); Image(systemName:"shield.fill"); Text("3"); Image(systemName:"flag.checkered"); Text("440") }.font(.system(size:23,weight:.bold)).padding(16).background(Palette.paper.opacity(0.95),in:Capsule()).accessibilityElement(children:.ignore).accessibilityLabel("Swipe left or right to steer. Three shields. 440 meters in 22 seconds. Collect coins; avoid rocks, cones and logs. No puzzle life cost")
                Button { game.raceActive=true; game.effect("tap") } label: { Image(systemName:"play.fill").font(.system(size:32,weight:.black)).foregroundStyle(Palette.night).frame(maxWidth:500,minHeight:64).background(Palette.sunlight,in:Capsule()).shadow(color:Palette.gold.opacity(0.4),radius:0,y:5) }.buttonStyle(PressStyle()).accessibilityLabel("Start rally").accessibilityIdentifier("startRace").padding(18)
            }
        }
    }
}

struct DeliveryRaceView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var run = DeliveryRun()
    @State private var paused = false
    @State private var rewarded = false
    @State private var flash = false
    @State private var coinFlightID: UUID?
    @State private var pickupLane = 1
    @State private var prepared = false
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            GeometryReader { geo in
                road(size:geo.size).contentShape(Rectangle()).gesture(DragGesture(minimumDistance:20).onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    steer(value.translation.width < 0 ? -1 : 1)
                }).accessibilityElement(children:.ignore).accessibilityLabel("Harvest rally road. Swipe left or right to steer")
                    .accessibilityValue("Lane \(run.lane+1) of 3, \(laneName(run.lane)). \(trafficGuidance)")
                    .accessibilityHint("Avoid obstacles. VoiceOver users can adjust the lane up or down")
                    .accessibilityIdentifier("raceTrack").accessibilityAdjustableAction { direction in steer(direction == .increment ? 1 : -1) }
                    .allowsHitTesting(!run.finished && !paused).anchorPreference(key:RallyFlightAnchors.self,value:.bounds) { ["road":$0] }
            }
            VStack { raceHeader; Spacer(); trafficGuide.padding(.horizontal,28).padding(.bottom,16) }.allowsHitTesting(!run.finished)
            if run.finished { finish }
            else if paused { pauseCard }
        }
        .overlayPreferenceValue(RallyFlightAnchors.self) { anchors in
            GeometryReader { geo in
                if !reduceMotion, let flightID = coinFlightID, let roadAnchor = anchors["road"], let targetAnchor = anchors["coins"] {
                    let roadRect = geo[roadAnchor], targetRect = geo[targetAnchor]
                    RallyFlyingCoin(start: CGPoint(x: roadRect.minX + laneX(pickupLane, width: roadRect.width), y: roadRect.minY + roadRect.height * 0.78), end: CGPoint(x: targetRect.midX, y: targetRect.midY)).id(flightID)
                }
            }.allowsHitTesting(false).accessibilityHidden(true)
        }
        .task(id: coinFlightID) {
            guard let flightID = coinFlightID else { return }
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled, coinFlightID == flightID else { return }
            coinFlightID = nil
        }
        .onAppear {
            if !prepared { run = game.prepareDeliveryRun(); prepared = true }
            announceTraffic()
        }
        .onChange(of: scenePhase) { _, phase in if phase != .active && !run.finished { paused = true } }
        .onChange(of: run.nextTraffic?.id) { _, _ in announceTraffic() }
        .onChange(of: paused) { _, isPaused in if !isPaused { announceTraffic() } }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)) { _ in announceTraffic() }
        .onReceive(timer) { _ in
            guard !paused, scenePhase == .active, !run.finished else { return }
            let event = run.tick(0.05)
            if event.hit {
                flash = true; game.effect("collision"); game.feedback(.heavy)
                Task { try? await Task.sleep(for: .milliseconds(220)); flash = false }
            }
            if event.pickup { pickupLane = run.lane; coinFlightID = UUID(); game.effect("coin"); game.feedback(.light) }
            if run.finished && !rewarded { rewarded = true; game.completeDelivery(run) }
        }
    }

    private func laneName(_ lane: Int) -> String { ["left", "center", "right"][lane] }
    private var trafficGuidance: String {
        guard let traffic = run.nextTraffic else { return "No more barriers." }
        return "Next barrier: lane \(traffic.barrierLane+1), \(laneName(traffic.barrierLane))." + (traffic.secondaryBarrierLane.map { " Second barrier: lane \($0+1), \(laneName($0))." } ?? "") + " Coin: lane \(traffic.coinLane+1), \(laneName(traffic.coinLane))."
    }
    private func announceTraffic() {
        guard UIAccessibility.isVoiceOverRunning, scenePhase == .active, !paused, let traffic = run.nextTraffic else { return }
        UIAccessibility.post(notification: .announcement, argument: trafficGuidance)
    }
    private var trafficGuide:some View {
        HStack(spacing:12) {
            ForEach(0..<3) { lane in
                let blocked=run.nextTraffic?.barrierLane == lane || run.nextTraffic?.secondaryBarrierLane == lane
                let coin=run.nextTraffic?.coinLane == lane
                ZStack {
                    Capsule().fill(blocked ? Color(hex:0xEFA18A).opacity(0.95) : coin ? Palette.sunlight : Palette.paper.opacity(0.9))
                    if blocked { RallyHazard(variant:run.nextTraffic?.id ?? 0).padding(9) }
                    else if coin { RallyCoin().padding(10) }
                    else { Image(systemName:"checkmark").font(.system(size:22,weight:.heavy)) }
                    Capsule().stroke(run.lane == lane ? Palette.night : .white.opacity(0.5),lineWidth:2)
                }.frame(maxWidth:.infinity).frame(height:52).accessibilityIdentifier("raceLaneGuide\(lane)")
            }
        }.frame(maxWidth:400).accessibilityElement(children:.ignore).accessibilityLabel("Next traffic").accessibilityValue(trafficGuidance).accessibilityIdentifier("raceTrafficGuide")
    }

    private var raceHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button { game.leaveDelivery() } label: { Image(systemName:"xmark").font(.system(size:22,weight:.bold)).frame(width:48,height:48).background(Palette.paper,in:Circle()) }.accessibilityLabel("Exit rally to island. No life cost. Rally coins are saved only when this run ends").accessibilityIdentifier("leaveRace")
                Button { paused.toggle(); game.effect("tap") } label: {
                    Image(systemName: paused ? "play.fill" : "pause.fill").font(.system(size: 17, weight: .bold)).accessibilityHidden(true)
                        .frame(width: 48, height: 48).background(Palette.paper, in: Circle()).overlay(Circle().stroke(Palette.night.opacity(0.10), lineWidth: 1))
                }.buttonStyle(PressStyle()).disabled(run.finished).accessibilityLabel(paused ? "Resume race" : "Pause race").accessibilityIdentifier("pauseRace")
                VStack(alignment: .leading, spacing: 3) {
                    EmptyView()
                    Text("\(run.distance)/440").font(.system(.headline, design: .rounded, weight: .bold)).monospacedDigit().accessibilityIdentifier("raceDistance")
                }
                Spacer(minLength: 4)
                Text("\(max(0, Int(ceil(run.duration - run.elapsed))))s").font(.system(.title2, design: .rounded, weight: .heavy)).monospacedDigit()
                    .accessibilityLabel("\(max(0, Int(ceil(run.duration - run.elapsed)))) seconds remaining").accessibilityIdentifier("raceTimeRemaining")
            }
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<3) { point in Image(systemName: point < run.health ? "shield.fill" : "shield").foregroundStyle(point < run.health ? Palette.night : Palette.muted.opacity(0.45)).accessibilityHidden(true) }
                    Text("\(max(0, run.health))/3").monospacedDigit()
                }.font(.system(.caption, design: .rounded, weight: .bold)).accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(max(0, run.health)) shield points").accessibilityIdentifier("raceShield")
                ProgressView(value: Double(run.distance), total: 440).tint(Palette.night).accessibilityHidden(true)
                HStack(spacing: 4) {
                    RallyCoin().frame(width: 23, height: 23).accessibilityHidden(true)
                    Text("\(run.collected)").font(.system(.headline, design: .rounded, weight: .bold)).monospacedDigit().contentTransition(.numericText())
                }.padding(.horizontal, 10).frame(minHeight: 36).background(Palette.paper, in: Capsule())
                    .accessibilityElement(children: .ignore).accessibilityLabel("\(run.collected) coins collected in this rally").accessibilityIdentifier("raceCollectedCoins")
                    .anchorPreference(key: RallyFlightAnchors.self, value: .bounds) { ["coins": $0] }
            }
        }.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .foregroundStyle(Palette.night).padding(12).background(Palette.paper.opacity(0.93),in:RoundedRectangle(cornerRadius:26)).padding(.horizontal,12).padding(.top,8)
    }

    private func road(size: CGSize) -> some View {
        ZStack {
            RallyRoadSurface(elapsed: reduceMotion ? 0 : run.elapsed)
            RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)).frame(width: size.width * 0.76 / 3 - 8)
                .position(x: laneX(run.lane, width: size.width), y: size.height / 2).animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: run.lane)
            ForEach(0..<run.obstacleCount, id: \.self) { id in
                let crossing = run.crossingTime(id)
                let y = size.height * 0.78 + CGFloat((run.elapsed - crossing) * 110)
                if y > -70 && y < size.height + 70 && !run.passed.contains(id) {
                    RallyHazard(variant:id).frame(width: min(64, size.width * 0.21), height: 58).position(x: laneX(run.obstacleLane(id), width: size.width), y: y)
                    if let lane=run.secondObstacleLane(id) { RallyHazard(variant:id+1).frame(width:min(64,size.width*0.21),height:58).position(x:laneX(lane,width:size.width),y:y) }
                    RallyCoin().frame(width: 32, height: 32).shadow(color: Palette.gold.opacity(0.4), radius: 5, y: 3)
                        .position(x: laneX((run.obstacleLane(id) + 1) % 3, width: size.width), y: y)
                }
            }
            ZStack {
                Ellipse().fill(.black.opacity(0.25)).frame(width: 65, height: 98).blur(radius: 5).offset(y: 8)
                Image("RallyRover").resizable().scaledToFit().frame(width: min(92, size.width * 0.25), height: 124).shadow(color: .black.opacity(0.18), radius: 3, x: 2, y: 7)
            }.rotationEffect(.degrees(flash && !reduceMotion ? 8 : 0)).position(x: laneX(run.lane, width: size.width), y: size.height * 0.78)
                .animation(reduceMotion ? nil : .spring(response: 0.23, dampingFraction: 0.8), value: run.lane)
            if flash {
                RoundedRectangle(cornerRadius: 28).stroke(Palette.coral, lineWidth: 7).background(Palette.coral.opacity(0.10)).allowsHitTesting(false)
                Image(systemName:"shield.slash.fill").font(.system(size:24,weight:.bold)).foregroundStyle(Palette.night)
                    .padding(.horizontal, 14).padding(.vertical, 9).background(Palette.paper, in: Capsule()).position(x: size.width / 2, y: 35)
            }
        }
    }

    private var pauseCard: some View {
        VStack(spacing: 12) {
            if !textSize.isAccessibilitySize {
                Image(systemName: "pause.circle.fill").font(.system(size: 36)).foregroundStyle(Palette.night).accessibilityHidden(true)
            }
            Text(textSize.isAccessibilitySize ? "Paused" : "Rally paused").font(.system(.title2, design: .rounded, weight: .heavy))
            if !textSize.isAccessibilitySize {
                Text("The road and shield are paused.").font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
            }
            if textSize.isAccessibilitySize {
                Button { paused = false; game.effect("tap") } label: {
                    Text("Resume").font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(Palette.night).frame(maxWidth: .infinity, minHeight: 48)
                        .padding(.vertical, 8).background(Palette.sunlight, in: Capsule())
                }.buttonStyle(PressStyle()).accessibilityLabel("Resume rally").accessibilityIdentifier("resumeRace")
            } else {
                PrimaryButton(title: "Resume rally", symbol: "play.fill", id: "resumeRace") { paused = false; game.effect("tap") }
            }
        }.foregroundStyle(Palette.night).padding(22).background(Palette.paper.opacity(0.98), in: RoundedRectangle(cornerRadius: 25)).padding(22)
    }

    private func steer(_ change: Int) {
        guard !run.finished, !paused else { return }
        let lane = min(2, max(0, run.lane + change))
        guard lane != run.lane else { return }
        run.lane = lane; game.effect("tap"); game.feedback(.light)
    }
    private func laneX(_ lane: Int, width: CGFloat) -> CGFloat { width * (0.12 + 0.76 * (CGFloat(lane) + 0.5) / 3) }
    private var finish: some View {
        VStack(spacing: 16) {
            Image(systemName: run.won ? "flag.checkered" : "wrench.adjustable.fill").font(.system(size: 38)).foregroundStyle(Palette.gold).accessibilityHidden(true)
            Text(run.won ? "Delivery complete!" : "Time for a tune-up").font(.system(.title2, design: .rounded, weight: .heavy)).foregroundStyle(Palette.cream)
                .multilineTextAlignment(.center).accessibilityIdentifier("raceResult")
            Text(run.won ? "Your harvest made it home. Coins are in your wallet." : "Your collected coin reward is safe. Try another route.")
                .font(.subheadline).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
            PrimaryButton(title: "Back to the world", symbol: "globe", id: "raceDone") { game.leaveDelivery() }
        }.padding(24).background(Palette.paper.opacity(0.98), in: RoundedRectangle(cornerRadius: 25)).padding(22)
    }
}

private struct RallyRoadSurface: View {
    let elapsed: Double
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(Gradient(colors: [Color(hex: 0xA7CC8C), Color(hex: 0x5F966B)]), startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)))
            let road = CGRect(x: size.width * 0.12, y: -30, width: size.width * 0.76, height: size.height + 60)
            context.fill(Path(CGRect(x: road.minX - 5, y: road.minY, width: road.width + 10, height: road.height)), with: .color(Color(hex: 0x456851)))
            context.fill(Path(road), with: .linearGradient(Gradient(colors: [Color(hex: 0xB7C2BE), Color(hex: 0x8FA59B)]), startPoint: CGPoint(x: road.minX, y: 0), endPoint: CGPoint(x: road.maxX, y: 0)))
            for edge in [road.minX + 4, road.maxX - 7] { context.fill(Path(CGRect(x: edge, y: 0, width: 3, height: size.height)), with: .color(Color(hex: 0xFFF4CF).opacity(0.82))) }
            let surfaceOffset = CGFloat(elapsed * 100)
            for lane in 1...2 {
                for dash in 0..<Int(size.height / 56) + 2 {
                    let y = (CGFloat(dash) * 56 + surfaceOffset).truncatingRemainder(dividingBy: size.height + 56) - 56
                    context.fill(Path(roundedRect: CGRect(x: size.width * (0.12 + CGFloat(lane) * 0.76 / 3) - 1.5, y: y, width: 3, height: 24), cornerRadius: 1.5), with: .color(Color(hex: 0xFFF9E5).opacity(0.7)))
                }
            }
            for tree in 0..<Int(size.height / 70) + 2 {
                let y = (CGFloat(tree) * 70 + surfaceOffset * 0.7).truncatingRemainder(dividingBy: size.height + 70) - 35
                let x = tree % 2 == 0 ? size.width * 0.045 : size.width * 0.955
                context.fill(Path(ellipseIn: CGRect(x: x - 18, y: y + 15, width: 35, height: 15)), with: .color(Color(hex: 0x244C40).opacity(0.23)))
                context.fill(Path(roundedRect: CGRect(x: x - 3, y: y + 10, width: 6, height: 19), cornerRadius: 2), with: .color(Color(hex: 0x8C6348)))
                context.fill(Path(ellipseIn: CGRect(x: x - 18, y: y - 14, width: 35, height: 38)), with: .color(Color(hex: 0x2C6C49)))
                context.fill(Path(ellipseIn: CGRect(x: x - 15, y: y - 14, width: 28, height: 29)), with: .color(Color(hex: 0x77A955)))
                for fruit in 0..<3 {
                    let fx = x - 10 + CGFloat(fruit) * 9, fy = y - 3 + CGFloat(fruit % 2) * 8
                    context.fill(Path(ellipseIn: CGRect(x: fx, y: fy, width: 7, height: 7)), with: .color(Color(hex: 0xED927E)))
                    context.fill(Path(ellipseIn: CGRect(x: fx + 1, y: fy + 1, width: 2, height: 2)), with: .color(Color(hex: 0xFFE0A0)))
                }
            }
        }.accessibilityHidden(true)
    }
}

private struct RallyHazard:View {
    let variant:Int
    var body:some View {
        GeometryReader { geo in
            let w=geo.size.width,h=geo.size.height
            ZStack {
                Ellipse().fill(.black.opacity(0.22)).frame(width:w*0.9,height:h*0.22).offset(y:h*0.33)
                if variant%3 == 0 {
                    RoundedRectangle(cornerRadius:7).fill(Color(hex:0x7D6758)).frame(height:h*0.67).rotationEffect(.degrees(-12)).overlay(RoundedRectangle(cornerRadius:7).stroke(Color(hex:0xD5BD9B),lineWidth:3).frame(height:h*0.67).rotationEffect(.degrees(-12)))
                    ForEach(0..<3) { i in Path { p in p.move(to:CGPoint(x:w*CGFloat(i+1)/4,y:h*0.25)); p.addLine(to:CGPoint(x:w*CGFloat(i+1)/4+8,y:h*0.65)) }.stroke(Color(hex:0x4F493D),lineWidth:2) }
                } else if variant%3 == 1 {
                    RoundedRectangle(cornerRadius:6).fill(Color(hex:0x514D50)).frame(height:h*0.25).offset(y:h*0.3)
                    Path { p in p.move(to:CGPoint(x:w*0.5,y:2)); p.addLine(to:CGPoint(x:w*0.83,y:h*0.8)); p.addQuadCurve(to:CGPoint(x:w*0.17,y:h*0.8),control:CGPoint(x:w*0.5,y:h)); p.closeSubpath() }.fill(LinearGradient(colors:[Color(hex:0xFFD48B),Color(hex:0xE37039)],startPoint:.topLeading,endPoint:.bottomTrailing))
                    Capsule().fill(Color(hex:0xFFF8DF)).frame(width:w*0.34,height:h*0.14).offset(y:h*0.03)
                } else {
                    Path { p in p.move(to:CGPoint(x:w*0.12,y:h*0.72)); p.addLine(to:CGPoint(x:w*0.2,y:h*0.22)); p.addLine(to:CGPoint(x:w*0.55,y:h*0.08)); p.addLine(to:CGPoint(x:w*0.89,y:h*0.36)); p.addLine(to:CGPoint(x:w*0.93,y:h*0.72)); p.addLine(to:CGPoint(x:w*0.46,y:h*0.9)); p.closeSubpath() }.fill(LinearGradient(colors:[Color(hex:0xD9D6CA),Color(hex:0x798F88)],startPoint:.topLeading,endPoint:.bottomTrailing))
                    Path { p in p.move(to:CGPoint(x:w*0.2,y:h*0.22)); p.addLine(to:CGPoint(x:w*0.5,y:h*0.44)); p.addLine(to:CGPoint(x:w*0.89,y:h*0.36)) }.stroke(.white.opacity(0.6),lineWidth:2)
                }
            }
        }.shadow(color:.black.opacity(0.15),radius:2,y:3).accessibilityHidden(true)
    }
}

private struct RallyBarrier: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(Color(hex: 0x405E54)).offset(y: 5)
            RoundedRectangle(cornerRadius: 8).fill(LinearGradient(colors: [Color(hex: 0xFFF4C7), Color(hex: 0xEAC579)], startPoint: .top, endPoint: .bottom))
            HStack(spacing: 7) { ForEach(0..<4) { _ in Rectangle().fill(Palette.coral).frame(width: 8).rotationEffect(.degrees(-20)) } }.clipped().clipShape(RoundedRectangle(cornerRadius: 8))
            RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.65), lineWidth: 2)
        }.shadow(color: .black.opacity(0.18), radius: 2, y: 5).accessibilityHidden(true)
    }
}

private struct RallyCoin: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(hex: 0xA66D19)).offset(y: 2)
            Circle().fill(LinearGradient(colors: [Color(hex: 0xFFF0A1), Color(hex: 0xF3BB4E)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().stroke(Color(hex: 0xB77C1E).opacity(0.65), lineWidth: 2).padding(3)
            Image(systemName: "star.fill").font(.system(size: 11, weight: .black)).foregroundStyle(Color(hex: 0xAF761B)).accessibilityHidden(true)
        }
    }
}

private struct RallyFlightAnchors: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) { value.merge(nextValue(), uniquingKeysWith: { _, new in new }) }
}

private struct RallyFlyingCoin: View {
    let start: CGPoint
    let end: CGPoint
    @State private var progress: CGFloat = 0
    var body: some View {
        RallyCoin().frame(width: 30, height: 30).scaleEffect(1 - progress * 0.3)
            .position(x: start.x + (end.x - start.x) * progress + sin(progress * .pi) * 28, y: start.y + (end.y - start.y) * progress - sin(progress * .pi) * 35)
            .opacity(progress > 0.95 ? 0 : 1).onAppear { withAnimation(.easeIn(duration: 0.62)) { progress = 1 } }
    }
}
