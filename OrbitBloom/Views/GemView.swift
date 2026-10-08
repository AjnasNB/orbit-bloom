import SwiftUI

struct Droplet: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.65), control1: CGPoint(x: rect.width * 0.63, y: rect.height * 0.24), control2: CGPoint(x: rect.maxX, y: rect.height * 0.43))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.height * 0.65), control1: CGPoint(x: rect.maxX, y: rect.height * 1.12), control2: CGPoint(x: rect.minX, y: rect.height * 1.12))
        path.addCurve(to: CGPoint(x: rect.midX, y: 0), control1: CGPoint(x: rect.minX, y: rect.height * 0.43), control2: CGPoint(x: rect.width * 0.37, y: rect.height * 0.24))
        return path
    }
}
struct Crystal: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.width * 0.5, y: 0))
            p.addLine(to: CGPoint(x: rect.width * 0.95, y: rect.height * 0.3))
            p.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.8))
            p.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height))
            p.addLine(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.72))
            p.addLine(to: CGPoint(x: rect.width * 0.05, y: rect.height * 0.3)); p.closeSubpath()
        }
    }
}
struct GemView: View {
    let gem: Gem
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                switch gem {
                case .leaf:
                    Ellipse().fill(LinearGradient(colors: [Color(hex: 0xB7E6A4), Color(hex: 0x3B9562)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: s * 0.6, height: s * 0.88).rotationEffect(.degrees(38))
                    Capsule().fill(Color(hex: 0xD3F0B5)).frame(width: s * 0.045, height: s * 0.68).rotationEffect(.degrees(38))
                case .water:
                    Droplet().fill(LinearGradient(colors: [Color(hex: 0x9CE8EF), Color(hex: 0x388BAF)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: s * 0.65, height: s * 0.88)
                    Ellipse().fill(.white.opacity(0.55)).frame(width: s * 0.10, height: s * 0.22).rotationEffect(.degrees(28)).offset(x: -s * 0.1, y: s * 0.1)
                case .sun:
                    ForEach(0..<8) { i in Capsule().fill(Color(hex: 0xF2BC5A)).frame(width: s * 0.09, height: s * 0.2).offset(y: -s * 0.35).rotationEffect(.degrees(Double(i) * 45)) }
                    Circle().fill(LinearGradient(colors: [Color(hex: 0xFFE39A), Color(hex: 0xEBA440)], startPoint: .top, endPoint: .bottom)).frame(width: s * 0.55, height: s * 0.55)
                    Circle().fill(.white.opacity(0.5)).frame(width: s * 0.11).offset(x: -s * 0.09, y: -s * 0.08)
                case .flower:
                    ForEach(0..<5) { i in Ellipse().fill(LinearGradient(colors: [Color(hex: 0xFFD5BB), Color(hex: 0xE78683)], startPoint: .top, endPoint: .bottom)).frame(width: s * 0.36, height: s * 0.5).offset(y: -s * 0.21).rotationEffect(.degrees(Double(i) * 72)) }
                    Circle().fill(Color(hex: 0xFFE7A4)).frame(width: s * 0.25)
                case .crystal:
                    Crystal().fill(LinearGradient(colors: [Color(hex: 0xD2BCF1), Color(hex: 0x8B73B7)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: s * 0.72, height: s * 0.9)
                    Crystal().fill(Color(hex: 0xF0DFF9).opacity(0.5)).frame(width: s * 0.32, height: s * 0.74).offset(x: -s * 0.09, y: -s * 0.03)
                }
            }.frame(width: geo.size.width, height: geo.size.height)
                .shadow(color: .black.opacity(0.16), radius: 1, x: 0, y: 2)
        }.accessibilityHidden(true)
    }
}
