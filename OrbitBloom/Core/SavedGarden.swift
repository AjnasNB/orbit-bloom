import Foundation

// Reject corrupt dates before countdowns convert their intervals to integers.
// Keep a broad calendar range so offline saves do not depend on today's clock.
private func validSaveDate(_ date: Date) -> Bool {
    let seconds = date.timeIntervalSince1970
    return seconds.isFinite && (0...253_402_300_799).contains(seconds)
}

/// The same complete wallet is used for local checkpoints and Apple cloud saves.
/// Optional fields retain compatibility with the first two local save formats.
public struct GardenWallet: Codable {
    public var progress: Progress
    public var ecosystem: Ecosystem
    public var session: GameEngine.Snapshot?
    public var charged: Bool?
    public var assistance: Assistance?
    public var journey: IslandJourney?

    public init(progress: Progress = Progress(), ecosystem: Ecosystem = Ecosystem(),
                session: GameEngine.Snapshot? = nil, charged: Bool? = false,
                assistance: Assistance? = Assistance(), journey: IslandJourney? = nil) {
        self.progress = progress; self.ecosystem = ecosystem; self.session = session
        self.charged = charged; self.assistance = assistance
        self.journey = journey
    }

    public var isValid: Bool {
        guard journey?.isValid != false else { return false }
        let counts = [progress.stars, progress.coins, progress.boosters, ecosystem.seeds,
                      ecosystem.water, ecosystem.compost, ecosystem.produce, ecosystem.harvested,
                      ecosystem.raceBest, ecosystem.deliveries, ecosystem.lives.reserve]
        guard counts.allSatisfy({ (0...100_000_000).contains($0) }),
              (0...LifeBank.capacity).contains(ecosystem.lives.hearts),
              progress.completed.allSatisfy({ (1...Level.total).contains($0.key) && (0...100_000_000).contains($0.value) }),
              progress.restored.isSubset(of: Set(GardenTask.all.map(\.id))),
              ecosystem.plots.count == 6, ecosystem.plots.map(\.id) == Array(0..<6),
              ecosystem.tools.values.allSatisfy({ (0...100_000_000).contains($0) }),
              ecosystem.creditedTransactions.allSatisfy({ !$0.isEmpty && $0.count <= 100 }),
              ecosystem.creditedTransactions.count <= 20_000 else { return false }
        if let nextAt = ecosystem.lives.nextAt, !validSaveDate(nextAt) { return false }
        guard ecosystem.plots.allSatisfy({ plot in
            (plot.crop == nil && plot.readyAt == nil) ||
                (plot.crop != nil && plot.readyAt.map(validSaveDate) == true)
        }) else { return false }
        if let assistance {
            guard [assistance.freeHints, assistance.shuffles, assistance.blasts].allSatisfy({ (0...100_000_000).contains($0) }),
                  assistance.claimed.isSubset(of: Set(FieldTask.all.map(\.id))) else { return false }
        }
        if let session {
            guard progress.isUnlocked(session.levelID), (0...100_000_000).contains(session.score),
                  let level = Level.savedLevel(id:session.levelID,rulesVersion:session.rulesVersion), session.moves <= level.moves,
                  session.collected.values.allSatisfy({ (0...100_000_000).contains($0) }),
                  session.frost.allSatisfy({ (0..<49).contains($0) }),
                  GameEngine(snapshot: session) != nil else { return false }
        }
        return true
    }

    /// A cloud restore must not remove purchase receipts already credited here.
    /// Resources are never summed across branches: that would duplicate rewards.
    public func canReplace(_ current: GardenWallet) -> Bool {
        isValid && current.ecosystem.creditedTransactions.isSubset(of: ecosystem.creditedTransactions)
    }
}

public struct SavedGarden: Codable, Identifiable {
    public var schema = 1
    public var id: UUID
    public var playerKey: String
    public var savedAt: Date
    public var wallet: GardenWallet
    public init(id: UUID = UUID(), playerKey: String, savedAt: Date = Date(), wallet: GardenWallet) {
        self.id = id; self.playerKey = playerKey; self.savedAt = savedAt; self.wallet = wallet
        // Old clients must reject new active rules rather than reinterpret their goals.
        self.schema = wallet.journey != nil ? 3 : wallet.session?.rulesVersion == 2 ? 2 : 1
    }
    public func encoded() throws -> Data { try JSONEncoder().encode(self) }
    public static func decode(_ data: Data, playerKey: String) -> SavedGarden? {
        guard data.count <= 1_000_000,
              let save = try? JSONDecoder().decode(Self.self, from: data),
              (1...3).contains(save.schema), !(save.schema == 1 && save.wallet.session?.rulesVersion == 2),
              !(save.schema < 3 && save.wallet.journey != nil),
              save.playerKey == playerKey, !playerKey.isEmpty,
              validSaveDate(save.savedAt), save.wallet.isValid else { return nil }
        return save
    }
}
