import SwiftUI

enum Palette {
    static let sky = Color(hex: 0xDFF3F2)
    static let paper = Color(hex: 0xFFFCED)
    static let night = Color(hex: 0x244C40)
    static let deep = Color(hex: 0xF0F7E8)
    static let cream = Color(hex: 0x244C40)
    static let mint = Color(hex: 0x527263)
    static let coral = Color(hex: 0xDD7B75)
    static let gold = Color(hex: 0xA96A0D)
    static let sunlight = Color(hex: 0xFFE0A0)
    static let muted = Color(hex: 0x657D73)
}
extension Color {
    init(hex: UInt32) { self.init(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255) }
}
struct PrimaryButton: View {
    let title: String
    var subtitle: String? = nil
    var symbol: String = "play.fill"
    var id = "primaryAction"
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol).accessibilityHidden(true).font(.system(size: 17, weight: .bold))
                Text(title).font(.system(.headline, design: .rounded, weight: .bold))
                Spacer(minLength: 0)
                if let subtitle { Text(subtitle).font(.system(.subheadline, design: .rounded, weight: .semibold)).opacity(0.65) }
                Image(systemName: "play.fill").accessibilityHidden(true).font(.system(size: 17, weight: .semibold))
            }.foregroundStyle(Palette.night).padding(.horizontal, 22).frame(minHeight: 60)
                .background(LinearGradient(colors: [Color(hex: 0xF6D293), Palette.coral], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.25), lineWidth: 1))
        }.buttonStyle(PressStyle()).accessibilityIdentifier(id)
    }
}
struct PressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
struct ResourcePill: View {
    let symbol: String
    let value: String
    var tint: Color = Palette.gold
    var body: some View {
        HStack(spacing: 7) { Image(systemName: symbol).accessibilityHidden(true).foregroundStyle(tint); Text(value).foregroundStyle(Palette.cream).monospacedDigit() }
            .accessibilityElement(children: .ignore).accessibilityLabel("\(symbol == "star.fill" ? "Stars" : "Coins"), \(value)").font(.system(.subheadline, design: .rounded, weight: .bold)).padding(.horizontal, 12).frame(height: 38)
            .background(Palette.paper, in: Capsule()).overlay(Capsule().stroke(.white.opacity(0.1), lineWidth: 1))
    }
}
struct SpaceBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex:0xD7F0EF), Palette.paper, Color(hex:0xE3EFCE)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Canvas { context, size in
                for i in 0..<70 {
                    let x = CGFloat((i * 157 + 47) % 997) / 997 * size.width
                    let y = CGFloat((i * 89 + 23) % 991) / 991 * size.height
                    let radius: CGFloat = i % 6 == 0 ? 1.3 : 0.7
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)), with: .color(.white.opacity(i % 4 == 0 ? 0.9 : 0.4)))
                }
            }
        }.ignoresSafeArea().accessibilityHidden(true)
    }
}
struct SectionEyebrow: View {
    let text: String
    var body: some View { Text(text.uppercased()).font(.system(size: 10, weight: .bold, design: .rounded)).tracking(2.5).foregroundStyle(Palette.mint) }
}
