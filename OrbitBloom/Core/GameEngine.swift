import Foundation
import Match3Kit

public enum Gem: Int, CaseIterable, GridFilling {
    case leaf, water, sun, flower, crystal
    public var pattern: Pattern { Pattern(indices: []) }
    public var name: String { ["Leaf", "Dewdrop", "Sun", "Blossom", "Crystal"][rawValue] }
}

public final class SeededGenerator: Generator<Gem> {
    private var state: UInt64 = 1
    public func seed(_ value: UInt64) { state = max(1, value) }
    public override func fill(grid: Grid<Gem>, indices: Set<Index>) -> Grid<Gem> {
        var updated = grid
        for index in indices.sorted(by: { $0.column == $1.column ? $0.row < $1.row : $0.column < $1.column }) {
            updated.setCell(generate(at: index), at: index)
        }
        return updated
    }
    public override func generate(at index: Index, filling: Gem? = nil) -> Grid<Gem>.Cell {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        let value = filling ?? Gem.allCases[Int((state >> 32) % 5)]
        return .init(id: UUID(), filling: value)
    }
}

public struct Level: Identifiable {
    public let id: Int
    public let title: String
    public let biome: String
    public let moves: Int
    public let target: Int
    public let goals: [Gem: Int]
    public let frost: Int
    public var subtitle: String { frost > 0 ? "Collect resources and melt every frozen patch." : "Collect resources to bring your little moon to life." }
    public static let campaign: [Level] = [
        .init(id: 1, title: "A little life", biome: "Moonseed Meadow", moves: 22, target: 450, goals: [.leaf: 6], frost: 0),
        .init(id: 2, title: "Morning dew", biome: "Moonseed Meadow", moves: 24, target: 700, goals: [.water: 9], frost: 0),
        .init(id: 3, title: "First flowers", biome: "Moonseed Meadow", moves: 25, target: 900, goals: [.flower: 10, .sun: 8], frost: 0),
        .init(id: 4, title: "Roots & starlight", biome: "Moonseed Meadow", moves: 26, target: 1100, goals: [.leaf: 12, .crystal: 9], frost: 4),
        .init(id: 5, title: "A coral sunrise", biome: "Coral Observatory", moves: 27, target: 1300, goals: [.sun: 12, .water: 10], frost: 4),
        .init(id: 6, title: "The quiet pool", biome: "Coral Observatory", moves: 28, target: 1500, goals: [.water: 15, .flower: 10], frost: 6),
        .init(id: 7, title: "Cosmic pollinators", biome: "Coral Observatory", moves: 29, target: 1700, goals: [.flower: 16, .leaf: 12], frost: 6),
        .init(id: 8, title: "Warmth returns", biome: "Coral Observatory", moves: 30, target: 1800, goals: [.sun: 16, .crystal: 12], frost: 8),
        .init(id: 9, title: "An aurora seed", biome: "Aurora Grove", moves: 30, target: 1900, goals: [.leaf: 16, .crystal: 14], frost: 8),
        .init(id: 10, title: "Into the blue", biome: "Aurora Grove", moves: 31, target: 2100, goals: [.water: 18, .sun: 14], frost: 10),
        .init(id: 11, title: "The last frost", biome: "Aurora Grove", moves: 32, target: 2300, goals: [.flower: 18, .leaf: 16], frost: 12),
        .init(id: 12, title: "A world in bloom", biome: "Aurora Grove", moves: 34, target: 2500, goals: [.flower: 20, .crystal: 18], frost: 12)
    ]
}

public struct CellState: Identifiable, Codable {
    public let id: UUID
    public let column: Int
    public let row: Int
    public let gem: Gem
    public var key: Int { row * 7 + column }
}
public struct Cascade {
    public let cleared: Set<Int>
    public let cells: [CellState]
    public let collected: [Gem: Int]
    public let points: Int
}
public struct Turn {
    public let accepted: Bool
    public let cascades: [Cascade]
    public let earnedCharge: Bool
}

public final class GameEngine {
    public typealias Board = Controller<Gem, SeededGenerator, Matcher<Gem>>
    public private(set) var board: Board
    public private(set) var score = 0
    public private(set) var moves: Int
    public private(set) var collected: [Gem: Int] = [:]
    public private(set) var frost: Set<Int> = []
    public let level: Level
    public var cells: [CellState] {
        board.grid.allIndices().map { index in
            let cell = board.grid[index]
            return .init(id: cell.id, column: index.column, row: index.row, gem: cell.filling)
        }
    }
    public var won: Bool { score >= level.target && frost.isEmpty && level.goals.allSatisfy { collected[$0.key, default: 0] >= $0.value } }
    public var lost: Bool { moves <= 0 && !won }
    public var hint: (Int, Int)? {
        guard let pair = board.findPossibleSwap() else { return nil }
        return (key(pair.0), key(pair.1))
    }
    public init(level: Level, seed: UInt64) {
        self.level = level
        moves = level.moves
        board = Board(size: Size(columns: 7, rows: 7), basic: Set(Gem.allCases), bonuse: [], obstacles: [])
        board.generator.seed(seed)
        resetBoard()
        // Spread frost deterministically across the board, with no repeated cells.
        frost = Set((0..<level.frost).map { ($0 * 11 + 16) % 49 })
    }
    private func key(_ index: Index) -> Int { index.row * 7 + index.column }
    private func index(_ key: Int) -> Index { Index(column: key % 7, row: key / 7) }
    public func swap(_ a: Int, _ b: Int) -> Turn {
        guard (0..<49).contains(a), (0..<49).contains(b), moves > 0, !won else { return Turn(accepted: false, cascades: [], earnedCharge: false) }
        let source = index(a), target = index(b)
        guard board.canSwapCell(at: source, with: target), board.shouldSwapCell(at: source, with: target) else { return Turn(accepted: false, cascades: [], earnedCharge: false) }
        moves -= 1
        let initial = board.swapAndMatchCell(at: source, with: target)
        return resolve(initial: initial)
    }
    public func burst(at key: Int) -> Turn {
        guard (0..<49).contains(key), !won, !lost else { return Turn(accepted: false, cascades: [], earnedCharge: false) }
        let row = key / 7, column = key % 7
        let indices = Set(board.grid.allIndices().filter { $0.row == row || $0.column == column })
        return resolve(initial: indices)
    }
    public func shuffle() {
        // A free recovery action; it never spends moves or progress.
        resetBoard()
    }
    public func addMoves(_ count: Int) { moves += max(0, count) }
    private func resolve(initial: Set<Index>) -> Turn {
        var matches = initial
        var waves: [Cascade] = []
        let charge = matches.count >= 4
        for chain in 1...64 {
            guard !matches.isEmpty else { break }
            var tally: [Gem: Int] = [:]
            for i in matches { tally[board.grid[i].filling, default: 0] += 1 }
            for (gem, amount) in tally { collected[gem, default: 0] += amount }
            let cleared = Set(matches.map(key))
            frost.subtract(cleared)
            let points = matches.count * 30 * min(chain, 4)
            score += points
            board.remove(indices: matches, refill: .spill)
            waves.append(.init(cleared: cleared, cells: cells, collected: tally, points: points))
            matches = board.findAllMatches()
        }
        // Guarantee a stable, playable board, including after a pathological long cascade.
        if !board.findAllMatches().isEmpty || board.findPossibleSwap() == nil {
            resetBoard()
            waves.append(.init(cleared: [], cells: cells, collected: [:], points: 0))
        }
        return Turn(accepted: true, cascades: waves, earnedCharge: charge)
    }
    private func resetBoard() {
        for _ in 0..<100 {
            for index in board.grid.allIndices() { _ = board.spawn(filling: board.generator.generate(at: index).filling, at: index) }
            for _ in 0..<100 {
                let matches = board.findAllMatches()
                if matches.isEmpty { break }
                board.remove(indices: matches, refill: .regenerate)
            }
            if board.findAllMatches().isEmpty && board.findPossibleSwap() != nil { return }
        }
        // A deterministic fallback contains a legal opening move and no pre-existing matches.
        for row in 0..<7 {
            for column in 0..<7 {
                _ = board.spawn(filling: Gem.allCases[(row * 2 + column) % 5], at: .init(column: column, row: row))
            }
        }
        _ = board.spawn(filling: .leaf, at: .init(column: 0, row: 0))
        _ = board.spawn(filling: .leaf, at: .init(column: 2, row: 0))
        _ = board.spawn(filling: .leaf, at: .init(column: 1, row: 1))
    }
    public func bestMove() -> (Int, Int)? {
        var best: (Int, Int)?
        var weight = -1
        for i in board.grid.allIndices() {
            for j in [i.right, i.upper] where board.grid.size.isInBounds(j) && board.shouldSwapCell(at: i, with: j) {
                var grid = board.grid
                grid.swapCell(at: i, with: j)
                let matches = board.matcher.findAllMatches(on: grid)
                let value = matches.reduce(0) { sum, index in
                    let gem = grid[index].filling
                    return sum + 1 + (frost.contains(key(index)) ? 6 : 0) + (collected[gem, default: 0] < level.goals[gem, default: 0] ? 4 : 0)
                }
                if value > weight { weight = value; best = (key(i), key(j)) }
            }
        }
        return best
    }
}

extension GameEngine {
    public struct Snapshot: Codable {
        public let levelID: Int
        public let grid: Grid<Gem>
        public let score: Int
        public let moves: Int
        public let collected: [Gem: Int]
        public let frost: Set<Int>
    }
    public var snapshot: Snapshot { .init(levelID: level.id, grid: board.grid, score: score, moves: moves, collected: collected, frost: frost) }
    public convenience init?(snapshot: Snapshot) {
        guard let level = Level.campaign.first(where: { $0.id == snapshot.levelID }), snapshot.grid.size == Size(columns: 7, rows: 7), snapshot.grid.columns.count == 7, snapshot.grid.columns.allSatisfy({ $0.count == 7 }), snapshot.moves >= 0 else { return nil }
        self.init(level: level, seed: UInt64.random(in: 1...UInt64.max))
        board = Board(grid: snapshot.grid, basic: Set(Gem.allCases), bonuse: [], obstacles: [])
        score = snapshot.score; moves = snapshot.moves; collected = snapshot.collected; frost = snapshot.frost.filter { (0..<49).contains($0) }
        if !board.findAllMatches().isEmpty || board.findPossibleSwap() == nil { resetBoard() }
    }
}
