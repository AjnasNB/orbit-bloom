import SwiftUI
import GameKit
import CryptoKit

struct AppleLeaderboardView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    func makeCoordinator() -> Coordinator { Coordinator { dismiss() } }
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let controller = GKGameCenterViewController(leaderboardID: "com.orbitbloom.atollskills", playerScope: .global, timeScope: .allTime)
        controller.gameCenterDelegate = context.coordinator; return controller
    }
    func updateUIViewController(_ controller: GKGameCenterViewController, context: Context) {}
    final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        let done: () -> Void
        init(done: @escaping () -> Void) { self.done = done }
        func gameCenterViewControllerDidFinish(_ controller: GKGameCenterViewController) { done() }
    }
}

struct RoomRecordsView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var account: PlayerAccount
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appleBoard = false
    @State private var submitting = false
    @State private var status = "Personal bests save with your garden."
    @State private var selectedRoom = 0
    @State private var selectedPart = 0
    @State private var informationPage: Int?

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let compact = textSize >= .xxxLarge || geometry.size.height < 520
                let parts = compact ? 2 : 1
                let roomCount = IslandActivityKind.allCases.count
                let infoCount = compact ? 3 : 1
                let part = min(selectedPart, parts - 1)
                let info = informationPage.map { min($0, infoCount - 1) }
                let page = info.map { roomCount * parts + $0 } ?? (selectedRoom * parts + part)
                let count = roomCount * parts + infoCount
                VStack(spacing: compact ? 12 : 18) {
                    if let info { rankingInformation(part: info, compact: compact) }
                    else {
                        let kind = IslandActivityKind.allCases[min(selectedRoom, roomCount - 1)]
                        if !compact {
                            Image(systemName: "trophy.fill").font(.system(size: 40)).foregroundStyle(Palette.gold).accessibilityHidden(true)
                        }
                        Text(kind.title).font(.system(compact ? .subheadline : .title2, design: .rounded, weight: .heavy))
                            .foregroundStyle(Palette.night).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                        if !compact || part == 0 {
                            Text("Personal best").font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(Palette.mint)
                            Text("\(game.journey.bestScores[kind.rawValue, default: 0])")
                                .font(.system(.title, design: .rounded, weight: .black)).monospacedDigit().foregroundStyle(Palette.mint)
                                .minimumScaleFactor(0.65).lineLimit(1)
                                .accessibilityLabel("Personal best \(game.journey.bestScores[kind.rawValue, default: 0]) points")
                                .accessibilityIdentifier("roomBestScore")
                        }
                        if !compact || part == 1 {
                            Text("\(game.journey.levels[kind.rawValue, default: 0]) challenges completed")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(Palette.night)
                                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                                .accessibilityIdentifier("roomCompletedChallenges")
                            Text("Completed results stay in your saved garden.").font(.caption2).multilineTextAlignment(.center)
                                .foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Spacer(minLength: 0)
                    Text("Swipe · \(page + 1)/\(count)").font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(Palette.mint)
                        .frame(maxWidth: .infinity, minHeight: 24).accessibilityIdentifier("roomRecordPages")
                        .accessibilityLabel("Room record pages").accessibilityValue("Page \(page + 1) of \(count)")
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: turnPage(1, page: page, parts: parts, roomCount: roomCount, infoCount: infoCount)
                            case .decrement: turnPage(-1, page: page, parts: parts, roomCount: roomCount, infoCount: infoCount)
                            @unknown default: break
                            }
                        }
                }.padding(compact ? 14 : 24).frame(maxWidth: 560).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Palette.paper).contentShape(Rectangle())
                    .highPriorityGesture(DragGesture(minimumDistance: 35).onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        turnPage(value.translation.width < 0 ? 1 : -1, page: page, parts: parts, roomCount: roomCount, infoCount: infoCount)
                    }).accessibilityElement(children: .contain).accessibilityIdentifier("roomRecords")
            }.navigationTitle("Room records").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
                .sheet(isPresented: $appleBoard) { AppleLeaderboardView() }
        }
    }

    @ViewBuilder private func rankingInformation(part: Int, compact: Bool) -> some View {
        Text("Atoll Skills").font(.system(compact ? .subheadline : .title2, design: .rounded, weight: .heavy)).foregroundStyle(Palette.night)
        if !compact || part == 0 {
            Text("Four personal bests. One skill score.").font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
        }
        if !compact || part == 1 {
            Text("Coins, lives and purchases never add ranking points.").font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
        }
        if !compact || part == 2 {
            Text(status).font(.caption2).multilineTextAlignment(.center).foregroundStyle(Palette.mint)
                .fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("leaderboardStatus")
            if matchedPlayerKey != nil && !game.testing {
                Button("Apple rankings") { Task { await reportAndOpen() } }
                    .font(.system(.subheadline, design: .rounded, weight: .bold)).frame(minHeight: 48)
                    .buttonStyle(.borderedProminent).tint(Palette.mint).disabled(submitting)
                    .accessibilityLabel("Open worldwide Game Center rankings").accessibilityIdentifier("openAppleLeaderboard")
                if submitting { ProgressView().accessibilityLabel("Sending your skill score to Apple") }
            } else {
                Text("Connect Game Center in Settings for worldwide rankings.").font(.caption2).multilineTextAlignment(.center)
                    .foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    private func turnPage(_ offset: Int, page: Int, parts: Int, roomCount: Int, infoCount: Int) {
        let next = min(roomCount * parts + infoCount - 1, max(0, page + offset))
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            if next < roomCount * parts {
                selectedRoom = next / parts; selectedPart = next % parts; informationPage = nil
            } else { informationPage = next - roomCount * parts }
        }
    }
    private var matchedPlayerKey: String? {
        let player = GKLocalPlayer.local
        guard account.connected, player.isAuthenticated, !player.gamePlayerID.isEmpty else { return nil }
        let key = SHA256.hash(data: Data(player.gamePlayerID.utf8)).map { String(format: "%02x", $0) }.joined()
        return account.playerKey == key && game.saveAccount == key ? key : nil
    }
    @MainActor private func reportAndOpen() async {
        guard !submitting, !game.testing, let key = matchedPlayerKey, game.journey.isValid else { return }
        let player = GKLocalPlayer.local
        let playerID = player.gamePlayerID
        let scores = IslandActivityKind.allCases.map { game.journey.bestScores[$0.rawValue, default: 0] }
        guard scores.allSatisfy({ (0...20_000).contains($0) }) else {
            status = "A saved score cannot be ranked. Your local records stay saved."; return
        }
        let score = scores.reduce(0, +)
        guard (0...80_000).contains(score) else { return }
        submitting = true; status = "Sending skill score to Apple…"
        defer { submitting = false }
        do {
            try await GKLeaderboard.submitScore(score, context: 0, player: player, leaderboardIDs: ["com.orbitbloom.atollskills"])
            guard !Task.isCancelled, GKLocalPlayer.local.isAuthenticated,
                  GKLocalPlayer.local.gamePlayerID == playerID, matchedPlayerKey == key else {
                status = "Apple account changed. Reopen records for the current player."; return
            }
            status = "Skill score sent to Game Center."; appleBoard = true
        } catch {
            guard matchedPlayerKey == key, GKLocalPlayer.local.gamePlayerID == playerID else {
                status = "Apple account changed. Your local records stay saved."; return
            }
            status = "Apple rankings are unavailable. Personal bests remain saved; try again later."
        }
    }
}
