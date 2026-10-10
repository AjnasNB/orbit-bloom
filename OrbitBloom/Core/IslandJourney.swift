import Foundation

/// Persistent first-win progression. Replaying a room never mints another star.
public struct IslandJourney: Codable, Equatable {
    public static let rooms = Set(["canal", "fireflies", "windmill", "observatory"])
    public var levels: [String: Int] = [:]
    public var bestScores: [String: Int] = [:]
    public var events: [String: Int] = [:]
    public var claimedEvents: Set<String> = []
    public init() {}
    public var isValid: Bool {
        levels.allSatisfy { Self.rooms.contains($0.key) && (0...1000).contains($0.value) } &&
        bestScores.allSatisfy { Self.rooms.contains($0.key) && (1...20_000).contains($0.value) } &&
        events.count <= 128 && events.allSatisfy { WorldEvent.validID($0.key) && (0...3).contains($0.value) } &&
        claimedEvents.count <= 128 && claimedEvents.allSatisfy(WorldEvent.validID)
    }
    @discardableResult public mutating func complete(room: String, level: Int, score: Int) -> Bool {
        guard Self.rooms.contains(room), (1...1000).contains(level), (1...20_000).contains(score),
              level == levels[room, default: 0] + 1 else { return false }
        levels[room] = level; bestScores[room] = max(bestScores[room, default: 0], score)
        return true
    }
    public mutating func record(room: String, at date: Date) {
        let windows = WorldEvent.windows(at: date)
        let relevant = Set(windows.map(\.id))
        // Expired windows cannot be claimed; old receipts do not need unbounded storage.
        events = events.filter { relevant.contains($0.key) }
        claimedEvents = claimedEvents.intersection(relevant)
        for event in windows where event.isActive(at: date) && event.room == room {
            events[event.id] = min(3, events[event.id, default: 0] + 1)
        }
    }
    @discardableResult public mutating func claim(_ event: WorldEvent, at date: Date) -> Bool {
        guard WorldEvent.windows(at: date).contains(event), event.isActive(at: date),
              events[event.id, default: 0] >= 3, !claimedEvents.contains(event.id) else { return false }
        claimedEvents.insert(event.id); return true
    }
}

/// Epoch-based UTC windows are identical in every country; the app uses server time.
public struct WorldEvent: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let room: String
    public let starts: Date
    public let ends: Date
    public let tool: GardenTool
    public func isActive(at now: Date) -> Bool { starts <= now && now < ends }
    public static func validID(_ id: String) -> Bool {
        let parts = id.split(separator: ":")
        return parts.count == 2 && ["skills", "harvest", "rally"].contains(String(parts[0])) &&
            parts[1].count <= 9 && Int(parts[1]).map { (0...10_000_000).contains($0) } == true
    }
    public static func windows(at now: Date) -> [WorldEvent] {
        let seconds = now.timeIntervalSince1970
        guard seconds.isFinite, (0...4_102_444_800).contains(seconds) else { return [] }
        let specs: [(String, Double, Double, [String], [String], GardenTool)] = [
            ("skills", 21_600, 10_800, ["canal","fireflies","windmill","observatory"],
             ["Waterlight workshop","Firefly gathering","Windmill festival","Stargazer night"], .bomb),
            ("harvest", 86_400, 28_800, ["farm"], ["Atoll harvest fair"], .tnt),
            ("rally", 172_800, 21_600, ["rally"], ["Moonseed convoy"], .mega)
        ]
        return specs.map { key, period, duration, rooms, titles, tool in
            let cycle = Int(seconds / period)
            let current = Double(cycle) * period
            let active = seconds < current + duration
            let selected = active ? cycle : cycle + 1
            let index = selected % rooms.count
            let start = Date(timeIntervalSince1970: Double(selected) * period)
            return WorldEvent(id: "\(key):\(selected)", title: titles[index], room: rooms[index],
                              starts: start, ends: start.addingTimeInterval(duration), tool: tool)
        }
    }
}
