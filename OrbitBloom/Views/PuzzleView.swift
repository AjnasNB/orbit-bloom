import SwiftUI

struct PuzzleView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        Button { game.paused = true } label: { Image(systemName: "pause.fill").accessibilityHidden(true).font(.system(size: 18)).foregroundStyle(Palette.cream).frame(width: 44, height: 44).background(.white.opacity(0.06), in: Circle()) }.accessibilityLabel("Pause game").accessibilityIdentifier("pauseGame")
                        Spacer()
                        VStack(spacing: 4) {
                            SectionEyebrow(text: "Level \(game.engine?.level.id ?? 1)")
                            Text(game.engine?.level.title ?? "").font(.system(.headline, design: .rounded)).foregroundStyle(Palette.cream)
                        }
                        Spacer()
                        VStack(spacing: 0) { Text("\(game.moves)").font(.system(size: 25, weight: .bold, design: .rounded)).monospacedDigit(); Text("MOVES").font(.system(size: 8, weight: .bold, design: .rounded)).tracking(1) }.foregroundStyle(Palette.gold).frame(width: 52).accessibilityElement(children: .combine).accessibilityIdentifier("movesCounter")
                    }
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            Text("GATHER").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(1.8).foregroundStyle(Palette.muted)
                            if let level = game.engine?.level {
                                ForEach(level.goals.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { gem in
                                    HStack(spacing: 6) {
                                        GemView(gem: gem).frame(width: 25, height: 28)
                                        Text("\(min(game.collected[gem, default: 0], level.goals[gem] ?? 0))/\(level.goals[gem] ?? 0)").font(.system(size: 13, weight: .bold, design: .rounded)).monospacedDigit().foregroundStyle(Palette.cream)
                                    }.accessibilityElement(children: .ignore).accessibilityLabel("\(gem.name), \(game.collected[gem, default: 0]) of \(level.goals[gem] ?? 0)")
                                }
                                if level.frost > 0 { HStack(spacing: 4) { Image(systemName: "snowflake").accessibilityHidden(true).foregroundStyle(Color(hex: 0xA8E4ED)); Text("\(game.frost.count)").foregroundStyle(Palette.cream) }.font(.system(size: 13, weight: .bold, design: .rounded)).accessibilityLabel("\(game.frost.count) frozen patches remaining") }
                            }
                            Spacer(minLength: 0)
                        }
                        HStack(spacing: 10) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(.white.opacity(0.08))
                                    Capsule().fill(LinearGradient(colors: [Palette.mint, Palette.gold], startPoint: .leading, endPoint: .trailing)).frame(width: geo.size.width * min(1, Double(game.score) / Double(game.engine?.level.target ?? 1)))
                                }
                            }.frame(height: 5)
                            Text("\(game.score) / \(game.engine?.level.target ?? 0)").font(.system(size: 11, weight: .semibold, design: .rounded)).monospacedDigit().foregroundStyle(Palette.muted).accessibilityIdentifier("scoreCounter")
                        }
                    }.padding(17).background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 20))
                    board
                    Text(game.message).font(.system(size: 12, weight: .medium, design: .rounded)).multilineTextAlignment(.center).foregroundStyle(game.burstMode ? Palette.gold : Palette.mint).frame(minHeight: 30).accessibilityIdentifier("gameMessage")
                    if !game.hintText.isEmpty { Text(game.hintText).font(.system(size: 11, design: .rounded)).foregroundStyle(Palette.cream).accessibilityIdentifier("hintInstruction") }
                    HStack(spacing: 12) {
                        tool("Hint", symbol: "lightbulb", detail: "Free", id: "hintButton") { game.hint() }
                        tool("Starlight burst", symbol: "sparkles", detail: game.charged ? "Ready!" : "\(game.progress.boosters) left", id: "burstButton", active: game.burstMode) { game.toggleBurst() }
                        tool("Shuffle", symbol: "shuffle", detail: "Free", id: "shuffleButton") {
                            guard !game.busy else { return }; game.engine?.shuffle(); game.sync(); game.selected = nil; game.hinted = []; game.save(); game.message = "A fresh arrangement. Same moves, same goals."
                        }
                    }
                    HStack(spacing: 6) { Image(systemName: "star.fill").accessibilityHidden(true).foregroundStyle(Palette.gold); Text("Win a star. Grow your garden.").foregroundStyle(Palette.muted) }.font(.system(size: 11, design: .rounded))
                    Text("Match 4+ pieces to earn a free starlight burst.").font(.system(size: 10, design: .rounded)).foregroundStyle(Palette.muted)
                }.padding(.horizontal, 22).padding(.top, 6).padding(.bottom, 24).frame(maxWidth: 550).frame(maxWidth: .infinity)
            }.scrollIndicators(.hidden).disabled(game.result != nil || game.paused).accessibilityHidden(game.result != nil || game.paused)
            if let won = game.result { resultView(won: won) }
            if game.paused { pauseView }
        }
    }
    var board: some View {
        GeometryReader { geo in
            let gap: CGFloat = 4
            let inset: CGFloat = 10
            let side = (geo.size.width - inset * 2 - gap * 6) / 7
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 22).fill(LinearGradient(colors: [Color(hex: 0x49666A), Color(hex: 0x304C54)], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 22).stroke(Palette.mint.opacity(0.3), lineWidth: 1)
                ForEach(game.cells) { cell in
                    let key = cell.key
                    let glowing = game.selected == key || game.hinted.contains(key) || game.burstMode
                    Button { game.tap(key) } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 11).fill(LinearGradient(colors: [Color(hex: 0xF4F0D9), Color(hex: 0xCCD9C9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            RoundedRectangle(cornerRadius: 11).stroke(.white.opacity(0.5), lineWidth: 1)
                            GemView(gem: cell.gem).padding(side * 0.16)
                            if game.frost.contains(key) {
                                RoundedRectangle(cornerRadius: 11).fill(Color(hex: 0xA5E2F1).opacity(0.3))
                                RoundedRectangle(cornerRadius: 11).stroke(Color(hex: 0xB9F1FF), lineWidth: 2)
                                Image(systemName: "snowflake").accessibilityHidden(true).font(.system(size: 9, weight: .bold)).foregroundStyle(.white).offset(x: side * 0.3, y: -side * 0.3)
                            }
                            if glowing { RoundedRectangle(cornerRadius: 11).stroke(Palette.gold, lineWidth: 3).shadow(color: Palette.gold.opacity(0.7), radius: 5) }
                        }.frame(width: side, height: side).scaleEffect(game.clearing.contains(key) && !reduceMotion ? 0.1 : 1).opacity(game.clearing.contains(key) ? 0 : 1)
                    }.buttonStyle(.plain).disabled(game.busy)
                        .simultaneousGesture(DragGesture(minimumDistance: 14).onEnded { value in game.swipe(key, dx: value.translation.width, dy: value.translation.height) })
                        .accessibilityLabel("\(cell.gem.name), row \(7 - cell.row), column \(cell.column + 1)\(game.frost.contains(key) ? ", frozen" : "")")
                        .accessibilityHint("Select this piece, then select a neighbor to match three.")
                        .accessibilityIdentifier("tile\(key)")
                        .accessibilityAddTraits(game.selected == key ? .isSelected : [])
                        .position(x: inset + CGFloat(cell.column) * (side + gap) + side / 2, y: inset + CGFloat(6 - cell.row) * (side + gap) + side / 2)
                }
            }
        }.aspectRatio(1, contentMode: .fit)
    }
    func tool(_ title: String, symbol: String, detail: String, id: String, active: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: symbol).accessibilityHidden(true).font(.system(size: 23, weight: .medium)).foregroundStyle(active ? Palette.night : Palette.gold)
                Text(title).font(.system(size: 11, weight: .bold, design: .rounded)).foregroundStyle(active ? Palette.night : Palette.cream)
                Text(detail).font(.system(size: 10, design: .rounded)).foregroundStyle(active ? Palette.night.opacity(0.7) : Palette.muted)
            }.frame(maxWidth: .infinity).frame(height: 88).background(active ? Palette.gold : Palette.deep, in: RoundedRectangle(cornerRadius: 21)).overlay(RoundedRectangle(cornerRadius: 21).stroke(.white.opacity(0.08), lineWidth: 1))
        }.buttonStyle(PressStyle()).disabled(game.busy).accessibilityIdentifier(id)
    }
    func resultView(won: Bool) -> some View {
        ZStack {
            Palette.night.opacity(0.94).ignoresSafeArea()
            VStack(spacing: 22) {
                Image(systemName: won ? "sparkles" : "moon.zzz.fill").font(.system(size: 65, weight: .light)).foregroundStyle(Palette.gold).padding(.bottom, 8)
                SectionEyebrow(text: won ? "A little victory" : "A fresh start")
                Text(won ? "Lovely things\nare growing." : "Let's try\nanother way.").font(.system(size: 37, weight: .bold, design: .rounded)).tracking(-1).multilineTextAlignment(.center).foregroundStyle(Palette.cream).accessibilityIdentifier(won ? "winTitle" : "loseTitle")
                Text(won ? "\(game.engine?.level.title ?? "Puzzle") complete.\n\(game.score) points, and a little closer to home." : "Your garden is safe. A fresh board and unlimited retries are waiting for you.").font(.system(.body, design: .rounded)).multilineTextAlignment(.center).foregroundStyle(Palette.muted)
                if won {
                    HStack(spacing: 16) {
                        ResourcePill(symbol: "star.fill", value: game.firstWin ? "+1 star" : "Already earned")
                        ResourcePill(symbol: "circle.inset.filled", value: game.firstWin ? "+120 coins" : "+30 coins", tint: Palette.coral)
                    }
                    PrimaryButton(title: "Back to my garden", symbol: "leaf.fill", id: "backToGarden") { game.gardenAfterWin() }
                    if let current = game.engine?.level.id, current < 12 {
                        Button("Play level \(current + 1)") { game.start(Level.campaign[current]) }.font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(Palette.mint).frame(minHeight: 44).accessibilityIdentifier("nextLevel")
                    }
                } else {
                    PrimaryButton(title: "Try again", symbol: "arrow.clockwise", id: "retryLevel") { if let level = game.engine?.level { game.start(level) } }
                    Button("Return to garden") { game.gardenAfterWin() }.font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.muted).frame(minHeight: 44)
                }
            }.padding(30).frame(maxWidth: 480)
        }.accessibilityElement(children: .contain)
    }
    var pauseView: some View {
        ZStack {
            Palette.night.opacity(0.97).ignoresSafeArea()
            VStack(spacing: 22) {
                Image(systemName: "moon.stars").accessibilityHidden(true).font(.system(size: 48)).foregroundStyle(Palette.gold)
                Text("A moment of quiet.").font(.system(size: 29, weight: .bold, design: .rounded)).foregroundStyle(Palette.cream)
                Text("Match three or more pieces in a row. Gather the resources above and fill the score bar. Match frozen pieces to melt their patches.").font(.system(.body, design: .rounded)).foregroundStyle(Palette.muted).multilineTextAlignment(.center)
                PrimaryButton(title: "Keep growing", symbol: "play.fill", id: "resumeGame") { game.paused = false }
                Button("Restart this puzzle") { if let level = game.engine?.level { game.start(level) } }.foregroundStyle(Palette.mint).frame(minHeight: 44).accessibilityIdentifier("restartLevel")
                Button("Leave level") { game.leave() }.foregroundStyle(Palette.coral).frame(minHeight: 44).accessibilityIdentifier("leaveLevel")
                Text("Leaving discards this puzzle. Your garden and earned rewards stay safe.").font(.system(.caption, design: .rounded)).foregroundStyle(Palette.muted).multilineTextAlignment(.center)
            }.padding(32).frame(maxWidth: 480)
        }.accessibilityElement(children: .contain)
    }
}
