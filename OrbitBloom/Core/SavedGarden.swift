import Foundation

/// The same complete wallet is used for local checkpoints and Apple cloud saves.
/// Optional fields retain compatibility with the first two local save formats.
public struct GardenWallet: Codable {
    public var progress: Progress
    public var ecosystem: Ecosystem
    public var session: GameEngine.Snapshot?
    public var charged: Bool?
    public var assistance: Assistance?

    public init(progress: Progress = Progress(), ecosystem: Ecosystem = Ecosystem(),
                session: GameEngine.Snapshot? = nil, charged: Bool? = false,
                assistance: Assistance? = Assistance()) {
        self.progress = progress; self.ecosystem = ecosystem; self.session = session
        self.charged = charged; self.assistance = assistance
    }

    public var isValid: Bool {
        let counts = [progress.stars, progress.coins, progress.boosters, ecosystem.seeds,
                      ecosystem.water, ecosystem.compost, ecosystem.produce, ecosystem.harvested,
                      ecosystem.raceBest, ecosystem.deliveries, ecosystem.lives.reserve]
        guard counts.allSatisfy({ (0...100_000_000).contains($0) }),
              (0...LifeBank.capacity).contains(ecosystem.lives.hearts),
              progress.completed.allSatisfy({ (1...Level.total).contains($0.key) && $0.value >= 0 }),
              progress.restored.isSubset(of: Set(GardenTask.all.map(\.id))),
              ecosystem.plots.count == 6, ecosystem.plots.map(\.id) == Array(0..<6),
              ecosystem.tools.values.allSatisfy({ (0...100_000_000).contains($0) }),
              ecosystem.creditedTransactions.allSatisfy({ !$0.isEmpty && $0.count <= 100 }),
              ecosystem.creditedTransactions.count <= 20_000 else { return false }
        if let assistance {
            guard [assistance.freeHints, assistance.shuffles, assistance.blasts].allSatisfy({ (0...100_000_000).contains($0) }),
                  assistance.claimed.isSubset(of: Set(FieldTask.all.map(\.id))) else { return false }
        }
        if let session {
            guard progress.isUnlocked(session.levelID), session.score >= 0,
                  session.moves <= Level.campaign[session.levelID - 1].moves,
                  session.collected.values.allSatisfy({ $0 >= 0 }),
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
    }
    public func encoded() throws -> Data { try JSONEncoder().encode(self) }
    public static func decode(_ data: Data, playerKey: String) -> SavedGarden? {
        guard data.count <= 1_000_000,
              let save = try? JSONDecoder().decode(Self.self, from: data),
              save.schema == 1, save.playerKey == playerKey, !playerKey.isEmpty,
              save.savedAt.timeIntervalSince1970.isFinite, save.wallet.isValid else { return nil }
        return save
    }
}
