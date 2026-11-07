import SwiftUI

enum Palette {
    static let bg = Color(hex: "0B0910")
    static let bg2 = Color(hex: "2A1A38")
    static let ink = Color(hex: "F3EEE6")
    static let muted = Color(hex: "9C94A8")
    static let gold = Color(hex: "D9B477")
    static let line = Color.white.opacity(0.10)
}

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }

        guard s.count == 6 else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
            return
        }

        var value: UInt64 = 0
        for ch in s {
            let digit: UInt64
            switch ch {
            case "0"..."9": digit = UInt64(ch.asciiValue! - 48)
            case "a"..."f": digit = UInt64(ch.asciiValue! - 87)
            case "A"..."F": digit = UInt64(ch.asciiValue! - 55)
            default:
                self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
                return
            }
            value = value * 16 + digit
        }

        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}

struct ScreenBackground: View {
    let accent: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.bg, Palette.bg2],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [accent.opacity(0.30), .clear],
                center: .init(x: 0.98, y: 0.02),
                startRadius: 10,
                endRadius: 520
            )
            .blendMode(.plusLighter)

            RadialGradient(
                colors: [Color(hex: "785AC8").opacity(0.22), .clear],
                center: .init(x: 0.0, y: 0.0),
                startRadius: 10,
                endRadius: 440
            )
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.45), value: accent)
    }
}

struct SectionTitle: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.6)
            .foregroundStyle(Palette.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}

struct ToastView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Capsule().fill(Color(hex: "1C1722")))
            .overlay(Capsule().strokeBorder(Palette.line, lineWidth: 1))
            .shadow(color: .black.opacity(0.55), radius: 18, y: 10)
    }
}

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(Color(hex: "1A1305"))
            .background(
                LinearGradient(
                    colors: [Color(hex: "F0D3A1"), Color(hex: "D3A967")],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(color: Palette.gold.opacity(0.35), radius: 18, y: 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12.5, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, minHeight: 46)
            .foregroundStyle(Palette.ink)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
