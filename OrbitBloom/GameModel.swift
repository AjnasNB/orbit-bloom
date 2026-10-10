import SwiftUI
import AVFoundation
import UIKit
import Match3Kit

@MainActor final class GameModel: ObservableObject {
    @Published var progress: Progress
    @Published var ecosystem = Ecosystem()
    @Published var assistance = Assistance()
    @Published var journey = IslandJourney()
    @Published var activity: IslandActivityKind?
    @Published private(set) var activityLevel = 1
    private var activityRewarded = false
    let eventClock = WorldEventClock()
    @Published var showWorldEvents = false
    @Published var showRoomRecords = false
    @Published var showTasks = false
    @Published var pendingTool: GardenTool?
    @Published var raceActive = false
    @Published var coinFlight: UUID?
    @Published var lastCoinAward = 0
    @Published var blastKey: Int?
    @Published var blastID = UUID()
    @Published var tab = 0
    @Published var engine: GameEngine?
    @Published var cells: [CellState] = []
    @Published var selected: Int?
    @Published var hinted: Set<Int> = []
    @Published var clearing: Set<Int> = []
    @Published var busy = false
    @Published var result: Bool?
    @Published var score = 0
    @Published var moves = 0
    @Published var collected: [Gem: Int] = [:]
    @Published var frost: Set<Int> = []
    @Published var message = "Swipe neighbors to match three, or tap a touching group."
    @Published var hintText = ""
    @Published var burstMode = false
    @Published var charged = false
    @Published var toast: String?
    @Published var showSettings = false
    @Published var paused = false
    @Published var firstWin = false
    private let defaults: UserDefaults
    var onSave: (() -> Void)?
    private(set) var saveGeneration = UUID()
    private(set) var saveAccount: String?
    private var creditedOnDevice: Set<String> = []
    private var runID = UUID()
    let testing: Bool

    init(defaults: UserDefaults = .standard) {
        testing = ProcessInfo.processInfo.arguments.contains("--uitesting")
        self.defaults = defaults
        if testing && !ProcessInfo.processInfo.arguments.contains("--keep-progress") {
            for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("orbitBloom.") {
                defaults.removeObject(forKey: key)
            }
        }
        saveAccount = defaults.string(forKey: "orbitBloom.saveAccount")
        creditedOnDevice = Set(defaults.stringArray(forKey: "orbitBloom.purchaseReceipts") ?? [])
        let legacyProgress = saveAccount == nil ? defaults.data(forKey: "orbitBloom.progress.v1").flatMap { try? JSONDecoder().decode(Progress.self, from: $0) } : nil
        progress = legacyProgress.flatMap { GardenWallet(progress: $0).isValid ? $0 : nil } ?? Progress()
        let sources = saveAccount.map { ["orbitBloom.player.\($0)", "orbitBloom.wallet.backup.\($0)"] } ?? ["orbitBloom.wallet.v2", "orbitBloom.wallet.backup"]
        let wallet = sources.compactMap { key in
            defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(GardenWallet.self, from: $0) }
        }.first(where: { $0.isValid })
        if let wallet { progress = wallet.progress; ecosystem = wallet.ecosystem; assistance = wallet.assistance ?? Assistance(); journey = wallet.journey ?? IslandJourney() }
        #if DEBUG
        // Explicit, resetting Store QA fixture. Never runs in Release or with keep-progress.
        if testing && !ProcessInfo.processInfo.arguments.contains("--keep-progress"),
           let option = ProcessInfo.processInfo.arguments.firstIndex(of:"--ui-stage"),
           ProcessInfo.processInfo.arguments.indices.contains(option+1),
           let stage = Int(ProcessInfo.processInfo.arguments[option+1]), (1...Level.total).contains(stage) {
            for id in 1..<stage { _ = progress.finish(level:id,score:500) }
        }
        #endif
        creditedOnDevice.formUnion(ecosystem.creditedTransactions)
        ecosystem.lives.refresh(at:Date())
        // Resume a saved puzzle, including earned/consumed boosters.
        let snapshot = wallet != nil ? wallet?.session : saveAccount == nil ? defaults.data(forKey:"orbitBloom.session.v1").flatMap { try? JSONDecoder().decode(GameEngine.Snapshot.self,from:$0) } : nil
        if let snapshot, GardenWallet(progress: progress, session: snapshot).isValid,
           let restored = GameEngine(snapshot:snapshot) {
            engine = restored; charged = wallet?.charged ?? defaults.bool(forKey: "orbitBloom.charged.v1"); sync()
            if restored.won { firstWin = progress.finish(level: restored.level.id, score: restored.score); ecosystem.lives.rewardWin(); result = true; save() }
            else if restored.lost { result = false; save() }
        }
    }
    var wallet: GardenWallet {
        GardenWallet(progress: progress, ecosystem: ecosystem, session: result == nil ? engine?.snapshot : nil,
                     charged: charged, assistance: assistance, journey: journey)
    }
    func save() {
        if let data = try? JSONEncoder().encode(wallet) {
            let source = saveAccount.map { "orbitBloom.player.\($0)" } ?? "orbitBloom.wallet.v2"
            let backup = saveAccount.map { "orbitBloom.wallet.backup.\($0)" } ?? "orbitBloom.wallet.backup"
            if let previous = defaults.data(forKey: source),
               let old = try? JSONDecoder().decode(GardenWallet.self, from: previous), old.isValid {
                defaults.set(previous, forKey: backup)
            }
            defaults.set(data,forKey:"orbitBloom.wallet.v2")
            if let saveAccount { defaults.set(data, forKey: "orbitBloom.player.\(saveAccount)") }
        }
        creditedOnDevice.formUnion(ecosystem.creditedTransactions)
        defaults.set(Array(creditedOnDevice), forKey: "orbitBloom.purchaseReceipts")
        defaults.set(charged, forKey: "orbitBloom.charged.v1")
        if let data = try? JSONEncoder().encode(progress) { defaults.set(data, forKey: "orbitBloom.progress.v1") }
        if let engine, result == nil, let data = try? JSONEncoder().encode(engine.snapshot) { defaults.set(data, forKey: "orbitBloom.session.v1") }
        else { defaults.removeObject(forKey: "orbitBloom.session.v1") }
        saveGeneration = UUID()
        onSave?()
    }
    /// First sign-in adopts the guest garden. Later accounts get isolated wallets.
    func useSaveAccount(_ key: String) {
        guard saveAccount != key else { return }
        save()
        if saveAccount != nil {
            let sources = ["orbitBloom.player.\(key)", "orbitBloom.wallet.backup.\(key)"]
            let saved = sources.compactMap { source in
                defaults.data(forKey: source).flatMap { try? JSONDecoder().decode(GardenWallet.self, from: $0) }
            }.first(where: { $0.isValid })
            installWallet(saved ?? GardenWallet())
        }
        saveAccount = key; defaults.set(key, forKey: "orbitBloom.saveAccount"); save()
    }
    @discardableResult func restoreWallet(_ saved: GardenWallet) -> Bool {
        guard !busy, !raceActive, activity == nil, saved.canReplace(wallet) else { return false }
        save() // Retain the previous local checkpoint before replacing the active wallet.
        if let previous = defaults.data(forKey: "orbitBloom.wallet.v2") {
            defaults.set(previous, forKey: restoreCheckpointKey)
        }
        installWallet(saved); save(); updateMusic(); return true
    }
    private var restoreCheckpointKey: String { "orbitBloom.wallet.beforeCloudRestore.\(saveAccount ?? "guest")" }
    var hasRestoreCheckpoint: Bool { defaults.data(forKey: restoreCheckpointKey) != nil }
    @discardableResult func undoCloudRestore() -> Bool {
        guard let data = defaults.data(forKey: restoreCheckpointKey),
              let saved = try? JSONDecoder().decode(GardenWallet.self, from: data),
              restoreWallet(saved) else { return false }
        defaults.removeObject(forKey: restoreCheckpointKey)
        return true
    }
    private func installWallet(_ saved: GardenWallet) {
        runID = UUID(); raceActive = false; activity = nil; activityRewarded = false; pendingTool = nil; blastKey = nil; busy = false
        result = nil; paused = false; selected = nil; hinted = []; clearing = []; tab = 0
        progress = saved.progress; ecosystem = saved.ecosystem; assistance = saved.assistance ?? Assistance(); journey = saved.journey ?? IslandJourney()
        charged = saved.charged ?? false; engine = saved.session.flatMap(GameEngine.init(snapshot:))
        ecosystem.lives.refresh(at: Date()); sync()
        if let engine, engine.won {
            firstWin = progress.finish(level: engine.level.id, score: engine.score)
            ecosystem.lives.rewardWin(); result = true
        } else if engine?.lost == true { result = false }
    }
    func start(_ level: Level) {
        guard progress.isUnlocked(level.id) else { showToast("Complete circuit \(progress.nextLevel) to open this place."); return }
        guard ecosystem.lives.spend(at:Date()) else { leave(); tab = 4; showToast("No lives yet. One returns every 30 minutes; farming and racing stay open."); return }
        pendingTool = nil
        blastKey = nil; blastID = UUID()
        runID = UUID()
        let seed = UInt64(level.id * 101)
        engine = GameEngine(level: level, seed: seed)
        selected = nil; hinted = []; clearing = []; result = nil; busy = false; paused = false
        charged = false; burstMode = false; hintText = ""; message = level.isOneShot ? "One move to clear every goal. Hints work; tools and shuffle rest." : "Swipe neighbors to match three, or tap a touching group."
        sync(); save()
    }
    func sync() {
        guard let engine else { return }
        cells = engine.cells; score = engine.score; moves = engine.moves; collected = engine.collected; frost = engine.frost
    }
    func tap(_ key: Int) {
        guard !busy, !paused, result == nil, let engine else { return }
        if let tool = pendingTool {
            guard ecosystem.tools[tool,default:0] > 0 else { return }
            ecosystem.tools[tool,default:0] -= 1; pendingTool = nil
            showBlast(at:key); effect("blast"); assistance.blasts += 1
            play(engine.activate(tool,at:key),allowCharge:false); return
        }
        if burstMode {
            guard charged || progress.boosters > 0 else { return }
            if charged { charged = false } else { progress.boosters -= 1 }
            burstMode = false; showBlast(at:key); effect("blast")
            play(engine.burst(at:key),allowCharge:false); return
        }
        if engine.powers[key] != nil {
            assistance.blasts += 1; showBlast(at:key); effect("blast")
            play(engine.detonate(at:key),allowCharge:false); return
        }
        let turn = engine.harvestCluster(at:key)
        if turn.accepted {
            play(turn)
        } else { message = "Find 2 or more touching pieces of the same kind."; effect("tap") }
    }
    func swipe(_ key: Int, dx: CGFloat, dy: CGFloat) {
        guard !busy, !paused, result == nil, let engine, max(abs(dx),abs(dy)) >= 16 else { return }
        let other = abs(dx) > abs(dy) ? key + (dx > 0 ? 1 : -1) : key + (dy > 0 ? -7 : 7)
        guard (0..<49).contains(other), abs(other/7-key/7)+abs(other%7-key%7) == 1 else { return }
        if engine.powers[key] != nil || engine.powers[other] != nil { assistance.blasts += 1; showBlast(at:other); effect("blast") }
        let turn = engine.swap(key,other)
        if turn.accepted { pendingTool = nil; burstMode = false; play(turn) }
        else { message = "Slide a neighbor to make 3 in a row. No turn spent."; effect("tap"); feedback(.rigid) }
    }
    func selectTool(_ tool: GardenTool) {
        guard !busy else { return }
        guard engine?.level.isOneShot != true else { showToast("One-shot circuits use one move. Your tools stay in your supplies."); return }
        guard ecosystem.tools[tool,default:0] > 0 else { showToast("Harvest compost in Farm to craft this tool."); return }
        pendingTool = pendingTool == tool ? nil : tool; burstMode = false
        message = pendingTool == nil ? "Swipe neighbors or tap a touching group." : tool.detail + ". Tap a target."; effect("tap")
    }
    private func play(_ turn: Turn, allowCharge: Bool = true) {
        guard turn.accepted else { message = "That swap needs to make a match. Try another!"; feedback(.rigid); return }
        busy = true; hinted = []; hintText = ""; selected = nil
        let currentRun = runID
        if turn.earnedCharge && allowCharge { charged = true }
        // Save farm water with the resolved board. Animations must not own rewards.
        ecosystem.water += turn.cascades.reduce(0) { $0 + $1.collected[.water,default:0] }
        save()
        Task {
            if let swapped = turn.swappedCells {
                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .spring(response:0.22,dampingFraction:0.8)) { cells = swapped }
                try? await Task.sleep(for:.milliseconds(testing ? 80 : 230))
            }
            for (i, wave) in turn.cascades.enumerated() {
                guard runID == currentRun else { return }
                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .easeOut(duration: 0.15)) { clearing = wave.cleared }
                tone(i); feedback(.light)
                try? await Task.sleep(for: .milliseconds(testing ? 50 : 180))
                guard runID == currentRun else { return }
                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .spring(response: 0.34, dampingFraction: 0.8)) { cells = wave.cells; clearing = [] }
                message = i > 0 ? "\(i + 1)× cascade · +\(wave.points)" : "+\(wave.points) · lovely match!"
                try? await Task.sleep(for: .milliseconds(testing ? 50 : 200))
            }
            guard runID == currentRun else { return }
            sync(); busy = false
            if turn.earnedCharge { message = "Starlight burst ready. Tap it to clear a cross!" }
            if let engine, engine.won {
                let before = progress.coins
                firstWin = progress.finish(level: engine.level.id, score: engine.score)
                if firstWin { recordWorldEvent(room:"bloom") }
                ecosystem.lives.rewardWin(); animateCoins(progress.coins-before); effect("win")
                result = true; feedback(.medium)
            } else if engine?.lost == true { result = false }
            save()
        }
    }
    func hint() {
        guard !busy, let engine else { return }
        guard let pair = engine.bestMove() else {
            engine.shuffle(); sync(); save(); message = "Fresh growth. Your hint was kept. Try again."; return
        }
        pendingTool = nil; burstMode = false
        guard assistance.spendHint(coins:&progress.coins) else { showToast("Earn hints in Field Tasks, or 3 coins from your farm or race."); return }
        hinted = [pair.0,pair.1]
        hintText = "Slide row \(7-pair.0/7), column \(pair.0%7+1) to row \(7-pair.1/7), column \(pair.1%7+1)."
        message = "Swipe the two glowing pieces."; effect("tap"); save()
    }
    func showBlast(at key:Int) {
        blastKey = key; blastID = UUID()
        let effectID = blastID
        Task {
            try? await Task.sleep(for:.milliseconds(UIAccessibility.isReduceMotionEnabled ? 100 : 650))
            guard blastID == effectID else { return }
            blastKey = nil
        }
    }
    func shuffle() {
        guard !busy, let engine else { return }
        guard !engine.level.isOneShot else { showToast("This one-shot formation stays fixed. A hint can help."); return }
        guard assistance.spendShuffle(coins:&progress.coins) else { showToast("Earn shuffles in Field Tasks, or use 15 earned coins."); return }
        hinted = []; hintText = ""; effect("cascade")
        let animated = !UIAccessibility.isReduceMotionEnabled
        busy = animated
        withAnimation(animated ? .easeInOut(duration:0.45) : nil) { engine.shuffle(); sync() }
        message = "A fresh arrangement. Tools and turns are kept."; save()
        // A moving piece's visual location differs from its final hit target.
        // Keep input closed through this finite animation and save its final board now.
        if animated {
            let currentRun = runID
            Task {
                try? await Task.sleep(for:.milliseconds(500))
                guard runID == currentRun else { return }
                busy = false
            }
        }
    }
    func claim(_ task:FieldTask) {
        guard task.claim(progress:progress,ecosystem:&ecosystem,assistance:&assistance) else { return }
        effect("craft"); showToast("\(task.tool.title), hints and shuffles added to your supplies."); save()
    }
    func toggleBurst() {
        guard !busy else { return }
        guard engine?.level.isOneShot != true else { showToast("One-shot circuits use one move. Your bursts are kept."); return }
        guard charged || progress.boosters > 0 else { showToast("Get a burst in the shop for 80 earned coins."); return }
        burstMode.toggle(); selected = nil
        message = burstMode ? "Tap a piece to clear its row and column." : "Swipe neighbors to match three, or tap a touching group."
    }
    func leave() { pendingTool = nil; blastKey = nil; blastID = UUID(); runID = UUID(); engine = nil; result = nil; busy = false; paused = false; charged = false; burstMode = false; hinted = []; clearing = []; hintText = ""; save() }
    func abandonCircuit() {
        guard engine != nil else { return }
        // A life was already committed by start(). Leaving never charges a second one.
        leave(); tab = 0; showToast("Circuit left. The attempt's life stays spent; your world is saved.")
    }
    func gardenAfterWin() { leave(); tab = 0 }
    func restore(_ task: GardenTask) {
        if progress.restore(task.id) { save(); showToast(progress.gardenComplete ? "Your little world is in bloom!" : "\(task.title) · restored!"); feedback(.medium) }
        else { showToast("Finish puzzles to earn 2 stars for this project.") }
    }
    func showToast(_ value: String) {
        toast = value
        Task { try? await Task.sleep(for: .seconds(3)); if toast == value { toast = nil } }
    }
    func feedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if progress.haptics { UIImpactFeedbackGenerator(style: style).impactOccurred() }
    }
    func tone(_ chain: Int) { effect(chain > 0 ? "cascade" : "match") }
    func effect(_ name: String) { AudioDirector.shared.effect(name,enabled:progress.sound) }
    func updateMusic() { AudioDirector.shared.theme(raceActive ? "race" : engine != nil ? "puzzle" : tab == 2 ? "farm" : "garden",enabled:ecosystem.music) }
    func refreshClock() { let old = ecosystem.lives; ecosystem.lives.refresh(at:Date()); if old != ecosystem.lives { save() } }
    func animateCoins(_ amount: Int) {
        lastCoinAward = amount; coinFlight = UUID()
        let event = coinFlight
        Task { try? await Task.sleep(for:.seconds(1.5)); if coinFlight == event { coinFlight = nil } }
    }
    func awardCoins(_ amount: Int) { progress.coins += max(0,amount); animateCoins(amount); effect("coin"); save() }
    func farmAction(_ id: Int, crop: Crop) {
        let now = Date()
        if let amount = ecosystem.harvest(id,at:now) { recordWorldEvent(room:"farm"); awardCoins(amount); effect("harvest"); showToast("Harvested! +\(amount) coins · +1 compost · +1 cargo") }
        else if ecosystem.plots[id].crop == nil {
            if ecosystem.plant(id,crop:crop,at:now) { effect("plant"); showToast("\(crop.title) planted. Tap to water and grow faster.") }
            else { showToast("Planting needs 1 seed and 2 water. Garden puzzles collect water.") }
        } else if ecosystem.waterPlot(id,at:now) { effect("water") }
        else { showToast("Your crop is growing. Come back when it blooms.") }
        save()
    }
    func craft(_ tool: GardenTool) {
        if ecosystem.craft(tool) { effect("craft"); showToast("\(tool.title) crafted!"); save() }
        else { showToast("Harvest \(tool.compostCost) compost to craft \(tool.title).") }
    }
    func refillLives() {
        refreshClock()
        guard ecosystem.lives.hearts < LifeBank.capacity else { showToast("Your regenerating lives are already full."); return }
        guard progress.coins >= 100 else { showToast("A refill costs 100 coins. Farm or race to earn more."); return }
        progress.coins -= 100; ecosystem.lives.refill(); effect("win"); save()
    }
    func applyTransaction(productID: String, transactionID: String) -> Bool {
        guard let pack = StorePack.all.first(where:{$0.id == productID}) else { return false }
        guard !creditedOnDevice.contains(transactionID), !ecosystem.creditedTransactions.contains(transactionID) else { return true }
        guard ecosystem.credit(pack.grant,transaction:transactionID) else { return false }
        progress.coins += pack.grant.coins
        save(); animateCoins(pack.grant.coins); effect("coin"); return true
    }
    func completeDelivery(_ run: DeliveryRun) {
        guard run.finished else { return }
        if run.won {
            recordWorldEvent(room:"rally")
            ecosystem.deliveries += 1; ecosystem.raceBest = max(ecosystem.raceBest,run.distance)
            if ecosystem.produce > 0 { ecosystem.produce -= 1; awardCoins(run.reward+40) }
            else { awardCoins(run.reward) }
            effect("win")
        } else { awardCoins(run.reward) }
        save()
    }

    func enterActivity(_ kind: IslandActivityKind) {
        guard engine == nil, !raceActive else { return }
        activity = kind; activityLevel = min(1000, journey.levels[kind.rawValue, default:0] + 1)
        activityRewarded = false; tab = 6; effect("tap"); updateMusic()
    }
    func exitActivity() { activity = nil; activityRewarded = false; tab = 5; save(); updateMusic() }
    func completeActivity(_ score: Int) {
        guard let activity, !activityRewarded,
              journey.complete(room:activity.rawValue, level:activityLevel, score:score) else { return }
        activityRewarded = true
        progress.stars = min(100_000_000, progress.stars + 1)
        ecosystem.water = min(100_000_000, ecosystem.water + 2)
        recordWorldEvent(room:activity.rawValue)
        awardCoins(25); effect("win"); feedback(.medium)
        showToast("Lio's project fund: +1 star · +25 coins · +2 water. Saved."); save()
    }
    func recordWorldEvent(room:String) {
        guard let date = eventClock.now else { return }
        journey.record(room:room, at:date)
    }
    func claimWorldEvent(_ event:WorldEvent) {
        guard let date = eventClock.now, journey.claim(event,at:date) else { return }
        ecosystem.tools[event.tool, default:0] += 1; save(); effect("craft")
        showToast("\(event.title): \(event.tool.title) added to the tool shed.")
    }
}
