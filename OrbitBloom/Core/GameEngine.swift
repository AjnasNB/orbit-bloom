import Foundation
import Match3Kit

public enum Gem: Int, CaseIterable, GridFilling {
    case leaf, water, sun, flower, crystal
    public var pattern: Pattern { Pattern(indices: []) }
    public var name: String { ["Leaf", "Dewdrop", "Apple", "Rose", "Diamond"][rawValue] }
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
    public var subtitle: String { frost > 0 ? "Bloom beside frozen patches to melt them." : "Collect resources to bring your little moon to life." }
    public static let total = 1020
    public static let campaign: [Level] = opening + (13...total).map { id in
        let region = (id-1)/10
        let names = GardenRegion.biomes
        let a = Gem.allCases[id%5], b = Gem.allCases[(id+2)%5]
        return Level(id:id,title:"\(names[region%names.count]) \(id)",biome:"Expedition \(region+1)",moves:16+id%5,target:1500+id%7*150,goals:[a:12+id%7,b:10+id%6],frost:4+id%9)
    }
    public static let opening: [Level] = [
        .init(id: 1, title: "A little life", biome: "Moonseed Meadow", moves: 10, target: 350, goals: [.leaf: 6], frost: 0),
        .init(id: 2, title: "Morning dew", biome: "Moonseed Meadow", moves: 11, target: 500, goals: [.water: 7], frost: 0),
        .init(id: 3, title: "First flowers", biome: "Moonseed Meadow", moves: 12, target: 700, goals: [.flower: 8, .sun: 6], frost: 0),
        .init(id: 4, title: "Roots & starlight", biome: "Moonseed Meadow", moves: 13, target: 800, goals: [.leaf: 10, .crystal: 7], frost: 4),
        .init(id: 5, title: "A coral sunrise", biome: "Coral Observatory", moves: 14, target: 1000, goals: [.sun: 10, .water: 8], frost: 4),
        .init(id: 6, title: "The quiet pool", biome: "Coral Observatory", moves: 14, target: 1100, goals: [.water: 12, .flower: 8], frost: 6),
        .init(id: 7, title: "Cosmic pollinators", biome: "Coral Observatory", moves: 18, target: 1300, goals: [.flower: 13, .leaf: 10], frost: 6),
        .init(id: 8, title: "Warmth returns", biome: "Coral Observatory", moves: 16, target: 1350, goals: [.sun: 13, .crystal: 10], frost: 8),
        .init(id: 9, title: "An aurora seed", biome: "Aurora Grove", moves: 19, target: 1400, goals: [.leaf: 13, .crystal: 11], frost: 6),
        .init(id: 10, title: "Into the blue", biome: "Aurora Grove", moves: 17, target: 1600, goals: [.water: 14, .sun: 11], frost: 8),
        .init(id: 11, title: "The last frost", biome: "Aurora Grove", moves: 18, target: 1700, goals: [.flower: 14, .leaf: 13], frost: 8),
        .init(id: 12, title: "A world in bloom", biome: "Aurora Grove", moves: 20, target: 1900, goals: [.flower: 16, .crystal: 14], frost: 8)
    ]
}

public struct CellState: Identifiable, Codable {
    public let id: UUID
    public let column: Int
    public let row: Int
    public let gem: Gem
    public var power: GardenTool? = nil
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
    public var swappedCells: [CellState]? = nil
}

public final class GameEngine {
    public typealias Board = Controller<Gem, SeededGenerator, Matcher<Gem>>
    public private(set) var board: Board
    public private(set) var score = 0
    public private(set) var moves: Int
    public private(set) var collected: [Gem: Int] = [:]
    public private(set) var frost: Set<Int> = []
    public let level: Level
    public private(set) var specials: [UUID:GardenTool] = [:]
    public var powers: [Int:GardenTool] { Dictionary(uniqueKeysWithValues:cells.compactMap { cell in cell.power.map { (cell.key,$0) } }) }
    public var cells: [CellState] {
        board.grid.allIndices().map { index in
            let cell = board.grid[index]
            return .init(id: cell.id, column: index.column, row: index.row, gem: cell.filling, power:specials[cell.id])
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
    public func cluster(at cell: Int) -> Set<Int> {
        guard (0..<49).contains(cell) else { return [] }
        let gem = board.grid[index(cell)].filling
        var seen: Set<Int> = [cell], pending = [cell]
        while let current = pending.popLast() {
            for neighbor in [current-1,current+1,current-7,current+7] where (0..<49).contains(neighbor) {
                guard abs(current/7-neighbor/7)+abs(current%7-neighbor%7) == 1,
                      !seen.contains(neighbor), board.grid[index(neighbor)].filling == gem else { continue }
                seen.insert(neighbor); pending.append(neighbor)
            }
        }
        return seen
    }
    public func bestCluster() -> Int? {
        cells.sorted { $0.key < $1.key }.filter { cluster(at:$0.key).count >= 2 }.max { a,b in
            func value(_ cell: CellState) -> Int {
                let group = cluster(at:cell.key)
                let warmed = frost.filter { frozen in group.contains { matched in abs(matched/7-frozen/7)+abs(matched%7-frozen%7) <= 1 } }
                return group.count * (collected[cell.gem,default:0] < level.goals[cell.gem,default:0] ? 5 : 1) + warmed.count * 8
            }
            return value(a) < value(b)
        }?.key
    }
    public func harvestCluster(at cell: Int) -> Turn {
        let group = cluster(at:cell)
        guard group.count >= 2, !won, !lost else { return .init(accepted:false,cascades:[],earnedCharge:false) }
        moves -= 1
        let turn = resolve(initial:Set(group.map(index)), bloomWarmth:true)
        if let tool = PowerRules.tool(for:group) { specials[board.grid[index(cell)].id] = tool }
        return turn
    }
    public func blastArea(_ tool:GardenTool, at cell:Int) -> Set<Int> {
        guard (0..<49).contains(cell) else { return [] }
        let color = board.grid[index(cell)].filling
        return Set(cells.filter { item in
            switch tool {
            case .bomb: return abs(item.row-cell/7) <= 1 && abs(item.column-cell%7) <= 1
            case .tnt: return item.row == cell/7 || item.column == cell%7
            case .mega: return abs(item.row-cell/7) <= 2 && abs(item.column-cell%7) <= 2
            case .rainbow: return item.gem == color
            }
        }.map(\.key))
    }
    public func activate(_ tool: GardenTool, at cell: Int) -> Turn {
        guard (0..<49).contains(cell), !won, !lost else { return .init(accepted:false,cascades:[],earnedCharge:false) }
        return resolve(initial:Set(blastArea(tool,at:cell).map(index)))
    }
    public func detonate(at cell:Int) -> Turn {
        guard let tool = powers[cell], !won, !lost else { return .init(accepted:false,cascades:[],earnedCharge:false) }
        moves -= 1
        return resolve(initial:Set(blastArea(tool,at:cell).map(index)))
    }
    public func swap(_ a: Int, _ b: Int) -> Turn {
        guard (0..<49).contains(a), (0..<49).contains(b), moves > 0, !won else { return Turn(accepted: false, cascades: [], earnedCharge: false) }
        let source = index(a), target = index(b)
        guard board.canSwapCell(at:source,with:target) else { return .init(accepted:false,cascades:[],earnedCharge:false) }
        if powers[a] != nil || powers[b] != nil {
            board.swapCell(at:source,with:target); let swapped = cells; moves -= 1
            let areas = [a,b].reduce(into:Set<Int>()) { keys, cell in if let tool = powers[cell] { keys.formUnion(blastArea(tool,at:cell)) } }
            var turn = resolve(initial:Set(areas.map(index))); turn.swappedCells = swapped; return turn
        }
        guard board.shouldSwapCell(at: source, with: target) else { return .init(accepted:false,cascades:[],earnedCharge:false) }
        moves -= 1
        let initial = board.swapAndMatchCell(at: source, with: target), swapped = cells
        let matchedByKind = Dictionary(grouping:initial,by:{ board.grid[$0].filling })
        let tool = matchedByKind.values.compactMap { PowerRules.tool(for:Set($0.map(key))) }.max { GardenTool.allCases.firstIndex(of:$0)! < GardenTool.allCases.firstIndex(of:$1)! }
        var turn = resolve(initial:initial,bloomWarmth:true)
        if let tool { specials[board.grid[target].id] = tool }
        turn.swappedCells = swapped; return turn
    }
    public func burst(at key: Int) -> Turn {
        guard (0..<49).contains(key), !won, !lost else { return Turn(accepted: false, cascades: [], earnedCharge: false) }
        let row = key / 7, column = key % 7
        let indices = Set(board.grid.allIndices().filter { $0.row == row || $0.column == column })
        return resolve(initial: indices)
    }
    public func shuffle() {
        // Rearrange actual identities, preserving all pieces and power-ups.
        for _ in 0..<150 {
            let order = Array(0..<49).shuffled()
            for a in 0..<49 { board.swapCell(at:index(a),with:index(order[a])) }
            if board.findAllMatches().isEmpty && hint != nil && bestCluster() != nil { return }
        }
        resetBoard(preservePowers:true)
    }
    public func addMoves(_ count: Int) { moves += max(0, count) }
    private func resolve(initial: Set<Index>, bloomWarmth: Bool = false) -> Turn {
        var matches = initial
        var waves: [Cascade] = []
        let charge = matches.count >= 4
        for chain in 1...64 {
            guard !matches.isEmpty else { break }
            // Expand every touched on-board power before removing any pieces.
            var detonated:Set<UUID> = []
            var expanded = true
            while expanded {
                expanded = false
                for item in Array(matches) {
                    let id = board.grid[item].id
                    if let tool = specials[id], !detonated.contains(id) {
                        detonated.insert(id); matches.formUnion(blastArea(tool,at:key(item)).map(index)); expanded = true
                    }
                }
            }
            for id in detonated { specials.removeValue(forKey:id) }
            var tally: [Gem: Int] = [:]
            for i in matches { tally[board.grid[i].filling, default: 0] += 1 }
            for (gem, amount) in tally { collected[gem, default: 0] += amount }
            let cleared = Set(matches.map(key))
            frost.subtract(cleared)
            if bloomWarmth {
                let warmed = frost.filter { frozen in cleared.contains { cell in
                    abs(cell/7-frozen/7) + abs(cell%7-frozen%7) == 1
                } }
                frost.subtract(warmed)
            }
            let points = matches.count * 30 * min(chain, 4)
            score += points
            board.remove(indices: matches, refill: .spill)
            waves.append(.init(cleared: cleared, cells: cells, collected: tally, points: points))
            matches = board.findAllMatches()
        }
        // Guarantee a stable, playable board, including after a pathological long cascade.
        if !board.findAllMatches().isEmpty || board.findPossibleSwap() == nil || bestCluster() == nil {
            resetBoard(preservePowers:true)
            waves.append(.init(cleared: [], cells: cells, collected: [:], points: 0))
        }
        return Turn(accepted: true, cascades: waves, earnedCharge: charge)
    }
    private func resetBoard(preservePowers:Bool = false) {
        let kept = preservePowers ? Array(specials.values) : []
        specials.removeAll()
        defer { for (offset,tool) in kept.prefix(49).enumerated() { specials[board.grid[index(offset)].id] = tool } }
        for _ in 0..<100 {
            for index in board.grid.allIndices() { _ = board.spawn(filling: board.generator.generate(at: index).filling, at: index) }
            for _ in 0..<100 {
                let matches = board.findAllMatches()
                if matches.isEmpty { break }
                board.remove(indices: matches, refill: .regenerate)
            }
            if board.findAllMatches().isEmpty && board.findPossibleSwap() != nil && bestCluster() != nil { return }
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
        public var specials: [UUID:GardenTool]? = nil
    }
    public var snapshot: Snapshot { .init(levelID: level.id, grid: board.grid, score: score, moves: moves, collected: collected, frost: frost, specials:specials) }
    public convenience init?(snapshot: Snapshot) {
        guard let level = Level.campaign.first(where: { $0.id == snapshot.levelID }), snapshot.grid.size == Size(columns: 7, rows: 7), snapshot.grid.columns.count == 7, snapshot.grid.columns.allSatisfy({ $0.count == 7 }), snapshot.moves >= 0 else { return nil }
        self.init(level: level, seed: UInt64.random(in: 1...UInt64.max))
        board = Board(grid: snapshot.grid, basic: Set(Gem.allCases), bonuse: [], obstacles: [])
        specials = snapshot.specials ?? [:]
        score = snapshot.score; moves = snapshot.moves; collected = snapshot.collected; frost = snapshot.frost.filter { (0..<49).contains($0) }
        if !board.findAllMatches().isEmpty || board.findPossibleSwap() == nil || bestCluster() == nil { resetBoard() }
    }
}
