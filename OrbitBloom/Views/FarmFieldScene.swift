import SwiftUI
import SceneKit
import simd

struct FarmFieldInteraction: Equatable {
    enum Kind { case plant, water, harvest }
    let token = UUID()
    let plot: Int
    let kind: Kind
}

/// The controls use the actual camera projection, so crops and touch targets stay together.
final class FarmFieldSceneView: SCNView {
    var plotLocations: ([CGPoint]) -> Void = { _ in }
    var previousBounds = CGRect.zero
    static func location(_ id: Int) -> SCNVector3 {
        SCNVector3(id % 2 == 0 ? -2.0 : 2.0, 0.08, Float(id / 2) * 3 - 2.8)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0, bounds != previousBounds else { return }
        previousBounds = bounds
        pointOfView?.camera?.orthographicScale = max(4.15, 9.4 * Double(bounds.height / bounds.width) / 2)
        let points = (0..<6).map { id -> CGPoint in
            var anchor = Self.location(id); anchor.z += 0.9
            let screen = projectPoint(anchor)
            return CGPoint(x: CGFloat(screen.x) / bounds.width, y: CGFloat(screen.y) / bounds.height)
        }
        DispatchQueue.main.async { [weak self] in self?.plotLocations(points) }
    }
}

struct FarmFieldScene: UIViewRepresentable {
    let plots: [FarmPlot]
    let now: Date
    let interaction: FarmFieldInteraction?
    var variant:Int=0
    let onLocations: ([CGPoint]) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeCoordinator() -> FarmFieldWorld { FarmFieldWorld(variant:variant) }
    func makeUIView(context: Context) -> FarmFieldSceneView {
        let world = context.coordinator
        let view = FarmFieldSceneView()
        view.scene = world.scene; view.pointOfView = world.camera
        view.backgroundColor = UIColor(red: 0.72, green: 0.82, blue: 0.48, alpha: 1)
        view.antialiasingMode = .multisampling4X; view.preferredFramesPerSecond = 30
        view.allowsCameraControl = false; view.isUserInteractionEnabled = false
        view.isAccessibilityElement = false; view.accessibilityElementsHidden = true
        return view
    }
    func updateUIView(_ view: FarmFieldSceneView, context: Context) {
        view.plotLocations = onLocations
        context.coordinator.update(plots: plots, now: now, interaction: interaction, reducedMotion: reduceMotion)
        view.isPlaying = !reduceMotion
    }
    static func dismantleUIView(_ view: FarmFieldSceneView, coordinator: FarmFieldWorld) {
        view.isPlaying = false; view.scene = nil; view.pointOfView = nil; view.plotLocations = { _ in }
    }
}

final class FarmFieldWorld {
    let scene = SCNScene()
    let camera = SCNNode()
    private var patches: [SCNNode] = []
    private var plants: [Int: SCNNode] = [:]
    private var appearances: [Int: String] = [:]
    private var lastInteraction: UUID?
    private var reducedMotion = false

    init(variant:Int=0) {
        camera.camera = SCNCamera(); camera.camera?.usesOrthographicProjection = true
        camera.camera?.orthographicScale = 4.8
        camera.position = SCNVector3(0, 12, 13); camera.look(at: SCNVector3(0, 0.4, 0.3))
        scene.rootNode.addChildNode(camera)
        let sun = SCNNode(); sun.light = SCNLight(); sun.light?.type = .directional
        sun.light?.intensity = 1100; sun.light?.castsShadow = true; sun.light?.shadowRadius = 5
        sun.light?.shadowColor = UIColor.black.withAlphaComponent(0.18)
        sun.position = SCNVector3(-8, 15, 9); sun.look(at: .init(0, 0, 0)); scene.rootNode.addChildNode(sun)
        let sky = SCNNode(); sky.light = SCNLight(); sky.light?.type = .ambient; sky.light?.intensity = 600
        sky.light?.color = UIColor(red: 0.86, green: 0.95, blue: 1, alpha: 1); scene.rootNode.addChildNode(sky)
        let ground = mesh(SCNPlane(width:28,height:28), [UInt32(0xB6CF7A),0xADCDA2,0xCCD596][min(2,max(0,variant))])
        ground.eulerAngles.x = -.pi / 2; scene.rootNode.addChildNode(ground)
        // Continuous paths, furrowed soil and borders form a farm, without floating plot cards.
        path(from: .init(0, 0.04, -6.5), to: .init(0, 0.04, 7), width: 0.7)
        for row in 0..<3 { path(from: .init(-4.8, 0.04, Float(row) * 3 - 1.4), to: .init(4.0, 0.04, Float(row) * 3 - 1.4), width: 0.4) }
        for id in 0..<6 {
            let patch = SCNNode(); patch.position = FarmFieldSceneView.location(id); patch.name = "field-\(id)"
            let soil = mesh(SCNCylinder(radius: 1.4, height: 0.07), 0x865B37)
            soil.scale.z = 0.66; patch.addChildNode(soil)
            for furrow in -2...2 {
                let ridge = mesh(SCNBox(width: 2.1, height: 0.045, length: 0.09, chamferRadius: 0.04), 0xA47A4B,
                                 .init(0, 0.055, Float(furrow) * 0.28)); patch.addChildNode(ridge)
            }
            for pebble in 0..<7 {
                let angle = Float(pebble) * 2.4
                let stone = mesh(SCNSphere(radius: 0.055), 0xC0AA7F, .init(cos(angle) * 1.23, 0.07, sin(angle) * 0.72))
                stone.scale.y = 0.55; patch.addChildNode(stone)
            }
            patches.append(patch); scene.rootNode.addChildNode(patch)
        }
        farmhouse(); streamAndBridge(); fence(); borderPlants()
    }

    func update(plots: [FarmPlot], now: Date, interaction: FarmFieldInteraction?, reducedMotion: Bool) {
        let motionChanged = self.reducedMotion != reducedMotion
        self.reducedMotion = reducedMotion
        for plot in plots where patches.indices.contains(plot.id) {
            let stage = plot.stage(at: now)
            let key = "\(plot.crop?.rawValue ?? "empty")-\(stage.rawValue)"
            if appearances[plot.id] != key || motionChanged {
                if let previous = plants.removeValue(forKey: plot.id) {
                    if plot.crop == nil && !reducedMotion {
                        previous.runAction(.sequence([.group([.moveBy(x: 0, y: 0.5, z: 0, duration: 0.4), .fadeOut(duration: 0.4)]), .removeFromParentNode()]))
                        harvestIntoBasket(from: previous.position)
                    } else { previous.removeFromParentNode() }
                }
                appearances[plot.id] = key
                if let crop = plot.crop {
                    let plant = crop == .apple ? appleTree(stage: stage) : roseBush(stage: stage)
                    plant.name = "crop-\(plot.id)-\(crop.rawValue)-\(stage.rawValue)"
                    plant.position = FarmFieldSceneView.location(plot.id); plant.position.y += 0.12
                    scene.rootNode.addChildNode(plant); plants[plot.id] = plant
                    if !reducedMotion {
                        plant.runAction(.repeatForever(.sequence([.rotateBy(x: 0, y: 0, z: 0.018, duration: 1.8), .rotateBy(x: 0, y: 0, z: -0.018, duration: 1.8)])), forKey: "breeze")
                    }
                }
            }
            if let plant = plants[plot.id] {
                let size = Float(0.45 + 0.55 * plot.growth(at: now))
                SCNTransaction.begin(); SCNTransaction.animationDuration = reducedMotion ? 0 : 0.75
                plant.scale = SCNVector3(size, size, size); SCNTransaction.commit()
            }
        }
        if let interaction, interaction.token != lastInteraction {
            lastInteraction = interaction.token
            if interaction.kind == .water && !reducedMotion { water(at: interaction.plot) }
            if interaction.kind == .harvest && !reducedMotion { swingSickle(at:interaction.plot) }
        }
    }

    private func appleTree(stage: FarmGrowthStage) -> SCNNode {
        let plant = SCNNode()
        if stage == .sprout {
            stem(on: plant, from: .init(0, 0, 0), to: .init(0, 0.55, 0), radius: 0.045)
            leaf(on: plant, at: .init(-0.14, 0.4, 0), angle: -0.6, size: 0.38)
            leaf(on: plant, at: .init(0.16, 0.53, 0), angle: 0.7, size: 0.42)
            return plant
        }
        stem(on: plant, from: .init(0, 0, 0), to: .init(0, 1.9, 0), radius: 0.1)
        for index in 0..<7 {
            let angle = Float(index) * 2.4
            let position = SCNVector3(cos(angle) * 0.6, 1.35 + Float(index % 3) * 0.28, sin(angle) * 0.5)
            stem(on: plant, from: .init(0, 0.9, 0), to: position, radius: 0.035)
            let crown = mesh(SCNSphere(radius: 0.49), index % 2 == 0 ? 0x5F9E4B : 0x82B552, position)
            crown.scale = .init(1, 0.68, 0.9); plant.addChildNode(crown)
            leaf(on: plant, at: .init(position.x * 1.4, position.y + 0.12, position.z * 1.4), angle: angle, size: 0.46)
            if stage == .ripe {
                let fruitPosition = SCNVector3(position.x, position.y - 0.14, position.z + 0.38)
                let fruit = mesh(SCNSphere(radius: 0.19), 0xEF6550, fruitPosition); fruit.scale.y = 0.92
                fruit.name = "ripe-apple"; plant.addChildNode(fruit)
                stem(on: plant, from: .init(fruitPosition.x, fruitPosition.y + 0.14, fruitPosition.z), to: .init(fruitPosition.x + 0.02, fruitPosition.y + 0.25, fruitPosition.z), radius: 0.025)
            } else if stage == .flowering {
                flower(on: plant, at: .init(position.x, position.y, position.z + 0.39), color: 0xFFE6CF, size: 0.08)
            }
        }
        return plant
    }

    private func roseBush(stage: FarmGrowthStage) -> SCNNode {
        let plant = SCNNode()
        let count = stage == .sprout ? 2 : 5
        for index in 0..<count {
            let x = Float(index % 3 - 1) * 0.46, z = Float(index / 3) * 0.5 - 0.2
            let height: Float = stage == .sprout ? 0.42 : 0.95 + Float(index % 2) * 0.18
            stem(on: plant, from: .init(x, 0, z), to: .init(x, height, z), radius: 0.035, color: 0x4E8950)
            leaf(on: plant, at: .init(x - 0.13, height * 0.48, z), angle: -0.5, size: 0.39)
            leaf(on: plant, at: .init(x + 0.17, height * 0.72, z), angle: 0.55, size: 0.42)
            if stage == .ripe { flower(on: plant, at: .init(x, height, z), color: 0xEF8294, size: 0.2) }
            else if stage == .flowering {
                let bud = mesh(SCNSphere(radius: 0.13), 0xE7889B, .init(x, height, z)); bud.scale.y = 1.4; plant.addChildNode(bud)
            }
        }
        return plant
    }

    private func leaf(on parent: SCNNode, at position: SCNVector3, angle: Float, size: CGFloat) {
        // Share the pointed, veined artwork with the puzzle. Facing the camera
        // keeps the blade visible instead of showing only an edge and its veins.
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "LivingLeaf")
        material.lightingModel = .constant; material.isDoubleSided = true
        material.blendMode = .alpha; material.writesToDepthBuffer = false
        let blade = SCNPlane(width: size * 1.5, height: size * 1.5)
        blade.materials = [material]
        let leaf = SCNNode(geometry: blade); leaf.position = position
        leaf.eulerAngles = .init(-0.72, 0, angle)
        parent.addChildNode(leaf)
    }

    private func flower(on parent: SCNNode, at position: SCNVector3, color: UInt32, size: CGFloat) {
        let bloom = SCNNode(); bloom.position = position
        for ring in 0..<2 { for i in 0..<6 {
            let angle = Float(i) * .pi / 3 + Float(ring) * 0.3
            let petal = mesh(SCNSphere(radius: size * (ring == 0 ? 0.73 : 0.5)), color,
                             .init(cos(angle) * Float(size) * (ring == 0 ? 0.74 : 0.38), Float(ring) * 0.04, sin(angle) * Float(size) * (ring == 0 ? 0.74 : 0.38)))
            petal.scale.y = 0.48; petal.eulerAngles.z = angle * 0.15; bloom.addChildNode(petal)
        } }
        bloom.addChildNode(mesh(SCNSphere(radius: size * 0.28), 0xFAD78B, .init(0, 0.05, 0)))
        parent.addChildNode(bloom)
    }

    private func farmhouse() {
        let barn = SCNNode(); barn.position = .init(-2.8, 0, -4.9)
        barn.addChildNode(mesh(SCNBox(width: 2.5, height: 1.5, length: 1.7, chamferRadius: 0.06), 0xF8DFAC, .init(0, 0.75, 0)))
        barn.addChildNode(mesh(SCNPyramid(width: 3, height: 1.1, length: 2.2), 0x8C5140, .init(0, 1.45, 0)))
        barn.addChildNode(mesh(SCNBox(width: 0.65, height: 0.9, length: 0.06, chamferRadius: 0.05), 0x699994, .init(0, 0.47, 0.88)))
        for x: Float in [-0.8, 0.8] { barn.addChildNode(mesh(SCNBox(width: 0.45, height: 0.5, length: 0.06, chamferRadius: 0.02), 0xB1DCDD, .init(x, 0.95, 0.88))) }
        scene.rootNode.addChildNode(barn)
        let basket = mesh(SCNCylinder(radius: 0.36, height: 0.3), 0xB88145, .init(3.45, 0.18, 4.25))
        basket.name = "harvest-basket"; scene.rootNode.addChildNode(basket)
        for i in 0..<4 { scene.rootNode.addChildNode(mesh(SCNSphere(radius: 0.12), 0xED7A55, .init(3.3 + Float(i % 2) * 0.22, 0.35, 4.12 + Float(i / 2) * 0.2))) }
    }
    private func streamAndBridge() {
        let stream = mesh(SCNBox(width: 0.85, height: 0.025, length: 22, chamferRadius: 0.2), 0x85C9D2, .init(4.7, 0.035, 0)); scene.rootNode.addChildNode(stream)
        for i in 0..<9 { scene.rootNode.addChildNode(mesh(SCNSphere(radius: 0.15), 0xB1BEA0, .init(4.15, 0.09, Float(i) * 1.8 - 6))) }
        for i in 0..<8 { scene.rootNode.addChildNode(mesh(SCNBox(width: 1.35, height: 0.08, length: 0.13, chamferRadius: 0.025), 0xD9AF77, .init(4.65, 0.14, Float(i) * 0.16 - 1.9))) }
    }
    private func fence() {
        for side: Float in [-1, 1] { for i in 0..<9 {
            let z = Float(i) * 1.15 - 4.5, x = side * 5.8
            scene.rootNode.addChildNode(mesh(SCNCylinder(radius: 0.06, height: 0.65), 0xE7D5A5, .init(x, 0.34, z)))
            scene.rootNode.addChildNode(mesh(SCNBox(width: 0.05, height: 0.09, length: 1.2, chamferRadius: 0.02), 0xE7D5A5, .init(x, 0.48, z + 0.55)))
        } }
    }
    private func borderPlants() {
        for i in 0..<12 {
            let x: Float = i % 2 == 0 ? -4.15 : 4.12, z = Float(i / 2) * 2.2 - 6
            let bush = mesh(SCNSphere(radius: 0.36), i % 3 == 0 ? 0x7BAB57 : 0x91B969, .init(x, 0.42, z)); bush.scale.y = 0.7; scene.rootNode.addChildNode(bush)
        }
        for i in 0..<12 { let plant = SCNNode(); flower(on: plant, at: .init(Float(i % 6) * 1.4 - 4, 0.22, i < 6 ? -7 : 6.6), color: i % 2 == 0 ? 0xEDADC1 : 0xF8DF8C, size: 0.13); scene.rootNode.addChildNode(plant) }
    }
    private func water(at id: Int) {
        guard patches.indices.contains(id) else { return }
        for i in 0..<10 {
            let base = FarmFieldSceneView.location(id)
            let drop = mesh(SCNSphere(radius: 0.055), 0x66BADD, .init(base.x + Float(i % 5 - 2) * 0.18, 1.25, base.z + Float(i / 5) * 0.3))
            drop.scale.y = 1.5; scene.rootNode.addChildNode(drop)
            drop.runAction(.sequence([.wait(duration: Double(i) * 0.025), .group([.moveBy(x: 0, y: -1.1, z: 0, duration: 0.55), .fadeOut(duration: 0.6)]), .removeFromParentNode()]))
        }
    }
    private func swingSickle(at id:Int) {
        guard patches.indices.contains(id) else { return }
        let tool=SCNNode(); let base=FarmFieldSceneView.location(id); tool.position=SCNVector3(base.x+0.65,0.9,base.z+0.3)
        let curve=UIBezierPath(); curve.move(to:CGPoint(x:0.35,y:0.3))
        curve.addCurve(to:CGPoint(x:-0.3,y:0.65),controlPoint1:CGPoint(x:-0.65,y:0.15),controlPoint2:CGPoint(x:-0.6,y:0.85))
        curve.addCurve(to:CGPoint(x:0.35,y:0.3),controlPoint1:CGPoint(x:-0.5,y:0.45),controlPoint2:CGPoint(x:0,y:0.4)); curve.close()
        let blade=mesh(SCNShape(path:curve,extrusionDepth:0.04),0xD3E7EA); blade.geometry?.firstMaterial?.metalness.contents=0.55; tool.addChildNode(blade)
        let grip=mesh(SCNCylinder(radius:0.06,height:0.5),0xA77847,.init(0.4,0.05,0)); grip.eulerAngles.z=0.7; tool.addChildNode(grip)
        scene.rootNode.addChildNode(tool)
        tool.runAction(.sequence([.rotateBy(x:0,y:0,z:-1.4,duration:0.28),.rotateBy(x:0,y:0,z:0.8,duration:0.22),.fadeOut(duration:0.18),.removeFromParentNode()]))
    }
    private func harvestIntoBasket(from position: SCNVector3) {
        for i in 0..<4 {
            let reward = mesh(SCNSphere(radius: 0.13), 0xF7C75F, .init(position.x, 1.1, position.z)); scene.rootNode.addChildNode(reward)
            reward.runAction(.sequence([.wait(duration: Double(i) * 0.07), .move(to: .init(3.45, 0.4, 4.25), duration: 0.7), .fadeOut(duration: 0.12), .removeFromParentNode()]))
        }
    }
    private func path(from a: SCNVector3, to b: SCNVector3, width: CGFloat) {
        let dx = b.x - a.x, dz = b.z - a.z
        let node = mesh(SCNBox(width: width, height: 0.035, length: CGFloat(sqrt(dx * dx + dz * dz)), chamferRadius: width / 2), 0xDCC493,
                        .init((a.x + b.x) / 2, a.y, (a.z + b.z) / 2))
        node.eulerAngles.y = atan2(dx, dz); scene.rootNode.addChildNode(node)
    }
    private func stem(on parent: SCNNode, from a: SCNVector3, to b: SCNVector3, radius: CGFloat, color: UInt32 = 0x94704B) {
        let delta = SIMD3<Float>(b.x - a.x, b.y - a.y, b.z - a.z)
        let node = mesh(SCNCylinder(radius: radius, height: CGFloat(simd_length(delta))), color, .init((a.x + b.x) / 2, (a.y + b.y) / 2, (a.z + b.z) / 2))
        node.simdOrientation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta)); parent.addChildNode(node)
    }
    private func mesh(_ geometry: SCNGeometry, _ hex: UInt32, _ position: SCNVector3 = .init(0, 0, 0)) -> SCNNode {
        let material = SCNMaterial(); material.diffuse.contents = UIColor(red: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
        material.roughness.contents = 0.8; material.lightingModel = .physicallyBased; geometry.materials = [material]
        let node = SCNNode(geometry: geometry); node.position = position; node.castsShadow = true; return node
    }
}
