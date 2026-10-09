import SwiftUI

struct PlayerAccountView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var account: PlayerAccount
    @State private var restoreChoice: CloudGarden?
    @State private var undoConfirmation = false
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: account.connected ? "cloud.fill" : "leaf.circle.fill")
                    .font(.system(size: 64)).foregroundStyle(Palette.mint).accessibilityHidden(true)
                VStack(spacing: 6) {
                    Text("Your garden travels with you.")
                        .font(.system(.title, design: .rounded, weight: .heavy)).multilineTextAlignment(.center)
                    Text(account.nickname.map { "Welcome, \($0)" } ?? "Play as a guest, or connect your Game Center account.")
                        .font(.system(.subheadline, design: .rounded)).multilineTextAlignment(.center)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Label(account.status, systemImage: account.lastBackup == nil ? "iphone" : "checkmark.icloud")
                        .font(.system(.headline, design: .rounded)).accessibilityIdentifier("saveStatus")
                    Text("\(game.progress.completed.count) stages · \(game.progress.restored.count)/6 restored · \(game.progress.coins) coins")
                        .font(.system(.subheadline, design: .rounded)).accessibilityIdentifier("saveSummary")
                    if let date = account.lastBackup {
                        Text("Last backup: \(date.formatted(date: .abbreviated, time: .shortened))").font(.footnote)
                    }
                    if account.working { ProgressView().accessibilityLabel("Connecting your saved garden") }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(20)
                    .background(.white, in: RoundedRectangle(cornerRadius: 24))
                if !account.connected {
                    Button { account.signIn() } label: {
                        Label("Connect Game Center", systemImage: "person.crop.circle.fill")
                            .font(.system(.headline, design: .rounded)).foregroundStyle(.white).frame(maxWidth: .infinity, minHeight: 54)
                    }.buttonStyle(.borderedProminent).tint(Palette.mint)
                        .accessibilityIdentifier("connectGameCenter").disabled(account.working)
                } else {
                    Toggle("Automatic iCloud backup", isOn: Binding(get: { account.enabled }, set: account.setEnabled))
                        .font(.system(.headline, design: .rounded)).accessibilityIdentifier("cloudBackupToggle")
                    Button("Check saved gardens") { Task { await account.checkSaves() } }
                        .frame(minHeight: 44).buttonStyle(.bordered).disabled(account.working || !account.enabled)
                        .accessibilityIdentifier("checkCloudSaves")
                    if !account.choices.isEmpty {
                        Text("Choose where to continue").font(.system(.title3, design: .rounded, weight: .bold))
                        Text("Gardens are kept separately. Coins and lives are never added together.")
                            .font(.footnote).foregroundStyle(Palette.mint)
                        ForEach(account.choices) { garden in
                            Button { restoreChoice = garden } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Label(garden.deviceName, systemImage: "cloud")
                                    Text("\(garden.save.wallet.progress.completed.count) stages · \(garden.save.wallet.progress.coins) coins")
                                    Text(garden.modified.formatted(date: .abbreviated, time: .shortened)).font(.caption)
                                }.frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                            }.buttonStyle(.bordered).disabled(account.working)
                        }
                        Button("Continue this device's garden") { Task { await account.keepDeviceGarden() } }
                            .frame(minHeight: 44).disabled(account.working).accessibilityIdentifier("keepDeviceGarden")
                    }
                }
                if game.hasRestoreCheckpoint {
                    Button("Undo last cloud restore") { undoConfirmation = true }
                        .frame(minHeight: 44).buttonStyle(.bordered)
                        .accessibilityIdentifier("undoCloudRestore")
                }
                VStack(alignment: .leading, spacing: 10) {
                    Label("Offline progress stays safe on this device.", systemImage: "checkmark.shield")
                    Label("Cloud backup needs iCloud Drive and a connection. Use the same Game Center and iCloud accounts on your devices.", systemImage: "icloud")
                    Label("Apple handles sign-in. We never ask for your password or receive your cloud saves.", systemImage: "lock")
                    Text("Guest saves can be lost if you delete the app. Before switching devices, check that your latest garden is backed up.")
                }.font(.footnote).foregroundStyle(Palette.mint)
            }.padding(24).frame(maxWidth: 560).frame(maxWidth: .infinity)
        }.background(Palette.paper).foregroundStyle(Palette.night)
            .navigationTitle("Player & saved garden").navigationBarTitleDisplayMode(.inline)
            .sheet(item: $account.login) { login in GameCenterLoginView(controller: login.controller).interactiveDismissDisabled() }
            .confirmationDialog("Continue this saved garden?", isPresented: Binding(get: { restoreChoice != nil }, set: { if !$0 { restoreChoice = nil } }), titleVisibility: .visible) {
                if let garden = restoreChoice {
                    Button("Use this saved garden") { restoreChoice = nil; Task { await account.restore(garden) } }
                }
                Button("Cancel", role: .cancel) { restoreChoice = nil }
            } message: {
                Text("This replaces your active device progress. A local checkpoint is kept, and other device backups stay in iCloud.")
            }
            .confirmationDialog("Return to your previous device garden?", isPresented: $undoConfirmation, titleVisibility: .visible) {
                Button("Return to previous garden") {
                    account.setEnabled(false)
                    if !game.undoCloudRestore() { game.showToast("Finish your action first. A checkpoint missing newer purchases cannot be used.") }
                }
                Button("Cancel", role: .cancel) {}
            } message: { Text("Automatic cloud backup pauses. Your cloud gardens are kept.") }
    }
}
