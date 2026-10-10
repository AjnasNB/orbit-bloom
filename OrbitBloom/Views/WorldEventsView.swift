import SwiftUI

struct WorldEventsView: View {
    @EnvironmentObject var game: GameModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject var clock: WorldEventClock
    let onChoose: (IslandRoom) -> Void
    @State private var selectedEvent = 0
    @State private var selectedPart = 0
    @State private var tick = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // Read timer state for rollover and the 15-minute clock expiry.
                let _ = tick
                let now = clock.now
                let windows = now.map(WorldEvent.windows) ?? []
                let compact = textSize >= .xxxLarge || geometry.size.height < 620
                let parts = compact ? 3 : 1
                let index = min(selectedEvent, max(0, windows.count - 1))
                let part = min(selectedPart, parts - 1)
                VStack(spacing: compact ? 10 : 16) {
                    if !compact {
                        Image(systemName: "globe.europe.africa.fill").font(.system(size: 40)).foregroundStyle(Palette.mint).accessibilityHidden(true)
                        Text(clock.status).font(.system(.caption, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center).foregroundStyle(Palette.mint).accessibilityIdentifier("worldClockStatus")
                    }
                    if let now, !windows.isEmpty {
                        let event = windows[index]
                        let active = event.isActive(at: now)
                        let progress = game.journey.events[event.id, default: 0]
                        let claimed = game.journey.claimedEvents.contains(event.id)
                        VStack(alignment: .leading, spacing: 12) {
                            if !compact || part == 0 {
                                Text(active ? "LIVE WORLD EVENT" : "NEXT WORLD EVENT")
                                    .font(.system(.caption2, design: .rounded, weight: .heavy)).tracking(1).foregroundStyle(Palette.mint)
                                Text(event.title).font(.system(compact ? .subheadline : .title2, design: .rounded, weight: .heavy))
                                    .foregroundStyle(Palette.night).fixedSize(horizontal: false, vertical: true)
                                Text(active ? "Ends \(event.ends.formatted(date: .abbreviated, time: .shortened))" : "Starts \(event.starts.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(Palette.mint)
                                    .fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("eventTiming")
                                if compact { Text("Times use your timezone.").font(.caption2).foregroundStyle(Palette.mint) }
                            }
                            if !compact || part == 1 {
                                if compact { Text("Event goal").font(.system(.subheadline, design: .rounded, weight: .heavy)).foregroundStyle(Palette.night) }
                                Text(goal(event)).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(Palette.night)
                                    .fixedSize(horizontal: false, vertical: true)
                                Label("\(min(3, progress))/3 · \(event.tool.title)", systemImage: "sparkles")
                                    .font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(Palette.mint)
                                    .fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("eventProgress")
                                if compact {
                                    Text(active ? "Finish and collect before the window ends." : "Progress counts after the event starts.")
                                        .font(.caption2).foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            if !compact || part == 2 {
                                if compact {
                                    Text(active ? "Live bonus" : "Upcoming bonus").font(.system(.subheadline, design: .rounded, weight: .heavy)).foregroundStyle(Palette.night)
                                }
                                Text(compact ? "Optional. Rooms stay open after events end." : "Optional bonus. Rooms stay open when events end. All countries follow the same UTC windows; displayed times use your timezone.")
                                    .font(.caption2).foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
                                action(event, active: active, progress: progress, claimed: claimed, compact: compact)
                                if compact {
                                    Text(clock.status).font(.caption2).foregroundStyle(Palette.mint)
                                        .fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("worldClockStatus")
                                }
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(compact ? 14 : 22)
                            .background(.white, in: RoundedRectangle(cornerRadius: 24))
                        Spacer(minLength: 0)
                        pageStatus(index: index, part: part, parts: parts, count: windows.count)
                    } else {
                        Text("Rooms work offline. Connect for world event bonuses.").font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(Palette.night).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                        Text(clock.status).font(.caption2).foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("worldClockStatus")
                        Button("Retry clock") { Task { await clock.refresh() } }
                            .font(.system(.subheadline, design: .rounded, weight: .bold)).frame(minHeight: 48)
                            .buttonStyle(.borderedProminent).tint(Palette.mint).accessibilityIdentifier("retryWorldClock")
                        Spacer(minLength: 0)
                    }
                }.padding(compact ? 14 : 20).frame(maxWidth: 600).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Palette.paper).contentShape(Rectangle())
                    .highPriorityGesture(DragGesture(minimumDistance: 35).onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height), !windows.isEmpty else { return }
                        turnPage(value.translation.width < 0 ? 1 : -1, index: index, part: part, parts: parts, count: windows.count)
                    }).accessibilityElement(children: .contain).accessibilityIdentifier("worldEvents")
            }
            .onReceive(timer) { tick = $0 }.task { await clock.refresh() }
            .navigationTitle("World events").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
    private func goal(_ event: WorldEvent) -> String {
        if event.room == "farm" { return "Harvest 3 crops during this window." }
        if event.room == "rally" { return "Finish 3 deliveries during this window." }
        return "Clear 3 new room challenges during this window."
    }
    @ViewBuilder private func action(_ event: WorldEvent, active: Bool, progress: Int, claimed: Bool, compact: Bool) -> some View {
        if active && progress >= 3 {
            Button(claimed ? "Reward saved" : "Collect \(event.tool.title)") { game.claimWorldEvent(event) }
                .font(.system(.subheadline, design: .rounded, weight: .bold)).frame(minHeight: 48)
                .buttonStyle(.borderedProminent).tint(Palette.mint).disabled(claimed).accessibilityIdentifier("claimWorldEvent")
        } else if let room = IslandRoom(rawValue: event.room) {
            Button { dismiss(); onChoose(room) } label: {
                Label(compact ? "Enter room" : "Enter \(room.title)", systemImage: room.symbol)
                    .font(.system(.subheadline, design: .rounded, weight: .bold)).fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }.buttonStyle(.borderedProminent).tint(Palette.mint)
                .accessibilityLabel("Enter \(room.title). \(active ? "Event is active" : "Event is upcoming; play now without event progress")")
                .accessibilityIdentifier("eventEnterRoom")
        }
    }
    private func pageStatus(index: Int, part: Int, parts: Int, count: Int) -> some View {
        Text("Swipe · \(index * parts + part + 1)/\(count * parts)").font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(Palette.mint)
            .frame(maxWidth: .infinity, minHeight: 24).accessibilityIdentifier("worldEventPages")
            .accessibilityLabel("World event pages").accessibilityValue("Page \(index * parts + part + 1) of \(count * parts)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: turnPage(1, index: index, part: part, parts: parts, count: count)
                case .decrement: turnPage(-1, index: index, part: part, parts: parts, count: count)
                @unknown default: break
                }
            }
    }
    private func turnPage(_ offset: Int, index: Int, part: Int, parts: Int, count: Int) {
        let next = min(count * parts - 1, max(0, index * parts + part + offset))
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            selectedEvent = next / parts; selectedPart = next % parts
        }
    }
}
