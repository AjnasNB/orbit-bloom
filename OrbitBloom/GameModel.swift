import SwiftUI
import AVFoundation
import UIKit
import Match3Kit

@MainActor final class GameModel: ObservableObject {
    @Published var progress: Progress
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
    @Published var message = "Tap two neighbors, or swipe a piece."
    @Published var hintText = ""
    @Published var burstMode = false
    @Published var charged = false
    @Published var toast: String?
    @Published var showSettings = false
    @Published var paused = false
    @Published var firstWin = false
    private let defaults: UserDefaults
    private var audio: AVAudioPlayer?
    private var runID = UUID()
    let testing: Bool

    init(defaults: UserDefaults = .standard) {
        testing = ProcessInfo.processInfo.arguments.contains("--uitesting")
        self.defaults = defaults
        if testing && !ProcessInfo.processInfo.arguments.contains("--keep-progress") {
            defaults.removeObject(forKey: "orbitBloom.progress.v1")
            defaults.removeObject(forKey: "orbitBloom.session.v1")
        }
        progress = defaults.data(forKey: "orbitBloom.progress.v1").flatMap { try? JSONDecoder().decode(Progress.self, from: $0) } ?? Progress()
        // Resume a saved puzzle, including earned/consumed boosters.
        if let data = defaults.data(forKey: "orbitBloom.session.v1"), let snapshot = try? JSONDecoder().decode(GameEngine.Snapshot.self, from: data), let restored = GameEngine(snapshot: snapshot) {
            engine = restored; charged = defaults.bool(forKey: "orbitBloom.charged.v1"); sync()
            if restored.won { firstWin = progress.finish(level: restored.level.id, score: restored.score); result = true; save() }
            else if restored.lost { result = false; save() }
        }
    }
    func save() {
        defaults.set(charged, forKey: "orbitBloom.charged.v1")
        if let data = try? JSONEncoder().encode(progress) { defaults.set(data, forKey: "orbitBloom.progress.v1") }
        if let engine, result == nil, let data = try? JSONEncoder().encode(engine.snapshot) { defaults.set(data, forKey: "orbitBloom.session.v1") }
        else { defaults.removeObject(forKey: "orbitBloom.session.v1") }
    }
    func start(_ level: Level) {
        runID = UUID()
        let seed: UInt64 = testing ? UInt64(level.id * 101) : UInt64.random(in: 1...UInt64.max)
        engine = GameEngine(level: level, seed: seed)
        selected = nil; hinted = []; clearing = []; result = nil; busy = false; paused = false
        charged = false; burstMode = false; hintText = ""; message = "Tap two neighbors, or swipe a piece."
        sync(); save()
    }
    func sync() {
        guard let engine else { return }
        cells = engine.cells; score = engine.score; moves = engine.moves; collected = engine.collected; frost = engine.frost
    }
    func tap(_ key: Int) {
        guard !busy, !paused, result == nil, let engine else { return }
        if burstMode {
            guard charged || progress.boosters > 0 else { return }
            if charged { charged = false } else { progress.boosters -= 1 }
            burstMode = false
            play(engine.burst(at: key))
            return
        }
        if let source = selected {
            if source == key { selected = nil; return }
            if abs(source / 7 - key / 7) + abs(source % 7 - key % 7) == 1 { selected = nil; play(engine.swap(source, key)) }
            else { selected = key }
        } else { selected = key; feedback(.light) }
    }
    func swipe(_ key: Int, dx: CGFloat, dy: CGFloat) {
        guard !busy, !paused, !burstMode, result == nil, let engine else { return }
        let column = key % 7, row = key / 7
        let horizontal = abs(dx) > abs(dy)
        let c = column + (horizontal ? (dx > 0 ? 1 : -1) : 0)
        let r = row + (!horizontal ? (dy > 0 ? -1 : 1) : 0)
        guard (0..<7).contains(c), (0..<7).contains(r) else { return }
        selected = nil; play(engine.swap(key, r * 7 + c))
    }
    private func play(_ turn: Turn) {
        guard turn.accepted else { message = "That swap needs to make a match. Try another!"; feedback(.rigid); return }
        busy = true; hinted = []; hintText = ""; selected = nil
        let currentRun = runID
        if turn.earnedCharge { charged = true }
        // Persist the resolved board before animation, so an interruption cannot lose a turn.
        save()
        Task {
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
                firstWin = progress.finish(level: engine.level.id, score: engine.score)
                result = true; feedback(.medium)
            } else if engine?.lost == true { result = false }
            save()
        }
    }
    func hint() {
        guard !busy, let pair = engine?.bestMove() else { return }
        hinted = [pair.0, pair.1]
        hintText = "Try row \(7 - pair.0 / 7), column \(pair.0 % 7 + 1) with row \(7 - pair.1 / 7), column \(pair.1 % 7 + 1)."
        message = "The glowing pieces make a match."
    }
    func toggleBurst() {
        guard !busy else { return }
        guard charged || progress.boosters > 0 else { showToast("Get a burst in the shop for 80 earned coins."); return }
        burstMode.toggle(); selected = nil
        message = burstMode ? "Tap a piece to clear its row and column." : "Tap two neighbors, or swipe a piece."
    }
    func leave() { runID = UUID(); engine = nil; result = nil; busy = false; paused = false; save() }
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
    func tone(_ chain: Int) {
        guard progress.sound, let url = Bundle.main.url(forResource: "bloom\(min(chain, 4))", withExtension: "wav") else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        audio = try? AVAudioPlayer(contentsOf: url); audio?.volume = 0.25; audio?.play()
    }
}
