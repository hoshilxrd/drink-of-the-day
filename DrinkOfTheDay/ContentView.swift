import SwiftUI
import UIKit

struct ContentView: View {
    @State private var index: Int = Cocktail.dailyIndex
    @State private var bag: [Int] = []
    @State private var seen: Set<Int> = []
    @State private var isDaily = true
    @State private var toast: String?

    @Environment(\.openURL) private var openURL

    private var cocktail: Cocktail { Cocktail.all[index] }

    private var dateLine: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.setLocalizedDateFormatFromTemplate("dMMMMyyyy")
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScreenBackground(accent: cocktail.accent)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    card
                    Text("Открыто \(seen.count) из \(Cocktail.all.count) рецептов")
                        .font(.caption)
                        .foregroundStyle(Palette.muted)
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 44)
            }

            if let toast {
                ToastView(text: toast)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.35), value: index)
        .onAppear {
            seen.insert(index)
            refill()
        }
    }

    // MARK: - Блоки

    private var header: some View {
        VStack(spacing: 6) {
            Text("🍸 НАПИТОК ДНЯ")
                .font(.system(size: 11, weight: .semibold))
                .tracking(2.4)
                .foregroundStyle(Palette.gold.opacity(0.9))

            Text("Что будем пить?")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.ink)

            Text(dateLine)
                .font(.footnote)
                .foregroundStyle(Palette.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                Text(cocktail.icon)
                    .font(.system(size: 33))
                    .frame(width: 64, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.07))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Palette.line, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(isDaily ? "НАПИТОК ДНЯ" : "СЛУЧАЙНЫЙ ВЫБОР")
                        .font(.system(size: 9.5, weight: .bold))
                        .tracking(1.3)
                        .foregroundStyle(isDaily ? Color(hex: "1A1408") : Color(hex: "120D1F"))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(isDaily ? Palette.gold : Color(hex: "8F7AD6")))

                    Text(cocktail.name)
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(cocktail.tagline)
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 18)

            chips
                .padding(.bottom, 20)

            SectionTitle("ИНГРЕДИЕНТЫ")
            ingredients

            SectionTitle("КАК ГОТОВИТЬ")
                .padding(.top, 20)
            steps

            actions
                .padding(.top, 24)
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Palette.line, lineWidth: 1)
        )
        .overlay(alignment: .top) {
            Circle()
                .fill(cocktail.accent.opacity(0.25))
                .frame(width: 230, height: 230)
                .blur(radius: 75)
                .offset(y: -110)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.45), radius: 30, y: 18)
    }

    private var chips: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 130), spacing: 8)],
            alignment: .leading,
            spacing: 8
        ) {
            chip("Крепость", cocktail.abv)
            chip("Бокал", cocktail.glass)
            chip("Время", cocktail.time)
        }
    }

    private func chip(_ title: String, _ value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .foregroundStyle(Palette.muted)
            Text(value)
                .foregroundStyle(Palette.ink)
                .fontWeight(.semibold)
        }
        .font(.system(size: 12))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(Color.white.opacity(0.05)))
        .overlay(Capsule().strokeBorder(Palette.line, lineWidth: 1))
    }

    private var ingredients: some View {
        VStack(spacing: 0) {
            ForEach(Array(cocktail.ingredients.enumerated()), id: \.element.id) { offset, item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(item.name)
                        .font(.subheadline)
                        .foregroundStyle(Palette.ink.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 12)

                    Text(item.amount)
                        .font(.subheadline)
                        .foregroundStyle(Palette.gold)
                        .monospacedDigit()
                }
                .padding(.vertical, 9)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Palette.line)
                        .frame(height: 0.5)
                        .opacity(offset == cocktail.ingredients.count - 1 ? 0 : 1)
                }
            }
        }
    }

    private var steps: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(cocktail.steps.enumerated()), id: \.offset) { offset, step in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(offset + 1)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Palette.gold)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(cocktail.accent.opacity(0.14)))
                        .overlay(Circle().strokeBorder(cocktail.accent.opacity(0.45), lineWidth: 1))

                    Text(step)
                        .font(.subheadline)
                        .foregroundStyle(Palette.ink.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                openURL(cocktail.recipeURL)
            } label: {
                HStack(spacing: 8) {
                    Text("Открыть рецепт на InShaker")
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 13, weight: .bold))
                }
            }
            .buttonStyle(GoldButtonStyle())
            .accessibilityHint("Откроется страница коктейля на сайте InShaker")

            HStack(spacing: 10) {
                Button {
                    roll()
                } label: {
                    Label("Другой", systemImage: "shuffle")
                }
                .buttonStyle(QuietButtonStyle())

                Button {
                    copyRecipe()
                } label: {
                    Label("Копировать", systemImage: "doc.on.doc")
                }
                .buttonStyle(QuietButtonStyle())

                ShareLink(item: recipeText) {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(QuietButtonStyle())
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 4) {
            Text("Рецепты и ссылки — ru.inshaker.com")
            Text("18+ · пейте ответственно")
        }
        .font(.caption2)
        .foregroundStyle(Palette.muted.opacity(0.7))
        .multilineTextAlignment(.center)
    }

    // MARK: - Логика

    private var recipeText: String {
        let drink = cocktail
        let ingredients = drink.ingredients
            .map { "• \($0.name) — \($0.amount)" }
            .joined(separator: "\n")
        let steps = drink.steps
            .enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")

        return """
        \(drink.name) (\(drink.abv))
        \(drink.tagline)

        Ингредиенты:
        \(ingredients)

        Приготовление:
        \(steps)

        Рецепт: \(drink.recipeURL.absoluteString)
        """
    }

    private func refill() {
        bag = Cocktail.all.indices.filter { $0 != index }.shuffled()
    }

    private func roll() {
        if bag.isEmpty { refill() }

        var next = bag.removeLast()
        if next == index, !bag.isEmpty {
            next = bag.removeLast()
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation(.easeInOut(duration: 0.3)) {
            index = next
            isDaily = false
        }
        seen.insert(next)
    }

    private func copyRecipe() {
        UIPasteboard.general.string = recipeText
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showToast("Рецепт скопирован")
    }

    private func showToast(_ text: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            toast = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.25)) {
                toast = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
