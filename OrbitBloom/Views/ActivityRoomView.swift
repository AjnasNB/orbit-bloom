import SwiftUI
import SceneKit

enum ActivityRoomKind: String {
    case farm, rally
    var title: String { self == .farm ? "Farm room" : "Rally room" }
    var purpose: String { self == .farm ? "Plant & harvest" : "Drive & deliver" }
    var accent: Color { Color(hex:self == .farm ? 0x527D49 : 0x356C8B) }
}

struct ActivityRoomEntrances: View {
    @EnvironmentObject var game:GameModel
    @Environment(\.dynamicTypeSize) private var textSize
    var body:some View {
        VStack(spacing:5) {
            Text("OTHER ROOMS · NO LIFE COST").font(.system(size:9,weight:.heavy,design:.rounded)).tracking(1).foregroundStyle(Palette.mint)
            if textSize.isAccessibilitySize {
                VStack(spacing:8) { entrance(.farm); entrance(.rally) }
            } else {
                HStack(spacing:10) { entrance(.farm); entrance(.rally) }
            }
        }.accessibilityElement(children:.contain).accessibilityIdentifier("activityRooms")
    }
    private func entrance(_ kind:ActivityRoomKind)->some View {
        Button { game.tab = kind == .farm ? 2 : 3; game.effect("tap") } label: {
            HStack(spacing:5) {
                ActivityRoomScene(kind:kind,detailed:false).frame(width:textSize.isAccessibilitySize ? 68 : 54,height:70).allowsHitTesting(false).accessibilityHidden(true)
                VStack(alignment:.leading,spacing:4) {
                    Text(kind.title).font(.system(.subheadline,design:.rounded,weight:.heavy)).foregroundStyle(Palette.night)
                    Text(kind.purpose).font(.system(.caption2,design:.rounded,weight:.semibold)).foregroundStyle(Palette.mint)
                    Label("Enter",systemImage:"door.left.hand.open").font(.system(.caption,design:.rounded,weight:.bold)).foregroundStyle(kind.accent)
                }.fixedSize(horizontal:false,vertical:true)
                Spacer(minLength:0)
            }.padding(.horizontal,8).padding(.vertical,7).frame(maxWidth:.infinity,minHeight:88)
                .background(Palette.paper,in:RoundedRectangle(cornerRadius:22))
                .overlay(RoundedRectangle(cornerRadius:22).stroke(kind.accent.opacity(0.22),lineWidth:1.5))
                .compositingGroup()
                .shadow(color:kind.accent.opacity(0.2),radius:0,y:5)
        }.buttonStyle(PressStyle())
            .accessibilityLabel("Enter \(kind.title). \(kind.purpose). No life cost.")
            .accessibilityHint("Opens a separate room with its own map and an Exit room button")
            .accessibilityIdentifier(kind == .farm ? "openFarm" : "openRace")
    }
}

struct RoomExitHeader: View {
    let kind:ActivityRoomKind
    let action:()->Void
    var body:some View {
        Button(action:action) {
            HStack(spacing:10) {
                Image(systemName:"xmark.circle.fill").font(.system(size:23)).accessibilityHidden(true)
                Text("Exit \(kind.title)").font(.system(.subheadline,design:.rounded,weight:.bold))
                Spacer(minLength:4)
                Label("Island",systemImage:"globe").font(.system(.caption,design:.rounded,weight:.bold))
            }.foregroundStyle(Palette.night).padding(.horizontal,14).frame(minHeight:48)
                .background(Palette.paper,in:Capsule()).overlay(Capsule().stroke(kind.accent.opacity(0.2),lineWidth:1))
        }.buttonStyle(PressStyle()).padding(.horizontal,22).padding(.bottom,8)
            .accessibilityLabel("Exit \(kind.title). Return to your island. Progress stays saved.").accessibilityIdentifier("returnWorld")
    }
}

struct RallyRoomMap: View {
    var body:some View {
        GeometryReader { geometry in
            ZStack {
                ActivityRoomScene(kind:.rally,detailed:true).allowsHitTesting(false).accessibilityHidden(true)
                VStack {
                    HStack { Text("ROUTE PREVIEW · 440 m").font(.system(size:10,weight:.heavy,design:.rounded)).foregroundStyle(Palette.night).padding(9).background(Palette.paper.opacity(0.95),in:Capsule()); Spacer() }
                    Spacer()
                }.padding(10)
                marker("Garage",symbol:"house.fill",detail:"START").position(x:geometry.size.width*0.24,y:geometry.size.height*0.69)
                marker("Orchard bend",symbol:"leaf.fill",detail:"PICKUPS").position(x:geometry.size.width*0.57,y:geometry.size.height*0.48)
                marker("Moonseed gate",symbol:"flag.checkered",detail:"FINISH").position(x:geometry.size.width*0.75,y:geometry.size.height*0.22)
            }.accessibilityElement(children:.combine).accessibilityLabel("Rally room route map: start at the Garage, pass the Orchard bend, finish at Moonseed gate. One 440-metre course.").accessibilityIdentifier("rallyRoomMap")
        }
    }
    private func marker(_ name:String,symbol:String,detail:String)->some View {
        VStack(spacing:3) {
            Label(detail,systemImage:symbol).font(.system(size:9,weight:.heavy,design:.rounded)).foregroundStyle(Color(hex:0x356C8B))
            Text(name).font(.system(size:11,weight:.bold,design:.rounded)).foregroundStyle(Palette.night)
        }.padding(.horizontal,10).padding(.vertical,7).background(Palette.paper,in:RoundedRectangle(cornerRadius:14)).compositingGroup().shadow(color:Palette.night.opacity(0.15),radius:0,y:3)
    }
}

// Original procedural meshes: static door miniatures, animated full room maps.
final class ActivityRoomSceneView: SCNView {
    var minimumScale:Double = 5.4
    var roomWidth:Double = 10.8
    var roomCamera:SCNCamera?
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }
        roomCamera?.orthographicScale = max(minimumScale,roomWidth*Double(bounds.height/bounds.width)/2)
    }
}

struct ActivityRoomScene: UIViewRepresentable {
    let kind:ActivityRoomKind
    let detailed:Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeUIView(context:Context)->ActivityRoomSceneView {
        let view=ActivityRoomSceneView(); view.backgroundColor = .clear; view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 30; view.allowsCameraControl = false; view.isUserInteractionEnabled = false
        view.isAccessibilityElement = false; view.accessibilityElementsHidden = true
        view.autoenablesDefaultLighting = false
        return view
    }
    func updateUIView(_ view:ActivityRoomSceneView,context:Context) {
        let key="\(kind.rawValue)-\(detailed)-\(reduceMotion)"
        guard view.accessibilityIdentifier != key else { return }
        view.accessibilityIdentifier=key; view.scene=scene(); view.isPlaying=detailed && !reduceMotion
        view.minimumScale=detailed ? 5.4 : 2.65; view.roomWidth=detailed ? 10.8 : 4.8
        view.roomCamera=view.scene?.rootNode.childNodes.first(where:{ $0.camera != nil })?.camera
        view.setNeedsLayout()
    }
    static func dismantleUIView(_ view:ActivityRoomSceneView,coordinator:()) { view.isPlaying=false; view.roomCamera=nil; view.scene=nil }
    private func scene()->SCNScene {
        let scene=SCNScene()
        let camera=SCNNode(); camera.camera=SCNCamera(); camera.camera?.usesOrthographicProjection=true
        camera.camera?.orthographicScale=detailed ? 5.4 : 2.65
        camera.position=detailed ? SCNVector3(6,11,12) : SCNVector3(5,7,9)
        camera.look(at:SCNVector3(0,0.3,0)); scene.rootNode.addChildNode(camera)
        let sun=SCNNode(); sun.light=SCNLight(); sun.light?.type = .directional; sun.light?.intensity=1050
        sun.light?.castsShadow=true; sun.light?.shadowRadius=4; sun.light?.shadowColor=UIColor.black.withAlphaComponent(0.18)
        sun.position=SCNVector3(-5,10,6); sun.look(at:SCNVector3Zero); scene.rootNode.addChildNode(sun)
        let ambient=SCNNode(); ambient.light=SCNLight(); ambient.light?.type = .ambient; ambient.light?.intensity=450
        ambient.light?.color=UIColor(red:0.90,green:0.97,blue:1,alpha:1); scene.rootNode.addChildNode(ambient)
        let width:CGFloat=detailed ? 7.6 : 3.8, length:CGFloat=detailed ? 8.4 : 3.8
        scene.rootNode.addChildNode(mesh(SCNBox(width:width,height:0.65,length:length,chamferRadius:0.45),0xB9A685,SCNVector3(0,-0.4,0)))
        scene.rootNode.addChildNode(mesh(SCNBox(width:width+0.05,height:0.18,length:length+0.05,chamferRadius:0.4),kind == .farm ? 0xB8DAA0 : 0x9FCABD,SCNVector3(0,0,0)))
        let building=SCNNode(); building.position=detailed ? (kind == .farm ? SCNVector3(-2.4,0,-3.1) : SCNVector3(-2.1,0,2.8)) : SCNVector3(-0.3,0,-0.7)
        building.addChildNode(mesh(SCNBox(width:1.85,height:1.2,length:1.35,chamferRadius:0.09),0xFFF3D4,SCNVector3(0,0.72,0)))
        building.addChildNode(mesh(SCNPyramid(width:2.3,height:0.95,length:1.9),kind == .farm ? 0x5F9F85 : 0x447B97,SCNVector3(0,1.32,0)))
        building.addChildNode(mesh(SCNBox(width:kind == .farm ? 0.52 : 1.3,height:0.85,length:0.05,chamferRadius:0.09),kind == .farm ? 0xA9DCD2 : 0x355E70,SCNVector3(0,0.55,0.7)))
        for side:Float in [-1,1] {
            building.addChildNode(mesh(SCNBox(width:0.32,height:0.38,length:0.06,chamferRadius:0.04),0x9FD4D9,SCNVector3(side*0.64,0.9,0.72)))
        }
        scene.rootNode.addChildNode(building)
        if kind == .farm {
            let pond=mesh(SCNCylinder(radius:detailed ? 0.65 : 0.3,height:0.05),0x79C6D7,detailed ? SCNVector3(2.4,0.16,-2.8) : SCNVector3(1.2,0.16,0.7)); pond.scale.z=1.4; scene.rootNode.addChildNode(pond)
            for i in 0..<(detailed ? 10 : 5) {
                let x:Float=detailed ? (i%2 == 0 ? -3.25 : 3.25) : Float(i%3)*0.5-0.5
                let z:Float=detailed ? Float(i/2)*1.35-2.5 : 1.0+Float(i/3)*0.5
                scene.rootNode.addChildNode(flower(x:x,z:z,color:i%2 == 0 ? 0xEDB3BB : 0xF5D17C))
            }
        } else {
            if detailed {
                // Ground-plane segments keep the route above the turf on every Metal renderer.
                let curves:[[SIMD2<Float>]] = [
                    [SIMD2(-2.1,2.8),SIMD2(-1.8,0.5),SIMD2(2.8,1.4),SIMD2(1,-0.4)],
                    [SIMD2(1,-0.4),SIMD2(-0.4,-1.5),SIMD2(1.5,-2.7),SIMD2(2.3,-3.2)]
                ]
                var roadPoints:[SIMD2<Float>] = []
                for (index,curve) in curves.enumerated() {
                    func point(_ t:Float)->SIMD2<Float> {
                        let u=1-t
                        return curve[0]*(u*u*u)+curve[1]*(3*u*u*t)+curve[2]*(3*u*t*t)+curve[3]*(t*t*t)
                    }
                    roadPoints += (index == 0 ? 0...18 : 1...18).map { point(Float($0)/18) }
                    for step in 0..<18 {
                        let a=point(Float(step)/18), b=point(Float(step+1)/18), middle=(a+b)/2
                        let delta=b-a, angle=atan2(delta.x,delta.y)
                        if step%3 == 1 {
                            let stripe=mesh(SCNBox(width:0.07,height:0.015,length:0.19,chamferRadius:0.007),0xFFF3D4,SCNVector3(middle.x,0.21,middle.y))
                            stripe.eulerAngles.y=angle; scene.rootNode.addChildNode(stripe)
                        }
                    }
                }
                var vertices:[SCNVector3]=[], indices:[Int32]=[]
                for index in roadPoints.indices {
                    let tangent=roadPoints[min(index+1,roadPoints.count-1)]-roadPoints[max(0,index-1)]
                    let length=sqrt(tangent.x*tangent.x+tangent.y*tangent.y)
                    let normal=SIMD2(-tangent.y,tangent.x)/length*0.575
                    for side:Float in [-1,1] {
                        let edge=roadPoints[index]+normal*side
                        vertices.append(SCNVector3(edge.x,0.2,edge.y))
                    }
                    if index < roadPoints.count-1 {
                        let a=Int32(index*2)
                        indices += [a,a+1,a+2,a+1,a+3,a+2]
                    }
                }
                let surface=SCNGeometry(sources:[SCNGeometrySource(vertices:vertices),SCNGeometrySource(normals:Array(repeating:SCNVector3(0,1,0),count:vertices.count))],elements:[SCNGeometryElement(indices:indices,primitiveType:.triangles)])
                let road=mesh(surface,0xC5B394,SCNVector3Zero)
                road.geometry?.firstMaterial?.isDoubleSided=true; scene.rootNode.addChildNode(road)
                for i in 0..<8 {
                    let tree=SCNNode(); tree.position=SCNVector3(i%2 == 0 ? -3.1 : 3.1,0.1,Float(i/2)*1.65-2.6)
                    tree.addChildNode(mesh(SCNCylinder(radius:0.08,height:0.75),0xAD825B,SCNVector3(0,0.37,0)))
                    tree.addChildNode(mesh(SCNSphere(radius:0.43),0x75AC80,SCNVector3(0,0.95,0)))
                    tree.addChildNode(mesh(SCNSphere(radius:0.11),0xDD7B75,SCNVector3(0.28,0.92,0.23))); scene.rootNode.addChildNode(tree)
                }
                for x:Float in [1.8,2.8] { scene.rootNode.addChildNode(mesh(SCNCylinder(radius:0.06,height:1.2),0xFFF0C8,SCNVector3(x,0.75,-3.2))) }
                scene.rootNode.addChildNode(mesh(SCNBox(width:1.2,height:0.25,length:0.15,chamferRadius:0.03),0xF3CA77,SCNVector3(2.3,1.3,-3.2)))
            }
            let rover=SCNNode(); rover.position=detailed ? SCNVector3(-1.25,0.15,2.0) : SCNVector3(0.3,0.15,0.85)
            rover.addChildNode(mesh(SCNBox(width:0.9,height:0.25,length:1.3,chamferRadius:0.12),0xF6D79F,SCNVector3(0,0.35,0)))
            rover.addChildNode(mesh(SCNBox(width:0.65,height:0.4,length:0.5,chamferRadius:0.1),0x6CAFB8,SCNVector3(0,0.61,-0.25)))
            rover.addChildNode(mesh(SCNBox(width:0.6,height:0.3,length:0.45,chamferRadius:0.04),0xB98456,SCNVector3(0,0.57,0.37)))
            for x:Float in [-0.47,0.47] { for z:Float in [-0.42,0.42] {
                let wheel=mesh(SCNCylinder(radius:0.24,height:0.13),0x3C4F4A,SCNVector3(x,0.25,z)); wheel.eulerAngles.z = .pi/2; rover.addChildNode(wheel)
            } }
            if detailed && !reduceMotion { rover.runAction(.repeatForever(.sequence([.moveBy(x:0,y:0.04,z:0,duration:1.6),.moveBy(x:0,y:-0.04,z:0,duration:1.6)]))) }
            scene.rootNode.addChildNode(rover)
        }
        return scene
    }
    private func flower(x:Float,z:Float,color:UInt32)->SCNNode {
        let flower=SCNNode(); flower.position=SCNVector3(x,0.15,z)
        flower.addChildNode(mesh(SCNCylinder(radius:0.035,height:0.5),0x5E9970,SCNVector3(0,0.25,0)))
        for petal in 0..<5 {
            let angle=Float(petal) * Float.pi * 2 / 5
            let bloom=mesh(SCNSphere(radius:0.17),color,SCNVector3(cos(angle)*0.15,0.55,sin(angle)*0.15)); bloom.scale.y=0.45; flower.addChildNode(bloom)
        }
        flower.addChildNode(mesh(SCNSphere(radius:0.09),0xD99F38,SCNVector3(0,0.57,0)))
        return flower
    }
    private func mesh(_ geometry:SCNGeometry,_ hex:UInt32,_ position:SCNVector3)->SCNNode {
        let material=SCNMaterial(); material.diffuse.contents=UIColor(red:CGFloat((hex>>16)&255)/255,green:CGFloat((hex>>8)&255)/255,blue:CGFloat(hex&255)/255,alpha:1)
        material.roughness.contents=0.75; material.lightingModel = .physicallyBased; geometry.materials=[material]
        let node=SCNNode(geometry:geometry); node.position=position; node.castsShadow=true; return node
    }
}
