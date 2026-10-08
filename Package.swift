// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "OrbitBloomCore", platforms: [.macOS(.v13)], products: [.library(name: "OrbitBloomCore", targets: ["OrbitBloomCore"])], dependencies: [.package(path: "vendor/Match3Kit")], targets: [.target(name: "OrbitBloomCore", dependencies: ["Match3Kit"], path: "OrbitBloom/Core"), .testTarget(name: "OrbitBloomCoreTests", dependencies: ["OrbitBloomCore", "Match3Kit"], path: "OrbitBloomTests/Core")], swiftLanguageModes: [.v5])
