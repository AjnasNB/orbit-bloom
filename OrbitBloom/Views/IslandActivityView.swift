import SwiftUI
import UIKit

private struct ActivityCompactLayoutKey: EnvironmentKey { static let defaultValue = false }
private struct ActivityHelpChangedKey: EnvironmentKey { static let defaultValue: (Bool) -> Void = { _ in } }
private extension EnvironmentValues {
    var activityHelpChanged: (Bool) -> Void {
        get { self[ActivityHelpChangedKey.self] }
        set { self[ActivityHelpChangedKey.self] = newValue }
    }
    var activityCompactLayout: Bool {
        get { self[ActivityCompactLayoutKey.self] }
        set { self[ActivityCompactLayoutKey.self] = newValue }
    }
}

/// Each room has a single play surface, a clear exit, and its own distinct mechanic.
struct IslandActivityView: View {
    let kind: IslandActivityKind
    let level: Int
    let onComplete: (Int) -> Void
    let onExit: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var paused = false
    @State private var helpOpen = false
    @State private var deliveredResult = false
    @State private var restartID = 0
    @State private var confirmRestart = false

    var body: some View {
        GeometryReader { geometry in
            let compact = textSize.isAccessibilitySize || geometry.size.height < 560
            room(compact: compact).environment(\.activityCompactLayout, compact)
                .environment(\.activityHelpChanged, { visible in helpOpen = visible })
        }
        .onChange(of: scenePhase) { _, phase in if phase != .active { paused = true } }
        .confirmationDialog("Restart this room?", isPresented: $confirmRestart, titleVisibility: .visible) {
            Button("Restart · no life cost") { restartID += 1; paused = false }
            Button("Keep playing", role: .cancel) { }
        } message: { Text("Only the current attempt restarts. Your completed rooms and rewards stay saved.") }
    }

    private func room(compact: Bool) -> some View {
        VStack(spacing: compact ? 8 : 12) {
            HStack(spacing: 10) {
                Button(action: onExit) {
                    Label("Rooms", systemImage: "xmark.circle.fill")
                        .font(compact ? .system(size: 17, weight: .bold, design: .rounded) : .system(.subheadline, design: .rounded, weight: .bold))
                        .padding(.horizontal, 10).frame(minWidth: 88, minHeight: 48)
                        .background(Palette.paper, in: Capsule()).contentShape(Capsule())
                }.buttonStyle(PressStyle()).accessibilityLabel("Exit \(kind.title), return to rooms")
                    .accessibilityHint("Discards this unfinished attempt without using a life. Saved successful rooms remain safe.")
                    .accessibilityIdentifier("activityExit")
                Spacer(minLength: 0)
                Button { confirmRestart = true } label: {
                    Image(systemName: "arrow.counterclockwise").accessibilityHidden(true).frame(width: 48, height: 48)
                        .background(Palette.paper, in: Circle()).contentShape(Circle())
                }.accessibilityLabel("Restart \(kind.title)").accessibilityIdentifier("activityRestart")
                Button { paused.toggle() } label: {
                    Image(systemName: paused ? "play.fill" : "pause.fill").accessibilityHidden(true).frame(width: 48, height: 48)
                        .background(Palette.paper, in: Circle()).contentShape(Circle())
                }.accessibilityLabel(paused ? "Resume activity" : "Pause activity")
                    .accessibilityIdentifier("activityPause")
            }.foregroundStyle(Palette.night).background(Palette.paper.opacity(0.85), in: Capsule())
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    if !compact { SectionEyebrow(text: "Restoration room · \(min(1000, max(1, level)))") }
                    Text(kind.title).font(compact ? .system(size: 20, weight: .heavy, design: .rounded) : .system(.title2, design: .rounded, weight: .heavy))
                        .foregroundStyle(Palette.night).accessibilityIdentifier("activityTitle")
                }
                Spacer(minLength: 8)
                if compact {
                    Text("\(min(1000, max(1, level)))").font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(kind.activityAccent).accessibilityLabel("Challenge \(min(1000, max(1, level)))")
                } else {
                    Image(systemName: kind.symbol).font(.system(size: 29, weight: .bold))
                        .foregroundStyle(kind.activityAccent).accessibilityHidden(true)
                }
            }.frame(minHeight: compact ? 30 : 0)
            ZStack {
                activity.id(restartID).allowsHitTesting(!paused && !helpOpen).accessibilityHidden(paused || helpOpen)
                if paused {
                    VStack(spacing: compact ? 10 : 14) {
                        if !compact { Image(systemName: "pause.circle.fill").accessibilityHidden(true).font(.system(size: 42)).foregroundStyle(kind.activityAccent) }
                        Text("Room paused").font(compact ? .system(size: 22, weight: .bold, design: .rounded) : .system(.title2, design: .rounded, weight: .bold))
                        Text("This attempt stays here while the app remains open. Leaving this room or closing the app discards it; saved successes stay safe.")
                            .font(compact ? .system(size: 17, design: .rounded) : .subheadline)
                            .multilineTextAlignment(.center).foregroundStyle(Palette.mint)
                        PrimaryButton(title: compact ? "Resume" : "Continue playing", symbol: "play.fill", id: "activityResume") { paused = false }
                    }.padding(24).background(Palette.paper, in: RoundedRectangle(cornerRadius: 28))
                        .shadow(color: Palette.night.opacity(0.18), radius: 18, y: 10).padding(16)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            if !compact {
                Text("No life cost. Exiting discards this attempt; save a successful result to keep it.")
                    .font(.system(.caption, design: .rounded)).foregroundStyle(Palette.mint)
                    .fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.center)
            }
        }.padding(.horizontal, 18).padding(.bottom, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: paused)
    }

    @ViewBuilder private var activity: some View {
        switch kind {
        case .canal: CanalRoom(level: level, paused: paused || helpOpen, complete: finish)
        case .fireflies: FireflyRoom(level: level, paused: paused || helpOpen, complete: finish)
        case .windmill: WindmillRoom(level: level, paused: paused || helpOpen, complete: finish)
        case .observatory: ObservatoryRoom(level: level, paused: paused || helpOpen, complete: finish)
        }
    }
    private func finish(_ score: Int) {
        guard !deliveredResult else { return }
        deliveredResult = true
        onComplete(score)
    }
}

private extension IslandActivityKind {
    var activityAccent: Color {
        switch self {
        case .canal: return Color(hex: 0x257D99)
        case .fireflies: return Color(hex: 0x817420)
        case .windmill: return Color(hex: 0x378161)
        case .observatory: return Color(hex: 0x71639E)
        }
    }
}

private struct ActivityInstruction: View {
    let text: String
    @Environment(\.activityCompactLayout) private var compact
    @State private var showHelp = false
    @Environment(\.activityHelpChanged) private var helpChanged
    var body: some View {
        Group {
            if compact {
                Button { showHelp = true } label: {
                    Label("How to play · exit rules", systemImage: "questionmark.circle.fill")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Palette.night).frame(maxWidth: .infinity, minHeight: 48)
                        .background(Palette.paper, in: Capsule())
                }.buttonStyle(PressStyle()).accessibilityIdentifier("activityHelp")
                    .accessibilityHint("Opens large text instructions. Swipe between steps.")
            } else {
                Text(text).font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Palette.mint).multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity)
            }
        }.sheet(isPresented: $showHelp) { ActivityHelpSheet(text: text).presentationDetents([.large]) }
            .onChange(of: showHelp) { _, visible in helpChanged(visible) }
            .onDisappear { helpChanged(false) }
    }
}

private struct ActivityHelpSheet: View {
    let text: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    private var steps: [String] {
        let play: [String]
        if text.hasPrefix("Tap a pipe") {
            play = ["Tap a pipe to turn it clockwise.", "Blue pipes have water flowing.", "Water enters the top-left pipe.", "The garden outlet is at bottom-right.", "Connect water before turns run out."]
        } else if text.hasPrefix("Watch the numbered") {
            play = ["Watch the numbered lanterns.", "Repeat the lights in the same order.", "One new light appears each round.", "Two mistakes end the attempt."]
        } else if text.hasPrefix("Guided timing") {
            play = ["Guided timing is on for VoiceOver.", "Tap Charge for each workshop battery."]
        } else if text.hasPrefix("Tap Charge") {
            play = ["Tap Start to begin the windmill.", "Watch the golden pointer.", "Tap Charge inside the mint wedge.", "Three misses end the attempt.", "Finish before the timer runs out."]
        } else {
            play = ["Swipe one star into the empty space.", "Arrange numbers from left to right.", "Continue row by row, top to bottom.", "Leave the empty space last.", "Finish within the move budget."]
        }
        return play + ["No lives are used in this room.", "Leaving discards this attempt.", "Closing the app discards this attempt.", "Save a win to keep its result."]
    }
    var body: some View {
        VStack(spacing: 18) {
            Text("How to play").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(Palette.night)
            Text("Step \(page + 1) of \(steps.count)").font(.system(size: 17, design: .rounded)).foregroundStyle(Palette.mint)
            Spacer(minLength: 0)
            Text(steps[page]).font(.system(.body, design: .rounded)).foregroundStyle(Palette.night)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("activityHelpStep")
            Spacer(minLength: 0)
            Text("Swipe for the next step").font(.system(size: 17, design: .rounded)).foregroundStyle(Palette.mint)
            Button("Done") { dismiss() }.font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(Palette.night).frame(maxWidth: .infinity, minHeight: 60)
                .background(Palette.sunlight, in: Capsule()).accessibilityIdentifier("activityHelpDone")
        }.padding(24).frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.paper).contentShape(Rectangle())
            .highPriorityGesture(DragGesture(minimumDistance: 35).onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                changePage(value.translation.width < 0 ? 1 : -1)
            }).accessibilityElement(children: .contain)
            .accessibilityAdjustableAction { direction in changePage(direction == .increment ? 1 : -1) }
    }
    private func changePage(_ delta: Int) {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { page = min(steps.count - 1, max(0, page + delta)) }
    }
}

private struct ActivityMeter: View {
    let title: String
    let value: String
    let symbol: String
    @Environment(\.activityCompactLayout) private var compact
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).foregroundStyle(Palette.gold).accessibilityHidden(true)
            Text(title).foregroundStyle(Palette.mint)
            Spacer(minLength: 6)
            Text(value).fontWeight(.bold).monospacedDigit().foregroundStyle(Palette.night)
        }.font(compact ? .system(size: 17, design: .rounded) : .system(.subheadline, design: .rounded)).padding(12)
            .background(Palette.paper, in: RoundedRectangle(cornerRadius: 15))
            .accessibilityElement(children: .combine)
    }
}

private struct ActivityOutcome: View {
    let won: Bool
    let title: String
    let detail: String
    let score: Int
    let retry: () -> Void
    let complete: (Int) -> Void
    @State private var submitted = false
    @Environment(\.activityCompactLayout) private var compact
    var body: some View {
        VStack(spacing: compact ? 10 : 15) {
            Image(systemName: won ? "checkmark.seal.fill" : "arrow.counterclockwise.circle.fill").accessibilityHidden(true)
                .font(.system(size: 42)).foregroundStyle(won ? Color(hex: 0x378161) : Palette.gold)
            Text(title).font(compact ? .system(size: 21, weight: .heavy, design: .rounded) : .system(.title2, design: .rounded, weight: .heavy))
                .foregroundStyle(Palette.night).multilineTextAlignment(.center)
                .accessibilityIdentifier("activityResult")
            Text(detail).font(compact ? .system(size: 17, design: .rounded) : .system(.subheadline, design: .rounded)).foregroundStyle(Palette.mint)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            if won {
                Text("Score \(score)").font(compact ? .system(size: 17, weight: .bold, design: .rounded) : .system(.headline, design: .rounded)).foregroundStyle(Palette.gold)
                PrimaryButton(title: compact ? "Save" : "Save result & return", symbol: "checkmark", id: "activityCollect") {
                    guard !submitted else { return }
                    submitted = true; complete(score)
                }.disabled(submitted).accessibilityLabel("Save result and return to rooms")
            } else {
                PrimaryButton(title: compact ? "Try again" : "Try this room again", symbol: "arrow.counterclockwise", id: "activityRetry", action: retry)
            }
        }.padding(24).frame(maxWidth: 370)
            .background(Palette.paper.opacity(0.98), in: RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.9), lineWidth: 2))
            .shadow(color: Palette.night.opacity(0.23), radius: 18, y: 10).padding(12)
    }
}

private struct CanalRoom: View {
    let level: Int
    let paused: Bool
    let complete: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var game: GameModel
    @Environment(\.activityCompactLayout) private var compact
    @State private var run: CanalWorksRun
    @State private var tileTurns: [Int: Int] = [:]
    init(level: Int, paused: Bool, complete: @escaping (Int) -> Void) {
        self.level = level; self.paused = paused; self.complete = complete
        _run = State(initialValue: CanalWorksRun(level: level))
    }
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                ActivityInstruction(text: "Tap a pipe to turn it clockwise. Connect the blue inlet to the garden outlet before turns run out.")
                ActivityMeter(title: "Turns left", value: "\(run.movesRemaining)", symbol: "arrow.trianglehead.clockwise")
                    .accessibilityIdentifier("canalMoves")
                HStack {
                    Label("TOP-LEFT IN", systemImage: "drop.fill").foregroundStyle(Color(hex: 0x257D99))
                    Spacer()
                    Label("BOTTOM-RIGHT OUT", systemImage: "leaf.fill").foregroundStyle(Palette.night)
                }.font(compact ? .system(size: 12, weight: .bold, design: .rounded) : .system(.caption2, design: .rounded, weight: .bold))
                GeometryReader { geometry in
                    let side = min(geometry.size.width / CGFloat(run.width), geometry.size.height / CGFloat(run.height))
                    let origin = CGPoint(x: (geometry.size.width - side * CGFloat(run.width)) / 2,
                                         y: (geometry.size.height - side * CGFloat(run.height)) / 2)
                    let wet = run.connectedCells
                    ForEach(run.pipes.indices, id: \.self) { index in
                        Button {
                            guard !paused else { return }
                            if run.turnPipe(at: index) { tileTurns[index, default: 0] += 1; game.effect("tap"); game.feedback(.light) }
                        } label: {
                            PipeTile(mask: run.pipes[index], wet: wet.contains(index), quarterTurns: tileTurns[index, default: 0])
                                .padding(3).frame(width: side, height: side)
                        }.buttonStyle(PressStyle())
                            .position(x: origin.x + (CGFloat(index % run.width) + 0.5) * side,
                                      y: origin.y + (CGFloat(index / run.width) + 0.5) * side)
                            .accessibilityLabel("Pipe, row \(index / run.width + 1), column \(index % run.width + 1)")
                            .accessibilityValue("\(portDescription(run.pipes[index])). \(wet.contains(index) ? "Water flowing" : "Dry")")
                            .accessibilityHint(index == 0 ? "Water enters this top-left pipe from the west. Turns clockwise by a quarter turn." : index == run.outlet ? "Water exits this bottom-right pipe to the east. Turns clockwise by a quarter turn." : "Turns this pipe clockwise by a quarter turn")
                            .accessibilityIdentifier("canalPipe\(index)")
                    }
                }.frame(minHeight: CGFloat(run.height) * 44, maxHeight: .infinity).frame(maxWidth: 450)
                    .background(Color(hex: 0xBDDCCE).opacity(0.45), in: RoundedRectangle(cornerRadius: 25))
                    .accessibilityElement(children: .contain).accessibilityIdentifier("canalBoard")
                if !compact { HStack(spacing: 12) {
                    SpriteView(index: 1).frame(width: 38, height: 42)
                    Text(run.won ? "The terrace has fresh water." : "Follow the blue flow; every connected pipe lights up.")
                        .font(.system(.caption, design: .rounded, weight: .medium)).foregroundStyle(Palette.mint)
                    Spacer(minLength: 0)
                } }
            }.accessibilityHidden(run.finished)
            if run.finished {
                ActivityOutcome(won: run.won, title: run.won ? "Water reaches the garden!" : "The canal needs another plan",
                                detail: run.won ? "Lio can restore another terrace with this water." : "The turn budget is used. Restart freely and follow the connected blue pipes.",
                                score: run.score, retry: { run = CanalWorksRun(level: level); tileTurns = [:] }, complete: complete)
            }
        }.animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: run.won)
    }
    private func portDescription(_ mask: Int) -> String {
        zip([1, 2, 4, 8], ["north", "east", "south", "west"]).filter { mask & $0.0 != 0 }.map(\.1).joined(separator: " and ")
    }
}

private struct PipeTile: View {
    let mask: Int
    let wet: Bool
    let quarterTurns: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var drawingMask: Int {
        var base = mask
        for _ in 0..<(quarterTurns % 4) { base = ((base >> 1) | (base << 3)) & 15 }
        return base
    }
    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: side * 0.16).fill(Color(hex: 0x8AAE94)).offset(y: 4)
                RoundedRectangle(cornerRadius: side * 0.16)
                    .fill(LinearGradient(colors: [Color(hex: 0xFFFFEF), Color(hex: 0xDFE8CC)], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: side * 0.16).stroke(.white.opacity(0.75), lineWidth: 1)
                Canvas { context, size in
                    var path = Path()
                    let middle = CGPoint(x: size.width / 2, y: size.height / 2)
                    for (port, end) in [(1, CGPoint(x: middle.x, y: 0)), (2, CGPoint(x: size.width, y: middle.y)),
                                        (4, CGPoint(x: middle.x, y: size.height)), (8, CGPoint(x: 0, y: middle.y))] where drawingMask & port != 0 {
                        path.move(to: middle); path.addLine(to: end)
                    }
                    context.stroke(path, with: .color(Color(hex: 0x577666)), style: StrokeStyle(lineWidth: side * 0.31, lineCap: .round))
                    context.stroke(path, with: .color(wet ? Color(hex: 0x318CA8) : Color(hex: 0xBAC9B5)), style: StrokeStyle(lineWidth: side * 0.22, lineCap: .round))
                    context.stroke(path, with: .color(.white.opacity(wet ? 0.45 : 0.3)), style: StrokeStyle(lineWidth: side * 0.035, lineCap: .round))
                }.padding(4).rotationEffect(.degrees(Double(quarterTurns) * 90))
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: quarterTurns)
                Circle().fill(wet ? Color(hex: 0x7EC7D6) : Color(hex: 0xD0D9C6)).frame(width: side * 0.23, height: side * 0.23)
                    .overlay(Circle().stroke(Color(hex: 0x577666).opacity(0.4), lineWidth: 1))
            }
        }.accessibilityHidden(true)
    }
}

private struct FireflyRoom: View {
    let level: Int
    let paused: Bool
    let complete: (Int) -> Void
    @EnvironmentObject private var game: GameModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.activityCompactLayout) private var compact
    @State private var run: FireflySignalRun
    @State private var glowing: Int? = nil
    @State private var playback: Task<Void, Never>? = nil
    @State private var playbackID = UUID()
    private let names = ["Sun", "Leaf", "Sky", "Rose"]
    private let colors: [Color] = [Color(hex: 0xBE811B), Color(hex: 0x3D956A), Color(hex: 0x3B8DAC), Color(hex: 0xC56F80)]
    init(level: Int, paused: Bool, complete: @escaping (Int) -> Void) {
        self.level = level; self.paused = paused; self.complete = complete
        _run = State(initialValue: FireflySignalRun(level: level))
    }
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                ActivityInstruction(text: "Watch the numbered lanterns, then tap them in the same order. Each round adds one light. Two mistakes end the attempt.")
                ActivityMeter(title: "Signal round", value: "\(min(run.round + 1, run.rounds)) / \(run.rounds) · \(2 - run.mistakes) chances", symbol: "sparkles")
                Text(compact ? compactStatus : status).font(compact ? .system(size: 18, weight: .bold, design: .rounded) : .system(.headline, design: .rounded)).foregroundStyle(Palette.night)
                    .accessibilityLabel(status)
                    .accessibilityIdentifier("fireflyStatus").accessibilityAddTraits(.updatesFrequently)
                GeometryReader { geometry in
                    let side = min(geometry.size.width / 2, geometry.size.height / 2)
                    let origin = CGPoint(x: (geometry.size.width - side * 2) / 2, y: (geometry.size.height - side * 2) / 2)
                    ForEach(0..<4) { index in
                        Button {
                            guard !paused, run.phase == .answering else { return }
                            let correct = run.selectLight(index)
                            game.effect(correct ? "tap" : "collision")
                            game.feedback(correct ? .light : .medium)
                        } label: {
                            LanternTile(number: index + 1, name: names[index], color: colors[index], glowing: glowing == index)
                                .padding(5).frame(width: side, height: side)
                        }.buttonStyle(PressStyle()).disabled(run.phase != .answering || paused)
                            .position(x: origin.x + (CGFloat(index % 2) + 0.5) * side,
                                      y: origin.y + (CGFloat(index / 2) + 0.5) * side)
                            .accessibilityLabel("Lantern \(index + 1), \(names[index])")
                            .accessibilityValue(glowing == index ? "Lit" : "Waiting")
                            .accessibilityIdentifier("fireflyLight\(index)")
                    }
                }.frame(minHeight: 176, maxHeight: .infinity).frame(maxWidth: 400)
                if run.phase == .ready {
                    PrimaryButton(title: compact ? "Watch" : run.round == 0 && run.mistakes == 0 ? "Watch the first signal" : "Watch this signal", symbol: "eye.fill", id: "fireflyWatch", action: watch)
                } else {
                    Text(run.phase == .answering ? "Your turn: \(run.answerIndex) / \(run.sequence.count) lights repeated" : "Watch carefully · \(run.sequence.count) lights")
                        .font(compact ? .system(size: 17, design: .rounded) : .system(.subheadline, design: .rounded)).foregroundStyle(Palette.mint).frame(minHeight: 60)
                }
            }.accessibilityHidden(run.finished)
            if run.finished {
                ActivityOutcome(won: run.won, title: run.won ? "The island hears your signal!" : "The lanterns lost their rhythm",
                                detail: run.won ? "Lio can guide the rescue boats safely home." : "Replay the sequence freely. Watch both the lantern number and its color.",
                                score: run.score, retry: { stopPlayback(); run = FireflySignalRun(level: level) }, complete: complete)
            }
        }.onChange(of: paused) { _, paused in if paused { stopPlayback() } }
            .onDisappear(perform: stopPlayback)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: glowing)
    }
    private var compactStatus: String {
        switch run.phase {
        case .ready: return run.mistakes > 0 ? "Try again" : "Ready to watch"
        case .watching: return glowing.map { "Lantern \($0 + 1)" } ?? "Remember the order"
        case .answering: return "Your turn"
        case .won: return "Signal complete"
        case .lost: return "Try again"
        }
    }
    private var status: String {
        switch run.phase {
        case .ready: return run.mistakes > 0 ? "One more chance · replay the signal" : "Ready to watch"
        case .watching: return glowing.map { "Lantern \($0 + 1) · \(names[$0])" } ?? "Remember this order"
        case .answering: return "Your turn · repeat the lights"
        case .won: return "Signal complete"
        case .lost: return "Try the signal again"
        }
    }
    private func watch() {
        guard !paused, run.beginPlayback() else { return }
        let id = UUID(); playbackID = id
        let sequence = run.sequence
        playback = Task { @MainActor in
            for index in sequence {
                guard !Task.isCancelled, playbackID == id else { return }
                glowing = index
                if UIAccessibility.isVoiceOverRunning {
                    UIAccessibility.post(notification: .announcement, argument: "Lantern \(index + 1), \(names[index])")
                }
                game.effect("tap")
                try? await Task.sleep(for: .milliseconds(UIAccessibility.isVoiceOverRunning ? 1500 : 650))
                guard !Task.isCancelled, playbackID == id else { return }
                glowing = nil
                try? await Task.sleep(for: .milliseconds(220))
            }
            guard !Task.isCancelled, playbackID == id else { return }
            run.finishPlayback(); playback = nil
        }
    }
    private func stopPlayback() {
        playbackID = UUID(); playback?.cancel(); playback = nil; glowing = nil
        run.interruptPlayback()
    }
}

private struct LanternTile: View {
    let number: Int
    let name: String
    let color: Color
    let glowing: Bool
    @Environment(\.activityCompactLayout) private var compact
    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: 25).fill(Color(hex: 0xA8B8A2)).offset(y: 5)
                RoundedRectangle(cornerRadius: 25).fill(LinearGradient(colors: [Color(hex: 0xFCFFED), Color(hex: 0xDDE8C9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(.white.opacity(0.9), lineWidth: 2))
                if glowing { Circle().fill(color.opacity(0.3)).blur(radius: 10).frame(width: side * 0.8, height: side * 0.8) }
                VStack(spacing: 3) {
                    ZStack {
                        Capsule().stroke(Color(hex: 0x756144), lineWidth: 4).frame(width: side * 0.29, height: side * 0.36).offset(y: -side * 0.12)
                        RoundedRectangle(cornerRadius: 15).fill(LinearGradient(colors: [color.opacity(glowing ? 0.95 : 0.27), color.opacity(glowing ? 0.65 : 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: side * 0.43, height: side * 0.45)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(color.opacity(0.5), lineWidth: 3))
                        Image(systemName: "sparkle").font(.system(size: side * 0.27, weight: .bold)).foregroundStyle(glowing ? .white : color)
                            .shadow(color: glowing ? color : .clear, radius: 10)
                        Capsule().fill(Color(hex: 0x756144)).frame(width: side * 0.47, height: 8).offset(y: side * 0.23)
                    }.frame(height: side * 0.6)
                    Text("\(number) · \(name)").font(compact ? .system(size: 15, weight: .bold, design: .rounded) : .system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(Palette.night)
                }
            }
        }.accessibilityHidden(true)
    }
}

private struct WindmillRoom: View {
    let level: Int
    let paused: Bool
    let complete: (Int) -> Void
    @EnvironmentObject private var game: GameModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.activityCompactLayout) private var compact
    @State private var run: WindmillRhythmRun
    @State private var guided = UIAccessibility.isVoiceOverRunning
    @State private var lastHit: Bool? = nil
    private let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    init(level: Int, paused: Bool, complete: @escaping (Int) -> Void) {
        self.level = level; self.paused = paused; self.complete = complete
        _run = State(initialValue: WindmillRhythmRun(level: level))
    }
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                ActivityInstruction(text: guided ? "Guided timing is on for VoiceOver. Tap Charge to fill each workshop battery." : "Tap Charge when the golden pointer reaches the mint wedge. Three misses or an empty timer ends the attempt.")
                ActivityMeter(title: "Workshop power", value: "\(run.hits) / \(run.targetHits) · \(3 - run.misses) chances", symbol: "bolt.fill")
                GeometryReader { geometry in
                    let side = min(geometry.size.width, geometry.size.height)
                    ZStack {
                        Circle().fill(Color(hex: 0xACCBB1)).offset(y: 7)
                        Circle().fill(LinearGradient(colors: [Color(hex: 0xFFFFF0), Color(hex: 0xD7E8C4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: 2))
                        Circle().stroke(Color(hex: 0x728F7A).opacity(0.35), lineWidth: side * 0.08).padding(side * 0.08)
                        Circle().trim(from: max(0, run.targetCenter - run.targetHalfWidth), to: min(1, run.targetCenter + run.targetHalfWidth))
                            .stroke(Color(hex: 0x3C9674), style: StrokeStyle(lineWidth: side * 0.095, lineCap: .round))
                            .rotationEffect(.degrees(-90)).padding(side * 0.08)
                        ForEach(0..<4) { blade in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [.white, Color(hex: 0x99BFB6)], startPoint: .top, endPoint: .bottom))
                                .frame(width: side * 0.12, height: side * 0.27).offset(y: -side * 0.18)
                                .rotationEffect(.degrees(Double(blade) * 90 + (reduceMotion ? 0 : run.elapsed * 48)))
                        }
                        Circle().fill(Color(hex: 0xEFC974)).frame(width: side * 0.15, height: side * 0.15)
                            .shadow(color: Palette.night.opacity(0.2), radius: 2, y: 3)
                        ZStack {
                            Capsule().fill(Color(hex: 0xB78023)).frame(width: 7, height: side * 0.31).offset(y: -side * 0.22)
                            Circle().fill(Color(hex: 0xFFDA87)).frame(width: side * 0.095, height: side * 0.095).offset(y: -side * 0.38)
                                .overlay(Circle().stroke(.white, lineWidth: 2).offset(y: -side * 0.38))
                        }.rotationEffect(.degrees(run.pointer * 360))
                    }.frame(width: side, height: side).position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }.frame(minHeight: 110).accessibilityElement(children: .ignore)
                    .accessibilityLabel("Windmill charge dial")
                    .accessibilityValue(guided ? "Guided mode" : run.inWindow ? "Charge window is open" : "Pointer approaching the charge window")
                    .accessibilityIdentifier("windmillDial")
                HStack {
                    Label(guided ? "Guided timing" : "\(run.remaining) seconds", systemImage: guided ? "accessibility" : "timer")
                    Spacer()
                    Text(lastHit.map { $0 ? "Clean charge!" : "Miss · wait for mint" } ?? "Ready when you are")
                }.font(compact ? .system(size: 15, weight: .semibold, design: .rounded) : .system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(Palette.mint)
                PrimaryButton(title: compact ? (run.started ? "Charge" : "Start") : (run.started ? "Charge the workshop" : "Start windmill"), symbol: "bolt.fill", id: "windmillCharge") {
                    guard !paused else { return }
                    if !run.started { run.start(); return }
                    lastHit = run.charge(guided: guided)
                    game.effect(lastHit == true ? "coin" : "collision")
                    game.feedback(lastHit == true ? .light : .medium)
                }
            }.accessibilityHidden(run.finished)
            if run.finished {
                ActivityOutcome(won: run.won, title: run.won ? "The workshop has power!" : "The windmill needs your timing",
                                detail: run.won ? "Lio can run the tools that rebuild the island." : "Start again freely. Wait for the mint wedge before tapping Charge.",
                                score: run.score, retry: { run = WindmillRhythmRun(level: level); lastHit = nil }, complete: complete)
            }
        }.onReceive(timer) { _ in
            guard !paused, scenePhase == .active, !guided else { return }
            run.tick(0.04)
        }.onReceive(NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)) { _ in
            guided = UIAccessibility.isVoiceOverRunning
        }
    }
}

private struct ObservatoryRoom: View {
    let level: Int
    let paused: Bool
    let complete: (Int) -> Void
    @EnvironmentObject private var game: GameModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.activityCompactLayout) private var compact
    @State private var run: ObservatoryRun
    init(level: Int, paused: Bool, complete: @escaping (Int) -> Void) {
        self.level = level; self.paused = paused; self.complete = complete
        _run = State(initialValue: ObservatoryRun(level: level))
    }
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                ActivityInstruction(text: "Swipe a star tile into the empty space. Arrange the numbers from left to right, top to bottom; leave the gap last.")
                ActivityMeter(title: "Chart alignment", value: "\(run.aligned) / \(run.goalCount) · \(run.movesRemaining) moves", symbol: "moon.stars.fill")
                    .accessibilityIdentifier("observatoryMoves")
                GeometryReader { geometry in
                    let side = min(geometry.size.width / CGFloat(run.width), geometry.size.height / CGFloat(run.width))
                    let origin = CGPoint(x: (geometry.size.width - side * CGFloat(run.width)) / 2,
                                         y: (geometry.size.height - side * CGFloat(run.width)) / 2)
                    ForEach(run.tiles, id: \.self) { tile in
                        let index = run.tiles.firstIndex(of: tile)!
                        let x = origin.x + (CGFloat(index % run.width) + 0.5) * side
                        let y = origin.y + (CGFloat(index / run.width) + 0.5) * side
                        if tile == 0 {
                            RoundedRectangle(cornerRadius: 16).fill(Color(hex: 0x6F6889).opacity(0.15))
                                .overlay(Image(systemName: "arrow.up.and.down.and.arrow.left.and.right").foregroundStyle(Color(hex: 0x73698D)))
                                .padding(4).frame(width: side, height: side).position(x: x, y: y)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("Empty space, row \(index / run.width + 1), column \(index % run.width + 1)")
                                .accessibilityIdentifier("observatoryGap")
                        } else {
                            Button { move(tile) } label: {
                                StarChartTile(number: tile, aligned: tile == index + 1).padding(4).frame(width: side, height: side)
                            }.buttonStyle(PressStyle()).position(x: x, y: y)
                                .highPriorityGesture(DragGesture(minimumDistance: 12).onEnded { value in
                                    let direction: IslandSwipeDirection
                                    if abs(value.translation.width) > abs(value.translation.height) {
                                        direction = value.translation.width > 0 ? .right : .left
                                    } else { direction = value.translation.height > 0 ? .down : .up }
                                    move(tile, direction: direction)
                                })
                                .accessibilityLabel("Star tile \(tile), row \(index / run.width + 1), column \(index % run.width + 1)")
                                .accessibilityValue(tile == index + 1 ? "Aligned" : "Out of place")
                                .accessibilityHint("Swipe toward the empty space, or double tap to slide if next to it")
                                .accessibilityIdentifier("observatoryTile\(tile)")
                        }
                    }
                }.frame(minHeight: CGFloat(run.width) * 44, maxHeight: .infinity).frame(maxWidth: 450)
                    .background(Color(hex: 0xDDD9ED).opacity(0.7), in: RoundedRectangle(cornerRadius: 25))
                    .accessibilityElement(children: .contain).accessibilityIdentifier("observatoryBoard")
                    .animation(reduceMotion ? nil : .spring(response: 0.24, dampingFraction: 0.88), value: run.tiles)
                if !compact { Text("The final chart reads 1 → \(run.goalCount). Gold corners mark stars already aligned.")
                    .font(.system(.caption, design: .rounded)).foregroundStyle(Palette.mint).multilineTextAlignment(.center) }
            }.accessibilityHidden(run.finished)
            if run.finished {
                ActivityOutcome(won: run.won, title: run.won ? "A new route is in the stars!" : "The chart needs another route",
                                detail: run.won ? "Lio has a safe night route to the next island." : "No lives are lost. Restart freely and slide one star at a time into the gap.",
                                score: run.score, retry: { run = ObservatoryRun(level: level) }, complete: complete)
            }
        }
    }
    private func move(_ tile: Int, direction: IslandSwipeDirection? = nil) {
        guard !paused else { return }
        if run.slide(tile: tile, direction: direction) {
            game.effect("tap"); game.feedback(.light)
        }
    }
}

private struct StarChartTile: View {
    let number: Int
    let aligned: Bool
    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(Color(hex: 0x777193)).offset(y: 4)
                RoundedRectangle(cornerRadius: 16).fill(LinearGradient(colors: [Color(hex: 0xFFFFFA), Color(hex: 0xD9D4EE)], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 16).stroke(aligned ? Color(hex: 0xBB8B35) : .white.opacity(0.8), lineWidth: aligned ? 2 : 1)
                Image(systemName: number.isMultiple(of: 3) ? "moon.stars.fill" : "star.fill")
                    .font(.system(size: side * 0.5)).foregroundStyle(Color(hex: 0x9185AF).opacity(0.24)).offset(x: side * 0.1, y: -side * 0.1)
                Text("\(number)").font(.system(size: max(18, side * 0.33), weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: 0x4F456F))
            }
        }.accessibilityHidden(true)
    }
}
