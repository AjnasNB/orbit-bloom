import Foundation

/// Reproducible formation rules. Keys use a seven-column garden grid.
public enum PowerRules {
    public static func tool(for keys:Set<Int>) -> GardenTool? {
        guard keys.count >= 4 else { return nil }
        var unseen = keys, groups:[Set<Int>] = []
        while let first = unseen.first {
            var pending = [first], group:Set<Int> = [first]; unseen.remove(first)
            while let current = pending.popLast() {
                for neighbor in [current-1,current+1,current-7,current+7] where unseen.contains(neighbor) && abs(current/7-neighbor/7)+abs(current%7-neighbor%7) == 1 {
                    unseen.remove(neighbor); group.insert(neighbor); pending.append(neighbor)
                }
            }
            groups.append(group)
        }
        if groups.count > 1 { return groups.compactMap { tool(for:$0) }.max { GardenTool.allCases.firstIndex(of:$0)! < GardenTool.allCases.firstIndex(of:$1)! } }
        let rows = Dictionary(grouping:keys,by:{$0/7})
        let columns = Dictionary(grouping:keys,by:{$0%7})
        func longest(_ groups:[Int:[Int]], vertical:Bool) -> Int {
            groups.values.map { items in
                let positions = items.map { vertical ? $0/7 : $0%7 }.sorted()
                var run = 0, best = 0, previous = -2
                for p in positions { run = p == previous+1 ? run+1 : 1; best = max(best,run); previous = p }
                return best
            }.max() ?? 0
        }
        let horizontal = longest(rows,vertical:false), vertical = longest(columns,vertical:true)
        if horizontal >= 5 || vertical >= 5 { return .rainbow }
        if horizontal >= 3 && vertical >= 3 { return keys.count >= 7 ? .mega : .tnt }
        if keys.count >= 10 { return .rainbow }
        if keys.count >= 8 { return .mega }
        if keys.count >= 6 { return .tnt }
        return .bomb
    }
}

public struct Assistance: Codable, Equatable {
    public var freeHints = 10
    public var shuffles = 3
    public var blasts = 0
    public var claimed:Set<String> = []
    public init() {}
    public mutating func spendHint(coins:inout Int) -> Bool {
        if freeHints > 0 { freeHints -= 1; return true }
        guard coins >= 3 else { return false }; coins -= 3; return true
    }
    public mutating func spendShuffle(coins:inout Int) -> Bool {
        if shuffles > 0 { shuffles -= 1; return true }
        guard coins >= 15 else { return false }; coins -= 15; return true
    }
}
public struct FieldTask: Identifiable {
    public let id:String
    public let title:String
    public let kind:String
    public let target:Int
    public let tool:GardenTool
    public let hints:Int
    public let shuffles:Int
    public static let all:[FieldTask] = [
        .init(id:"harvest1",title:"Your first harvest",kind:"harvest",target:1,tool:.bomb,hints:2,shuffles:0),
        .init(id:"harvest3",title:"A thriving patch",kind:"harvest",target:3,tool:.tnt,hints:0,shuffles:2),
        .init(id:"delivery1",title:"Fresh flowers, delivered",kind:"delivery",target:1,tool:.tnt,hints:3,shuffles:0),
        .init(id:"delivery3",title:"A reliable rover",kind:"delivery",target:3,tool:.mega,hints:0,shuffles:3),
        .init(id:"circuit3",title:"A promising gardener",kind:"circuit",target:3,tool:.rainbow,hints:3,shuffles:1),
        .init(id:"blast3",title:"A little chain reaction",kind:"blast",target:3,tool:.mega,hints:2,shuffles:1)
    ]
    public func value(progress:Progress,ecosystem:Ecosystem,assistance:Assistance) -> Int {
        switch kind { case "harvest": return ecosystem.harvested; case "delivery": return ecosystem.deliveries; case "circuit": return progress.completed.count; default: return assistance.blasts }
    }
    @discardableResult public func claim(progress:Progress,ecosystem:inout Ecosystem,assistance:inout Assistance) -> Bool {
        guard !assistance.claimed.contains(id), value(progress:progress,ecosystem:ecosystem,assistance:assistance) >= target else { return false }
        assistance.claimed.insert(id); ecosystem.tools[tool,default:0] += 1
        assistance.freeHints += hints; assistance.shuffles += shuffles; return true
    }
}
