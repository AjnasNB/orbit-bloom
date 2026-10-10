import SwiftUI
import GameKit
import CryptoKit

struct CloudGarden: Identifiable {
    let save: SavedGarden
    let modified: Date
    let deviceName: String
    var id: UUID { save.id }
}

@MainActor protocol GardenCloudTransport {
    func fetch(playerKey: String) async throws -> [CloudGarden]
    func write(_ save: SavedGarden, name: String) async throws
}

@MainActor struct AppleGardenCloud: GardenCloudTransport {
    func fetch(playerKey: String) async throws -> [CloudGarden] {
        let prefix = "OrbitBloom-\(playerKey)-"
        let files: [GKSavedGame] = try await appleRequest { GKLocalPlayer.local.fetchSavedGames(completionHandler: $0) }
        var gardens: [CloudGarden] = []
        for file in files where file.name?.hasPrefix(prefix) == true {
            let data: Data = try await appleRequest { file.loadData(completionHandler: $0) }
            guard let save = SavedGarden.decode(data, playerKey: playerKey) else {
                throw CocoaError(.coderReadCorrupt)
            }
            gardens.append(CloudGarden(save: save, modified: file.modificationDate ?? save.savedAt,
                                       deviceName: file.deviceName ?? "Another device"))
        }
        return gardens.sorted { $0.modified > $1.modified }
    }
    func write(_ save: SavedGarden, name: String) async throws {
        let data = try save.encoded()
        let _: GKSavedGame = try await appleRequest { GKLocalPlayer.local.saveGameData(data, withName: name, completionHandler: $0) }
    }
}

/// Apple's callback can arrive after a network timeout. Resume exactly once.
@MainActor private final class AppleRequestResult<Value> {
    var continuation: CheckedContinuation<Value, Error>?
    var deadline: Task<Void, Never>?
    init(_ continuation: CheckedContinuation<Value, Error>) { self.continuation = continuation }
    func finish(_ value: Value?, _ error: Error?) {
        guard let continuation else { return }
        self.continuation = nil; deadline?.cancel(); deadline = nil
        if let error { continuation.resume(throwing: error) }
        else if let value { continuation.resume(returning: value) }
        else { continuation.resume(throwing: CocoaError(.coderReadCorrupt)) }
    }
}

@MainActor func appleRequest<Value>(timeout: Duration = .seconds(20), _ start: (@escaping (Value?, Error?) -> Void) -> Void) async throws -> Value {
    try await withCheckedThrowingContinuation { continuation in
        let result = AppleRequestResult(continuation)
        result.deadline = Task {
            do { try await Task.sleep(for: timeout) } catch { return }
            result.finish(nil, URLError(.timedOut))
        }
        start { value, error in Task { @MainActor in result.finish(value, error) } }
    }
}

struct GameCenterLogin: Identifiable {
    let id = UUID()
    let controller: UIViewController
}

struct GameCenterLoginView: UIViewControllerRepresentable {
    let controller: UIViewController
    func makeUIViewController(context: Context) -> UIViewController { controller }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

/// Game Center identifies the player. GameKit stores private saves in their iCloud Drive.
/// Each physical device writes its own file; another device's backup is never overwritten.
@MainActor final class PlayerAccount: NSObject, ObservableObject, GKLocalPlayerListener {
    @Published private(set) var nickname: String?
    @Published private(set) var working = false
    @Published private(set) var status = "Saved on this device"
    @Published private(set) var lastBackup: Date?
    @Published private(set) var choices: [CloudGarden] = []
    @Published var login: GameCenterLogin?
    @Published var showSaves = false
    @Published var enabled: Bool
    private(set) var playerKey: String?
    private let game: GameModel
    private let defaults: UserDefaults
    private let transport: GardenCloudTransport
    private let deviceID: String
    private var generation = UUID()
    private var pending: Task<Void, Never>?
    private var authStarted = false
    private var authDeadline: Task<Void, Never>?
    private var readyToWrite = false
    private var acknowledged: Set<String> = []
    private var failedCheck = false
    private let usesApple: Bool
    private let currentPlayerMatches: ((String) -> Bool)?
    var connected: Bool { playerKey != nil }

    init(game: GameModel, defaults: UserDefaults = .standard,
         transport: GardenCloudTransport? = nil, deviceID: String? = nil,
         currentPlayerMatches: ((String) -> Bool)? = nil) {
        self.game = game; self.defaults = defaults
        self.transport = transport ?? AppleGardenCloud(); usesApple = transport == nil
        self.currentPlayerMatches = currentPlayerMatches
        self.deviceID = deviceID ?? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        enabled = defaults.bool(forKey: "orbitBloom.cloud.enabled")
        super.init()
        game.onSave = { [weak self] in self?.scheduleBackup() }
    }
    func signIn() {
        guard !working else { return }
        enabled = true; defaults.set(true, forKey: "orbitBloom.cloud.enabled")
        if game.testing && usesApple {
            status = "Use a signed build and your Game Center account to connect. Your local save is safe."
            return
        }
        working = true; status = "Connecting to Game Center…"
        authStarted = true
        authDeadline?.cancel()
        authDeadline = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(20)) } catch { return }
            guard let self, self.working, !self.connected, self.login == nil else { return }
            self.working = false; self.status = "Game Center is taking longer to connect. Your local save is safe. Try again."
        }
        GKLocalPlayer.local.authenticateHandler = { [weak self] controller, error in
            Task { @MainActor in
                guard let self, self.enabled else { return }
                self.authDeadline?.cancel()
                if let controller { self.login = GameCenterLogin(controller: controller); self.working = false; return }
                self.login = nil
                guard GKLocalPlayer.local.isAuthenticated else {
                    self.disconnect(); self.status = "Game Center is not connected. Continue playing on this device."
                    return
                }
                let player = GKLocalPlayer.local
                player.register(self)
                await self.connect(playerID: player.gamePlayerID, nickname: player.displayName)
            }
        }
    }
    func resume() {
        guard enabled else { return }
        if !authStarted { signIn() }
        else if usesApple && !GKLocalPlayer.local.isAuthenticated { disconnect() }
        else if connected { Task { await checkSaves() } }
    }
    func disconnect() {
        generation = UUID(); pending?.cancel(); authDeadline?.cancel(); readyToWrite = false; working = false
        playerKey = nil; nickname = nil; choices = []; lastBackup = nil
    }
    func setEnabled(_ value: Bool) {
        enabled = value; defaults.set(value, forKey: "orbitBloom.cloud.enabled")
        if value {
            if connected { Task { await checkSaves() } } else { signIn() }
        } else {
            pending?.cancel(); authDeadline?.cancel(); generation = UUID(); readyToWrite = false; working = false
            status = "Cloud backup paused. Saved on this device."
        }
    }
    func connect(playerID: String, nickname: String) async {
        guard !playerID.isEmpty else { disconnect(); return }
        let key = SHA256.hash(data: Data(playerID.utf8)).map { String(format: "%02x", $0) }.joined()
        generation = UUID(); pending?.cancel(); readyToWrite = false; working = false; choices = []
        self.playerKey = key; self.nickname = nickname
        game.useSaveAccount(key)
        acknowledged = Set(defaults.stringArray(forKey: "orbitBloom.cloud.seen.\(key)") ?? [])
        lastBackup = defaults.object(forKey: "orbitBloom.cloud.date.\(key)") as? Date
        await checkSaves()
    }
    func checkSaves() async {
        guard enabled, let key = playerKey, !working else { return }
        guard requireCurrentPlayer(key) else { return }
        working = true; readyToWrite = false; failedCheck = false; status = "Checking your iCloud garden…"
        let run = generation
        do {
            let gardens = try await transport.fetch(playerKey: key)
            guard generation == run, playerKey == key, enabled else { return }
            guard requireCurrentPlayer(key) else { return }
            choices = gardens.filter { !acknowledged.contains($0.id.uuidString) }
            working = false
            if !choices.isEmpty {
                status = "A saved garden is available. Choose which progress to continue."
            } else {
                readyToWrite = true; await backup()
            }
        } catch {
            guard generation == run else { return }
            working = false; failedCheck = true
            status = "iCloud is unavailable. Your progress is saved here. Check iCloud Drive and retry."
        }
    }
    func keepDeviceGarden() async {
        guard enabled, !working, !failedCheck, let key = playerKey,
              requireCurrentPlayer(key) else { return }
        acknowledge(choices.map(\.id)); choices = []; readyToWrite = true
        await backup()
    }
    func restore(_ garden: CloudGarden) async {
        guard enabled, !working, let key = playerKey, requireCurrentPlayer(key),
              garden.save.playerKey == key,
              choices.contains(where: { $0.id == garden.id }) else { return }
        guard game.restoreWallet(garden.save.wallet) else {
            status = game.busy || game.raceActive || game.activity != nil ? "Finish this action before restoring your garden." :
                "This backup is missing a purchase credited here. Keep this device's garden to protect your items."
            return
        }
        acknowledge(choices.map(\.id)); choices = []; readyToWrite = true
        await backup()
    }
    func backup() async {
        guard enabled, readyToWrite, choices.isEmpty, !working, let key = playerKey else { return }
        guard requireCurrentPlayer(key) else { return }
        guard game.wallet.isValid else { status = "Your local garden needs checking before backup."; return }
        let save = SavedGarden(playerKey: key, wallet: game.wallet)
        let run = generation, localGeneration = game.saveGeneration
        working = true; status = "Backing up your garden…"
        do {
            try await transport.write(save, name: "OrbitBloom-\(key)-\(deviceID)")
            guard generation == run, playerKey == key, enabled else { return }
            guard requireCurrentPlayer(key) else { return }
            acknowledge([save.id]); lastBackup = Date()
            defaults.set(lastBackup, forKey: "orbitBloom.cloud.date.\(key)")
            working = false; status = "Backed up to iCloud"
            if game.saveGeneration != localGeneration { scheduleBackup() }
        } catch {
            guard generation == run else { return }
            working = false; status = "Backup waiting. Your progress is safe on this device. Retry when connected."
        }
    }
    private func applePlayerMatches(_ key: String) -> Bool {
        if let currentPlayerMatches { return currentPlayerMatches(key) }
        guard usesApple else { return true }
        guard GKLocalPlayer.local.isAuthenticated else { return false }
        return SHA256.hash(data: Data(GKLocalPlayer.local.gamePlayerID.utf8)).map { String(format: "%02x", $0) }.joined() == key
    }
    @discardableResult private func requireCurrentPlayer(_ key: String) -> Bool {
        guard game.saveAccount == key, applePlayerMatches(key) else {
            disconnect()
            status = "Game Center account changed. Your garden is kept on this device. Connect the current player to continue."
            return false
        }
        return true
    }
    private func acknowledge(_ ids: [UUID]) {
        guard let playerKey else { return }
        acknowledged.formUnion(ids.map(\.uuidString))
        // Bounded metadata; old files may be offered again, but can never silently replace a wallet.
        if acknowledged.count > 500 {
            acknowledged = Set(acknowledged.sorted().suffix(500)); acknowledged.formUnion(ids.map(\.uuidString))
        }
        defaults.set(Array(acknowledged), forKey: "orbitBloom.cloud.seen.\(playerKey)")
    }
    private func scheduleBackup() {
        guard enabled, connected, readyToWrite, choices.isEmpty else { return }
        pending?.cancel()
        pending = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(2)) } catch { return }
            guard !Task.isCancelled, let self else { return }
            await self.backup()
        }
    }
    nonisolated func player(_ player: GKPlayer, didModifySavedGame savedGame: GKSavedGame) {
        Task { @MainActor [weak self] in await self?.checkSaves() }
    }
    nonisolated func player(_ player: GKPlayer, hasConflictingSavedGames savedGames: [GKSavedGame]) {
        // Leave both files intact and offer them in the save picker.
        Task { @MainActor [weak self] in await self?.checkSaves() }
    }
}
