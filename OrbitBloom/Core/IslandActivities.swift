import Foundation

/// Four short, no-life-cost activities that support the same island restoration story.
enum IslandActivityKind: String, Codable, CaseIterable, Identifiable {
    case canal, fireflies, windmill, observatory
    var id: String { rawValue }
    var title: String {
        switch self {
        case .canal: return "Canal Weave"
        case .fireflies: return "Firefly Trail"
        case .windmill: return "Windmill Works"
        case .observatory: return "Moon Observatory"
        }
    }
    var subtitle: String {
        switch self {
        case .canal: return "Bring water back to the terraces"
        case .fireflies: return "Remember the island's light language"
        case .windmill: return "Charge the restoration workshop"
        case .observatory: return "Chart a route through the night sky"
        }
    }
    var symbol: String {
        switch self {
        case .canal: return "drop.fill"
        case .fireflies: return "sparkles"
        case .windmill: return "wind"
        case .observatory: return "moon.stars.fill"
        }
    }
}

private struct ActivityRandom {
    var state: UInt64
    mutating func next(_ upperBound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 32) % UInt64(max(1, upperBound)))
    }
}

private func activityLevel(_ level: Int) -> Int { min(1_000, max(1, level)) }
private func activityScore(_ value: Int) -> Int { min(20_000, max(1, value)) }

/// Pipe ports are north, east, south and west bits, respectively.
struct CanalWorksRun {
    let level: Int
    let width: Int
    let height: Int
    let solution: [Int]
    let moveLimit: Int
    private(set) var pipes: [Int]
    private(set) var moves = 0
    private(set) var won = false
    var finished: Bool { won || moves >= moveLimit }
    var movesRemaining: Int { max(0, moveLimit - moves) }
    var score: Int { won ? activityScore(150 + level * 10 + movesRemaining * 8) : 0 }
    var outlet: Int { width * height - 1 }

    init(level: Int) {
        let level = activityLevel(level)
        self.level = level
        let width = level >= 8 ? 5 : 4
        let height = level >= 18 ? 5 : 3
        self.width = width
        self.height = height
        var route: [Int] = []
        for row in 0..<height {
            let columns = row.isMultiple(of: 2) ? Array(0..<width) : Array((0..<width).reversed())
            route.append(contentsOf: columns.map { row * width + $0 })
        }
        var solved = Array(repeating: 0, count: width * height)
        for (step, index) in route.enumerated() {
            let before = step == 0 ? 8 : Self.port(from: index, to: route[step - 1], width: width)
            let after = step == route.count - 1 ? 2 : Self.port(from: index, to: route[step + 1], width: width)
            solved[index] = before | after
        }
        solution = solved
        var random = ActivityRandom(state: UInt64(level) &* 71 &+ 809)
        var scrambled = solved
        var indices = Array(solved.indices)
        let count = min(solved.count, 3 + level / 2)
        var required = 0
        for _ in 0..<count {
            let selected = indices.remove(at: random.next(indices.count))
            let turns = 1 + random.next(3)
            var mask = solved[selected]
            for _ in 0..<turns { mask = Self.rotate(mask) }
            // A straight pipe's 180° turn is visually and functionally unchanged.
            if mask == solved[selected] { mask = Self.rotate(mask) }
            scrambled[selected] = mask
            var restore = mask
            repeat {
                restore = Self.rotate(restore)
                required += 1
            } while restore != solved[selected]
        }
        pipes = scrambled
        moveLimit = required + (level < 12 ? 3 : 1)
    }

    @discardableResult mutating func turnPipe(at index: Int) -> Bool {
        guard !finished, pipes.indices.contains(index) else { return false }
        pipes[index] = Self.rotate(pipes[index])
        moves += 1
        won = connectedCells.contains(outlet) && pipes[outlet] & 2 != 0
        return true
    }

    var connectedCells: Set<Int> {
        guard pipes.first.map({ $0 & 8 != 0 }) == true else { return [] }
        var reached: Set<Int> = [0]
        var frontier = [0]
        while let index = frontier.popLast() {
            let row = index / width, column = index % width
            let neighbours: [(Int, Int, Int, Bool)] = [
                (index - width, 1, 4, row > 0), (index + 1, 2, 8, column < width - 1),
                (index + width, 4, 1, row < height - 1), (index - 1, 8, 2, column > 0)
            ]
            for (other, port, reverse, inBounds) in neighbours where inBounds {
                if pipes[index] & port != 0, pipes[other] & reverse != 0, reached.insert(other).inserted {
                    frontier.append(other)
                }
            }
        }
        return reached
    }

    static func rotate(_ mask: Int) -> Int { ((mask << 1) & 15) | ((mask >> 3) & 1) }
    private static func port(from a: Int, to b: Int, width: Int) -> Int {
        if b == a - width { return 1 }
        if b == a + 1 { return 2 }
        if b == a + width { return 4 }
        return 8
    }
}

struct FireflySignalRun {
    enum Phase: Equatable { case ready, watching, answering, won, lost }
    let level: Int
    let rounds: Int
    let lights: [Int]
    let initialLength: Int
    private(set) var round = 0
    private(set) var answerIndex = 0
    private(set) var mistakes = 0
    private(set) var phase: Phase = .ready
    var sequence: [Int] { Array(lights.prefix(initialLength + round)) }
    var won: Bool { phase == .won }
    var finished: Bool { phase == .won || phase == .lost }
    var score: Int { won ? activityScore(250 + level * 12 + rounds * 80 - mistakes * 60) : 0 }

    init(level: Int) {
        let level = activityLevel(level)
        self.level = level
        initialLength = min(6, 3 + level / 6)
        rounds = level >= 18 ? 4 : 3
        var random = ActivityRandom(state: UInt64(level) &* 419 &+ 27)
        var pattern: [Int] = []
        for _ in 0..<(initialLength + rounds - 1) {
            var next = random.next(4)
            if next == pattern.last { next = (next + 1 + random.next(3)) % 4 }
            pattern.append(next)
        }
        lights = pattern
    }
    @discardableResult mutating func beginPlayback() -> Bool {
        guard phase == .ready else { return false }
        phase = .watching
        answerIndex = 0
        return true
    }
    mutating func finishPlayback() { if phase == .watching { phase = .answering } }
    /// Replaying an interrupted demonstration is free and cannot produce a reward.
    mutating func interruptPlayback() {
        if phase == .watching { phase = .ready; answerIndex = 0 }
    }
    @discardableResult mutating func selectLight(_ index: Int) -> Bool {
        guard phase == .answering, (0..<4).contains(index) else { return false }
        guard sequence[answerIndex] == index else {
            mistakes += 1
            answerIndex = 0
            phase = mistakes >= 2 ? .lost : .ready
            return false
        }
        answerIndex += 1
        if answerIndex == sequence.count {
            round += 1
            answerIndex = 0
            phase = round == rounds ? .won : .ready
        }
        return true
    }
}

struct WindmillRhythmRun {
    let level: Int
    let targetHits: Int
    let targetHalfWidth: Double
    let duration: Double
    private(set) var elapsed: Double = 0
    private(set) var hits = 0
    private(set) var misses = 0
    private(set) var started = false
    var won: Bool { hits >= targetHits }
    var finished: Bool { won || misses >= 3 || (started && elapsed >= duration) }
    var remaining: Int { max(0, Int(ceil(duration - elapsed))) }
    var pointer: Double { (elapsed * (0.39 + Double(min(level, 50)) * 0.003)).truncatingRemainder(dividingBy: 1) }
    var targetCenter: Double { [0.28, 0.64, 0.42, 0.79, 0.18, 0.55][hits % 6] }
    var inWindow: Bool { Self.circularDistance(pointer, targetCenter) <= targetHalfWidth }
    var score: Int { won ? activityScore(200 + level * 10 + hits * 60 + remaining * 3 - misses * 30) : 0 }
    init(level: Int) {
        self.level = activityLevel(level)
        targetHits = level >= 15 ? 6 : 4
        targetHalfWidth = max(0.055, 0.13 - Double(min(self.level, 30)) * 0.0025)
        duration = level >= 15 ? 32 : 24
    }
    mutating func start() { if !started { started = true } }
    mutating func tick(_ delta: Double) {
        guard started, !finished, delta.isFinite, delta > 0 else { return }
        elapsed = min(duration, elapsed + min(0.2, delta))
    }
    /// Guided timing offers the same route to completion for VoiceOver users.
    @discardableResult mutating func charge(guided: Bool = false) -> Bool {
        guard started, !finished else { return false }
        if guided || inWindow { hits += 1; return true }
        misses += 1
        return false
    }
    private static func circularDistance(_ a: Double, _ b: Double) -> Double {
        let distance = abs(a - b)
        return min(distance, 1 - distance)
    }
}

enum IslandSwipeDirection { case up, right, down, left }

struct ObservatoryRun {
    let level: Int
    let width: Int
    let moveLimit: Int
    /// Legal moves used to create the board. Reversing them is always a valid solution.
    let scrambleHistory: [Int]
    private(set) var tiles: [Int]
    private(set) var moves = 0
    private(set) var won = false
    var finished: Bool { won || moves >= moveLimit }
    var movesRemaining: Int { max(0, moveLimit - moves) }
    var score: Int { won ? activityScore(200 + level * 10 + movesRemaining * 7) : 0 }
    var gap: Int { tiles.firstIndex(of: 0)! }
    var aligned: Int { tiles.enumerated().filter { $0.element != 0 && $0.element == $0.offset + 1 }.count }
    var goalCount: Int { width * width - 1 }
    init(level: Int) {
        let level = activityLevel(level)
        self.level = level
        let width = level >= 20 ? 4 : 3
        self.width = width
        var board = Array(1..<(width * width)) + [0]
        var random = ActivityRandom(state: UInt64(level) &* 211 &+ 913)
        var previousGap = -1
        var history: [Int] = []
        let scrambleCount = min(42, 5 + level * 2)
        for _ in 0..<scrambleCount {
            let gap = board.firstIndex(of: 0)!
            var neighbours = Self.neighbours(of: gap, width: width).filter { $0 != previousGap }
            if neighbours.isEmpty { neighbours = Self.neighbours(of: gap, width: width) }
            let next = neighbours[random.next(neighbours.count)]
            history.append(board[next])
            board.swapAt(gap, next)
            previousGap = gap
        }
        if Self.isSolved(board) {
            let gap = board.firstIndex(of: 0)!, next = Self.neighbours(of: gap, width: width)[0]
            history.append(board[next]); board.swapAt(gap, next)
        }
        tiles = board
        scrambleHistory = history
        moveLimit = history.count + (level < 15 ? 8 : 3)
    }
    @discardableResult mutating func slide(tile: Int, direction: IslandSwipeDirection? = nil) -> Bool {
        guard !finished, tile > 0, let index = tiles.firstIndex(of: tile), Self.neighbours(of: gap, width: width).contains(index) else { return false }
        if let direction {
            let actual: IslandSwipeDirection
            if gap == index - width { actual = .up }
            else if gap == index + width { actual = .down }
            else if gap == index - 1 { actual = .left }
            else { actual = .right }
            guard actual == direction else { return false }
        }
        tiles.swapAt(index, gap)
        moves += 1
        won = Self.isSolved(tiles)
        return true
    }
    static func neighbours(of index: Int, width: Int) -> [Int] {
        let row = index / width, column = index % width
        var result: [Int] = []
        if row > 0 { result.append(index - width) }
        if column < width - 1 { result.append(index + 1) }
        if row < width - 1 { result.append(index + width) }
        if column > 0 { result.append(index - 1) }
        return result
    }
    private static func isSolved(_ tiles: [Int]) -> Bool {
        tiles.enumerated().allSatisfy { $0.element == ($0.offset == tiles.count - 1 ? 0 : $0.offset + 1) }
    }
}
