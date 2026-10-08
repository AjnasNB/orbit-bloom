import Foundation

public struct GardenTask: Identifiable {
    public let id: Int
    public let title: String
    public let detail: String
    public let icon: String
    public static let all: [GardenTask] = [
        .init(id: 0, title: "Wake the greenhouse", detail: "A warm home for your very first seedlings.", icon: "house.lodge.fill"),
        .init(id: 1, title: "Plant the moonseed beds", detail: "Little leaves. A whole new beginning.", icon: "leaf.fill"),
        .init(id: 2, title: "Fill the starlight pond", detail: "Bring a little ripple to this quiet moon.", icon: "drop.fill"),
        .init(id: 3, title: "Light the observatory", detail: "A place to watch the coral sunrise.", icon: "sparkles"),
        .init(id: 4, title: "Grow the aurora grove", detail: "Let luminous blossoms find their sky.", icon: "tree.fill"),
        .init(id: 5, title: "Welcome the pollinators", detail: "Your tiny world is ready to come alive.", icon: "ladybug.fill")
    ]
}

public struct Progress: Codable, Equatable {
    public var completed: [Int: Int] = [:]
    public var stars = 0
    public var coins = 160
    public var restored: Set<Int> = []
    public var boosters = 2
    public var hasSeenIntro = false
    public var sound = true
    public var haptics = true
    public var auroraTheme = false
    public init() {}
    public var nextLevel: Int { min(Level.total, (completed.keys.max() ?? 0) + 1) }
    public var chapterComplete: Bool { (1...12).allSatisfy { completed[$0] != nil } }
    public var gardenComplete: Bool { restored.count == GardenTask.all.count }
    @discardableResult public mutating func finish(level: Int, score: Int) -> Bool {
        guard (1...Level.total).contains(level) else { return false }
        let first = completed[level] == nil
        completed[level] = max(completed[level, default: 0], score)
        if first { stars += 1; coins += 120 } else { coins += 30 }
        return first
    }
    @discardableResult public mutating func restore(_ id: Int) -> Bool {
        guard GardenTask.all.contains(where: { $0.id == id }), stars >= 2, !restored.contains(id),
              id == 0 || restored.contains(id - 1) else { return false }
        stars -= 2
        restored.insert(id)
        return true
    }
    @discardableResult public mutating func buyBooster() -> Bool {
        guard coins >= 80 else { return false }
        coins -= 80; boosters += 1; return true
    }
}
