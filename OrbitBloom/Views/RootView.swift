import SwiftUI

struct RootView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
    var body: some View {
        ZStack {
            SpaceBackdrop()
            if game.engine != nil { PuzzleView() }
            else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            header
                            if game.tab == 0 { GardenView() }
                            else if game.tab == 1 { JourneyView() }
                            else { ShopView() }
                        }.frame(maxWidth: 600).frame(maxWidth: .infinity)
                    }.scrollIndicators(.hidden)
                    navigation
                }.accessibilityHidden(!game.progress.hasSeenIntro)
            }
            if !game.progress.hasSeenIntro { intro }
            if let toast = game.toast {
                VStack { Spacer(); Text(toast).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(Palette.night).padding(18).background(Palette.cream, in: Capsule()).padding(.horizontal, 24).padding(.bottom, 85) }.allowsHitTesting(false).transition(.opacity)
            }
        }
        .sheet(isPresented: $game.showSettings) { SettingsView() }
        .onChange(of: purchases.ownsAurora) { _, owned in
            if !owned && game.progress.auroraTheme { game.progress.auroraTheme = false; game.save() }
        }
    }
    var header: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle").accessibilityHidden(true).foregroundStyle(Palette.coral).font(.system(size: 21))
                Text("orbit bloom").font(.system(size: 19, weight: .heavy, design: .rounded)).tracking(-0.7).lineLimit(1).minimumScaleFactor(0.85).foregroundStyle(Palette.cream)
            }.accessibilityElement(children: .combine)
            Spacer(minLength: 4)
            ResourcePill(symbol: "star.fill", value: "\(game.progress.stars)")
            ResourcePill(symbol: "circle.inset.filled", value: "\(game.progress.coins)", tint: Palette.coral)
            Button { game.showSettings = true } label: { Image(systemName: "gearshape").accessibilityHidden(true).font(.system(size: 18)).foregroundStyle(Palette.muted).frame(width: 44, height: 44) }.accessibilityLabel("Settings").accessibilityIdentifier("settings")
        }.padding(.horizontal, 20).padding(.top, 6).padding(.bottom, 16)
    }
    var navigation: some View {
        HStack(spacing: 0) {
            tabButton(0, "Garden", "leaf")
            tabButton(1, "Journey", "point.topleft.down.to.point.bottomright.curvepath")
            tabButton(2, "Shop", "bag")
        }.padding(.top, 12).padding(.bottom, 5).background(Palette.night.opacity(0.97))
            .overlay(alignment: .top) { Rectangle().fill(Palette.mint.opacity(0.13)).frame(height: 1) }
    }
    func tabButton(_ id: Int, _ title: String, _ symbol: String) -> some View {
        Button { game.tab = id } label: {
            VStack(spacing: 5) {
                Image(systemName: symbol).accessibilityHidden(true).font(.system(size: 20, weight: game.tab == id ? .bold : .regular)).frame(height: 24)
                Text(title).font(.system(size: 10, weight: .semibold, design: .rounded))
            }.foregroundStyle(game.tab == id ? Palette.coral : Palette.muted).frame(maxWidth: .infinity).frame(minHeight: 44)
        }.accessibilityIdentifier("tab\(title)").accessibilityAddTraits(game.tab == id ? .isSelected : [])
    }
    var intro: some View {
        ZStack {
            Palette.night.ignoresSafeArea()
            VStack(spacing: 22) {
                Image("MoonGarden").resizable().accessibilityLabel("Your future moon garden").scaledToFit().frame(maxWidth: 310).mask(RoundedRectangle(cornerRadius: 38))
                SectionEyebrow(text: "A tiny moon. A new beginning.")
                Text("A little space\nfor something lovely.").font(.system(size: 33, weight: .bold, design: .rounded)).tracking(-1).multilineTextAlignment(.center).foregroundStyle(Palette.cream)
                Text("Match leaves, collect starlight, and bring a forgotten garden back to life. One lovely little puzzle at a time.").font(.system(.body, design: .rounded)).multilineTextAlignment(.center).foregroundStyle(Palette.muted).fixedSize(horizontal: false, vertical: true)
                PrimaryButton(title: "Let's grow", symbol: "leaf.fill", id: "introStart") { game.progress.hasSeenIntro = true; game.save() }
                Text("No timers. No lives to wait for. Yours to explore.").font(.system(.caption, design: .rounded)).foregroundStyle(Palette.muted)
            }.padding(30).frame(maxWidth: 480)
        }.accessibilityElement(children: .contain)
    }
}

struct GardenView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var purchases: PurchaseStore
    var nextTask: GardenTask? { GardenTask.all.first { !game.progress.restored.contains($0.id) } }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack { SectionEyebrow(text: "Chapter 01 / The forgotten moon"); Spacer(); Image(systemName: "moon.stars").accessibilityHidden(true).foregroundStyle(Palette.gold) }
                Text(game.progress.gardenComplete ? "A world in bloom." : "Your little\ncorner of the cosmos.").font(.system(size: 34, weight: .bold, design: .rounded)).tracking(-1.2).lineSpacing(-1).foregroundStyle(Palette.cream)
            }.padding(.horizontal, 26)
            GardenScene(restored: game.progress.restored, aurora: game.progress.auroraTheme && purchases.ownsAurora)
                .frame(height: 340)
                .overlay(alignment: .bottomLeading) {
                    HStack(spacing: 7) {
                        Circle().fill(Palette.mint).frame(width: 5, height: 5)
                        Text("MOONSEED MEADOW").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(2)
                        Spacer()
                        Text("\(game.progress.restored.count)/6 restored").font(.system(size: 11, weight: .semibold, design: .rounded))
                    }.foregroundStyle(Palette.cream).padding(.horizontal, 27).padding(.bottom, 9)
                }
            VStack(alignment: .leading, spacing: 16) {
                if let task = nextTask {
                    HStack(spacing: 13) {
                        Image(systemName: task.icon).accessibilityHidden(true).font(.system(size: 22)).foregroundStyle(Palette.mint).frame(width: 48, height: 52).background(Palette.mint.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        VStack(alignment: .leading, spacing: 5) {
                            Text("NEXT GARDEN PROJECT").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(1.5).foregroundStyle(Palette.muted)
                            Text(task.title).font(.system(.headline, design: .rounded)).foregroundStyle(Palette.cream)
                            Text(task.detail).font(.system(size: 11, design: .rounded)).foregroundStyle(Palette.muted).fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                        Button { game.restore(task) } label: {
                            VStack(spacing: 4) { HStack(spacing: 3) { Image(systemName: "star.fill").accessibilityHidden(true); Text("2") }; Text("Restore").font(.system(size: 10, weight: .bold, design: .rounded)) }
                                .font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(game.progress.stars >= 2 ? Palette.night : Palette.gold).frame(width: 60, height: 56).background(game.progress.stars >= 2 ? Palette.gold : Palette.gold.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                        }.accessibilityLabel("Restore \(task.title) for 2 stars").accessibilityIdentifier("restoreProject")
                    }
                } else {
                    HStack { Image(systemName: "checkmark.seal.fill").accessibilityHidden(true).foregroundStyle(Palette.mint); Text("Every little corner is alive again.").font(.system(.headline, design: .rounded)).foregroundStyle(Palette.cream) }.padding(.vertical, 10)
                }
                PrimaryButton(title: game.progress.chapterComplete ? "Revisit the garden" : "Play level \(game.progress.nextLevel)", subtitle: game.progress.chapterComplete ? "12 puzzles" : "\(Level.campaign[game.progress.nextLevel - 1].moves) moves", id: "playLevel") {
                    if game.progress.chapterComplete { game.tab = 1 }
                    else { game.start(Level.campaign[game.progress.nextLevel - 1]) }
                }
                HStack { Image(systemName: "infinity").accessibilityHidden(true); Text("Take your time. Your garden will be here.") }.font(.system(size: 11, design: .rounded)).foregroundStyle(Palette.muted).frame(maxWidth: .infinity)
            }.padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 22)
        }
    }
}

struct GardenScene: View {
    let restored: Set<Int>
    let aurora: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let points: [CGPoint] = [.init(x: 0.5, y: 0.25), .init(x: 0.24, y: 0.48), .init(x: 0.64, y: 0.58), .init(x: 0.8, y: 0.36), .init(x: 0.25, y: 0.25), .init(x: 0.76, y: 0.7)]
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("MoonGarden").resizable().accessibilityHidden(true).scaledToFill().frame(width: geo.size.width, height: geo.size.height).clipped()
                    .saturation(restored.isEmpty ? 0.45 : min(1, 0.45 + Double(restored.count) * 0.1))
                    .brightness(restored.isEmpty ? -0.1 : 0)
                if aurora { LinearGradient(colors: [Color(hex: 0x71E9D0).opacity(0.35), .clear, Color(hex: 0x7C86D3).opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing).blendMode(.screen) }
                ForEach(0..<6) { id in
                    if !restored.contains(id) {
                        Circle().fill(RadialGradient(colors: [Palette.night.opacity(0.6), .clear], center: .center, startRadius: 5, endRadius: 65)).frame(width: 130, height: 130).position(x: points[id].x * geo.size.width, y: points[id].y * geo.size.height)
                    }
                }
                ForEach(0..<6) { id in
                    Image(systemName: restored.contains(id) ? "sparkle" : GardenTask.all[id].icon)
                        .font(.system(size: restored.contains(id) ? 17 : 12, weight: .semibold)).foregroundStyle(restored.contains(id) ? Palette.gold : Palette.cream.opacity(0.7))
                        .frame(width: 28, height: 28).background(Palette.night.opacity(restored.contains(id) ? 0 : 0.7), in: Circle()).overlay(Circle().stroke(Palette.cream.opacity(restored.contains(id) ? 0 : 0.3), lineWidth: 1))
                        .position(x: points[id].x * geo.size.width, y: points[id].y * geo.size.height)
                }
                LinearGradient(stops: [.init(color: Palette.night, location: 0), .init(color: .clear, location: 0.12), .init(color: .clear, location: 0.84), .init(color: Palette.night, location: 1)], startPoint: .top, endPoint: .bottom)
            }
        }.accessibilityElement(children: .ignore).accessibilityLabel("Moon garden, \(restored.count) of 6 areas restored").accessibilityIdentifier("gardenScene")
    }
}

struct JourneyView: View {
    @EnvironmentObject var game: GameModel
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            SectionEyebrow(text: "A small adventure, at your pace")
            Text("Follow the starlight.").font(.system(size: 32, weight: .bold, design: .rounded)).tracking(-1).foregroundStyle(Palette.cream)
            Text("12 puzzles. Three places to explore.\nEvery first win earns a star for your garden.").font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.muted)
            ForEach(0..<3) { biome in
                VStack(alignment: .leading, spacing: 14) {
                    HStack { Text(["01", "02", "03"][biome]).foregroundStyle(Palette.coral); Text(Level.campaign[biome * 4].biome).foregroundStyle(Palette.cream); Spacer() }.font(.system(.headline, design: .rounded))
                    ForEach(Array(Level.campaign[(biome * 4)..<(biome * 4 + 4)])) { level in
                        let unlocked = level.id <= game.progress.nextLevel
                        let completed = game.progress.completed[level.id] != nil
                        Button { if unlocked { game.start(level) } } label: {
                            HStack(spacing: 14) {
                                Text(String(format: "%02d", level.id)).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(completed ? Palette.night : Palette.mint).frame(width: 43, height: 43).background(completed ? Palette.mint : Palette.deep, in: Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.title).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(Palette.cream)
                                    Text(completed ? "Best: \(game.progress.completed[level.id] ?? 0)" : "\(level.moves) moves" + (level.frost > 0 ? " · frozen patches" : " · collect & grow")).font(.system(.caption, design: .rounded)).foregroundStyle(Palette.muted)
                                }
                                Spacer()
                                Image(systemName: completed ? "star.fill" : unlocked ? "play.fill" : "lock.fill").foregroundStyle(completed ? Palette.gold : Palette.muted)
                            }.padding(12).background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 18)).opacity(unlocked ? 1 : 0.5)
                        }.disabled(!unlocked).accessibilityIdentifier("level\(level.id)")
                    }
                }
            }
        }.padding(.horizontal, 25).padding(.bottom, 30)
    }
}
