import SwiftUI

// MARK: - Reusable buttons for Pop Quiz style flows

struct PopQuizPrimaryButton: View {
    let title: String
    let subtitle: String?
    let action: () -> Void
    private let height: CGFloat = 66

    init(title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(FontTokens.architectsDaughter(size: 18))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(FontTokens.architectsDaughter(size: 12))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(ColorTokens.red300)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .stroke(.white, lineWidth: 2)
            )
            // Mimic figma drop look: soft white bottom glow plus subtle dark lift
            .shadow(color: .white.opacity(0.8), radius: 3, x: 0, y: 4)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

struct PopQuizSecondaryButton: View {
    let title: String
    let subtitle: String?
    let action: () -> Void
    private let height: CGFloat = 66

    init(title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(FontTokens.architectsDaughter(size: 18))
                    .foregroundStyle(ColorTokens.shade100)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(FontTokens.architectsDaughter(size: 12))
                        .foregroundStyle(ColorTokens.shade100.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.black.opacity(0.35))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .stroke(Color.white.opacity(0.9), lineWidth: 2)
            )
            .shadow(color: .white.opacity(0.8), radius: 3, x: 0, y: 4)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Gray style button (for secondary choices)
struct PopQuizGrayButton: View {
    let title: String
    let subtitle: String?
    let action: () -> Void
    private let height: CGFloat = 66

    init(title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(FontTokens.architectsDaughter(size: 18))
                    .foregroundStyle(ColorTokens.shade100)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(FontTokens.architectsDaughter(size: 12))
                        .foregroundStyle(ColorTokens.shade100.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(ColorTokens.gray800)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .stroke(.white, lineWidth: 2)
            )
            .shadow(color: .white.opacity(0.8), radius: 3, x: 0, y: 4)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 12) {
            PopQuizSecondaryButton(title: "A. One boba", subtitle: "(only lasting 10min)", action: {})
            PopQuizPrimaryButton(title: "B. 10X my focus", action: {})
            PopQuizGrayButton(title: "C. Gray option", action: {})
        }
        .padding()
    }
}


