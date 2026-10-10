import Foundation

public struct LifeBank: Codable, Equatable {
    public static let capacity = 5
    public static let interval: TimeInterval = 1800
    public var hearts = 5
    public var reserve = 0
    public var nextAt: Date?
    public init() {}
    public var total: Int { hearts + reserve }
    public mutating func refresh(at now: Date) {
        guard hearts < Self.capacity else { nextAt = nil; return }
        guard let nextAt else { self.nextAt = now.addingTimeInterval(Self.interval); return }
        guard now >= nextAt else { return }
        let elapsed = now.timeIntervalSince(nextAt)
        guard elapsed.isFinite else { return }
        // Only the missing hearts matter, even after an extremely long absence.
        if elapsed >= Double(Self.capacity - hearts - 1) * Self.interval {
            hearts = Self.capacity; self.nextAt = nil; return
        }
        let count = Int(elapsed / Self.interval) + 1
        hearts = min(Self.capacity, hearts + count)
        self.nextAt = hearts == Self.capacity ? nil : nextAt.addingTimeInterval(Double(count) * Self.interval)
    }
    @discardableResult public mutating func spend(at now: Date) -> Bool {
        refresh(at: now)
        if hearts > 0 { hearts -= 1; if nextAt == nil { nextAt = now.addingTimeInterval(Self.interval) }; return true }
        if reserve > 0 { reserve -= 1; return true }
        return false
    }
    public mutating func rewardWin() { hearts = min(Self.capacity, hearts + 1); if hearts == Self.capacity { nextAt = nil } }
    public mutating func refill() { hearts = Self.capacity; nextAt = nil }
    public func remaining(at now: Date) -> Int {
        let seconds = ceil((nextAt ?? now).timeIntervalSince(now))
        guard seconds.isFinite, seconds > 0 else { return 0 }
        if seconds >= Double(Int.max / 2) { return Int.max / 2 }
        return Int(seconds)
    }
}

public enum GardenTool: String, CaseIterable, Codable, Identifiable {
    case bomb, tnt, mega, rainbow
    public var id: String { rawValue }
    public var title: String { ["bomb":"Bomb", "tnt":"TNT", "mega":"Mega bomb", "rainbow":"Rainbow"][rawValue]! }
    public var detail: String { ["bomb":"Blast a 3×3 patch", "tnt":"Clear a row + column", "mega":"Blast a 5×5 patch", "rainbow":"Clear every matching color"][rawValue]! }
    public var compostCost: Int { ["bomb":2, "tnt":3, "mega":5, "rainbow":6][rawValue]! }
    public var sprite: Int { ["bomb":5, "tnt":6, "mega":7, "rainbow":8][rawValue]! }
}

public enum Crop: String, CaseIterable, Codable, Identifiable {
    case rose, apple
    public var id: String { rawValue }
    public var duration: TimeInterval { self == .rose ? 30 : 45 }
    public var coins: Int { self == .rose ? 35 : 50 }
    public var title: String { self == .rose ? "Coral rose" : "Moon apple" }
    public var sprite: Int { self == .rose ? 3 : 2 }
}
public struct FarmPlot: Codable, Equatable, Identifiable {
    public let id: Int
    public var crop: Crop?
    public var readyAt: Date?
    public func ready(at now: Date) -> Bool { crop != nil && (readyAt ?? .distantFuture) <= now }
    public init(id: Int) { self.id = id }
}

public struct Ecosystem: Codable, Equatable {
    public var lives = LifeBank()
    public var plots = (0..<6).map(FarmPlot.init)
    public var seeds = 8
    public var water = 12
    public var compost = 0
    public var produce = 1
    public var harvested = 0
    public var tools: [GardenTool: Int] = [.bomb:2, .tnt:2, .mega:1, .rainbow:1]
    public var raceBest = 0
    public var deliveries = 0
    public var music = true
    public var creditedTransactions: Set<String> = []
    public init() {}
    @discardableResult public mutating func plant(_ id: Int, crop: Crop, at now: Date) -> Bool {
        guard plots.indices.contains(id), plots[id].crop == nil, seeds > 0, water >= 2 else { return false }
        seeds -= 1; water -= 2; plots[id].crop = crop; plots[id].readyAt = now.addingTimeInterval(crop.duration); return true
    }
    @discardableResult public mutating func waterPlot(_ id: Int, at now: Date) -> Bool {
        guard plots.indices.contains(id), plots[id].crop != nil, !plots[id].ready(at: now), water > 0, let ready = plots[id].readyAt else { return false }
        water -= 1; plots[id].readyAt = max(now, ready.addingTimeInterval(-10)); return true
    }
    public mutating func harvest(_ id: Int, at now: Date) -> Int? {
        guard plots.indices.contains(id), plots[id].ready(at: now), let crop = plots[id].crop else { return nil }
        plots[id] = FarmPlot(id: id); compost += 1; produce += 1; seeds += 1; harvested += 1; return crop.coins
    }
    @discardableResult public mutating func craft(_ tool: GardenTool) -> Bool {
        guard compost >= tool.compostCost else { return false }
        compost -= tool.compostCost; tools[tool, default:0] += 1; return true
    }
    @discardableResult public mutating func credit(_ grant: StoreGrant, transaction: String) -> Bool {
        guard !transaction.isEmpty, !creditedTransactions.contains(transaction) else { return false }
        creditedTransactions.insert(transaction); lives.reserve += grant.lives; return true
    }
}

public struct StoreGrant: Equatable {
    public let coins: Int
    public let lives: Int
    public init(coins: Int = 0, lives: Int = 0) { self.coins = coins; self.lives = lives }
}
public struct StorePack: Identifiable {
    public let id: String
    public let title: String
    public let detail: String
    public let intendedINR: Int
    public let grant: StoreGrant
    public let once: Bool
    public static let all: [StorePack] = [
        .init(id:"com.orbitbloom.coins400", title:"Pocket of coins", detail:"400 coins", intendedINR:99, grant:.init(coins:400), once:false),
        .init(id:"com.orbitbloom.coins1500", title:"Garden chest", detail:"1,500 coins", intendedINR:299, grant:.init(coins:1500), once:false),
        .init(id:"com.orbitbloom.coins3000", title:"Orchard treasury", detail:"3,000 coins", intendedINR:499, grant:.init(coins:3000), once:false),
        .init(id:"com.orbitbloom.coins7000", title:"Moon vault", detail:"7,000 coins", intendedINR:999, grant:.init(coins:7000), once:false),
        .init(id:"com.orbitbloom.lives5", title:"Extra lives", detail:"5 extra lives · never expire", intendedINR:99, grant:.init(lives:5), once:false),
        .init(id:"com.orbitbloom.starter", title:"First bloom bundle", detail:"600 coins + 3 extra lives · once per Apple account", intendedINR:99, grant:.init(coins:600,lives:3), once:true)
    ]
}

public struct DeliveryRun {
    public let difficulty: Int
    public var obstacleCount: Int { 10 + difficulty * 2 }
    public var lane = 1
    public private(set) var elapsed: Double = 0
    public private(set) var health = 3
    public private(set) var collected = 0
    public private(set) var passed: Set<Int> = []
    public let duration: Double = 22
    public init(difficulty: Int = 0) { self.difficulty = min(4,max(0,difficulty)) }
    public var finished: Bool { elapsed >= duration || health <= 0 }
    public var won: Bool { elapsed >= duration && health > 0 }
    public var distance: Int { min(440, Int(elapsed * 20)) }
    public var reward: Int { won ? 60 + collected * 10 : collected * 5 }
    public func obstacleLane(_ index: Int) -> Int { [1,2,1,0,2,1,2,0,1,2][(max(0,index)%10+difficulty*3) % 10] }
    public func crossingTime(_ index: Int) -> Double { duration / Double(obstacleCount + 1) * Double(min(obstacleCount-1,max(0,index)) + 1) }
    public mutating func tick(_ delta: Double) -> (hit: Bool, pickup: Bool) {
        guard !finished, delta.isFinite, delta > 0 else { return (false,false) }
        elapsed = min(duration, elapsed + max(0,min(0.25,delta)))
        var hit = false, pickup = false
        for id in 0..<obstacleCount {
            let crossing = crossingTime(id)
            if elapsed >= crossing && !passed.contains(id) {
                passed.insert(id)
                if lane == obstacleLane(id) { health -= 1; hit = true }
                else if lane == (obstacleLane(id)+1)%3 { collected += 1; pickup = true }
            }
        }
        return (hit,pickup)
    }
}
