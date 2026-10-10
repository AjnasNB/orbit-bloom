import SwiftUI
import SceneKit

/// Stable identifiers keep the world doors independent of the current activity level.
enum IslandRoom: String, CaseIterable, Identifiable {
    case bloom, farm, rally, canal, fireflies, windmill, observatory
    var id: String { rawValue }
    var title: String {
        switch self {
        case .bloom: return "Bloom Circuits"
        case .farm: return "Farm Terraces"
        case .rally: return "Harvest Rally"
        case .canal: return "Canal Weave"
        case .fireflies: return "Firefly Trail"
        case .windmill: return "Windmill Works"
        case .observatory: return "Moon Observatory"
        }
    }
    var purpose: String {
        switch self {
        case .bloom: return "Clear frost with botanical powers"
        case .farm: return "Plant, harvest and craft tools"
        case .rally: return "Swipe lanes and deliver supplies"
        case .canal: return "Connect water to thirsty gardens"
        case .fireflies: return "Remember the lantern sequence"
        case .windmill: return "Time each charge to power the workshop"
        case .observatory: return "Slide star tiles to align the chart"
        }
    }
    var shortPurpose: String {
        switch self {
        case .bloom: return "Clear frost"
        case .farm: return "Plant & harvest"
        case .rally: return "Swipe road lanes"
        case .canal: return "Rotate water pipes"
        case .fireflies: return "Repeat lanterns"
        case .windmill: return "Time the charge"
        case .observatory: return "Slide star tiles"
        }
    }
    var symbol: String {
        switch self {
        case .bloom: return "leaf.fill"
        case .farm: return "carrot.fill"
        case .rally: return "flag.checkered"
        case .canal: return "drop.fill"
        case .fireflies: return "lightbulb.fill"
        case .windmill: return "wind"
        case .observatory: return "moon.stars.fill"
        }
    }
    var accent: Color { Color(hex: colorHex) }
    var colorHex: UInt32 {
        switch self {
        case .bloom: return 0xA75470
        case .farm: return 0x487548
        case .rally: return 0x386884
        case .canal: return 0x2C7B83
        case .fireflies: return 0xA26E13
        case .windmill: return 0x74669A
        case .observatory: return 0x4F6098
        }
    }
    var reward: String {
        switch self {
        case .bloom: return "Stars · coins · farm water"
        case .farm: return "Produce · compost · tools"
        case .rally: return "Coins · cargo delivery"
        default: return "Stars · coins · farm water"
        }
    }
    var lifeRule: String { self == .bloom ? "Puzzle life required" : "No life cost" }
}

/// A world directory rather than a website menu. Every door names its activity,
/// its benefit and its exit. The campaign map remains the restoration domain.
struct IslandHubView: View {
    let stars: Int
    let completedProjects: Int
    let activityLevels: [String: Int]
    let onChoose: (IslandRoom) -> Void
    let onExit: () -> Void
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // Retain the chosen room when rotation or Dynamic Type changes page capacity.
    @State private var selectedEntry: Int

    init(stars: Int, completedProjects: Int, activityLevels: [String: Int], initialRoom: IslandRoom? = nil,
         onChoose: @escaping (IslandRoom) -> Void, onExit: @escaping () -> Void) {
        self.stars = stars; self.completedProjects = completedProjects; self.activityLevels = activityLevels
        self.onChoose = onChoose; self.onExit = onExit
        _selectedEntry = State(initialValue: initialRoom.flatMap { IslandRoom.allCases.firstIndex(of: $0) } ?? -2)
    }

    var body: some View {
        GeometryReader { geometry in
            let singleRoom = textSize >= .xxxLarge || geometry.size.height < 490
            let roomsPerPage = singleRoom ? 1 : 2
            let splitWelcome = textSize.isAccessibilitySize || geometry.size.height < 420
            let starts = (splitWelcome ? [-2, -1] : [-1]) + Array(stride(from: 0, to: IslandRoom.allCases.count, by: roomsPerPage))
            let page = starts.lastIndex(where: { $0 <= selectedEntry }) ?? 0
            let start = starts[page]
            VStack(spacing: 10) {
                if !textSize.isAccessibilitySize || geometry.size.height >= 420 {
                    header(story: start < 0, compact: singleRoom)
                }
                if start == -2 {
                    conciseStory
                } else if start == -1 {
                    welcome(compact: geometry.size.height < 600, showStory: !splitWelcome)
                } else {
                    ViewThatFits(in: .vertical) {
                        VStack(spacing: 12) {
                            ForEach(Array(IslandRoom.allCases.dropFirst(start).prefix(roomsPerPage))) { room in
                                roomDoor(room, compact: !singleRoom, availableHeight: geometry.size.height)
                            }
                        }
                        VStack(spacing: 12) {
                            ForEach(Array(IslandRoom.allCases.dropFirst(start).prefix(roomsPerPage))) { room in
                                conciseDoor(room)
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    if !textSize.isAccessibilitySize {
                        Text("Different skills. One island to restore.")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(Palette.mint)
                    }
                }
                pageControl(page: page, starts: starts)
                exitButton
            }
            .padding(.horizontal, 20).padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .contentShape(Rectangle())
            // Paging wins over the large door button beneath the finger. A drag
            // must never both turn the directory page and enter that room.
            .highPriorityGesture(DragGesture(minimumDistance: 35).onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                turnPage(value.translation.width < 0 ? 1 : -1, page: page, starts: starts)
            })
            .accessibilityElement(children: .contain).accessibilityIdentifier("islandHub")
        }
    }

    private func header(story: Bool, compact: Bool) -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(story ? "Lio’s Atoll" : compact ? "Rooms" : "Seven island rooms")
                    .font(.system(compact ? .headline : .title2, design: .rounded, weight: .heavy))
                    .foregroundStyle(Palette.night).fixedSize(horizontal: false, vertical: true)
                if !textSize.isAccessibilitySize {
                    Text(story ? "A keeper. A garden. A new beginning." : "Choose a skill. Help the island grow.")
                        .font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(Palette.mint)
                }
            }
            Spacer(minLength: 0)
            if !textSize.isAccessibilitySize {
                ResourcePill(symbol: "star.fill", value: "\(stars)")
            }
        }
    }

    private var conciseStory: some View {
        VStack(spacing: 12) {
            if !textSize.isAccessibilitySize {
                Image("KeeperLio").resizable().scaledToFit().frame(height: 100).accessibilityHidden(true)
            }
            Text("Lio, a keeper apprentice, restores Aurora Atoll after the Great Eclipse.")
                .font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(Palette.night)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("keeperStory")
            Spacer(minLength: 0)
            Button { withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) { selectedEntry = -1 } } label: {
                Label("Your project", systemImage: "leaf.fill")
                    .font(.system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(Palette.night)
                    .frame(maxWidth: .infinity, minHeight: 48).padding(10)
                    .background(Palette.sunlight, in: RoundedRectangle(cornerRadius: 20))
            }.buttonStyle(PressStyle()).accessibilityIdentifier("keeperNextProject")
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func welcome(compact: Bool, showStory: Bool) -> some View {
        VStack(spacing: compact ? 10 : 14) {
            if showStory { HStack(alignment: .center, spacing: 12) {
                Image("KeeperLio").resizable().scaledToFit()
                    .frame(width: compact ? 64 : 88, height: compact ? 86 : 114)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Meet Lio")
                        .font(.system(.headline, design: .rounded, weight: .heavy)).foregroundStyle(Palette.night)
                    Text("A keeper apprentice rebuilding Aurora Atoll after the Great Eclipse.")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Palette.mint).fixedSize(horizontal: false, vertical: true)
                }
            }.accessibilityElement(children: .combine).accessibilityIdentifier("keeperStory") }
            if showStory && !textSize.isAccessibilitySize {
                AtollRoomScene(room: nil, restored: completedProjects)
                    .frame(maxWidth: .infinity).frame(height: compact ? 86 : 150)
                    .allowsHitTesting(false).accessibilityHidden(true)
                    .background(Color.white.opacity(0.35), in: RoundedRectangle(cornerRadius: 26))
                Text("Restore the gardens, reconnect the waterways and bring light back to the homes.")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(Palette.night)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }
            restorationCheckpoint
            Spacer(minLength: 0)
            if textSize.isAccessibilitySize {
                Button { withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) { selectedEntry = 0 } } label: {
                    Label("Rooms", systemImage: "door.left.hand.open")
                        .font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(Palette.night)
                        .frame(maxWidth: .infinity, minHeight: 48).padding(10)
                        .background(Palette.sunlight, in: RoundedRectangle(cornerRadius: 20))
                }.buttonStyle(PressStyle()).accessibilityLabel("Choose an island room").accessibilityIdentifier("chooseIslandRoom")
            } else {
                PrimaryButton(title: "Choose a room", symbol: "door.left.hand.open", id: "chooseIslandRoom") {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) { selectedEntry = 0 }
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var restorationCheckpoint: some View {
        let count = min(GardenTask.all.count, max(0, completedProjects))
        let task = count < GardenTask.all.count ? GardenTask.all[count].title : "Aurora Atoll is in bloom"
        return VStack(alignment: .leading, spacing: 5) {
            Text(count < GardenTask.all.count ? "NEXT RESTORATION" : "YOUR RESTORED ISLAND")
                .font(.system(.caption2, design: .rounded, weight: .heavy)).tracking(1).foregroundStyle(Palette.mint)
            Text(task).font(.system(.subheadline, design: .rounded, weight: .heavy)).foregroundStyle(Palette.night)
                .fixedSize(horizontal: false, vertical: true)
            Text(count < GardenTask.all.count ? "\(count)/6 · \(stars) stars · cost: 2 stars" : "6/6 complete · keep exploring")
                .font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(Palette.mint)
                .fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(14)
            .background(Palette.paper, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityElement(children: .combine).accessibilityIdentifier("hubRestoration")
    }

    private func conciseDoor(_ room: IslandRoom) -> some View {
        let challenge = max(1, activityLevels[room.rawValue] ?? 1)
        return Button { onChoose(room) } label: {
            VStack(alignment: .leading, spacing: 7) {
                Text(room.title).font(.system(.subheadline, design: .rounded, weight: .heavy)).foregroundStyle(Palette.night)
                    .fixedSize(horizontal: false, vertical: true)
                Text(room.shortPurpose).font(.system(.caption2, design: .rounded, weight: .semibold)).foregroundStyle(room.accent)
                    .fixedSize(horizontal: false, vertical: true)
                Label("Enter", systemImage: "door.left.hand.open")
                    .font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(Palette.night)
            }.frame(maxWidth: .infinity, minHeight: 60, alignment: .leading).padding(14)
                .background(Palette.paper, in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(room.accent.opacity(0.25), lineWidth: 1.5))
        }.buttonStyle(PressStyle())
            .accessibilityLabel("Enter \(room.title). \(room.purpose). Challenge \(challenge). \(room.reward). \(room.lifeRule).")
            .accessibilityHint("Opens the game room; use its visible exit to leave")
            .accessibilityIdentifier("hubRoom_\(room.rawValue)")
    }

    private func roomDoor(_ room: IslandRoom, compact: Bool, availableHeight: CGFloat) -> some View {
        let challenge = max(1, activityLevels[room.rawValue] ?? 1)
        let rank = room == .farm ? "6 growing plots" : room == .rally ? "Delivery route" : room == .bloom ? "Level \(challenge)" : "Challenge \(challenge)"
        return Button { onChoose(room) } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    AtollRoomScene(room: room, restored: completedProjects)
                        .frame(height: compact ? min(130, max(72, availableHeight * 0.17)) : min(220, max(105, availableHeight * 0.27)))
                        .allowsHitTesting(false).accessibilityHidden(true)
                    Label(rank, systemImage: room.symbol)
                        .font(.system(.caption2, design: .rounded, weight: .heavy)).foregroundStyle(room.accent)
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Palette.paper.opacity(0.96), in: Capsule()).padding(10)
                }
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(room.title).font(.system(.headline, design: .rounded, weight: .heavy)).foregroundStyle(Palette.night)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Image(systemName: "door.left.hand.open").accessibilityHidden(true).foregroundStyle(room.accent)
                    }
                    Text(room.purpose).font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(Palette.mint)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Text(room.reward).font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(room.accent)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        if !textSize.isAccessibilitySize {
                            Text("Enter").font(.system(.caption, design: .rounded, weight: .heavy)).foregroundStyle(Palette.night)
                        }
                    }
                    if !compact {
                        Text(room.lifeRule).font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(Palette.mint)
                    }
                }.padding(.horizontal, 15).padding(.top, 2).padding(.bottom, 13)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.paper, in: RoundedRectangle(cornerRadius: 24))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(room.accent.opacity(0.2), lineWidth: 1.5))
            .compositingGroup().shadow(color: room.accent.opacity(0.18), radius: 0, y: 5)
        }.buttonStyle(PressStyle())
            .accessibilityLabel("Enter \(room.title). \(room.purpose). \(rank). \(room.reward). \(room.lifeRule).")
            .accessibilityHint("Opens a separate game room with a visible exit")
            .accessibilityIdentifier("hubRoom_\(room.rawValue)")
    }

    private func pageControl(page: Int, starts: [Int]) -> some View {
        Text("Swipe · \(page + 1)/\(starts.count)")
            .font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(Palette.mint)
            .frame(maxWidth: .infinity, minHeight: 24)
            .accessibilityLabel("Island room pages").accessibilityValue("Page \(page + 1) of \(starts.count)")
            .accessibilityIdentifier("hubPages")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: turnPage(1, page: page, starts: starts)
                case .decrement: turnPage(-1, page: page, starts: starts)
                @unknown default: break
                }
            }
            .accessibilityAction(named: "Next room page") { turnPage(1, page: page, starts: starts) }
            .accessibilityAction(named: "Previous room page") { turnPage(-1, page: page, starts: starts) }
    }

    private var exitButton: some View {
        Button(action: onExit) {
            Label(textSize.isAccessibilitySize ? "Island" : "Exit rooms · Your island", systemImage: "xmark.circle.fill")
                .font(.system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(Palette.night)
                .frame(maxWidth: .infinity, minHeight: 48).background(Palette.paper, in: Capsule())
                .overlay(Capsule().stroke(Palette.mint.opacity(0.18), lineWidth: 1))
        }.buttonStyle(PressStyle()).accessibilityLabel("Exit island rooms. Return to your island. Progress stays saved.")
            .accessibilityIdentifier("exitIslandHub")
    }

    private func turnPage(_ offset: Int, page: Int, starts: [Int]) {
        let target = min(starts.count - 1, max(0, page + offset))
        guard target != page else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) { selectedEntry = starts[target] }
    }
}

private final class AtollSceneView: SCNView {
    var sceneCamera: SCNCamera?
    var visibleWidth: Double = 8.2
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }
        sceneCamera?.orthographicScale = max(4.15, visibleWidth * Double(bounds.height / bounds.width) / 2)
    }
}

/// Original, static SceneKit miniatures. Decorative maps cannot steal a swipe
/// or accessibility focus; the labeled native door is the only hit target.
private struct AtollRoomScene: UIViewRepresentable {
    let room: IslandRoom?
    let restored: Int
    func makeUIView(context: Context) -> AtollSceneView {
        let view = AtollSceneView()
        view.backgroundColor = .clear; view.antialiasingMode = .multisampling4X
        view.isUserInteractionEnabled = false; view.accessibilityElementsHidden = true
        view.autoenablesDefaultLighting = false; view.isPlaying = false
        return view
    }
    func updateUIView(_ view: AtollSceneView, context: Context) {
        let key = "\(room?.rawValue ?? "atoll")-\(restored)"
        guard view.accessibilityIdentifier != key else { return }
        view.accessibilityIdentifier = key
        view.scene = makeScene(); view.isPlaying = false
        view.sceneCamera = view.scene?.rootNode.childNodes.first(where: { $0.camera != nil })?.camera
        view.setNeedsLayout()
    }
    static func dismantleUIView(_ view: AtollSceneView, coordinator: ()) {
        view.isPlaying = false; view.sceneCamera = nil; view.scene = nil
    }
    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        let camera = SCNNode(); camera.camera = SCNCamera(); camera.camera?.usesOrthographicProjection = true
        camera.camera?.orthographicScale = 4.15; camera.position = SCNVector3(7, 10, 11)
        camera.look(at: SCNVector3(0, 0.4, 0)); scene.rootNode.addChildNode(camera)
        let sun = SCNNode(); sun.light = SCNLight(); sun.light?.type = .directional
        sun.light?.intensity = 1050; sun.light?.castsShadow = true; sun.light?.shadowRadius = 4
        sun.light?.shadowColor = UIColor.black.withAlphaComponent(0.18)
        sun.position = SCNVector3(-5, 8, 7); sun.look(at: SCNVector3Zero); scene.rootNode.addChildNode(sun)
        let ambient = SCNNode(); ambient.light = SCNLight(); ambient.light?.type = .ambient
        ambient.light?.intensity = 420; scene.rootNode.addChildNode(ambient)
        scene.rootNode.addChildNode(node(SCNBox(width: 6.2, height: 0.65, length: 4.1, chamferRadius: 0.4), 0xBDA783, .init(0, -0.45, 0)))
        scene.rootNode.addChildNode(node(SCNBox(width: 6.24, height: 0.15, length: 4.14, chamferRadius: 0.4), room == .observatory ? 0xB0C4DB : 0xB3D1A1, .init(0, -0.03, 0)))
        if let room { decorate(room, root: scene.rootNode) }
        else {
            house(root: scene.rootNode, x: -1.7, z: -0.6, color: 0xF5CC82)
            house(root: scene.rootNode, x: 0.7, z: -0.8, color: 0x83B5B1)
            water(root: scene.rootNode, x: 1.8, z: 0.8, length: 1.3)
            for index in 0..<6 {
                flower(root: scene.rootNode, x: Float(index) * 0.68 - 2, z: 1.1,
                       color: index < restored ? 0xECAAAD : 0xA7BCA3)
            }
        }
        return scene
    }
    private func decorate(_ room: IslandRoom, root: SCNNode) {
        switch room {
        case .bloom:
            for index in 0..<9 {
                let x = Float(index % 3) * 1.2 - 1.2, z = Float(index / 3) * 0.85 - 0.9
                flower(root: root, x: x, z: z, color: [0xEBAAB9, 0xF2D590, 0xAAABD9][index % 3])
            }
            root.addChildNode(node(SCNSphere(radius: 0.44), 0xEDCAA8, .init(2.35, 0.7, 0.35)))
            root.addChildNode(node(SCNBox(width: 0.55, height: 0.9, length: 0.55, chamferRadius: 0.16), 0xA5D8DB, .init(-2.4, 0.55, -0.45)))
        case .farm:
            house(root: root, x: -1.9, z: -0.6, color: 0x7AAC8D)
            for index in 0..<6 {
                let x = Float(index % 3) * 0.9 + 0.1, z = Float(index / 3) * 0.85
                root.addChildNode(node(SCNBox(width: 0.74, height: 0.22, length: 0.6, chamferRadius: 0.08), 0xA37B57, .init(x, 0.14, z)))
                flower(root: root, x: x, z: z, color: index.isMultiple(of: 2) ? 0xEBB1B6 : 0xF1D783)
            }
        case .rally:
            root.addChildNode(node(SCNBox(width: 5.4, height: 0.06, length: 1.2, chamferRadius: 0.18), 0xC4B699, .init(0, 0.1, 0.15)))
            for index in 0..<7 { root.addChildNode(node(SCNBox(width: 0.35, height: 0.01, length: 0.07, chamferRadius: 0.01), 0xFFF7D9, .init(Float(index) * 0.7 - 2.1, 0.14, 0.15))) }
            house(root: root, x: -1.9, z: -0.95, color: 0x83A7BA)
            for x: Float in [1.35, 2.65] { root.addChildNode(node(SCNCylinder(radius: 0.08, height: 1.5), 0xFFF0D0, .init(x, 0.9, 0.05))) }
            root.addChildNode(node(SCNBox(width: 1.6, height: 0.28, length: 0.2, chamferRadius: 0.06), 0xF0C66F, .init(2, 1.62, 0.05)))
            tree(root: root, x: 0.3, z: -1.2)
        case .canal:
            water(root: root, x: 0, z: 0.1, length: 3.5)
            root.addChildNode(node(SCNBox(width: 4.8, height: 0.09, length: 0.42, chamferRadius: 0.12), 0x81C4DA, .init(0, 0.1, 0.1)))
            for x: Float in [-1.6, 1.6] {
                root.addChildNode(node(SCNBox(width: 0.55, height: 0.25, length: 1.5, chamferRadius: 0.08), 0xEDD0A3, .init(x, 0.22, 0.1)))
                flower(root: root, x: x, z: -1.3, color: 0xDBB0CA)
                flower(root: root, x: x, z: 1.3, color: 0xEED28C)
            }
        case .fireflies:
            for index in 0..<5 {
                let x = Float(index) * 1.0 - 2, z: Float = index.isMultiple(of: 2) ? 0.65 : -0.7
                root.addChildNode(node(SCNCylinder(radius: 0.06, height: 0.8), 0x927250, .init(x, 0.5, z)))
                root.addChildNode(node(SCNSphere(radius: 0.32), 0xFFE4A2, .init(x, 1.1, z)))
                root.addChildNode(node(SCNSphere(radius: 0.07), 0xFFF6B7, .init(x + 0.35, 1.3, z + 0.2)))
            }
            tree(root: root, x: -2.6, z: -1.05); tree(root: root, x: 2.5, z: -1.05)
        case .windmill:
            root.addChildNode(node(SCNCone(topRadius: 0.45, bottomRadius: 0.8, height: 1.9), 0xFFF0D6, .init(0, 1.08, 0)))
            root.addChildNode(node(SCNCone(topRadius: 0, bottomRadius: 0.8, height: 0.65), 0x8F9BAE, .init(0, 2.26, 0)))
            let blades = SCNNode(); blades.position = .init(0, 1.85, 0.75)
            for index in 0..<4 {
                let blade = node(SCNBox(width: 0.27, height: 1.75, length: 0.09, chamferRadius: 0.035), 0xA896C4, .init(0, 0, 0))
                blade.eulerAngles.z = Float(index) * .pi / 2 + .pi / 4; blades.addChildNode(blade)
            }
            blades.addChildNode(node(SCNSphere(radius: 0.18), 0xE8C784, .init(0, 0, 0.06))); root.addChildNode(blades)
            water(root: root, x: -1.8, z: 0.3, length: 1.2)
            flower(root: root, x: 1.7, z: 0.5, color: 0xDFC5EF)
        case .observatory:
            root.addChildNode(node(SCNCylinder(radius: 1.1, height: 0.75), 0xFFF0D7, .init(0, 0.53, 0)))
            let dome = node(SCNSphere(radius: 1.1), 0x7D9FC0, .init(0, 0.94, 0)); dome.scale.y = 0.6; root.addChildNode(dome)
            let telescope = node(SCNCylinder(radius: 0.17, height: 1.45), 0xF2D296, .init(0.75, 1.7, 0.6)); telescope.eulerAngles.z = -.pi / 4; root.addChildNode(telescope)
            for index in 0..<4 {
                root.addChildNode(node(SCNSphere(radius: index == 1 ? 0.13 : 0.08), 0xFFE9AB, .init(Float(index) * 0.9 - 1.4, 2.6 + Float(index % 2) * 0.3, -0.4)))
            }
        }
    }
    private func house(root: SCNNode, x: Float, z: Float, color: UInt32) {
        root.addChildNode(node(SCNBox(width: 1.3, height: 1.0, length: 1.0, chamferRadius: 0.09), 0xFFF0D6, .init(x, 0.61, z)))
        root.addChildNode(node(SCNPyramid(width: 1.65, height: 0.75, length: 1.4), color, .init(x, 1.1, z)))
        root.addChildNode(node(SCNBox(width: 0.37, height: 0.63, length: 0.05, chamferRadius: 0.07), 0x90BDCB, .init(x, 0.44, z + 0.52)))
    }
    private func water(root: SCNNode, x: Float, z: Float, length: CGFloat) {
        root.addChildNode(node(SCNBox(width: 0.62, height: 0.06, length: length, chamferRadius: 0.2), 0x83C7D9, .init(x, 0.08, z)))
    }
    private func tree(root: SCNNode, x: Float, z: Float) {
        root.addChildNode(node(SCNCylinder(radius: 0.08, height: 0.75), 0xAE845C, .init(x, 0.48, z)))
        root.addChildNode(node(SCNSphere(radius: 0.52), 0x77A67D, .init(x, 1.04, z)))
    }
    private func flower(root: SCNNode, x: Float, z: Float, color: UInt32) {
        root.addChildNode(node(SCNCylinder(radius: 0.035, height: 0.48), 0x659A73, .init(x, 0.38, z)))
        for index in 0..<5 {
            let angle = Float(index) * .pi * 2 / 5
            let petal = node(SCNSphere(radius: 0.19), color, .init(x + cos(angle) * 0.17, 0.65, z + sin(angle) * 0.17))
            petal.scale.y = 0.45; root.addChildNode(petal)
        }
        root.addChildNode(node(SCNSphere(radius: 0.09), 0xD6A245, .init(x, 0.68, z)))
    }
    private func node(_ geometry: SCNGeometry, _ hex: UInt32, _ position: SCNVector3) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
        material.roughness.contents = 0.78; material.lightingModel = .physicallyBased
        geometry.materials = [material]
        let result = SCNNode(geometry: geometry); result.position = position; return result
    }
}
