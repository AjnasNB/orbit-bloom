import SwiftUI

struct DeliveryLobby: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionEyebrow(text: "Rally room")
            Text("Harvest rally").font(.system(size: 27, weight: .heavy, design: .rounded)).foregroundStyle(Palette.cream)
            RallyRoomMap().frame(maxHeight: .infinity).layoutPriority(1)
            Text("Bring the harvest home.").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(Palette.cream)
            Text("Swipe left or right on the road to change lanes. Collect gold coins and avoid the striped barriers.")
                .font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
            HStack { Label("3 shield points", systemImage: "shield.fill"); Spacer(minLength: 4); Label("No life cost", systemImage: "heart.fill") }
                .font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(Palette.gold)
            Text(game.ecosystem.produce > 0 ? "\(game.ecosystem.produce) cargo ready · +40 delivery bonus" : "No cargo? Race for coins, then harvest your farm for a delivery bonus.")
                .font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.cream).fixedSize(horizontal: false, vertical: true)
            PrimaryButton(title: "Start rally", subtitle: textSize.isAccessibilitySize ? nil : "440 m · 22 sec", symbol: "flag.checkered", id: "startRace") {
                game.raceActive = true; game.effect("tap")
            }
            Text("Best: \(game.ecosystem.raceBest) m · Deliveries: \(game.ecosystem.deliveries)").font(.caption).foregroundStyle(Palette.muted)
            Text("Route tier \(min(4,game.ecosystem.deliveries/3)+1) · tighter traffic every 3 deliveries").font(.caption.bold()).foregroundStyle(Palette.mint).accessibilityIdentifier("rallyDifficulty")
        }.padding(.horizontal, 22).padding(.bottom, 12)
    }
}

struct DeliveryRaceView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var run = DeliveryRun()
    @State private var paused = false
    @State private var rewarded = false
    @State private var flash = false
    @State private var coinFlightID: UUID?
    @State private var pickupLane = 1
    @State private var prepared = false
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack(spacing: 10) {
            raceHeader
            GeometryReader { geo in
                road(size: geo.size).clipped().clipShape(RoundedRectangle(cornerRadius: 28)).contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 20).onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        steer(value.translation.width < 0 ? -1 : 1)
                    })
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Harvest rally road. Swipe left or right to steer.")
                    .accessibilityValue("Lane \(run.lane + 1) of 3")
                    .accessibilityHint("Avoid striped barriers and collect coins. VoiceOver users can adjust the lane up or down.")
                    .accessibilityIdentifier("raceTrack")
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: steer(1)
                        case .decrement: steer(-1)
                        @unknown default: break
                        }
                    }
                    .allowsHitTesting(!run.finished)
                    .anchorPreference(key: RallyFlightAnchors.self, value: .bounds) { ["road": $0] }
                    .overlay {
                        if run.finished { finish }
                        else if paused { pauseCard }
                    }
            }.padding(.horizontal, 20)
            Label(paused ? "Paused · your shield is safe" : "Swipe left or right to steer", systemImage: paused ? "pause.circle.fill" : "hand.draw.fill")
                .font(.system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(Palette.mint).frame(minHeight: 34)
                .accessibilityIdentifier("raceSteeringHelp")
            Button { game.raceActive = false; game.tab = 0 } label: {
                Label("Exit rally room · Island", systemImage: "xmark.circle.fill")
                    .font(.system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(Palette.night)
                    .frame(maxWidth: .infinity, minHeight: 48).background(Palette.paper, in: Capsule())
            }.buttonStyle(PressStyle()).padding(.horizontal, 22).padding(.bottom, 8)
                .accessibilityHint("No life is spent. Coins are banked when the rally ends.").accessibilityIdentifier("leaveRace")
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
        .onAppear { if !prepared { run = DeliveryRun(difficulty:game.ecosystem.deliveries/3); prepared = true } }
        .onChange(of: scenePhase) { _, phase in if phase != .active && !run.finished { paused = true } }
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

    private var raceHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button { paused.toggle(); game.effect("tap") } label: {
                    Image(systemName: paused ? "play.fill" : "pause.fill").font(.system(size: 17, weight: .bold)).accessibilityHidden(true)
                        .frame(width: 48, height: 48).background(Palette.paper, in: Circle()).overlay(Circle().stroke(Palette.night.opacity(0.10), lineWidth: 1))
                }.buttonStyle(PressStyle()).disabled(run.finished).accessibilityLabel(paused ? "Resume race" : "Pause race").accessibilityIdentifier("pauseRace")
                VStack(alignment: .leading, spacing: 3) {
                    SectionEyebrow(text: "Harvest rally")
                    Text("\(run.distance) / 440 m").font(.system(.headline, design: .rounded, weight: .bold)).monospacedDigit().accessibilityIdentifier("raceDistance")
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
        }.foregroundStyle(Palette.night).padding(.horizontal, 22).padding(.top, 8)
    }

    private func road(size: CGSize) -> some View {
        ZStack {
            RallyRoadSurface(elapsed: reduceMotion ? 0 : run.elapsed)
            RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)).frame(width: size.width * 0.76 / 3 - 8)
                .position(x: laneX(run.lane, width: size.width), y: size.height / 2).animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: run.lane)
            ForEach(0..<run.obstacleCount) { id in
                let crossing = run.crossingTime(id)
                let y = size.height * 0.78 + CGFloat((run.elapsed - crossing) * 110)
                if y > -70 && y < size.height + 70 && !run.passed.contains(id) {
                    RallyBarrier().frame(width: min(64, size.width * 0.21), height: 45).position(x: laneX(run.obstacleLane(id), width: size.width), y: y)
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
                Text("Shield hit").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(Palette.night)
                    .padding(.horizontal, 14).padding(.vertical, 9).background(Palette.paper, in: Capsule()).position(x: size.width / 2, y: 35)
            }
        }
    }

    private var pauseCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "pause.circle.fill").font(.system(size: 36)).foregroundStyle(Palette.night).accessibilityHidden(true)
            Text("Rally paused").font(.system(.title2, design: .rounded, weight: .heavy))
            Text("Take your time. The road waits for you.").font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.mint).multilineTextAlignment(.center)
            PrimaryButton(title: "Resume rally", symbol: "play.fill", id: "resumeRace") { paused = false; game.effect("tap") }
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
            PrimaryButton(title: "Back to the world", symbol: "globe", id: "raceDone") { game.raceActive = false; game.tab = 0 }
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
